<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>更新处理</title>
</head>
<body>
<%
    String appointmentId = request.getParameter("id");
    String status = request.getParameter("status");

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

        String sql = "UPDATE appointments SET status = ? WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, status);
        pstmt.setString(2, appointmentId);
        int rows = pstmt.executeUpdate();

        if (rows > 0) {
%>
<p>预约状态更新成功！</p>
<%
} else {
%>
<p>更新失败，请重试。</p>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
%>
<p>系统错误：<%= e.getMessage() %></p>
<%
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>
<a href="updateSchedule.jsp">返回</a>
</body>
</html>


