<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>修改诊断或处方</title>
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
        form {
            margin-top: 20px;
        }
        label {
            font-weight: bold;
            color: #333;
        }
        input, textarea {
            width: 100%;
            margin-top: 8px;
            margin-bottom: 20px;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        button {
            background-color: #00796b;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        button:hover {
            background-color: #005a52;
        }
        .back-link {
            display: inline-block;
            margin-top: 20px;
            text-align: center;
            font-size: 16px;
            color: #00796b;
            text-decoration: none;
        }
        .back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>修改诊断或处方</h2>

    <%
        // 获取记录ID
        String recordId = request.getParameter("record_id");
        if (recordId == null) {
            out.println("<p>未指定要修改的记录。</p>");
            return;
        }

        // 数据库连接
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

            // 查询指定记录
            String query = "SELECT diagnosis, prescription FROM medical_records WHERE id = ?";
            stmt = conn.prepareStatement(query);
            stmt.setInt(1, Integer.parseInt(recordId));
            rs = stmt.executeQuery();

            if (rs.next()) {
                String diagnosis = rs.getString("diagnosis");
                String prescription = rs.getString("prescription");
    %>

    <form action="processEditDiagnosis.jsp" method="post">
        <input type="hidden" name="record_id" value="<%= recordId %>">

        <label for="diagnosis">诊断内容</label>
        <textarea id="diagnosis" name="diagnosis" rows="5" required><%= diagnosis %></textarea>

        <label for="prescription">处方</label>
        <textarea id="prescription" name="prescription" rows="5" required><%= prescription %></textarea>

        <button type="submit">保存修改</button>
    </form>

    <%
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p>系统错误：" + e.getMessage() + "</p>");
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    %>

    <a class="back-link" href="editDiagnosisPrescription.jsp">返回诊断列表</a>
</div>
</body>
</html>

