<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    String appointmentId = request.getParameter("appointmentId");

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        // 连接数据库
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

        // 更新预约状态为 "已确认"
        String sql = "UPDATE appointments SET status = '已确认' WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, Integer.parseInt(appointmentId));
        int rowsAffected = pstmt.executeUpdate();

        if (rowsAffected > 0) {
            out.println("<script>alert('预约已成功确认。'); window.location.href='../studentIndex.jsp';</script>");
        } else {
            out.println("<script>alert('确认预约失败，请稍后再试。'); window.history.back();</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
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

