<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>预约确认</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .container {
            width: 100%;
            max-width: 600px;
            background-color: #ffffff;
            padding: 30px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
            text-align: center;
            box-sizing: border-box;
            border: 2px solid #00796b;
        }

        .title {
            color: #00796b;
            font-size: 24px;
            margin-bottom: 20px;
            font-weight: bold;
        }

        .info {
            text-align: left;
            font-size: 16px;
            margin-bottom: 20px;
            color: #333;
        }

        .info strong {
            color: #00796b;
        }

        a {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #00796b;
            color: white;
            text-decoration: none;
            font-size: 16px;
            border-radius: 5px;
        }

        a:hover {
            background-color: #004d40;
        }

        button {
            padding: 10px 20px;
            font-size: 16px;
            color: white;
            background-color: #00796b;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        button:hover {
            background-color: #004d40;
        }
    </style>
</head>
<body>
<%
    // 获取患者的预约信息
    String patientId = (String) session.getAttribute("user_id");
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // 定义变量存储预约信息
    String appointmentType = "";
    String doctorName = "";
    String appointmentDate = "";
    String purpose = "";
    int appointmentId = 0; // 用于存储预约ID

    try {
        // 连接数据库
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

        // 查询患者的最新预约记录
        String sql = "SELECT a.id AS appointment_id, a.appointment_date, a.purpose, a.doctor_id, m.doctor_name " +
                "FROM appointments a " +
                "LEFT JOIN medical_staff m ON a.doctor_id = m.id " +
                "WHERE a.patient_id = ? " +
                "ORDER BY a.appointment_date DESC LIMIT 1";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, Integer.parseInt(patientId));
        rs = pstmt.executeQuery();

        // 获取预约信息
        if (rs.next()) {
            appointmentId = rs.getInt("appointment_id"); // 获取预约ID
            appointmentDate = rs.getString("appointment_date");
            purpose = rs.getString("purpose");
            int doctorId = rs.getInt("doctor_id");
            doctorName = rs.getString("doctor_name");

            // 根据是否有 doctor_id 判断预约类型
            if (doctorId > 0) {
                appointmentType = "预约医生";
            } else {
                appointmentType = "预约体检";
            }
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

<div class="container">
    <!-- 标题 -->
    <h1 class="title">预约确认</h1>

    <!-- 预约信息 -->
    <div class="info">
        <p><strong>预约类型：</strong> <%= appointmentType %></p>
        <% if ("预约医生".equals(appointmentType)) { %>
        <p><strong>医生姓名：</strong> <%= doctorName != null ? doctorName : "未指定医生" %></p>
        <% } %>
        <p><strong>预约日期：</strong> <%= appointmentDate != null ? appointmentDate : "未指定日期" %></p>
        <p><strong>预约目的：</strong> <%= purpose != null ? purpose : "未填写目的" %></p>
    </div>

    <!-- 确认预约按钮 -->
    <% if (appointmentId > 0) { %>
    <div>
        <form action="statusConfirm.jsp" method="post">
            <input type="hidden" name="appointmentId" value="<%= appointmentId %>">
            <button type="submit" onclick="return confirm('确认此预约吗？')">确认预约</button>
        </form>
    </div>
    <% } %>

    <!-- 返回首页链接 -->
    <a href="../studentIndex.jsp">返回功能选择首页</a>
</div>

</body>
</html>


