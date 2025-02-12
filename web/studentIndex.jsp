<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>学生首页</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #6e7a7d, #c5e1f3); /* 背景渐变 */
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .header {
            text-align: center;
            background-color: #00796b; /* 深绿色 */
            padding: 15px;
            color: white;
            font-size: 1.6em; /* 修改标题字体大小 */
        }

        .greeting {
            font-size: 1em;
            margin-top: 5px;
        }

        .container {
            display: flex;
            justify-content: space-between;
            padding: 20px;
            flex: 1;
            margin-top: 20px;
        }

        .module {
            background-color: white;
            border-radius: 8px;
            padding: 15px;
            width: 28%; /* 调整模块宽度 */
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            text-align: center;
            transition: transform 0.2s;
            height: 250px; /* 增加高度，避免太空 */
        }

        .module:hover {
            transform: scale(1.05);
        }

        .module .icon {
            font-size: 40px; /* 增大图标大小 */
            color: #00796b;
            margin-bottom: 10px;
        }

        .module h3 {
            font-size: 1.1em; /* 更小的标题字体 */
            margin-bottom: 10px;
        }

        .module a {
            text-decoration: none;
            color: #00796b;
            font-weight: bold;
            font-size: 1em; /* 调整链接字体大小 */
        }

        footer {
            text-align: center;
            padding: 10px;
            background-color: #00796b; /* 深绿色 */
            color: white;
            position: fixed;
            bottom: 0;
            width: 100%;
        }
    </style>
</head>
<body>
<div class="header">
    <h1>欢迎来到学生医务管理系统</h1>
    <%
        String userName = (String) session.getAttribute("user_name");
        if (userName == null) {
            userName = "学生"; // 如果未设置用户名，则默认为"学生"
        }
    %>
    <p class="greeting">你好，<%= userName %>！</p>
</div>

<div class="container">
    <div class="module">
        <i class="fas fa-user-edit icon"></i>
        <h3>修改个人信息</h3>
        <a href="./1FirstFunction/editPatient.jsp">修改患者个人信息</a>
    </div>
    <div class="module">
        <i class="fas fa-calendar-check icon"></i>
        <h3>预约医生/体检</h3>
        <a href="./2SecondFunction/appointmentForm.jsp">进入模块</a>
    </div>
    <div class="module">
        <i class="fas fa-file-medical icon"></i>
        <h3>查看并跟踪健康记录</h3>
        <a href="./3ThirdFunction/healthRecord.jsp">查看健康记录</a>
    </div>
</div>

<footer>
    <p>&copy; 2024 SHMS学生医务管理系统 | yimaojiu版权所有</p>
</footer>
</body>
</html>




