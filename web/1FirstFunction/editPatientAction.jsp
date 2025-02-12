<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
    String studentId = (String) session.getAttribute("user_id");
    String name = request.getParameter("name");
    String gender = request.getParameter("gender");
    String age = request.getParameter("age");
    String phone = request.getParameter("phone");
    String className = request.getParameter("class");
    String address = request.getParameter("address");
    String password = request.getParameter("password");  // 获取修改后的密码

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String id = null; // 用来存储通过 student_id 查到的患者 id

    try {
        // 连接数据库
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");

        // 根据 student_id 查询患者的 id
        String selectSql = "SELECT id FROM patients WHERE student_id = ?";
        pstmt = conn.prepareStatement(selectSql);
        pstmt.setString(1, studentId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            id = rs.getString("id"); // 获取对应的患者 id
        } else {
            out.println("<script>alert('未找到该学号对应的患者信息。'); window.history.back();</script>");
            return;
        }

        // 检查密码是否为空，如果密码不为空则进行密码更新
        if (password != null && !password.trim().isEmpty()) {
            // 进行密码强度限制：长度必须在 6 到 10 位之间，且包含字母、数字和符号
            if (password.length() < 6 || password.length() > 10 ||
                    !password.matches(".*[A-Za-z].*") ||  // 包含字母
                    !password.matches(".*[0-9].*") ||    // 包含数字
                    !password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?].*")) {  // 包含符号
                out.println("<script>alert('密码必须在6到10个字符之间，包含字母、数字和符号。'); window.history.back();</script>");
                return;
            }
        }

        // 更新患者信息
        String updateSql = "UPDATE patients SET name = ?, gender = ?, age = ?, phone = ?, student_id = ?, class = ?, address = ?";
        if (password != null && !password.trim().isEmpty()) {
            updateSql += ", password = ?"; // 如果密码不为空，添加密码更新
        }
        updateSql += " WHERE id = ?"; // 根据 id 更新患者信息

        pstmt = conn.prepareStatement(updateSql);
        pstmt.setString(1, name);
        pstmt.setString(2, gender);
        pstmt.setInt(3, Integer.parseInt(age));
        pstmt.setString(4, phone);
        pstmt.setString(5, studentId);
        pstmt.setString(6, className);
        pstmt.setString(7, address);

        if (password != null && !password.trim().isEmpty()) {
            pstmt.setString(8, password);  // 设置密码
            pstmt.setString(9, id);         // 设置 id 用于 WHERE 子句
        } else {
            pstmt.setString(8, id);         // 如果没有修改密码，则只设置 id
        }

        int rowsAffected = pstmt.executeUpdate(); // 执行更新操作

        // 显示修改结果
        if (rowsAffected > 0) {
            out.println("<div class='success-message'>");
            out.println("<h2>信息修改成功！</h2>");
            out.println("<p><strong>姓名：</strong>" + name + "</p>");
            out.println("<p><strong>性别：</strong>" + gender + "</p>");
            out.println("<p><strong>年龄：</strong>" + age + "</p>");
            out.println("<p><strong>电话：</strong>" + phone + "</p>");
            out.println("<p><strong>班级：</strong>" + className + "</p>");
            out.println("<p><strong>地址：</strong>" + address + "</p>");
            out.println("<a href='../studentIndex.jsp' class='return-btn'>返回选择功能页面</a>");
            out.println("</div>");
        } else {
            out.println("<script>alert('修改失败，请稍后再试。'); window.history.back();</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('系统错误，请稍后再试。'); window.history.back();</script>");
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<!-- 添加CSS样式 -->
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
        height: 100vh; /* 满屏高度 */
    }

    /* 主容器 */
    .container {
        width: 100%; /* 更宽的容器 */
        max-width: 1000px; /* 最大宽度设置为1000px */
        margin: 0 auto;
        background-color: #ffffff;
        padding: 30px; /* 增加内边距 */
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        border-radius: 8px;
    }

    /* 修改成功提示 */
    .success-message {
        color: #333;
        padding: 30px; /* 增加内边距 */
        border-radius: 8px;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        background-color: #f9f9f9;
    }

    .success-message h2 {
        color: #00796b;
        font-size: 28px;
        text-align: center;
        margin-bottom: 20px;
    }

    /* 信息项 */
    .info-item {
        display: flex;
        justify-content: space-between;
        font-size: 20px; /* 调整字号 */
        margin-bottom: 20px;
        padding: 12px;
        background-color: #f1f1f1;
        border-radius: 5px;
    }

    .info-item strong {
        color: #00796b;
        width: 100px; /* 固定宽度，保证冒号对齐 */
        text-align: right; /* 冒号对齐 */
    }

    /* 返回按钮 */
    .return-btn {
        display: inline-block;
        background-color: #00796b;
        color: white;
        padding: 14px 28px;
        border-radius: 5px;
        text-align: center;
        font-size: 18px;
        margin-top: 30px;
        text-decoration: none;
    }

    .return-btn:hover {
        background-color: #004d40;
    }

    /* 响应式调整 */
    @media (max-width: 768px) {
        .container {
            width: 100%; /* 在小屏设备上宽度更大 */
        }
    }
</style>





