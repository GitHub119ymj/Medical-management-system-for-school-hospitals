<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="zh">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>健康记录汇总</title>
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

    .summary-section {
      margin: 20px auto;
      width: 80%;
      background-color: #fff;
      border: 1px solid #ddd;
      box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
      padding: 20px;
      border-radius: 5px;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin: 10px 0;
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
<h1>健康记录汇总</h1>

<%
  Connection conn = null;
  PreparedStatement pstmt = null;
  ResultSet rs = null;

  // 获取学生ID
  String studentId = (String) session.getAttribute("user_id");

  if (studentId != null) {
    try {
      conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");
    } catch (SQLException e) {
      out.println("<p>数据库连接失败，请稍后重试。</p>");
      e.printStackTrace();
    }
  }
%>

<!-- 最近的体检报告 -->
<div class="summary-section">
  <h2>最近的体检报告</h2>
  <table>
    <thead>
    <tr>
      <th>体检日期</th>
      <th>身高 (cm)</th>
      <th>体重 (kg)</th>
      <th>血压</th>
      <th>视力</th>
    </tr>
    </thead>
    <tbody>
    <%
      if (conn != null) {
        try {
          String checkupQuery = "SELECT checkup_date, height, weight, blood_pressure, vision " +
                  "FROM health_checkups WHERE student_id = ? ORDER BY checkup_date DESC LIMIT 1";
          pstmt = conn.prepareStatement(checkupQuery);
          pstmt.setString(1, studentId);
          rs = pstmt.executeQuery();

          if (rs.next()) {
    %>
    <tr>
      <td><%= rs.getString("checkup_date") %></td>
      <td><%= rs.getFloat("height") %></td>
      <td><%= rs.getFloat("weight") %></td>
      <td><%= rs.getString("blood_pressure") %></td>
      <td><%= rs.getString("vision") %></td>
    </tr>
    <%
    } else {
    %>
    <tr>
      <td colspan="5">暂无体检记录。</td>
    </tr>
    <%
      }
    } catch (SQLException e) {
      e.printStackTrace();
    %>
    <tr>
      <td colspan="5">加载数据失败，请稍后重试。</td>
    </tr>
    <%
        }
      }
    %>
    </tbody>
  </table>
</div>

<!-- 最近的运动记录 -->
<div class="summary-section">
  <h2>最近的运动记录</h2>
  <table>
    <thead>
    <tr>
      <th>活动日期</th>
      <th>活动名称</th>
      <th>持续时间 (分钟)</th>
      <th>健康效果</th>
    </tr>
    </thead>
    <tbody>
    <%
      if (conn != null) {
        try {
          String activityQuery = "SELECT activity_date, activity_name, duration, health_effect " +
                  "FROM sports_activities WHERE student_id = ? ORDER BY activity_date DESC LIMIT 1";
          pstmt = conn.prepareStatement(activityQuery);
          pstmt.setString(1, studentId);
          rs = pstmt.executeQuery();

          if (rs.next()) {
    %>
    <tr>
      <td><%= rs.getString("activity_date") %></td>
      <td><%= rs.getString("activity_name") %></td>
      <td><%= rs.getInt("duration") %></td>
      <td><%= rs.getString("health_effect") %></td>
    </tr>
    <%
    } else {
    %>
    <tr>
      <td colspan="4">暂无运动记录。</td>
    </tr>
    <%
      }
    } catch (SQLException e) {
      e.printStackTrace();
    %>
    <tr>
      <td colspan="4">加载数据失败，请稍后重试。</td>
    </tr>
    <%
        }
      }
    %>
    </tbody>
  </table>
</div>

<!-- 最近的就诊记录 -->
<div class="summary-section">
  <h2>最近的就诊记录</h2>
  <table>
    <thead>
    <tr>
      <th>就诊日期</th>
      <th>诊断信息</th>
      <th>处方</th>
      <th>备注</th>
    </tr>
    </thead>
    <tbody>
    <%
      if (conn != null) {
        try {
          String medicalQuery = "SELECT date, diagnosis, prescription, remarks " +
                  "FROM medical_records WHERE patient_id = ? ORDER BY date DESC LIMIT 1";
          pstmt = conn.prepareStatement(medicalQuery);
          pstmt.setString(1, studentId);
          rs = pstmt.executeQuery();

          if (rs.next()) {
    %>
    <tr>
      <td><%= rs.getString("date") %></td>
      <td><%= rs.getString("diagnosis") %></td>
      <td><%= rs.getString("prescription") %></td>
      <td><%= rs.getString("remarks") %></td>
    </tr>
    <%
    } else {
    %>
    <tr>
      <td colspan="4">暂无就诊记录。</td>
    </tr>
    <%
      }
    } catch (SQLException e) {
      e.printStackTrace();
    %>
    <tr>
      <td colspan="4">加载数据失败，请稍后重试。</td>
    </tr>
    <%
        }
      }
    %>
    </tbody>
  </table>
</div>

<%
  if (rs != null) rs.close();
  if (pstmt != null) pstmt.close();
  if (conn != null) conn.close();
%>

<a href="../studentIndex.jsp" class="return-btn">返回选择功能页面</a>
</body>
</html>

