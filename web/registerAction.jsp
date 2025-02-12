<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // 获取表单提交的数据
    String userName = request.getParameter("user_name");
    String userPassword = request.getParameter("user_password");
    String userRole = request.getParameter("user_role");

    // 获取其他表单字段
    String gender = request.getParameter("gender");
    String ageStr = request.getParameter("age");
    int age = ageStr != null ? Integer.parseInt(ageStr) : 0;
    String phone = request.getParameter("phone");
    String studentId = request.getParameter("student_id");
    String studentClass = request.getParameter("class");
    String address = request.getParameter("address");
    String doctorId = request.getParameter("doctor_id");
    String department = request.getParameter("department");

    // 数据库连接
    Connection con = null;
    PreparedStatement stmt = null;

    try {
        // 连接数据库
        String url = "jdbc:mysql://localhost:3306/hms";
        String username = "root";
        String password = "123456";
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(url, username, password);

        if ("student".equals(userRole)) {
            // 插入学生信息到数据库
            String sql = "INSERT INTO patients (student_id, name, gender, age, phone, class, address, password, role) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            stmt = con.prepareStatement(sql);
            stmt.setString(1, studentId);
            stmt.setString(2, userName);
            stmt.setString(3, gender); // 性别
            stmt.setInt(4, age);
            stmt.setString(5, phone);
            stmt.setString(6, studentClass);
            stmt.setString(7, address);
            stmt.setString(8, userPassword);
            stmt.setString(9, "学生");

        } else if ("doctor".equals(userRole)) {
            // 插入医生信息到数据库
            String sql = "INSERT INTO medical_staff (doctor_id, doctor_name, phone, department, doctor_password, role) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";
            stmt = con.prepareStatement(sql);
            stmt.setString(1, doctorId);
            stmt.setString(2, userName);
            stmt.setString(3, phone);
            stmt.setString(4, department);
            stmt.setString(5, userPassword);
            stmt.setString(6, "医生");
        }

        int result = stmt.executeUpdate();
        if (result > 0) {
            // 注册成功，根据角色跳转到不同的首页
            if ("student".equals(userRole)) {
                out.println("<script>alert('注册成功！'); window.location.href='studentIndex.jsp';</script>");
            } else if ("doctor".equals(userRole)) {
                out.println("<script>alert('注册成功！'); window.location.href='doctorIndex.jsp';</script>");
            }
        }  else {
            // 注册失败，弹出提示并返回注册页面
            out.println("<script>alert('注册失败，请重试！'); window.location.href='register.jsp';</script>");
        }
    } catch (SQLException e) {
        // 数据库连接错误
        e.printStackTrace();
        out.println("<script>alert('数据库连接错误: " + e.getMessage() + "'); window.location.href='register.jsp';</script>");
    } catch (Exception e) {
        // 其他错误
        e.printStackTrace();
        out.println("<script>alert('发生未知错误: " + e.getMessage() + "'); window.location.href='register.jsp';</script>");
    } finally {
        try {
            if (stmt != null) stmt.close();
            if (con != null) con.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>









