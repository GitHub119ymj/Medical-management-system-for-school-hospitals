import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;

public class ProfileServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String studentId = request.getParameter("studentId");

        // 连接数据库并查询患者信息
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456")) {
            String sql = "SELECT * FROM patients WHERE student_id = ?";
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setString(1, studentId);
                ResultSet resultSet = statement.executeQuery();
                if (resultSet.next()) {
                    // 将查询结果存储在request中
                    request.setAttribute("name", resultSet.getString("name"));
                    request.setAttribute("gender", resultSet.getString("gender"));
                    request.setAttribute("age", resultSet.getInt("age"));
                    request.setAttribute("phone", resultSet.getString("phone"));
                    request.setAttribute("studentId", resultSet.getString("student_id"));
                    request.setAttribute("className", resultSet.getString("class_name"));
                    request.setAttribute("address", resultSet.getString("address"));

                    // 跳转到显示页面
                    request.getRequestDispatcher("profile.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "患者信息未找到！");
                    request.getRequestDispatcher("error.jsp").forward(request, response);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "数据库连接错误！");
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
}
