<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>医生诊断与处方管理</title>
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
            background-color: #00796b;
            color: white;
            text-align: center;
            padding: 20px;
        }

        .header h1 {
            font-size: 28px;
        }

        .container {
            display: flex;
            justify-content: space-between; /* 第一行的模块平分空间 */
            align-items: flex-start;
            flex-wrap: wrap; /* 使子元素换行 */
            margin-top: 20px;
            padding: 20px;
        }

        .module {
            background-color: #ffffff;
            border: 2px solid #00796b;
            border-radius: 8px;
            margin: 10px;
            padding: 25px;
            text-align: center;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transition: transform 0.2s;
            flex: 1 1 30%; /* 第一行3个框，设置为占 30% 的宽度 */
            max-width: 33%; /* 限制最大宽度 */
            box-sizing: border-box; /* 防止盒子溢出 */
        }

        .module:hover {
            transform: scale(1.05);
        }

        .icon {
            font-size: 60px;
            color: #00796b;
            margin-bottom: 20px;
        }

        h3 {
            font-size: 20px;
            color: #333;
            margin-bottom: 15px;
        }

        .module a {
            font-size: 18px;
            color: #00796b;
            text-decoration: none;
        }

        .module a:hover {
            text-decoration: underline;
        }

        /* 第二行：两个模块居中对齐 */
        .container {
            display: flex;
            justify-content: center; /* 第二行的两个模块居中 */
            flex-wrap: wrap; /* 允许换行 */
        }

        .container .module {
            flex: 1 1 30%; /* 每个模块占 30% */
            max-width: 30%; /* 限制最大宽度 */
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
    <h1>医生诊断与处方管理</h1>
    <p class="greeting">你好，<%= doctorName != null ? doctorName : "医生" %>！</p>
</div>

<div class="container">
    <!-- 查看患者健康记录 -->
    <div class="module">
        <i class="fas fa-notes-medical icon"></i>
        <h3>查看患者健康记录</h3>
        <a href="viewHealthRecords.jsp">进入模块</a>
    </div>

    <!-- 提供诊断 -->
    <div class="module">
        <i class="fas fa-stethoscope icon"></i>
        <h3>提供诊断</h3>
        <a href="provideDiagnosis.jsp">进入模块</a>
    </div>

    <!-- 开具处方 -->
    <div class="module">
        <i class="fas fa-prescription-bottle-alt icon"></i>
        <h3>开具处方</h3>
        <a href="prescribeMedicine.jsp">进入模块</a>
    </div>

    <!-- 药品销售记录 -->
    <div class="module">
        <i class="fas fa-cash-register icon"></i>
        <h3>药品销售记录</h3>
        <a href="medicineSales.jsp">进入模块</a>
    </div>

    <!-- 修改诊断或处方 -->
    <div class="module">
        <i class="fas fa-edit icon"></i>
        <h3>修改诊断或处方</h3>
        <a href="editDiagnosisPrescription.jsp">进入模块</a>
    </div>
</div>

<footer>
    <p>&copy; 2024 SHMS学生医务管理系统 | yimaojiu版权所有</p>
</footer>

</body>
</html>

