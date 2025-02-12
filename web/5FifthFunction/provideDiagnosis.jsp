<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>提供诊断</title>
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
        input, textarea, select {
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
    <h2>提供诊断</h2>

    <%
        // 验证医生是否登录
        String doctorId = (String) session.getAttribute("user_id");
        if (doctorId == null) {
            out.println("<h3>请先登录！</h3>");
            response.sendRedirect("login.jsp");
            return;
        }

        // 数据库连接，查询医生的所有患者
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            // 数据库连接信息
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

            // 查询医生负责的患者
            String query = "SELECT DISTINCT p.student_id AS patient_id, p.name FROM patients p " +
                    "JOIN appointments a ON p.student_id = a.patient_id WHERE a.doctor_id = ?";
            stmt = conn.prepareStatement(query);
            stmt.setString(1, doctorId);
            rs = stmt.executeQuery();

            // 检查是否有结果
            if (!rs.isBeforeFirst()) {
                out.println("<p>暂无患者信息。</p>");
            } else {
    %>

    <!-- 提供诊断的表单 -->
    <form action="processDiagnosis.jsp" method="post">
        <label for="patient">选择患者</label>
        <select id="patient" name="patient_id" required>
            <option value="">请选择患者</option>
            <%
                while (rs.next()) {
                    String patientId = rs.getString("patient_id");
                    String patientName = rs.getString("name");
            %>
            <option value="<%= patientId %>"><%= patientName %></option>
            <%
                }
            %>
        </select>

        <label for="diagnosis">诊断内容</label>
        <textarea id="diagnosis" name="diagnosis" rows="5" placeholder="请输入诊断信息" required></textarea>

        <label for="date">诊断日期</label>
        <input type="date" id="date" name="diagnosis_date" value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" required>

        <button type="submit">提交诊断</button>
    </form>

    <%
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<h3>系统错误，请稍后再试！</h3>");
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    %>

    <a class="back-link" href="../doctorIndex.jsp">返回医生首页</a>
</div>
</body>
</html>


