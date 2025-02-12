<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>注册页面</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background: linear-gradient(135deg, #6e7a7d, #c5e1f3);  /* 背景渐变 */
            color: #333;
            margin: 0;
            padding: 0;
            padding-bottom: 60px; /* 留出空间给固定的页脚 */
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

        header h1 {
            margin: 0;
            font-size: 30px;
            letter-spacing: 1px;
        }

        header .welcome-message {
            font-size: 10px;
            margin-top: 5px;
            font-weight: normal;
        }

        /* 页面标题 */
        h2 {
            text-align: center;
            font-size: 32px;  /* 增大字体 */
            background: linear-gradient(135deg, #6e7a7d, #c5e1f3);  /* 背景渐变 */
            margin-top: 80px;
            letter-spacing: 1px;
            padding: 20px 0;  /* 增加上下内边距，给标题更多空间 */
        }

        /* 注册表单容器 */
        form {
            width: 100%;
            max-width: 500px;  /* 缩小表单 */
            margin: 20px auto; /* 上移表单 */
            padding: 20px;  /* 缩小表单内边距 */
            background-color: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }

        /* 输入框和选择框 */
        input[type="text"],
        input[type="password"],
        input[type="number"],
        select {
            width: 100%;
            padding: 12px;
            margin: 10px 0;
            border: 2px solid #ccc;
            border-radius: 8px;
            font-size: 16px;
            background-color: #f9f9f9;
            box-sizing: border-box;
        }

        /* 输入框和下拉框获取焦点时的样式 */
        input[type="text"]:focus,
        input[type="password"]:focus,
        input[type="number"]:focus,
        select:focus {
            border-color: #1b4f1f; /* 深绿色 */
            background-color: #f1f1f1;
            box-shadow: 0 0 8px rgba(27, 79, 31, 0.4); /* 深绿色阴影 */
        }

        /* 提交按钮 */
        input[type="submit"] {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #6e7a7d, #c5e1f3);  /* 背景渐变 */
            color: white;
            font-size: 18px;
            font-weight: bold;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        input[type="submit"]:hover {
            background-color: #153c15; /* 更深绿色 */
            transform: translateY(-2px);
        }

        input[type="submit"]:active {
            background-color: #0e2a0e; /* 更深的绿色 */
            transform: translateY(0);
        }

        /* 错误和验证消息 */
        .error-message {
            color: #f44336; /* 红色 */
            font-size: 14px;
            margin-top: 5px;
        }

        .valid-message {
            color: #4CAF50; /* 绿色 */
            font-size: 14px;
            margin-top: 5px;
        }

        /* 角色特定字段 */
        .role-specific-fields {
            display: none;
        }

        /* 选择框样式 */
        label {
            font-size: 16px;
            color: #333;
            margin-bottom: 5px;
            display: block;
        }

        select {
            width: 100%;
            display: inline-block;
            padding: 12px;
            font-size: 16px;
            border-radius: 8px;
            border: 2px solid #ccc;
        }

        /* 页脚样式 */
        footer {
            background-color: #00796b; /* 深绿色 */
            color: white;
            text-align: center;
            padding: 15px;
            font-size: 14px;
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
        }

        /* 链接样式 */
        a {
            color: #1b4f1f; /* 深绿色 */
            text-decoration: none;
        }

        a:hover {
            text-decoration: underline;
            color: #153c15; /* 更深绿色 */
        }
    </style>
    <script>
        // 提供表单验证功能
        function validateForm() {
            var userPassword = document.forms["registerForm"]["user_password"].value;
            var age = document.forms["registerForm"]["age"].value;
            var phone = document.forms["registerForm"]["phone"].value;

            // 密码验证
            var passwordPattern = /^(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#$%^&*])[A-Za-z\d@$!%*?&]{6,10}$/;
            if (!passwordPattern.test(userPassword)) {
                alert("密码必须是6-10位，且包含至少一个大写字母、一个小写字母和一个符号！");
                return false;
            }

            // 年龄验证
            if (isNaN(age) || age < 10 || age > 99) {
                alert("年龄必须是两位数！");
                return false;
            }
            return true; // 如果所有验证通过，返回true，提交表单
        }

        // 根据选择的角色显示或隐藏字段
        function toggleRoleFields() {
            var role = document.getElementById("user_role").value;
            if (role == "student") {
                document.getElementById("student-fields").style.display = "block";
                document.getElementById("doctor-fields").style.display = "none";
            } else if (role == "doctor") {
                document.getElementById("doctor-fields").style.display = "block";
                document.getElementById("student-fields").style.display = "none";
            }
        }

        // 密码输入实时验证
        function validatePassword() {
            var password = document.getElementById("user_password").value;
            var passwordMessage = document.getElementById("password-message");

            var passwordPattern = /^(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#$%^&*])[A-Za-z\d@$!%*?&]{6,10}$/;
            if (password.length > 0 && !passwordPattern.test(password)) {
                passwordMessage.textContent = "密码必须包含6-10位，且包括大写字母、小写字母和符号。";
                passwordMessage.className = "error-message";
            } else if (password.length > 0) {
                passwordMessage.textContent = "密码符合要求。";
                passwordMessage.className = "valid-message";
            } else {
                passwordMessage.textContent = "";
            }
        }

        // 年龄输入实时验证
        function validateAge() {
            var age = document.getElementById("age").value;
            var ageMessage = document.getElementById("age-message");

            if (isNaN(age) || age < 10 || age > 99) {
                ageMessage.textContent = "年龄必须是两位数（10-99）。";
                ageMessage.className = "error-message";
            } else {
                ageMessage.textContent = "年龄符合要求。";
                ageMessage.className = "valid-message";
            }
        }
    </script>
</head>
<body>

<header>
    <h1>欢迎注册学生医务管理系统</h1>
    <p class="welcome-message">注册以获取更多使用功能</p>
</header>

<h2>注册页面</h2>
<!-- 注册表单 -->
<form name="registerForm" action="registerAction.jsp" method="post" onsubmit="return validateForm()">
    <!-- 通用信息 -->
    <input type="text" name="user_name" placeholder="用户名"  /><br>
    <input type="password" id="user_password" name="user_password" placeholder="密码"  oninput="validatePassword()" /><br>
    <span id="password-message"></span><br>

    <label for="user_role">选择角色：</label>
    <select id="user_role" name="user_role" onchange="toggleRoleFields()">
        <option value="">请选择用户角色</option>
        <option value="student">学生</option>
        <option value="doctor">医生</option>
    </select><br>

    <!-- 性别选择 -->
    <label for="gender">性别：</label>
    <select id="gender" name="gender" >
        <option value="男">男</option>
        <option value="女">女</option>
    </select><br>

    <!-- 学生信息 -->
    <div class="role-specific-fields" id="student-fields">
        <input type="text" name="student_id" placeholder="学号" /><br>
        <input type="text" name="class" placeholder="班级"  /><br>
        <input type="text" name="address" placeholder="地址"  /><br>
        <input type="number" id="age" name="age" placeholder="年龄"  oninput="validateAge()" /><br>
        <span id="age-message"></span><br>
        <input type="text" id="phone" name="phone" placeholder="电话"  oninput="validatePhone()" /><br>
        <span id="phone-message"></span><br>
    </div>

    <!-- 医生信息 -->
    <div class="role-specific-fields" id="doctor-fields">
        <input type="text" name="doctor_id" placeholder="医生ID"  /><br>
        <input type="text" name="department" placeholder="科室"  /><br>
        <input type="text" id="doctor_phone" name="phone" placeholder="电话"  oninput="validatePhone()" /><br>
        <span id="doctor_phone-message"></span><br>
    </div>

    <input type="submit" value="提交" />
</form>

<footer>
    <p>© 2024 学生医务管理系统 | 版权yimaojiu所有</p>
</footer>

</body>
</html>







