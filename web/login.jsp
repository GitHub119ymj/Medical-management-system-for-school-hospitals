<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户登录</title>
    <style>
        /* 页面背景 */
        body {
            font-family: 'Arial', sans-serif;
            background: linear-gradient(135deg, #6e7a7d, #c5e1f3);  /* 背景渐变 */
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            min-height: 100vh;
            color: #333;
        }

        /* 页首绿色条 */
        header {
            background-color: #00796b;
            color: white;
            width: 100%;
            padding: 15px 0;
            position: fixed;
            top: 0;
            left: 0;
            z-index: 100;
            text-align: center;
            font-size: 24px;
            font-weight: 600;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        /* 页首文字 */
        header h1 {
            margin: 0;
        }

        /* 欢迎信息 */
        .welcome-message {
            font-size: 20px;
            margin-top: 70px; /* 让欢迎信息下移，避开页首 */
            color: #ffffff;
            text-align: center;
            font-weight: 300;
            line-height: 1.5;
        }

        /* 登录框容器 */
        .login-container {
            background-color: #fff;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 420px;
            margin-top: 40px;
            text-align: center;
        }

        h2 {
            color: #333;
            font-size: 26px;
            margin-bottom: 25px;
            font-weight: 600;
        }

        /* 输入框样式 */
        input[type="text"],
        input[type="password"],
        select {
            width: 100%;
            padding: 12px;
            margin-bottom: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            box-sizing: border-box;
            background-color: #f9f9f9;
            transition: all 0.3s ease;
        }

        input[type="text"]:focus,
        input[type="password"]:focus,
        select:focus {
            border-color: #00796b;
            outline: none;
        }

        /* 提交按钮 */
        input[type="submit"] {
            width: 100%;
            padding: 14px;
            background-color: #00796b;
            color: white;
            font-size: 18px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        input[type="submit"]:hover {
            background-color: #004d40;
        }

        /* 错误提示信息 */
        .error {
            color: red;
            font-size: 14px;
            margin-top: 10px;
            text-align: center;
        }

        /* 下拉框样式 */
        select {
            cursor: pointer;
            background-color: #f9f9f9;
        }

        /* 注册链接样式 */
        .register-link {
            margin-top: 20px;
            font-size: 14px;
            color: #00796b;
            text-decoration: none;
        }

        .register-link:hover {
            text-decoration: underline;
        }

        /* 页脚样式 */
        footer {
            background-color: #ffffff;
            color: #777;
            width: 100%;
            padding: 15px 0;
            text-align: center;
            position: fixed;
            bottom: 0;
            font-size: 14px;
            font-weight: 300;
        }

        /* 响应式设计 */
        @media (max-width: 480px) {
            .login-container {
                padding: 25px;
                width: 90%;
            }

            h2 {
                font-size: 22px;
            }

            .welcome-message {
                font-size: 18px;
            }
        }
    </style>
</head>
<body>

<!-- 页首绿色条 -->
<header>
    <h1>学生医务管理系统</h1>
</header>

<!-- 欢迎信息 -->
<div class="welcome-message">
    欢迎进入系统，请登录以获取更多功能权限。
</div>

<!-- 登录框 -->
<div class="login-container">
    <h2>用户登录</h2>

    <form action="loginAction.jsp" method="post">
        <label for="user_id">用户ID：</label>
        <input type="text" id="user_id" name="user_id"><br>

        <label for="user_password">密码：</label>
        <input type="password" id="user_password" name="user_password"><br>

        <label for="user_role">选择角色：</label>
        <select id="user_role" name="user_role">
            <option value="student">学生</option>
            <option value="doctor">医生</option>
        </select><br>

        <input type="submit" value="登录">
    </form>

    <!-- 注册链接 -->
    <p>没有账号？<a href="register.jsp" class="register-link">点击这里注册</a></p>
</div>

<!-- 页脚 -->
<footer>
    2024 SHMS | 版权 &copy;yimaojiu 所有
</footer>

</body>
</html>





