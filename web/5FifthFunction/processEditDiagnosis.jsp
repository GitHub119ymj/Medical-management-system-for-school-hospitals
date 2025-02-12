<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>修改结果</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f7f6;
        }
        .container {
            max-width: 600px;
            margin: 40px auto;
            background-color: #fff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        h2 {
            text-align: center;
            color: #00796b;
        }
        p {
            text-align: center;
            font-size: 16px;
            color: #333;
        }
        a {
            display: inline-block;
            margin-top: 20px;
            text-align: center;
            font-size: 16px;
            color: #00796b;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>修改结果</h2>

    <%
        // 获取表单数据
        String recordId = request.getParameter("record_id");
        String diagnosis = request.getParameter("diagnosis");
        String prescription = request.getParameter("prescription");

        // 数据库操作
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

            // 更新记录
            String query = "UPDATE medical_records SET diagnosis = ?, prescription = ? WHERE id = ?";
            stmt = conn.prepareStatement(query);
            stmt.setString(1, diagnosis);
            stmt.setString(2, prescription);
            stmt.setInt(3, Integer.parseInt(recordId));
            int result = stmt.executeUpdate();

            if (result > 0) {
                out.println("<p>记录修改成功！</p>");
            } else {
                out.println("<p>记录修改失败，请稍后再试。</p>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p>系统错误：" + e.getMessage() + "</p>");
        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    %>

    <a href="editDiagnosisPrescription.jsp">返回诊断列表</a>
</div>
</body>
</html>
