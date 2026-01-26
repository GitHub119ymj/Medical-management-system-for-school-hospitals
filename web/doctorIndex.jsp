<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>医生首页</title>
    <!-- 引入 Font Awesome 图标库 -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f7f6;
            display: flex;
            flex-direction: column;
            height: 100vh;
        }

        .header {
            background-color: #00796b; /* 深绿色 */
            color: white;
            text-align: center;
            padding: 20px;
        }

        .greeting {
            font-size: 20px;
            margin: 10px 0;
        }

        .container {
            display: flex;
            justify-content: space-evenly;
            align-items: center;
            flex: 1;
            margin-top: 20px;
            flex-wrap: wrap;
        }

        .module {
            background-color: #ffffff;
            border: 2px solid #00796b;
            border-radius: 8px;
            width: 350px; /* 增加宽度 */
            height: 270px; /* 增加高度 */
            margin: 20px;
            padding: 25px;
            text-align: center;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transition: transform 0.2s;
        }

        .module:hover {
            transform: scale(1.05);
        }

        .icon {
            font-size: 60px; /* 增大图标 */
            color: #00796b;
            margin-bottom: 20px;
        }

        h3 {
            font-size: 20px; /* 调整标题大小 */
            color: #333;
            margin-bottom: 15px;
        }

        .module a {
            font-size: 18px; /* 调整链接文字大小 */
            color: #00796b;
            text-decoration: none;
        }

        .module a:hover {
            text-decoration: underline;
        }

        footer {
            background-color: #00796b;
            color: white;
            text-align: center;
            padding: 10px 0;
            margin-top: auto;
        }
    </style>
</head>
<body>
<%
    String doctorName = (String) session.getAttribute("doctor_name"); // 获取医生名字
%>

<div class="header">
    <h1>欢迎来到学生医务管理系统</h1>
    <p class="greeting">你好，<%= doctorName != null ? doctorName : "医生" %>！</p>
</div>

<div class="container">
    <!-- 医生用户功能模块 -->
    <div class="module">
        <i class="fas fa-calendar-alt icon"></i>
        <h3>医生查看日程</h3>
        <a href="./4FourthFunction/doctorSchedule.jsp">进入模块</a>
    </div>
    <div class="module">
        <i class="fas fa-prescription-bottle-alt icon"></i>
        <h3>医生诊断与处方管理</h3>
        <a href="./5FifthFunction/diagnosisPrescription.jsp">进入模块</a>
    </div>
    <div class="module">
        <i class="fas fa-pills icon"></i>
        <h3>药品库存管理</h3>
        <a href="./6SixthFunction/medicineList.jsp">进入模块</a>
    </div>
</div>

<footer>
    <p>&copy; 2024 SHMS学生医务管理系统 | yimaojiu版权所有</p>
</footer>
</body>
</html>


