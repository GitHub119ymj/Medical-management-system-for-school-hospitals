package com.hms.servlet;

import com.hms.service.AppointmentService;
import com.hms.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/smartAppointmentProcess")
public class SmartAppointmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 设置请求和响应的字符编码
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        // 获取患者ID和其他预约信息
        HttpSession session = request.getSession();
        String patientIdStr = (String) session.getAttribute("user_id");
        if (patientIdStr == null) {
            response.sendRedirect("../login.jsp");
            return;
        }

        int patientId = Integer.parseInt(patientIdStr);
        String appointmentType = request.getParameter("appointmentType");
        String doctorIdStr = request.getParameter("doctorId");
        String appointmentDate = request.getParameter("appointmentDate");
        String purpose = request.getParameter("purpose");
        String urgencyStr = request.getParameter("urgency");

        Connection conn = null;
        boolean success = false;

        try {
            // 连接数据库
            conn = DBUtil.getConnection();
            DBUtil.startTransaction(conn);

            // 检查学生每月预约次数限制（5次/月）
            if (!AppointmentService.checkMonthlyLimit(patientId)) {
                throw new Exception("您本月预约次数已达上限（5次），请下月再预约。");
            }

            // 检查是否连续两天约同一医生
            if ("doctor".equals(appointmentType) && doctorIdStr != null) {
                int doctorId = Integer.parseInt(doctorIdStr);
                if (!AppointmentService.checkConsecutiveDays(patientId, doctorId, appointmentDate)) {
                    throw new Exception("不能连续两天预约同一医生，请选择其他日期。");
                }
            }

            // 检查医生当天预约人数（限30人/天，紧急可超额）
            if ("doctor".equals(appointmentType) && doctorIdStr != null) {
                int doctorId = Integer.parseInt(doctorIdStr);
                int urgency = (urgencyStr != null) ? Integer.parseInt(urgencyStr) : 1;
                if (!AppointmentService.checkDoctorDailyLimit(doctorId, appointmentDate, urgency)) {
                    throw new Exception("该医生当天预约已满（30人），紧急情况可超额预约。");
                }
            }

            // 计算患者优先级
            int staffId = 0;
            if ("doctor".equals(appointmentType) && doctorIdStr != null) {
                staffId = Integer.parseInt(doctorIdStr);
            }
            double priority = AppointmentService.calculatePriority(patientId, urgencyStr, staffId);

            // 检查是否存在冲突
            boolean hasConflict = false;
            if ("doctor".equals(appointmentType) && doctorIdStr != null) {
                hasConflict = AppointmentService.checkConflict(doctorIdStr, appointmentDate, appointmentType);
            } else if ("checkup".equals(appointmentType)) {
                hasConflict = AppointmentService.checkConflict(null, appointmentDate, appointmentType);
            }

            // 体检时间检查（仅对体检预约有效）
            if ("checkup".equals(appointmentType)) {
                AppointmentService.checkCheckupTime(appointmentDate, hasConflict);
            }

            if (hasConflict) {
                // 处理冲突
                List<AppointmentService.AppointmentConflictSolution> solutions = AppointmentService.resolveConflict(
                        doctorIdStr, appointmentDate, appointmentType, patientId, priority);

                // 创建原始预约信息对象
                AppointmentService.OriginalAppointment originalAppointment = new AppointmentService.OriginalAppointment(
                        patientId, doctorIdStr, appointmentDate, appointmentType, purpose, urgencyStr);

                // 将解决方案和原始预约信息存储到session中
                session.setAttribute("conflictSolutions", solutions);
                session.setAttribute("originalAppointment", originalAppointment);

                // 跳转到冲突解决方案页面
                response.sendRedirect("2SecondFunction/conflictResolution.jsp");
            } else {
                // 无冲突，直接创建预约
                AppointmentService.createAppointment(patientId, doctorIdStr, appointmentDate, appointmentType, purpose);
                success = true;
            }

            if (success) {
                DBUtil.commitTransaction(conn);
                // 跳转到预约确认页面
                response.sendRedirect("2SecondFunction/appointmentConfirmation.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                DBUtil.rollbackTransaction(conn);
            }
            // 将错误信息存储到session中
            session.setAttribute("errorMessage", "预约失败：" + e.getMessage());
            // 跳回预约页面
            response.sendRedirect("2SecondFunction/appointmentForm.jsp");
        } finally {
            DBUtil.close(conn);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}