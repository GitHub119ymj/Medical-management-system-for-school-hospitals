<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.hms.service.AppointmentService" %>
<%
    // 获取冲突解决方案和原始预约信息
    List<AppointmentService.AppointmentConflictSolution> solutions = (List<AppointmentService.AppointmentConflictSolution>) session.getAttribute("conflictSolutions");
    AppointmentService.OriginalAppointment originalAppointment = (AppointmentService.OriginalAppointment) session.getAttribute("originalAppointment");

    // 如果没有解决方案，返回预约页面
    if (solutions == null || solutions.isEmpty() || originalAppointment == null) {
        response.sendRedirect("appointmentForm.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>预约冲突解决方案</title>
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
            max-width: 800px;
            background-color: #ffffff;
            padding: 30px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
            box-sizing: border-box;
            border: 2px solid #00796b;
        }

        /* 标题样式 */
        .title {
            color: #00796b;
            font-size: 24px;
            margin-bottom: 20px;
            font-weight: bold;
            text-align: center;
        }

        /* 原始预约信息样式 */
        .original-appointment {
            background-color: #f5f5f5;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            border-left: 4px solid #ff9800;
        }

        .original-appointment h3 {
            color: #333;
            margin-top: 0;
            margin-bottom: 10px;
        }

        .original-appointment p {
            margin: 5px 0;
            color: #666;
        }

        /* 解决方案列表样式 */
        .solutions-list {
            margin-top: 20px;
        }

        .solution-item {
            background-color: #f9f9f9;
            padding: 20px;
            border-radius: 5px;
            margin-bottom: 15px;
            border-left: 4px solid #2196f3;
            transition: box-shadow 0.3s ease;
        }

        .solution-item:hover {
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .solution-item h3 {
            color: #333;
            margin-top: 0;
            margin-bottom: 10px;
        }

        .solution-item p {
            margin: 5px 0;
            color: #666;
        }

        .solution-type {
            display: inline-block;
            padding: 4px 8px;
            background-color: #2196f3;
            color: white;
            border-radius: 3px;
            font-size: 12px;
            margin-bottom: 10px;
        }

        /* 按钮样式 */
        .btn {
            padding: 10px 20px;
            background-color: #00796b;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-right: 10px;
            transition: background-color 0.3s ease;
        }

        .btn:hover {
            background-color: #004d40;
        }

        .btn-secondary {
            background-color: #6c757d;
        }

        .btn-secondary:hover {
            background-color: #545b62;
        }

        /* 按钮容器 */
        .button-container {
            text-align: center;
            margin-top: 30px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="title">预约冲突解决方案</h1>

        <!-- 原始预约信息 -->
        <div class="original-appointment">
            <h3>原始预约信息</h3>
            <p><strong>预约类型：</strong><%= originalAppointment.getAppointmentType().equals("doctor") ? "医生预约" : "体检预约" %></p>
            <% if (originalAppointment.getAppointmentType().equals("doctor")) { %>
                <p><strong>医生ID：</strong><%= originalAppointment.getDoctorId() %></p>
            <% } %>
            <p><strong>预约时间：</strong><%= originalAppointment.getAppointmentDate() %></p>
            <p><strong>预约目的：</strong><%= originalAppointment.getPurpose() %></p>
            <p><strong>紧急度：</strong><%= originalAppointment.getUrgency() %></p>
        </div>

        <!-- 冲突解决方案 -->
        <h2>可用解决方案</h2>
        <div class="solutions-list">
            <% for (int i = 0; i < solutions.size(); i++) { %>
                <div class="solution-item">
                    <span class="solution-type"><%= solutions.get(i).getType() %></span>
                    <h3>方案 <%= i + 1 %></h3>
                    <p><strong>时间：</strong><%= solutions.get(i).getTime() %></p>
                    <% if (solutions.get(i).getDoctorName() != null) { %>
                        <p><strong>医生：</strong><%= solutions.get(i).getDoctorName() %></p>
                    <% } %>
                    <p><strong>目的：</strong><%= solutions.get(i).getPurpose() %></p>
                    <form action="../confirmSolution" method="post" style="display: inline;">
                        <input type="hidden" name="solutionIndex" value="<%= i %>" />
                        <input type="submit" value="选择此方案" class="btn" />
                    </form>
                </div>
            <% } %>
        </div>

        <!-- 返回按钮 -->
        <div class="button-container">
            <a href="appointmentForm.jsp" class="btn btn-secondary">返回重新预约</a>
        </div>
    </div>
</body>
</html>