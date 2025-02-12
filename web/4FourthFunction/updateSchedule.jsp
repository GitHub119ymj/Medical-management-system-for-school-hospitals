<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>更新日程安排</title>
    <style>
        /* 通用样式 */
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            color: #333;
            margin: 0;
            padding: 0;
        }

        /* 容器 */
        .container {
            max-width: 900px;
            margin: 50px auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        /* 标题 */
        h1 {
            text-align: center;
            color: #00796b;
            margin-bottom: 20px;
        }

        /* 表格 */
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        table th, table td {
            padding: 12px;
            text-align: center;
            border: 1px solid #ddd;
        }

        table th {
            background-color: #00796b;
            color: white;
        }

        table tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        table tr:hover {
            background-color: #f1f1f1;
        }

        /* 表单按钮 */
        form button {
            background-color: #00796b;
            color: white;
            border: none;
            padding: 8px 16px;
            font-size: 14px;
            cursor: pointer;
            border-radius: 4px;
            transition: background-color 0.3s;
        }

        form button:hover {
            background-color: #004d40;
        }

        /* 选择框 */
        form select {
            padding: 8px;
            border-radius: 4px;
            border: 1px solid #ddd;
            font-size: 14px;
            background-color: white;
        }

        /* 返回链接按钮 */
        a.btn {
            display: inline-block;
            margin-top: 20px;
            background-color: #00796b;
            color: white;
            padding: 10px 20px;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.3s;
        }

        a.btn:hover {
            background-color: #004d40;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>更新日程安排</h1>

    <%
        // 数据库连接
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

            // 查询当前医生的预约信息
            String doctorId = (String) session.getAttribute("user_id"); // 从 session 获取医生 ID
            String sql = "SELECT a.id, p.name AS patient_name, a.appointment_date, a.status, a.purpose " +
                    "FROM appointments a " +
                    "JOIN patients p ON a.patient_id = p.student_id " +
                    "WHERE a.doctor_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, doctorId);
            rs = pstmt.executeQuery();
    %>

    <!-- 显示预约列表 -->
    <table>
        <thead>
        <tr>
            <th>预约ID</th>
            <th>患者姓名</th>
            <th>预约时间</th>
            <th>状态</th>
            <th>预约目的</th>
            <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <%
            while (rs.next()) {
                String appointmentId = rs.getString("id");
                String patientName = rs.getString("patient_name");
                String appointmentDate = rs.getString("appointment_date");
                String status = rs.getString("status");
                String purpose = rs.getString("purpose");
        %>
        <tr>
            <td><%= appointmentId %></td>
            <td><%= patientName %></td>
            <td><%= appointmentDate %></td>
            <td><%= status %></td>
            <td><%= purpose %></td>
            <td>
                <!-- 更新按钮，跳转到处理更新的 JSP -->
                <form action="processUpdateSchedule.jsp" method="POST" style="margin: 0;">
                    <input type="hidden" name="id" value="<%= appointmentId %>">
                    <select name="status">
                        <option value="待确认" <%= "待确认".equals(status) ? "selected" : "" %>>待确认</option>
                        <option value="已完成" <%= "已完成".equals(status) ? "selected" : "" %>>已完成</option>
                        <option value="取消" <%= "取消".equals(status) ? "selected" : "" %>>取消</option>
                    </select>
                    <button type="submit" class="btn">更新</button>
                </form>
            </td>
        </tr>
        <%
            }
        %>
        </tbody>
    </table>

    <%
    } catch (Exception e) {
        e.printStackTrace();
    %>
    <p>系统错误：<%= e.getMessage() %></p>
    <%
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    %>

    <a href="doctorSchedule.jsp" class="btn">返回日程管理</a>
</div>
</body>
</html>
