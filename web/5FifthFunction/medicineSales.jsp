<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>药品销售记录</title>
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
        .filters {
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
        }
        .filters input, .filters select {
            padding: 8px;
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
    <h2>药品销售记录</h2>

    <div class="filters">
        <form method="get" action="medicineSales.jsp">
            <label for="filter">按药品或患者过滤:</label>
            <input type="text" name="filter" id="filter" placeholder="输入药品或患者名称">
            <button type="submit">筛选</button>
        </form>
    </div>

    <table>
        <thead>
        <tr>
            <th>药品名称</th>
            <th>患者姓名</th>
            <th>销售数量</th>
            <th>销售日期</th>
            <th>支付方式</th>
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

            // 获取筛选参数
            String filter = request.getParameter("filter");

            // 数据库连接
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

                // 基础查询
                String query = "SELECT m.name AS medicine_name, p.name AS patient_name, ms.quantity, ms.sale_date, ms.payment_method " +
                        "FROM medicine_sales ms " +
                        "JOIN medicines m ON ms.medicine_id = m.id " +
                        "JOIN patients p ON ms.patient_id = p.student_id";

                // 根据筛选条件修改查询
                if (filter != null && !filter.trim().isEmpty()) {
                    query += " WHERE m.name LIKE ? OR p.name LIKE ?";
                }

                stmt = conn.prepareStatement(query);

                if (filter != null && !filter.trim().isEmpty()) {
                    stmt.setString(1, "%" + filter + "%");
                    stmt.setString(2, "%" + filter + "%");
                }

                rs = stmt.executeQuery();

                // 遍历结果集
                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getString("medicine_name") %></td>
            <td><%= rs.getString("patient_name") %></td>
            <td><%= rs.getInt("quantity") %></td>
            <td><%= rs.getDate("sale_date") %></td>
            <td><%= rs.getString("payment_method") %></td>
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

    <a class="back-link" href="doctorIndex.jsp">返回医生首页</a>
</div>
</body>
</html>
