<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    // 获取患者ID和其他预约信息
    String patientId = (String) session.getAttribute("user_id");
    String appointmentType = request.getParameter("appointmentType");  // 预约类型：医生或体检
    String doctorId = request.getParameter("doctorId");  // 医生ID（仅当预约医生时）
    String appointmentDate = request.getParameter("appointmentDate");  // 预约日期
    String purpose = request.getParameter("purpose");  // 预约目的（体检、感冒等）

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        // 连接数据库
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");
        // 处理预约类型：医生预约或体检预约
        if ("doctor".equals(appointmentType)) {
            // 医生预约
            String sql = "INSERT INTO appointments (patient_id, doctor_id, appointment_date, status, purpose) VALUES (?, ?, ?, '已预约', ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(patientId));
            pstmt.setInt(2, Integer.parseInt(doctorId));
            pstmt.setString(3, appointmentDate);
            pstmt.setString(4, purpose);
        } else if ("checkup".equals(appointmentType)) {
            // 体检预约
            String sql = "INSERT INTO appointments (patient_id, doctor_id, appointment_date, status, purpose) VALUES (?, NULL, ?, '已预约', '体检')";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(patientId));  // 确保 patientId 正确
            pstmt.setString(2, appointmentDate);
        }

        // 执行插入操作
        int rowsAffected = pstmt.executeUpdate();

        if (rowsAffected > 0) {
            out.println("<script>alert('预约成功！'); window.location.href='appointmentConfirmation.jsp';</script>");
        } else {
            out.println("<script>alert('预约失败，请稍后再试。'); window.history.back();</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("错误信息: " + e.getMessage());
        out.println("<script>alert('系统错误，请稍后再试。'); window.history.back();</script>");
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

