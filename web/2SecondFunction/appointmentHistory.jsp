<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>历史预约记录</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        /* 表格样式 */
        table {
            width: 80%;
            border-collapse: collapse;
            margin: 20px auto;
            background-color: #ffffff;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            border: 1px solid #ddd;
        }

        table thead {
            background-color: #00796b;
            color: white;
        }

        table th, table td {
            padding: 10px;
            text-align: center;
            border: 1px solid #ddd;
        }

        table tbody tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        table tbody tr:hover {
            background-color: #f1f1f1;
        }

        /* 错误消息样式 */
        .error-message {
            text-align: center;
            color: red;
            margin: 20px 0;
            font-size: 18px;
        }

        /* 按钮样式 */
        .return-btn {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #00796b;
            color: white;
            text-decoration: none;
            font-size: 16px;
            border-radius: 5px;
            position: absolute;
            bottom: 20px;
            text-align: center;
        }

        .return-btn:hover {
            background-color: #004d40;
        }
    </style>
</head>
<body>
<h1>历史预约记录</h1>

<table>
    <thead>
    <tr>
        <th>预约日期</th>
        <th>预约目的</th>
        <th>预约医生</th>
        <th>状态</th>
        <th>操作</th>
    </tr>
    </thead>
    <tbody>
    <%
        // 获取患者的预约记录
        String patientId = (String) session.getAttribute("user_id");
        if (session.getAttribute("user_id") == null) {
            response.sendRedirect("../login.jsp");
            return;
        }

    if (patientId != null) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");
                String query = "SELECT a.id, a.appointment_date, a.purpose, m.doctor_name AS doctor_name, a.status " +
                        "FROM appointments a " +
                        "LEFT JOIN medical_staff m ON a.doctor_id = m.id " +
                        "WHERE a.patient_id = ?";
                pstmt = conn.prepareStatement(query);
                pstmt.setInt(1, Integer.parseInt(patientId));
                rs = pstmt.executeQuery();

                while (rs.next()) {
                    int appointmentId = rs.getInt("id"); // 预约ID
    %>
    <tr>
        <td><%= rs.getString("appointment_date") %></td>
        <td><%= rs.getString("purpose") %></td>
        <td><%= rs.getString("doctor_name") == null ? "无" : rs.getString("doctor_name") %></td>
        <td><%= rs.getString("status") %></td>
        <td>
            <% if ("已预约".equals(rs.getString("status"))) { %>
            <form action="cancelAppointment.jsp" method="post" style="display:inline;">
                <input type="hidden" name="appointmentId" value="<%= appointmentId %>">
                <button type="submit" onclick="return confirm('确定要取消此预约吗？')">取消预约</button>
            </form>
            <% } else { %>
            无法操作
            <% } %>
        </td>
    </tr>
    <%
        }
    } catch (SQLException e) {
        e.printStackTrace();
    %>
    <tr>
        <td colspan="5">加载数据失败，请稍后重试。</td>
    </tr>
    <%
        } finally {
            // 关闭数据库连接
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
    %>
    <tr>
        <td colspan="5">无法获取患者信息，请登录后查看预约记录。</td>
    </tr>
    <%
        }
    %>
    </tbody>
</table>

<a href="../studentIndex.jsp" class="return-btn">返回选择功能页面</a>

</body>
</html>


