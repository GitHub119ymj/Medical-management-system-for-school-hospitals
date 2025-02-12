<!DOCTYPE html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<html>
<head>
    <title>患者信息</title>
</head>
<body>
<h2>患者信息</h2>
<p><strong>姓名:</strong> ${name}</p>
<p><strong>性别:</strong> ${gender}</p>
<p><strong>年龄:</strong> ${age}</p>
<p><strong>联系电话:</strong> ${phone}</p>
<p><strong>学号:</strong> ${studentId}</p>
<p><strong>班级:</strong> ${className}</p>
<p><strong>地址:</strong> ${address}</p>

<form action="EditPatientServlet" method="get">
    <input type="hidden" name="studentId" value="${studentId}" />
    <input type="submit" value="编辑信息" />
</form>
</body>
</html>
