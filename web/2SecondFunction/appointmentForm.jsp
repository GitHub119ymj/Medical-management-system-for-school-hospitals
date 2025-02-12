<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>预约医生或体检</title>
    <style>
        /* 页面整体样式 */
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        /* 外层容器样式 */
        .container {
            width: 100%;
            max-width: 500px;
            background-color: #ffffff;
            padding: 30px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
            text-align: center; /* 居中对齐内容 */
            box-sizing: border-box;
            border: 2px solid #00796b; /* 添加绿色边框 */
        }

        /* 标题样式 */
        .title {
            color: #00796b;
            font-size: 24px;
            margin-bottom: 20px;
            font-weight: bold;
        }

        /* 表单标签和输入框 */
        label {
            font-size: 16px;
            margin-bottom: 8px;
            display: block;
            color: #333;
        }

        select, input[type="text"], input[type="datetime-local"] {
            width: 90%; /* 调整宽度 */
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
            border: 1px solid #ccc;
            font-size: 16px;
            box-sizing: border-box;
        }

        /* 提交按钮 */
        input[type="submit"] {
            width: 90%;
            padding: 14px;
            background-color: #00796b;
            color: white;
            font-size: 18px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        input[type="submit"]:hover {
            background-color: #004d40;
        }

        /* 隐藏医生预约相关选项 */
        #doctorAppointment {
            display: none;
        }
    </style>
</head>
<body>

<div class="container">
    <!-- 页首标题 -->
    <h1 class="title">预约医生或体检</h1>

    <!-- 表单部分 -->
    <form action="processAppointment.jsp" method="post">
        <!-- 选择预约类型 -->
        <label for="appointmentType">选择预约类型：</label>
        <select name="appointmentType" id="appointmentType" required>
            <option value="doctor">预约医生</option>
            <option value="checkup">预约体检</option>
        </select>

        <!-- 选择医生（仅当预约类型为“医生”时） -->
        <div id="doctorAppointment">
            <label for="doctorId">选择医生：</label>
            <select name="doctorId" id="doctorId">
                <%
                    // 从数据库加载医生信息
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");
                        String query = "SELECT id, doctor_name FROM medical_staff WHERE role = 'doctor'";
                        PreparedStatement stmt = conn.prepareStatement(query);
                        ResultSet rs = stmt.executeQuery();

                        if (!rs.isBeforeFirst()) {
                            // 如果没有医生记录
                %>
                <option value="">暂无医生可预约</option>
                <%
                } else {
                    // 遍历医生数据
                    while (rs.next()) {
                %>
                <option value="<%= rs.getInt("id") %>"><%= rs.getString("doctor_name") %></option>
                <%
                            }
                        }
                        conn.close();
                    } catch (Exception e) {
                        out.println("<option value=''>加载失败，请稍后重试</option>");
                        e.printStackTrace();
                    }
                %>
            </select>
        </div>

        <!-- 选择预约时间 -->
        <label for="appointmentDate">选择预约日期：</label>
        <input type="datetime-local" name="appointmentDate" id="appointmentDate" required>

        <!-- 预约目的 -->
        <label for="purpose">预约目的：</label>
        <input type="text" name="purpose" id="purpose" placeholder="例如：体检、感冒等" required>

        <!-- 提交按钮 -->
        <input type="submit" value="提交预约">
    </form>
    <!-- 查看预约记录链接 -->
    <a href="appointmentHistory.jsp" class="view-records">查看预约记录</a>
</div>

<script>
    // 根据预约类型显示相应的选项
    document.getElementById('appointmentType').addEventListener('change', function() {
        if (this.value === 'doctor') {
            document.getElementById('doctorAppointment').style.display = 'block';
        } else {
            document.getElementById('doctorAppointment').style.display = 'none';
        }
    });
</script>

</body>
</html>

