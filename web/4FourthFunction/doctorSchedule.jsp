<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>医生日程管理</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <style>
        /* 页面背景与全局样式 */
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background: #e0e0e0;
            min-height: 100vh;
        }

        /* 顶部绿色长条 */
        .header-bar {
            background-color: #00796b; /* 深绿色背景 */
            color: white;
            text-align: center;
            padding: 15px 0;
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 20px;
        }

        /* 模块布局 */
        .container {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 20px;
            padding: 20px;
        }

        /* 功能模块卡片 */
        .module {
            width: 250px;
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease;
            cursor: pointer;
        }

        .module:hover {
            transform: scale(1.05);
        }

        .module h3 {
            font-size: 18px;
            margin-bottom: 15px;
            color: #00796b;
        }

        .module a {
            text-decoration: none;
            color: white;
            background-color: #00796b;
            padding: 10px 20px;
            border-radius: 5px;
            display: inline-block;
            transition: background-color 0.3s ease;
        }

        .module a:hover {
            background-color: #A9A9A9;
        }
    </style>
</head>
<body>

<div class="header-bar">医生日程管理</div>
<div class="container">
    <div class="module">
        <h3>查看预约日程</h3>
        <a href="viewSchedule.jsp">查看日程</a>
    </div>
    <div class="module">
        <h3>设置接诊限制</h3>
        <a href="doctorSetLimit.jsp">设置限制</a>
    </div>
    <div class="module">
        <h3>更新日程安排</h3>
        <a href="updateSchedule.jsp">更新日程</a>
    </div>
</div>

</body>
</html>


