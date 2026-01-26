<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>添加药品</title>
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
            max-width: 800px;
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
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        input[type="text"],
        input[type="number"],
        input[type="date"],
        select,
        textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        input[type="number"] {
            width: 200px;
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
        .form-actions {
            margin-top: 30px;
            display: flex;
            gap: 10px;
            justify-content: center;
        }
        .footer {
            margin-top: 30px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>添加新药品</h1>
        
        <form action="processMedicine.jsp" method="post">
            <div class="form-group">
                <label for="medicine_name">药品名称 *</label>
                <input type="text" id="medicine_name" name="medicine_name" required>
            </div>
            
            <div class="form-group">
                <label for="category">类别 *</label>
                <select id="category" name="category" required>
                    <option value="处方药">处方药</option>
                    <option value="非处方药">非处方药</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="specification">规格 *</label>
                <input type="text" id="specification" name="specification" required placeholder="如500mg*20片">
            </div>
            
            <div class="form-group">
                <label for="stock_quantity">库存数量 *</label>
                <input type="number" id="stock_quantity" name="stock_quantity" required min="0">
            </div>
            
            <div class="form-group">
                <label for="unit_price">单价 *</label>
                <input type="number" id="unit_price" name="unit_price" required min="0" step="0.01">
            </div>
            
            <div class="form-group">
                <label for="manufacturer">生产厂家 *</label>
                <input type="text" id="manufacturer" name="manufacturer" required>
            </div>
            
            <div class="form-group">
                <label for="expiry_date">有效期 *</label>
                <input type="date" id="expiry_date" name="expiry_date" required>
            </div>
            
            <div class="form-group">
                <label for="stock_warning_level">库存预警阈值</label>
                <input type="number" id="stock_warning_level" name="stock_warning_level" value="10" min="1">
            </div>
            
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> 保存
                </button>
                <button type="reset" class="btn btn-secondary">
                    <i class="fas fa-redo"></i> 重置
                </button>
            </div>
        </form>
        
        <div class="footer">
            <a href="medicineList.jsp" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> 返回
            </a>
        </div>
    </div>
</body>
</html>