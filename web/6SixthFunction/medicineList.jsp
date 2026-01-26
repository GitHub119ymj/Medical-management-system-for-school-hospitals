<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>药品库存管理</title>
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
            max-width: 1200px;
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
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .search-box {
            display: flex;
            gap: 10px;
        }
        .search-box input[type="text"] {
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            width: 300px;
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
        .btn-danger {
            background-color: #f44336;
            color: white;
        }
        .btn-danger:hover {
            background-color: #d32f2f;
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
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        .footer {
            margin-top: 30px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>药品库存管理</h1>
        
        <div class="header">
            <div class="search-box">
                <form action="medicineList.jsp" method="get">
                    <input type="text" name="search" placeholder="按药品名称搜索" value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-search"></i> 搜索
                    </button>
                </form>
            </div>
            <a href="addMedicine.jsp" class="btn btn-primary">
                <i class="fas fa-plus"></i> 添加新药品
            </a>
        </div>
        
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>药品名称</th>
                    <th>类别</th>
                    <th>规格</th>
                    <th>库存数量</th>
                    <th>单价</th>
                    <th>生产厂家</th>
                    <th>有效期</th>
                    <th>库存预警阈值</th>
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
                    
                    try {
                        // 加载驱动
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        // 建立连接
                        conn = DriverManager.getConnection(url, username, password);
                        
                        // 构建SQL语句
                        String sql = "SELECT * FROM medicines";
                        String search = request.getParameter("search");
                        
                        if (search != null && !search.isEmpty()) {
                            sql += " WHERE medicine_name LIKE ?";
                            pstmt = conn.prepareStatement(sql);
                            pstmt.setString(1, "%" + search + "%");
                        } else {
                            pstmt = conn.prepareStatement(sql);
                        }
                        
                        // 执行查询
                        rs = pstmt.executeQuery();
                        
                        // 遍历结果集
                        while (rs.next()) {
                            int id = rs.getInt("id");
                            String medicineName = rs.getString("medicine_name");
                            String category = rs.getString("category");
                            String specification = rs.getString("specification");
                            int stockQuantity = rs.getInt("stock_quantity");
                            double unitPrice = rs.getDouble("unit_price");
                            String manufacturer = rs.getString("manufacturer");
                            Date expiryDate = rs.getDate("expiry_date");
                            int stockWarningLevel = rs.getInt("stock_warning_level");
                            
                            // 判断是否需要库存预警
                            boolean isStockWarning = stockQuantity < stockWarningLevel;
                            %>
                            <tr <%= isStockWarning ? "class='stock-warning'" : "" %>>
                                <td><%= id %></td>
                                <td><%= medicineName %></td>
                                <td><%= category %></td>
                                <td><%= specification %></td>
                                <td><%= stockQuantity %></td>
                                <td><%= unitPrice %></td>
                                <td><%= manufacturer %></td>
                                <td><%= expiryDate %></td>
                                <td><%= stockWarningLevel %></td>
                                <td class="action-buttons">
                                    <a href="editMedicine.jsp?id=<%= id %>" class="btn btn-secondary">
                                        <i class="fas fa-edit"></i> 编辑
                                    </a>
                                    <a href="deleteMedicine.jsp?id=<%= id %>" class="btn btn-danger" onclick="return confirm('确定要删除该药品吗？');">
                                        <i class="fas fa-trash"></i> 删除
                                    </a>
                                </td>
                            </tr>
                            <% 
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        out.println("<tr><td colspan='10'>数据库连接失败：" + e.getMessage() + "</td></tr>");
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
            <a href="../doctorIndex.jsp" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> 返回
            </a>
        </div>
    </div>
</body>
</html>