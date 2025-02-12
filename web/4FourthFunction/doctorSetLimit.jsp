<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>设置接诊限制</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f7f7f7;
        }
        .header {
            text-align: center;
            background-color: #00796b;
            padding: 15px;
            color: white;
            font-size: 1.5em;
        }
        .container {
            width: 60%;
            margin: 50px auto;
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        .form-group {
            margin: 15px 0;
        }
        .form-group label {
            display: block;
            font-size: 1.2em;
            margin-bottom: 5px;
        }
        .form-group input {
            width: 100%;
            padding: 10px;
            font-size: 1em;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        .form-group button {
            margin-top: 20px;
            width: 100%;
            padding: 10px;
            font-size: 1em;
            color: white;
            background-color: #00796b;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .form-group button:hover {
            background-color: #005f57;
        }
        .message {
            text-align: center;
            margin-top: 20px;
            font-size: 1.1em;
        }
    </style>
</head>
<body>
<div class="header">
    <h1>设置接诊限制</h1>
</div>
<div class="container">
    <form method="post">
        <div class="form-group">
            <label for="dailyLimit">每日接诊人数限制：</label>
            <input type="number" id="dailyLimit" name="dailyLimit" placeholder="输入每日最大接诊人数">
        </div>
        <div class="form-group">
            <button type="submit">保存设置</button>
        </div>
    </form>
    <%
        String doctorId = (String) session.getAttribute("user_id");
        if (request.getMethod().equalsIgnoreCase("POST")) {
            String dailyLimitStr = request.getParameter("dailyLimit");
            int dailyLimit = Integer.parseInt(dailyLimitStr);

            Connection conn = null;
            PreparedStatement pstmt = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

                String updateQuery = "UPDATE medical_staff SET daily_limit = ? WHERE doctor_id = ?";
                pstmt = conn.prepareStatement(updateQuery);
                pstmt.setInt(1, dailyLimit);
                pstmt.setString(2, doctorId);

                int rowsAffected = pstmt.executeUpdate();
                if (rowsAffected > 0) {
                    out.println("<p class='message' style='color: green;'>接诊限制已成功设置为：" + dailyLimit + " 人/天。</p>");
                } else {
                    out.println("<p class='message' style='color: red;'>更新失败，请稍后再试。</p>");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<p class='message' style='color: red;'>系统错误：" + e.getMessage() + "</p>");
            } finally {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            }
        }
    %>
</div>
</body>
</html>

