import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;


public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        String gender = request.getParameter("gender");
        int age = Integer.parseInt(request.getParameter("age"));
        String phone = request.getParameter("phone");
        String studentId = request.getParameter("studentId");
        String className = request.getParameter("className");
        String address = request.getParameter("address");

        // 连接数据库并插入数据
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456")) {
            String sql = "INSERT INTO patients (name, gender, age, phone, student_id, class, address) VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setString(1, name);
                statement.setString(2, gender);
                statement.setInt(3, age);
                statement.setString(4, phone);
                statement.setString(5, studentId);
                statement.setString(6, className);
                statement.setString(7, address);

                int rows = statement.executeUpdate();
                if (rows > 0) {
                    response.sendRedirect("profile.jsp?studentId=" + studentId); // 跳转到患者信息查看页面
                } else {
                    request.setAttribute("error", "注册失败！");
                    request.getRequestDispatcher("register.jsp").forward(request, response);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "数据库连接错误！");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}
