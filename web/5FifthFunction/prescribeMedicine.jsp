<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>开具处方</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f7f6;
        }
        .container {
            max-width: 800px;
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
        form {
            margin-top: 20px;
        }
        label {
            font-weight: bold;
            color: #333;
        }
        select, input, textarea {
            width: 100%;
            margin-top: 8px;
            margin-bottom: 20px;
            padding: 10px;
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
    <h2>开具处方</h2>

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
        PreparedStatement stmtPatients = null;
        PreparedStatement stmtMedicines = null;
        ResultSet rsPatients = null;
        ResultSet rsMedicines = null;

        try {
            // 数据库连接信息
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

            // 查询医生负责的患者
            String queryPatients = "SELECT DISTINCT p.student_id AS patient_id, p.name FROM patients p " +
                    "JOIN appointments a ON p.student_id = a.patient_id WHERE a.doctor_id = ?";
            stmtPatients = conn.prepareStatement(queryPatients);
            stmtPatients.setString(1, doctorId);
            rsPatients = stmtPatients.executeQuery();

            // 查询所有药品信息
            String queryMedicines = "SELECT id, name, stock FROM medicines";
            stmtMedicines = conn.prepareStatement(queryMedicines);
            rsMedicines = stmtMedicines.executeQuery();
    %>

    <!-- 开具处方表单 -->
    <form action="processPrescription.jsp" method="post">
        <label for="patient">选择患者</label>
        <select id="patient" name="patient_id" required>
            <option value="">请选择患者</option>
            <%
                while (rsPatients.next()) {
                    String patientId = rsPatients.getString("patient_id");
                    String patientName = rsPatients.getString("name");
            %>
            <option value="<%= patientId %>"><%= patientName %></option>
            <%
                }
            %>
        </select>

        <label for="medicine">选择药品</label>
        <select id="medicine" name="medicine_id" required>
            <option value="">请选择药品</option>
            <%
                while (rsMedicines.next()) {
                    int medicineId = rsMedicines.getInt("id");
                    String medicineName = rsMedicines.getString("name");
                    int stock = rsMedicines.getInt("stock");
            %>
            <option value="<%= medicineId %>"><%= medicineName %> (库存: <%= stock %>)</option>
            <%
                }
            %>
        </select>

        <label for="quantity">数量</label>
        <input type="number" id="quantity" name="quantity" min="1" required>

        <label for="remarks">备注</label>
        <textarea id="remarks" name="remarks" rows="4" placeholder="填写用药说明（可选）"></textarea>

        <button type="submit">提交处方</button>
    </form>

    <%
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p>系统错误：" + e.getMessage() + "</p>");
        } finally {
            if (rsPatients != null) rsPatients.close();
            if (rsMedicines != null) rsMedicines.close();
            if (stmtPatients != null) stmtPatients.close();
            if (stmtMedicines != null) stmtMedicines.close();
            if (conn != null) conn.close();
        }
    %>

    <a class="back-link" href="../doctorIndex.jsp">返回医生首页</a>
</div>
</body>
</html>
