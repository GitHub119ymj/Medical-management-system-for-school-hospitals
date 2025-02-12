<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>体检历史记录</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f4f4f9;
      margin: 0;
      padding: 20px;
      text-align: center;
    }

    h1 {
      color: #00796b;
      margin-bottom: 20px;
    }

    table {
      width: 80%;
      margin: 0 auto;
      border-collapse: collapse;
      box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
      background-color: #fff;
    }

    th, td {
      padding: 10px;
      border: 1px solid #ddd;
      text-align: center;
    }

    th {
      background-color: #00796b;
      color: #fff;
    }

    tr:nth-child(even) {
      background-color: #f9f9f9;
    }

    .return-btn {
      display: inline-block;
      margin-top: 20px;
      padding: 10px 20px;
      background-color: #00796b;
      color: #fff;
      text-decoration: none;
      border-radius: 5px;
    }

    .return-btn:hover {
      background-color: #005f56;
    }
  </style>
</head>
<body>
<h1>体检历史记录</h1>

<table>
  <thead>
  <tr>
    <th>体检日期</th>
    <th>身高 (cm)</th>
    <th>体重 (kg)</th>
    <th>血压</th>
    <th>视力</th>
    <th>备注</th>
  </tr>
  </thead>
  <tbody>
  <%
    String patientId = (String) session.getAttribute("user_id");

    if (patientId != null) {
      Connection conn = null;
      PreparedStatement pstmt = null;
      ResultSet rs = null;

      try {
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");
        String query = "SELECT checkup_date, height, weight, blood_pressure, vision, remarks " +
                "FROM health_checkups WHERE student_id = ? ORDER BY checkup_date DESC";
        pstmt = conn.prepareStatement(query);
        pstmt.setString(1, patientId);
        rs = pstmt.executeQuery();

        if (!rs.isBeforeFirst()) {
  %>
  <tr>
    <td colspan="6">暂无体检记录。</td>
  </tr>
  <%
    }

    while (rs.next()) {
  %>
  <tr>
    <td><%= rs.getString("checkup_date") %></td>
    <td><%= rs.getString("height") %></td>
    <td><%= rs.getString("weight") %></td>
    <td><%= rs.getString("blood_pressure") %></td>
    <td><%= rs.getString("vision") %></td>
    <td><%= rs.getString("remarks") %></td>
  </tr>
  <%
    }
  } catch (SQLException e) {
    e.printStackTrace();
  %>
  <tr>
    <td colspan="6">加载数据失败，请稍后重试。</td>
  </tr>
  <%
    } finally {
      if (rs != null) rs.close();
      if (pstmt != null) pstmt.close();
      if (conn != null) conn.close();
    }
  } else {
  %>
  <tr>
    <td colspan="6">无法获取患者信息，请登录后查看体检记录。</td>
  </tr>
  <%
    }
  %>
  </tbody>
</table>

<a href="../studentIndex.jsp" class="return-btn">返回选择功能页面</a>
</body>
</html>

