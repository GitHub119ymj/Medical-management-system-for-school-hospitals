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

@WebServlet("/confirmSolution")
public class ConfirmSolutionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 设置请求和响应的字符编码
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        // 获取用户选择的解决方案索引
        int solutionIndex = Integer.parseInt(request.getParameter("solutionIndex"));

        // 获取冲突解决方案和原始预约信息
        HttpSession session = request.getSession();
        List<AppointmentService.AppointmentConflictSolution> solutions = (List<AppointmentService.AppointmentConflictSolution>) session.getAttribute("conflictSolutions");
        AppointmentService.OriginalAppointment originalAppointment = (AppointmentService.OriginalAppointment) session.getAttribute("originalAppointment");

        // 如果没有解决方案或原始预约信息，返回预约页面
        if (solutions == null || solutions.isEmpty() || originalAppointment == null || solutionIndex >= solutions.size()) {
            response.sendRedirect("2SecondFunction/appointmentForm.jsp");
            return;
        }

        // 获取选择的解决方案
        AppointmentService.AppointmentConflictSolution selectedSolution = solutions.get(solutionIndex);

        Connection conn = null;
        boolean success = false;

        try {
            // 连接数据库
            conn = DBUtil.getConnection();
            DBUtil.startTransaction(conn);

            // 创建新的预约
            AppointmentService.createAppointment(
                    originalAppointment.getPatientId(),
                    selectedSolution.getDoctorId() != null ? selectedSolution.getDoctorId() : originalAppointment.getDoctorId(),
                    selectedSolution.getTime(),
                    originalAppointment.getAppointmentType(),
                    selectedSolution.getPurpose());

            // 检查是否需要级联调整后续预约（仅当选择调整时长方案时）
            if (selectedSolution.getType().equals("调整时长") && originalAppointment.getDoctorId() != null) {
                AppointmentService.cascadeAdjustAppointments(
                        Integer.parseInt(originalAppointment.getDoctorId()),
                        originalAppointment.getAppointmentDate());
            }

            success = true;
            DBUtil.commitTransaction(conn);

            // 清除session中的临时数据
            session.removeAttribute("conflictSolutions");
            session.removeAttribute("originalAppointment");
            session.removeAttribute("errorMessage");

            // 跳转到预约确认页面
            response.sendRedirect("2SecondFunction/appointmentConfirmation.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                DBUtil.rollbackTransaction(conn);
            }
            // 将错误信息存储到session中
            session.setAttribute("errorMessage", "预约失败：" + e.getMessage());
            // 跳回冲突解决方案页面
            response.sendRedirect("2SecondFunction/conflictResolution.jsp");
        } finally {
            DBUtil.close(conn);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}