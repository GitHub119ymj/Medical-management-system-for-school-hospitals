<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>健康记录</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #6e7a7d, #c5e1f3);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .header {
            text-align: center;
            background-color: #00796b;
            padding: 15px;
            color: white;
            font-size: 1.6em;
        }

        .container {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            padding: 40px 20px 20px;
            margin-top: 20px;
            gap: 20px;
            flex-grow: 1;
        }

        .module {
            background-color: white;
            border-radius: 8px;
            padding: 15px;
            width: 40%;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            text-align: center;
            transition: transform 0.2s;
            height: auto;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }

        .module:hover {
            transform: scale(1.05);
        }

        .module .icon {
            font-size: 36px;  /* Adjust icon size to make it larger */
            color: #00796b;
            margin-bottom: 10px;  /* Adjust margin between icon and text */
        }

        .module h3 {
            font-size: 1.2em;  /* Adjust title font size to make it larger */
            margin-bottom: 10px;  /* Adjust margin between title and link */
        }

        .module a {
            text-decoration: none;
            color: #00796b;
            font-weight: bold;
        }

        footer {
            text-align: center;
            padding: 10px;
            background-color: #00796b;
            color: white;
            position: fixed;
            bottom: 0;
            width: 100%;
        }
    </style>
</head>
<body>
<div class="header">
    <h1>健康记录模块</h1>
</div>

<div class="container">
    <div class="module">
        <i class="fas fa-file-alt icon"></i>
        <h3>查看体检记录</h3>
        <a href="healthCheckupHistory.jsp">进入查看体检记录</a>
    </div>
    <div class="module">
        <i class="fas fa-dumbbell icon"></i>
        <h3>查看运动记录</h3>
        <a href="sportsActivityHistory.jsp">进入查看运动记录</a>
    </div>
    <div class="module">
        <i class="fas fa-notes-medical icon"></i>
        <h3>查看就诊记录</h3>
        <a href="medicalRecordHistory.jsp">进入查看就诊记录</a>
    </div>
    <div class="module">
        <i class="fas fa-layer-group icon"></i>
        <h3>健康记录汇总</h3>
        <a href="healthSummary.jsp">查看健康记录汇总</a>
    </div>
</div>

<footer>
    <p>&copy; 2024 SHMS学生医务管理系统 | yimaojiu版权所有</p>
</footer>
</body>
</html>


