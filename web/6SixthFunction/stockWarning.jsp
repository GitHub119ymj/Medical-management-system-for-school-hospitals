<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>库存预警</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
            color: #333;
        }
        .container {
            max-width: 1000px;
            margin: 20px auto;
            padding: 20px;
            background-color: white;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            border-radius: 5px;
        }
        h1 {
            color: #00796b;
            text-align: center;
            margin-bottom: 30px;
        }
        .warning-header {
            background-color: #ffebee;
            color: #c62828;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            text-align: center;
            font-weight: bold;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #00796b;
            color: white;
            font-weight: bold;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .stock-warning {
            background-color: #ffebee;
            color: #c62828;
            font-weight: bold;
        }
        .reorder-quantity {
            background-color: #e3f2fd;
            font-weight: bold;
        }
        .btn {
            padding: 10px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
        }
        .btn-primary {
            background-color: #00796b;
            color: white;
        }
        .btn-primary:hover {
            background-color: #00695c;
        }
        .btn-secondary {
            background-color: #607d8b;
            color: white;
        }
        .btn-secondary:hover {
            background-color: #455a64;
        }
        .footer {
            margin-top: 30px;
            text-align: center;
        }
        .no-data {
            text-align: center;
            padding: 40px;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>库存预警</h1>
        
        <div class="warning-header">
            <i class="fas fa-exclamation-triangle"></i> 以下药品库存低于预警阈值，需要及时补货！
        </div>
        
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>药品名称</th>
                    <th>类别</th>
                    <th>规格</th>
                    <th>当前库存</th>
                    <th>预警阈值</th>
                    <th>建议补货数量</th>
                    <th>单价</th>
                    <th>生产厂家</th>
                    <th>有效期</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
                <% 
                    // 数据库连接信息
                    String url = "jdbc:mysql://localhost:3306/hms";
                    String username = "root";
                    String password = "123456";
                    
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    
                    boolean hasData = false;
                    
                    try {
                        // 加载驱动
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        // 建立连接
                        conn = DriverManager.getConnection(url, username, password);
                        
                        // 查询库存低于预警阈值的药品
                        String sql = "SELECT * FROM medicines WHERE stock_quantity < stock_warning_level";
                        pstmt = conn.prepareStatement(sql);
                        
                        // 执行查询
                        rs = pstmt.executeQuery();
                        
                        // 遍历结果集
                        while (rs.next()) {
                            hasData = true;
                            int id = rs.getInt("id");
                            String medicineName = rs.getString("medicine_name");
                            String category = rs.getString("category");
                            String specification = rs.getString("specification");
                            int stockQuantity = rs.getInt("stock_quantity");
                            int stockWarningLevel = rs.getInt("stock_warning_level");
                            double unitPrice = rs.getDouble("unit_price");
                            String manufacturer = rs.getString("manufacturer");
                            Date expiryDate = rs.getDate("expiry_date");
                            
                            // 计算建议补货数量（预警阈值的2倍）
                            int suggestedReorderQuantity = stockWarningLevel * 2 - stockQuantity;
                            if (suggestedReorderQuantity < 0) suggestedReorderQuantity = 0;
                            %>
                            <tr class="stock-warning">
                                <td><%= id %></td>
                                <td><%= medicineName %></td>
                                <td><%= category %></td>
                                <td><%= specification %></td>
                                <td><%= stockQuantity %></td>
                                <td><%= stockWarningLevel %></td>
                                <td class="reorder-quantity"><%= suggestedReorderQuantity %></td>
                                <td><%= unitPrice %></td>
                                <td><%= manufacturer %></td>
                                <td><%= expiryDate %></td>
                                <td>
                                    <a href="editMedicine.jsp?id=<%= id %>" class="btn btn-primary">
                                        <i class="fas fa-edit"></i> 编辑
                                    </a>
                                </td>
                            </tr>
                            <% 
                        }
                        
                        if (!hasData) {
                            out.println("<tr>");
                            out.println("<td colspan='11' class='no-data'>");
                            out.println("<i class='fas fa-check-circle'></i> 所有药品库存正常，无需预警！");
                            out.println("</td>");
                            out.println("</tr>");
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("<tr><td colspan='11'>数据库连接失败：" + e.getMessage() + "</td></tr>");
                    } finally {
                        // 关闭资源
                        try {
                            if (rs != null) rs.close();
                            if (pstmt != null) pstmt.close();
                            if (conn != null) conn.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                %>
            </tbody>
        </table>
        
        <div class="footer">
            <a href="medicineList.jsp" class="btn btn-primary">
                <i class="fas fa-list"></i> 查看完整药品列表
            </a>
            <a href="../doctorIndex.jsp" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> 返回
            </a>
        </div>
    </div>
</body>
</html>