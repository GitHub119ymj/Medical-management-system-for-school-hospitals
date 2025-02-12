<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>首页</title>
</head>
<body>
<%
    String role = (String) session.getAttribute("user_role");
    if (role == null) {
        // 未登录时，重定向到登录页面
        response.sendRedirect("login.jsp");
    } else if ("student".equals(role)) {
        // 如果是学生，重定向到 studentIndex.jsp
        response.sendRedirect("studentIndex.jsp");
    } else if ("doctor".equals(role)) {
        // 如果是医生，重定向到 doctorIndex.jsp
        response.sendRedirect("doctorIndex.jsp");
    }
%>
</body>
</html>

