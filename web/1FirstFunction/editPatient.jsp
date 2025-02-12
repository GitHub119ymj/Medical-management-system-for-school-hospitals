<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    // 从 session 获取用户信息
    String studentId = (String) session.getAttribute("user_id");
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String name = "";
    String gender = "";
    String age = "";
    String phone = "";
    String className = "";
    String address = "";
    String password = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

        // 根据 studentId 查询患者信息
        String sql = "SELECT name, gender, age, phone, student_id, class, address, password FROM patients WHERE student_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, studentId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            name = rs.getString("name");
            gender = rs.getString("gender");
            age = rs.getString("age");
            phone = rs.getString("phone");
            className = rs.getString("class");
            address = rs.getString("address");
            password = rs.getString("password");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>修改患者信息</title>
    <style>
        /* 页面总体样式 */
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f4f7f6; /* 更柔和的灰色 */
            margin: 0;
            padding: 0;
        }

        header {
            background-color: #00796b; /* 深绿色 */
            color: white;
            padding: 20px 0;
            text-align: center;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        header h1 {
            margin: 0;
            font-size: 28px;
        }

        /* 主容器 */
        .container {
            width: 70%;
            margin: 50px auto;
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        /* 表单样式 */
        form {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        /* 表单组 */
        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group label {
            font-size: 16px;
            color: #333;
            margin-bottom: 5px;
        }

        /* 输入框样式 */
        .form-group input,
        .form-group select {
            padding: 12px;
            font-size: 16px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background-color: #f9f9f9;
            transition: border-color 0.3s;
        }

        /* 输入框聚焦时的样式 */
        .form-group input:focus,
        .form-group select:focus {
            border-color: #00796b; /* 深绿色 */
        }

        /* 提交按钮 */
        button[type="submit"] {
            background-color: #00796b;
            color: white;
            padding: 12px 20px;
            border-radius: 5px;
            font-size: 18px;
            border: none;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        /* 提交按钮悬停效果 */
        button[type="submit"]:hover {
            background-color: #004d40; /* 深绿色悬停 */
        }

        /* 禁用输入框样式 */
        input[disabled] {
            background-color: #f0f0f0;
            cursor: not-allowed;
        }
    </style>
</head>
<body>

<header>
    <h1>修改患者信息</h1>
</header>

<div class="container">
    <form action="editPatientAction.jsp" method="post">
        <div class="form-group">
            <label for="name">姓名：</label>
            <input type="text" id="name" name="name" value="<%= name %>" required>
        </div>

        <div class="form-group">
            <label for="gender">性别：</label>
            <select id="gender" name="gender">
                <option value="男" <%= gender.equals("男") ? "selected" : "" %>>男</option>
                <option value="女" <%= gender.equals("女") ? "selected" : "" %>>女</option>
            </select>
        </div>

        <div class="form-group">
            <label for="age">年龄：</label>
            <input type="number" id="age" name="age" value="<%= age %>" required>
        </div>

        <div class="form-group">
            <label for="phone">电话：</label>
            <input type="text" id="phone" name="phone" value="<%= phone %>" required>
        </div>

        <div class="form-group">
            <label for="student_id">学号：</label>
            <input type="text" id="student_id" name="student_id" value="<%= studentId %>" disabled>
        </div>

        <div class="form-group">
            <label for="class">班级：</label>
            <input type="text" id="class" name="class" value="<%= className %>" required>
        </div>

        <div class="form-group">
            <label for="address">地址：</label>
            <input type="text" id="address" name="address" value="<%= address %>" required>
        </div>

        <div class="form-group">
            <label for="password">密码：</label>
            <input type="password" id="password" name="password" placeholder="如果您想修改密码，请输入新密码">
        </div>

        <button type="submit" class="submit-btn">提交修改</button>
    </form>
</div>

</body>
</html>



