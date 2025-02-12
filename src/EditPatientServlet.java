import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;

public class EditPatientServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String studentId = request.getParameter("studentId");

        // 查询当前患者信息
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456")) {
            String sql = "SELECT * FROM patients WHERE student_id = ?";
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setString(1, studentId);
                ResultSet resultSet = statement.executeQuery();
                if (resultSet.next()) {
                    // 将数据放入请求属性中
                    request.setAttribute("studentId", resultSet.getString("student_id"));
                    request.setAttribute("name", resultSet.getString("name"));
                    request.setAttribute("gender", resultSet.getString("gender"));
                    request.setAttribute("age", resultSet.getInt("age"));
                    request.setAttribute("phone", resultSet.getString("phone"));
                    request.setAttribute("className", resultSet.getString("class"));
                    request.setAttribute("address", resultSet.getString("address"));

                    // 跳转到编辑页面
                    request.getRequestDispatcher("editPatient.jsp").forward(request, response);
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

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String studentId = request.getParameter("studentId");
        String name = request.getParameter("name");
        String gender = request.getParameter("gender");
        int age = Integer.parseInt(request.getParameter("age"));
        String phone = request.getParameter("phone");
        String className = request.getParameter("className");
        String address = request.getParameter("address");

        // 更新患者信息
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/your_database_name", "root", "password")) {
            String sql = "UPDATE patients SET name = ?, gender = ?, age = ?, phone = ?, class = ?, address = ? WHERE student_id = ?";
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setString(1, name);
                statement.setString(2, gender);
                statement.setInt(3, age);
                statement.setString(4, phone);
                statement.setString(5, className);
                statement.setString(6, address);
                statement.setString(7, studentId);

                int rows = statement.executeUpdate();
                if (rows > 0) {
                    response.sendRedirect("profile.jsp?studentId=" + studentId); // 更新成功后跳转到患者信息页面
                } else {
                    request.setAttribute("error", "更新失败！");
                    request.getRequestDispatcher("editPatient.jsp").forward(request, response);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "数据库连接错误！");
            request.getRequestDispatcher("editPatient.jsp").forward(request, response);
        }
    }
}
