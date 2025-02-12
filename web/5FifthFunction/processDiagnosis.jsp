<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>诊断提交结果</title>
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
        .debug {
            background-color: #fce4e4;
            color: #d32f2f;
            border: 1px solid #f44336;
            padding: 10px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>诊断提交结果</h2>

    <%
        // 获取表单提交的数据
        String doctorId = (String) session.getAttribute("user_id");
        String patientId = request.getParameter("patient_id");
        String diagnosis = request.getParameter("diagnosis");
        String diagnosisDate = request.getParameter("diagnosis_date");

        // 打印调试信息
//        out.println("<div class='debug'>Debug: doctorId = " + doctorId + "</div>");
//        out.println("<div class='debug'>Debug: patientId = " + patientId + "</div>");
//        out.println("<div class='debug'>Debug: diagnosis = " + diagnosis + "</div>");
//        out.println("<div class='debug'>Debug: diagnosisDate = " + diagnosisDate + "</div>");

        // 验证登录状态
        if (doctorId == null) {
            out.println("<p>您尚未登录，请先登录。</p>");
            response.sendRedirect("login.jsp");
            return;
        }

        // 数据库操作
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            // 数据库连接
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

            // 插入诊断记录
            String query = "INSERT INTO medical_records (doctor_id, patient_id, diagnosis, date, prescription) VALUES (?, ?, ?, ?, ?)";
            stmt = conn.prepareStatement(query);
            stmt.setString(1, doctorId);
            stmt.setString(2, patientId);
            stmt.setString(3, diagnosis);
            stmt.setString(4, diagnosisDate);
            stmt.setString(5, ""); // 默认空值

            int result = stmt.executeUpdate();

            if (result > 0) {
                out.println("<p>诊断已成功提交！</p>");
            } else {
                out.println("<p>提交失败，请稍后再试。</p>");
            }
        } catch (Exception e) {
            e.printStackTrace(); // 打印完整错误信息
            out.println("<p>系统错误：" + e.getMessage() + "</p>");
        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    %>

    <a href="doctorIndex.jsp">返回医生首页</a>
</div>
</body>
</html>

