<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>提交处方结果</title>
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
    </style>
</head>
<body>
<div class="container">
    <h2>提交处方结果</h2>

    <%
        // 获取表单数据
        String doctorId = (String) session.getAttribute("user_id");
        String patientId = request.getParameter("patient_id");
        String medicineId = request.getParameter("medicine_id");
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        String remarks = request.getParameter("remarks");

        // 数据库操作
        Connection conn = null;
        PreparedStatement stmtUpdateStock = null;
        PreparedStatement stmtInsertRecord = null;
        ResultSet rs = null;

        try {
            // 数据库连接
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

            // 检查药品库存是否足够
            String checkStockQuery = "SELECT stock FROM medicines WHERE id = ?";
            stmtUpdateStock = conn.prepareStatement(checkStockQuery);
            stmtUpdateStock.setInt(1, Integer.parseInt(medicineId));
            rs = stmtUpdateStock.executeQuery();
            if (rs.next()) {
                int stock = rs.getInt("stock");
                if (stock < quantity) {
                    out.println("<p>库存不足，无法开具处方！</p>");
                    return;
                }
            }

            // 减少药品库存
            String updateStockQuery = "UPDATE medicines SET stock = stock - ? WHERE id = ?";
            stmtUpdateStock = conn.prepareStatement(updateStockQuery);
            stmtUpdateStock.setInt(1, quantity);
            stmtUpdateStock.setInt(2, Integer.parseInt(medicineId));
            stmtUpdateStock.executeUpdate();

            // 插入处方记录
            String insertRecordQuery = "INSERT INTO medical_records (doctor_id, patient_id, diagnosis, date, prescription) VALUES (?, ?, ?, NOW(), ?)";
            stmtInsertRecord = conn.prepareStatement(insertRecordQuery);
            stmtInsertRecord.setString(1, doctorId);
            stmtInsertRecord.setString(2, patientId);
            stmtInsertRecord.setString(3, "开药");
            stmtInsertRecord.setString(4, remarks != null ? remarks : "");
            stmtInsertRecord.executeUpdate();

            out.println("<p>处方提交成功！</p>");
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p>系统错误：" + e.getMessage() + "</p>");
        } finally {
            if (rs != null) rs.close();
            if (stmtUpdateStock != null) stmtUpdateStock.close();
            if (stmtInsertRecord != null) stmtInsertRecord.close();
            if (conn != null) conn.close();
        }
    %>

    <a href="../doctorIndex.jsp">返回医生首页</a>
</div>
</body>
</html>

