<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>查看患者健康记录</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f7f6;
        }
        .container {
            max-width: 1200px;
            margin: 20px auto;
            background-color: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        h2 {
            text-align: center;
            color: #00796b;
        }
        .section {
            margin-bottom: 30px;
        }
        .section h3 {
            color: #00796b;
            margin-bottom: 10px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 12px;
            text-align: center;
            border: 1px solid #ddd;
        }
        th {
            background-color: #00796b;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
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
    <h2>查看患者健康记录</h2>

    <%
        // 获取医生ID
        String doctorId = (String) session.getAttribute("user_id");
        if (doctorId == null) {
            out.println("<h3>您尚未登录，请先登录！</h3>");
            response.sendRedirect("login.jsp");
            return;
        }

        // 数据库连接
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            // 数据库连接信息
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

            // 查询医生负责的患者信息
            String patientQuery = "SELECT DISTINCT p.student_id, p.name, p.gender, p.age FROM patients p " +
                    "JOIN appointments a ON p.student_id = a.patient_id WHERE a.doctor_id = ?";
            stmt = conn.prepareStatement(patientQuery);
            stmt.setString(1, doctorId);
            rs = stmt.executeQuery();

            // 遍历所有患者
            while (rs.next()) {
                int patientId = rs.getInt("student_id");
                String patientName = rs.getString("name");
                String gender = rs.getString("gender");
                int age = rs.getInt("age");
    %>

    <!-- 患者信息展示 -->
    <div class="section">
        <h3>患者基本信息</h3>
        <p><strong>姓名：</strong><%= patientName %></p>
        <p><strong>性别：</strong><%= gender %></p>
        <p><strong>年龄：</strong><%= age %> 岁</p>
    </div>

    <!-- 体检报告 -->
    <div class="section">
        <h3>体检报告</h3>
        <table>
            <thead>
            <tr>
                <th>体检日期</th>
                <th>身高 (cm)</th>
                <th>体重 (kg)</th>
                <th>血压</th>
                <th>视力</th>
            </tr>
            </thead>
            <tbody>
            <%
                PreparedStatement checkupStmt = conn.prepareStatement(
                        "SELECT checkup_date, height, weight, blood_pressure, vision " +
                                "FROM health_checkups WHERE student_id = ?");
                checkupStmt.setInt(1, patientId);
                ResultSet checkupRs = checkupStmt.executeQuery();

                while (checkupRs.next()) {
            %>
            <tr>
                <td><%= checkupRs.getString("checkup_date") %></td>
                <td><%= checkupRs.getString("height") %></td>
                <td><%= checkupRs.getString("weight") %></td>
                <td><%= checkupRs.getString("blood_pressure") %></td>
                <td><%= checkupRs.getString("vision") %></td>
            </tr>
            <%
                }
                checkupRs.close();
                checkupStmt.close();
            %>
            </tbody>
        </table>
    </div>

    <!-- 运动记录 -->
    <div class="section">
        <h3>运动记录</h3>
        <table>
            <thead>
            <tr>
                <th>活动名称</th>
                <th>活动日期</th>
                <th>持续时间 (分钟)</th>
                <th>健康效果</th>
            </tr>
            </thead>
            <tbody>
            <%
                PreparedStatement activityStmt = conn.prepareStatement(
                        "SELECT activity_name, activity_date, duration, health_effect " +
                                "FROM sports_activities WHERE student_id = ?");
                activityStmt.setInt(1, patientId);
                ResultSet activityRs = activityStmt.executeQuery();

                while (activityRs.next()) {
            %>
            <tr>
                <td><%= activityRs.getString("activity_name") %></td>
                <td><%= activityRs.getString("activity_date") %></td>
                <td><%= activityRs.getString("duration") %></td>
                <td><%= activityRs.getString("health_effect") %></td>
            </tr>
            <%
                }
                activityRs.close();
                activityStmt.close();
            %>
            </tbody>
        </table>
    </div>

    <!-- 就诊记录 -->
    <div class="section">
        <h3>就诊记录</h3>
        <table>
            <thead>
            <tr>
                <th>诊断</th>
                <th>处方</th>
                <th>备注</th>
            </tr>
            </thead>
            <tbody>
            <%
                PreparedStatement medicalStmt = conn.prepareStatement(
                        "SELECT diagnosis, prescription, remarks FROM medical_records WHERE patient_id = ?");
                medicalStmt.setInt(1, patientId);
                ResultSet medicalRs = medicalStmt.executeQuery();

                while (medicalRs.next()) {
            %>
            <tr>
                <td><%= medicalRs.getString("diagnosis") %></td>
                <td><%= medicalRs.getString("prescription") %></td>
                <td><%= medicalRs.getString("remarks") %></td>
            </tr>
            <%
                }
                medicalRs.close();
                medicalStmt.close();
            %>
            </tbody>
        </table>
    </div>

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

    <!-- 返回链接 -->
    <a class="back-link" href="../doctorIndex.jsp">返回医生首页</a>
</div>
</body>
</html>
