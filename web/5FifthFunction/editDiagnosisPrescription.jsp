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
            max-width: 1000px;
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
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
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

    <table>
        <thead>
        <tr>
            <th>患者姓名</th>
            <th>诊断内容</th>
            <th>处方</th>
            <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <%
            // 验证医生是否登录
            String doctorId = (String) session.getAttribute("user_id");
            if (doctorId == null) {
                out.println("<p>请先登录！</p>");
                response.sendRedirect("login.jsp");
                return;
            }

            // 数据库连接
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

                // 查询医生的诊断记录
                String query = "SELECT m.id, p.name AS patient_name, m.diagnosis, m.prescription " +
                        "FROM medical_records m " +
                        "JOIN patients p ON m.patient_id = p.student_id " +
                        "WHERE m.doctor_id = ?";
                stmt = conn.prepareStatement(query);
                stmt.setString(1, doctorId);
                rs = stmt.executeQuery();

                // 遍历结果集
                while (rs.next()) {
                    int recordId = rs.getInt("id");
                    String patientName = rs.getString("patient_name");
                    String diagnosis = rs.getString("diagnosis");
                    String prescription = rs.getString("prescription");
        %>
        <tr>
            <td><%= patientName %></td>
            <td><%= diagnosis %></td>
            <td><%= prescription %></td>
            <td>
                <form action="editDiagnosisForm.jsp" method="get">
                    <input type="hidden" name="record_id" value="<%= recordId %>">
                    <button type="submit">修改</button>
                </form>
            </td>
        </tr>
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
        </tbody>
    </table>

    <a class="back-link" href="../doctorIndex.jsp">返回医生首页</a>
</div>
</body>
</html>

