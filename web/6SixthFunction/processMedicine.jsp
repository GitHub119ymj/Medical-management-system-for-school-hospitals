<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>处理药品信息</title>
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
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
            background-color: white;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            border-radius: 5px;
            text-align: center;
        }
        h1 {
            color: #00796b;
            margin-bottom: 20px;
        }
        .message {
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .success {
            background-color: #e8f5e8;
            color: #2e7d32;
            border: 1px solid #c8e6c9;
        }
        .error {
            background-color: #ffebee;
            color: #c62828;
            border: 1px solid #ffcdd2;
        }
        .btn {
            padding: 10px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
            margin: 10px;
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
    </style>
</head>
<body>
    <div class="container">
        <h1>处理药品信息</h1>
        
        <% 
            // 获取表单参数
            String idStr = request.getParameter("id");
            String medicineName = request.getParameter("medicine_name");
            String category = request.getParameter("category");
            String specification = request.getParameter("specification");
            String stockQuantityStr = request.getParameter("stock_quantity");
            String unitPriceStr = request.getParameter("unit_price");
            String manufacturer = request.getParameter("manufacturer");
            String expiryDate = request.getParameter("expiry_date");
            String stockWarningLevelStr = request.getParameter("stock_warning_level");
            
            // 数据库连接信息
            String url = "jdbc:mysql://localhost:3306/hms";
            String username = "root";
            String password = "123456";
            
            Connection conn = null;
            PreparedStatement pstmt = null;
            
            try {
                // 加载驱动
                Class.forName("com.mysql.cj.jdbc.Driver");
                // 建立连接
                conn = DriverManager.getConnection(url, username, password);
                
                if (idStr == null || idStr.isEmpty()) {
                    // 新增药品
                    String sql = "INSERT INTO medicines (medicine_name, category, specification, stock_quantity, unit_price, manufacturer, expiry_date, stock_warning_level) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, medicineName);
                    pstmt.setString(2, category);
                    pstmt.setString(3, specification);
                    pstmt.setInt(4, Integer.parseInt(stockQuantityStr));
                    pstmt.setDouble(5, Double.parseDouble(unitPriceStr));
                    pstmt.setString(6, manufacturer);
                    pstmt.setDate(7, Date.valueOf(expiryDate));
                    pstmt.setInt(8, Integer.parseInt(stockWarningLevelStr));
                    
                    int rows = pstmt.executeUpdate();
                    if (rows > 0) {
                        out.println("<div class='message success'>");
                        out.println("<i class='fas fa-check-circle'></i> 药品添加成功！");
                        out.println("</div>");
                    } else {
                        out.println("<div class='message error'>");
                        out.println("<i class='fas fa-exclamation-circle'></i> 药品添加失败！");
                        out.println("</div>");
                    }
                } else {
                    // 更新药品
                    int id = Integer.parseInt(idStr);
                    String sql = "UPDATE medicines SET medicine_name = ?, category = ?, specification = ?, stock_quantity = ?, unit_price = ?, manufacturer = ?, expiry_date = ?, stock_warning_level = ? WHERE id = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, medicineName);
                    pstmt.setString(2, category);
                    pstmt.setString(3, specification);
                    pstmt.setInt(4, Integer.parseInt(stockQuantityStr));
                    pstmt.setDouble(5, Double.parseDouble(unitPriceStr));
                    pstmt.setString(6, manufacturer);
                    pstmt.setDate(7, Date.valueOf(expiryDate));
                    pstmt.setInt(8, Integer.parseInt(stockWarningLevelStr));
                    pstmt.setInt(9, id);
                    
                    int rows = pstmt.executeUpdate();
                    if (rows > 0) {
                        out.println("<div class='message success'>");
                        out.println("<i class='fas fa-check-circle'></i> 药品更新成功！");
                        out.println("</div>");
                    } else {
                        out.println("<div class='message error'>");
                        out.println("<i class='fas fa-exclamation-circle'></i> 药品更新失败！");
                        out.println("</div>");
                    }
                }
                
                // 延迟跳转回列表页
                out.println("<script>");
                out.println("setTimeout(function() { window.location.href = 'medicineList.jsp'; }, 1500);");
                out.println("</script>");
                
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<div class='message error'>");
                out.println("<i class='fas fa-exclamation-circle'></i> 操作失败：" + e.getMessage());
                out.println("</div>");
            } finally {
                // 关闭资源
                try {
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        %>
        
        <div style="margin-top: 20px;">
            <a href="medicineList.jsp" class="btn btn-primary">
                <i class="fas fa-arrow-left"></i> 返回药品列表
            </a>
        </div>
    </div>
</body>
</html>