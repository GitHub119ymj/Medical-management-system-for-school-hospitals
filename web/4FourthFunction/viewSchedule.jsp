<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>医生日程查看</title>
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
        .table-container {
            margin: 20px auto;
            width: 80%;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            background: white;
        }
        th, td {
            padding: 12px;
            border: 1px solid #ddd;
            text-align: center;
        }
        th {
            background-color: #00796b;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        .no-data {
            text-align: center;
            color: #555;
            font-size: 1.2em;
            margin-top: 20px;
        }
    </style>
</head>
<body>
<div class="header">
    <h1>医生日程查看</h1>
</div>
<div class="table-container">
    <table>
        <thead>
        <tr>
            <th>患者姓名</th>
            <th>预约日期</th>
            <th>预约状态</th>
            <th>预约目的</th>
        </tr>
        </thead>
        <tbody>
        <%
            String doctorId = (String) session.getAttribute("user_id");
//            out.println(doctorId);
            if (doctorId != null) {
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

                    String query = "SELECT p.name AS patient_name, a.appointment_date, a.status, a.purpose " +
                            "FROM appointments a " +
                            "JOIN patients p ON a.patient_id = p.student_id " +
                            "WHERE a.doctor_id = ? " +
                            "ORDER BY a.appointment_date";
                    pstmt = conn.prepareStatement(query);
                    pstmt.setString(1, doctorId);
                    rs = pstmt.executeQuery();

                    boolean hasData = false; // 标记是否有数据
                    while (rs.next()) {
                        hasData = true;
                        String patientName = rs.getString("patient_name");
                        String appointmentDate = rs.getString("appointment_date");
                        String status = rs.getString("status");
                        String purpose = rs.getString("purpose");

                        out.println("<tr>");
                        out.println("<td>" + patientName + "</td>");
                        out.println("<td>" + appointmentDate + "</td>");
                        out.println("<td>" + status + "</td>");
                        out.println("<td>" + purpose + "</td>");
                        out.println("</tr>");
                    }
                    if (!hasData) {
                        out.println("<tr><td colspan='4'>暂无预约记录</td></tr>");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                }
            } else {
                out.println("<tr><td colspan='4'>未登录医生账户，请重新登录。</td></tr>");
            }
        %>
        </tbody>
    </table>
</div>
</body>
</html>

