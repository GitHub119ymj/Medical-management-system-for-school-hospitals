<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>运动活动历史</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 20px;
            text-align: center;
        }

        h1 {
            color: #00796b;
            margin-bottom: 20px;
        }

        table {
            width: 80%;
            margin: 0 auto;
            border-collapse: collapse;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            background-color: #fff;
        }

        th, td {
            padding: 10px;
            border: 1px solid #ddd;
            text-align: center;
        }

        th {
            background-color: #00796b;
            color: #fff;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .return-btn {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #00796b;
            color: #fff;
            text-decoration: none;
            border-radius: 5px;
        }

        .return-btn:hover {
            background-color: #005f56;
        }
    </style>
</head>
<body>
<h1>运动活动历史</h1>

<table>
    <thead>
    <tr>
        <th>活动名称</th>
        <th>活动日期</th>
        <th>持续时间 (分钟)</th>
        <th>健康影响</th>
    </tr>
    </thead>
    <tbody>
    <%
        String studentId = (String) session.getAttribute("user_id");

        if (studentId != null) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");
                String query = "SELECT activity_name, activity_date, duration, health_effect " +
                        "FROM sports_activities WHERE student_id = ? ORDER BY activity_date DESC";
                pstmt = conn.prepareStatement(query);
                pstmt.setString(1, studentId);
                rs = pstmt.executeQuery();

                if (!rs.isBeforeFirst()) {
    %>
    <tr>
        <td colspan="4">暂无运动记录。</td>
    </tr>
    <%
        }

        while (rs.next()) {
    %>
    <tr>
        <td><%= rs.getString("activity_name") %></td>
        <td><%= rs.getString("activity_date") %></td>
        <td><%= rs.getInt("duration") %></td>
        <td><%= rs.getString("health_effect") %></td>
    </tr>
    <%
        }
    } catch (SQLException e) {
        e.printStackTrace();
    %>
    <tr>
        <td colspan="4">加载数据失败，请稍后重试。</td>
    </tr>
    <%
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    } else {
    %>
    <tr>
        <td colspan="4">无法获取患者信息，请登录后查看运动记录。</td>
    </tr>
    <%
        }
    %>
    </tbody>
</table>

<a href="../studentIndex.jsp" class="return-btn">返回选择功能页面</a>
</body>
</html>

