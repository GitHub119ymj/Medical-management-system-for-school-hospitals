<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    // 获取用户选择的解决方案索引
    int solutionIndex = Integer.parseInt(request.getParameter("solutionIndex"));

    // 获取冲突解决方案和原始预约信息
    List<smartAppointmentProcess.AppointmentConflictSolution> solutions = (List<smartAppointmentProcess.AppointmentConflictSolution>) session.getAttribute("conflictSolutions");
    smartAppointmentProcess.OriginalAppointment originalAppointment = (smartAppointmentProcess.OriginalAppointment) session.getAttribute("originalAppointment");

    // 如果没有解决方案或原始预约信息，返回预约页面
    if (solutions == null || solutions.isEmpty() || originalAppointment == null || solutionIndex >= solutions.size()) {
        response.sendRedirect("appointmentForm.jsp");
        return;
    }

    // 获取选择的解决方案
    smartAppointmentProcess.AppointmentConflictSolution selectedSolution = solutions.get(solutionIndex);

    Connection conn = null;
    PreparedStatement pstmt = null;
    boolean success = false;

    try {
        // 连接数据库
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");
        conn.setAutoCommit(false); // 开始事务

        // 创建新的预约
        String sql = "INSERT INTO appointments (patient_id, doctor_id, appointment_date, status, purpose) VALUES (?, ?, ?, '已预约', ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, originalAppointment.getPatientId());

        if (originalAppointment.getAppointmentType().equals("doctor")) {
            if (selectedSolution.getDoctorId() != null) {
                pstmt.setInt(2, Integer.parseInt(selectedSolution.getDoctorId()));
            } else {
                pstmt.setInt(2, Integer.parseInt(originalAppointment.getDoctorId()));
            }
        } else {
            pstmt.setNull(2, Types.INTEGER);
        }

        pstmt.setString(3, selectedSolution.getTime());
        pstmt.setString(4, selectedSolution.getPurpose());
        pstmt.executeUpdate();

        // 检查是否需要级联调整后续预约（仅当选择调整时长方案时）
        if (selectedSolution.getType().equals("调整时长")) {
            cascadeAdjustAppointments(conn, originalAppointment, selectedSolution);
        }

        success = true;
        conn.commit();

        // 清除session中的临时数据
        session.removeAttribute("conflictSolutions");
        session.removeAttribute("originalAppointment");

        // 跳转到预约确认页面
        response.sendRedirect("appointmentConfirmation.jsp");

    } catch (Exception e) {
        e.printStackTrace();
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        out.println("错误信息: " + e.getMessage());
        out.println("<script>alert('预约失败：" + e.getMessage() + "'); window.history.back();</script>");
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 级联调整后续预约的函数
    void cascadeAdjustAppointments(Connection conn, smartAppointmentProcess.OriginalAppointment originalAppointment, smartAppointmentProcess.AppointmentConflictSolution selectedSolution) throws SQLException, ParseException {
        if (!originalAppointment.getAppointmentType().equals("doctor")) {
            return; // 仅医生预约需要级联调整
        }

        // 获取该医生在冲突时间之后的所有预约
        String getSubsequentAppointmentsSql = "SELECT id, appointment_date FROM appointments WHERE doctor_id = ? AND appointment_date > ? AND status != '已取消' ORDER BY appointment_date";
        PreparedStatement pstmt = conn.prepareStatement(getSubsequentAppointmentsSql);
        pstmt.setInt(1, Integer.parseInt(originalAppointment.getDoctorId()));
        pstmt.setString(2, originalAppointment.getAppointmentDate());
        ResultSet rs = pstmt.executeQuery();

        // 调整后续预约时间（每个预约提前15分钟）
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
        java.util.Calendar cal = java.util.Calendar.getInstance();

        while (rs.next()) {
            int appointmentId = rs.getInt("id");
            String appointmentDate = rs.getString("appointment_date");

            // 将时间提前15分钟
            java.util.Date date = sdf.parse(appointmentDate);
            cal.setTime(date);
            cal.add(java.util.Calendar.MINUTE, -15);
            String newAppointmentDate = sdf.format(cal.getTime());

            // 更新预约时间
            String updateAppointmentSql = "UPDATE appointments SET appointment_date = ? WHERE id = ?";
            PreparedStatement updatePstmt = conn.prepareStatement(updateAppointmentSql);
            updatePstmt.setString(1, newAppointmentDate);
            updatePstmt.setInt(2, appointmentId);
            updatePstmt.executeUpdate();
            updatePstmt.close();
        }
    }
%>