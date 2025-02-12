<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    session.invalidate(); // 清除会话
    response.sendRedirect("login.jsp"); // 重定向到登录页面
%>
