<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    String userId = request.getParameter("user_id");
    String userPassword = request.getParameter("user_password");
    String userRole = request.getParameter("user_role");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    boolean loginSuccess = false;

    try {
        // Establish connection
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

        if ("student".equals(userRole)) {
            // For student login
            String studentQuery = "SELECT * FROM patients WHERE student_id = ? AND password = ?";
            pstmt = conn.prepareStatement(studentQuery);
            pstmt.setString(1, userId);
            pstmt.setString(2, userPassword);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                loginSuccess = true;
                String student_name = rs.getString("name");
                session.setAttribute("user_name", student_name);
                session.setAttribute("user_role", "student");
                session.setAttribute("user_id", userId);
            }
        } else if ("doctor".equals(userRole)) {
            // For doctor login
            String doctorQuery = "SELECT * FROM medical_staff WHERE doctor_id = ? AND doctor_password = ?";
            pstmt = conn.prepareStatement(doctorQuery);
            pstmt.setString(1, userId);
            pstmt.setString(2, userPassword);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                loginSuccess = true;
                String doctor_name= rs.getString("doctor_name");
                session.setAttribute("doctor_name", doctor_name);
                session.setAttribute("user_role", "doctor");
                session.setAttribute("user_id", userId);
            }
        }

        if (loginSuccess) {
            // Redirect to appropriate dashboard
            if ("student".equals(userRole)) {
                response.sendRedirect("studentIndex.jsp");
            } else {
                response.sendRedirect("doctorIndex.jsp");
            }
        } else {
            // Redirect to login page with error message
            response.sendRedirect("login.jsp?error=Invalid credentials");
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("login.jsp?error=System error");
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

