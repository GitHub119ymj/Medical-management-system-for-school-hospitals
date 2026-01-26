package com.hms.service;

import com.hms.util.DBUtil;

import java.sql.*;
import java.util.*;
import java.text.*;

public class AppointmentService {

    // 预约类定义
    public static class Appointment {
        private int id;
        private int patientId;
        private int staffId;
        private String appointmentDate;
        private String appointmentType;
        private String purpose;
        private String status;
        private int urgency;

        // Getters and Setters
        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public int getPatientId() { return patientId; }
        public void setPatientId(int patientId) { this.patientId = patientId; }
        public int getStaffId() { return staffId; }
        public void setStaffId(int staffId) { this.staffId = staffId; }
        public String getAppointmentDate() { return appointmentDate; }
        public void setAppointmentDate(String appointmentDate) { this.appointmentDate = appointmentDate; }
        public String getAppointmentType() { return appointmentType; }
        public void setAppointmentType(String appointmentType) { this.appointmentType = appointmentType; }
        public String getPurpose() { return purpose; }
        public void setPurpose(String purpose) { this.purpose = purpose; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public int getUrgency() { return urgency; }
        public void setUrgency(int urgency) { this.urgency = urgency; }
    }

    // 医生类定义
    public static class Doctor {
        private String id;
        private String name;
        private String department;
        private String title;

        // Getters and Setters
        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getDepartment() { return department; }
        public void setDepartment(String department) { this.department = department; }
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
    }

    // 冲突解决方案类定义
    public static class AppointmentConflictSolution {
        private String solutionType;
        private String description;
        private String details;
        private int conflictingAppointmentId;
        private boolean isForce;

        // Getters and Setters
        public String getSolutionType() { return solutionType; }
        public void setSolutionType(String solutionType) { this.solutionType = solutionType; }
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        public String getDetails() { return details; }
        public void setDetails(String details) { this.details = details; }
        public int getConflictingAppointmentId() { return conflictingAppointmentId; }
        public void setConflictingAppointmentId(int conflictingAppointmentId) { this.conflictingAppointmentId = conflictingAppointmentId; }
        public boolean isIsForce() { return isForce; }
        public void setIsForce(boolean isForce) { this.isForce = isForce; }
    }

    // 原始预约信息类定义
    public static class OriginalAppointment {
        private int patientId;
        private String doctorId;
        private String appointmentDate;
        private String appointmentType;
        private String purpose;
        private String urgency;

        // Constructor
        public OriginalAppointment(int patientId, String doctorId, String appointmentDate, String appointmentType, String purpose, String urgency) {
            this.patientId = patientId;
            this.doctorId = doctorId;
            this.appointmentDate = appointmentDate;
            this.appointmentType = appointmentType;
            this.purpose = purpose;
            this.urgency = urgency;
        }

        // Getters and Setters
        public int getPatientId() { return patientId; }
        public void setPatientId(int patientId) { this.patientId = patientId; }
        public String getDoctorId() { return doctorId; }
        public void setDoctorId(String doctorId) { this.doctorId = doctorId; }
        public String getAppointmentDate() { return appointmentDate; }
        public void setAppointmentDate(String appointmentDate) { this.appointmentDate = appointmentDate; }
        public String getAppointmentType() { return appointmentType; }
        public void setAppointmentType(String appointmentType) { this.appointmentType = appointmentType; }
        public String getPurpose() { return purpose; }
        public void setPurpose(String purpose) { this.purpose = purpose; }
        public String getUrgency() { return urgency; }
        public void setUrgency(String urgency) { this.urgency = urgency; }
    }

    // 查询医生连续接诊数的方法
    public static int getDoctorConsecutiveAppointments(int staffId, String appointmentDate) throws SQLException, ParseException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int consecutiveCount = 0;

        try {
            conn = DBUtil.getConnection();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Date date = sdf.parse(appointmentDate);
            Calendar cal = Calendar.getInstance();
            cal.setTime(date);
            String appointmentDateStr = new SimpleDateFormat("yyyy-MM-dd").format(date);

            // 查询当天该医生在当前预约时间之前的所有预约
            String sql = "SELECT appointment_date FROM appointments " +
                        "WHERE staff_id = ? AND DATE(appointment_date) = ? AND appointment_date < ? " +
                        "AND status != '已取消' ORDER BY appointment_date DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, staffId);
            pstmt.setString(2, appointmentDateStr);
            pstmt.setString(3, appointmentDate);
            rs = pstmt.executeQuery();

            // 检查连续接诊数
            while (rs.next()) {
                Date prevDate = sdf.parse(rs.getString(1));
                Calendar prevCal = Calendar.getInstance();
                prevCal.setTime(prevDate);

                // 检查是否连续（间隔不超过1小时）
                long diff = cal.getTimeInMillis() - prevCal.getTimeInMillis();
                if (diff <= 60 * 60 * 1000) { // 1小时内
                    consecutiveCount++;
                    cal.setTime(prevDate); // 继续检查前一个预约
                } else {
                    break; // 不连续，停止计数
                }
            }
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }

        return consecutiveCount;
    }

    /**
     * 计算患者预约优先级的方法
     * 优先级计算公式：等待天数*0.3 + 紧急度*0.2 + 年级*0.1 - 失约次数*5
     * 额外调整：等待每增加1天+5%优先级，医生连续接诊≥5人时-10%优先级
     * 
     * @param patientId 患者ID
     * @param urgencyStr 紧急度字符串（1-5）
     * @param staffId 医护人员ID（医生ID）
     * @return 计算后的优先级值
     * @throws SQLException 数据库操作异常
     * @throws ParseException 日期解析异常
     */
    public static double calculatePriority(int patientId, String urgencyStr, int staffId) throws SQLException, ParseException {
        double priority = 0.0;
        int urgency = (urgencyStr != null) ? Integer.parseInt(urgencyStr) : 1;

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();

            // 1. 获取等待天数（从上次预约至今的天数）
            String getLastAppointmentSql = "SELECT appointment_date FROM appointments WHERE patient_id = ? AND status != '已取消' ORDER BY appointment_date DESC LIMIT 1";
            pstmt = conn.prepareStatement(getLastAppointmentSql);
            pstmt.setInt(1, patientId);
            rs = pstmt.executeQuery();
            int waitingDays = 0;
            if (rs.next()) {
                Date lastAppointmentDate = rs.getDate("appointment_date");
                Date currentDate = new Date();
                long diffDays = (currentDate.getTime() - lastAppointmentDate.getTime()) / (1000 * 60 * 60 * 24);
                waitingDays = Math.max(0, (int) diffDays); // 确保等待天数不为负
            }

            // 2. 获取年级（从patients表的class字段提取，而不是users表）
            String getGradeSql = "SELECT class FROM patients WHERE user_id = ?";
            pstmt = conn.prepareStatement(getGradeSql);
            pstmt.setInt(1, patientId);
            rs = pstmt.executeQuery();
            int grade = 1;
            if (rs.next()) {
                String className = rs.getString("class");
                if (className != null && className.length() >= 4) {
                    try {
                        grade = Integer.parseInt(className.substring(0, 4));
                    } catch (NumberFormatException e) {
                        grade = 1; // 解析失败时默认年级为1
                    }
                }
            }

            // 3. 获取失约次数（状态为'已取消'的预约视为失约）
            String getNoShowSql = "SELECT COUNT(*) FROM appointments WHERE patient_id = ? AND status = '已取消'";
            pstmt = conn.prepareStatement(getNoShowSql);
            pstmt.setInt(1, patientId);
            rs = pstmt.executeQuery();
            int noShowCount = 0;
            if (rs.next()) {
                noShowCount = rs.getInt(1);
            }

            // 4. 基础优先级计算
            priority = waitingDays * 0.3 + urgency * 0.2 + grade * 0.1 - noShowCount * 5;

            // 5. 医生疲劳度调整（仅对医生预约有效）
            if (staffId > 0) {
                String currentDateTime = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(new Date());
                int consecutiveCount = getDoctorConsecutiveAppointments(staffId, currentDateTime);
                if (consecutiveCount >= 5) {
                    priority *= 0.9; // 连续接诊≥5人，降低10%优先级
                }
            }

            // 6. 等待时间补偿：等待每增加1天，优先级自动+5%
            if (waitingDays > 0) {
                priority *= Math.pow(1.05, waitingDays);
            }

            // 确保优先级不为负
            priority = Math.max(0.0, priority);

        } finally {
            DBUtil.close(conn, pstmt, rs);
        }

        return priority;
    }

    /**
     * 检查体检时间是否符合规定
     * 规则：体检必须在8:00-12:00上午进行，无冲突时不允许下午体检
     * 例外：如果有冲突，可以允许下午体检（13:00-17:00）
     * 
     * @param appointmentDate 预约时间字符串（格式：yyyy-MM-dd'T'HH:mm）
     * @param hasConflict 是否存在时间冲突
     * @return true表示时间有效，false表示时间无效
     * @throws ParseException 日期解析异常
     * @throws IllegalArgumentException 时间不符合规定时抛出
     */
    public static boolean checkCheckupTime(String appointmentDate, boolean hasConflict) throws ParseException {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
        Date date = sdf.parse(appointmentDate);
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        int hour = cal.get(Calendar.HOUR_OF_DAY);

        // 体检时间规则：无冲突时必须在上午8:00-12:00
        if (hour < 8 || hour >= 12) {
            if (!hasConflict) {
                // 无冲突时，上午以外的时间不允许体检
                throw new IllegalArgumentException("体检必须在上午8:00-12:00进行，请选择其他时间。");
            }
            // 有冲突时，允许下午体检（13:00-17:00）
            if (hour < 13 || hour >= 17) {
                throw new IllegalArgumentException("即使有冲突，体检也只能在上午8:00-12:00或下午13:00-17:00进行，请选择其他时间。");
            }
            return true;
        }
        return true; // 上午时间有效
    }

    // 检查冲突的方法
    public static boolean checkConflict(String doctorId, String appointmentDate, String appointmentType) throws SQLException, ParseException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();

            boolean hasConflict = false;

        if ("doctor".equals(appointmentType)) {
            String checkConflictSql = "SELECT COUNT(*) FROM appointments WHERE staff_id = ? AND appointment_date = ? AND status != '已取消' FOR UPDATE";
            pstmt = conn.prepareStatement(checkConflictSql);
            pstmt.setInt(1, Integer.parseInt(doctorId));
            pstmt.setString(2, appointmentDate);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                hasConflict = rs.getInt(1) > 0;
            }
        } else if ("checkup".equals(appointmentType)) {
            // 体检冲突检查（同一时间段是否有其他体检）
            String checkConflictSql = "SELECT COUNT(*) FROM appointments WHERE staff_id IS NULL AND appointment_date = ? AND status != '已取消' FOR UPDATE";
            pstmt = conn.prepareStatement(checkConflictSql);
            pstmt.setString(1, appointmentDate);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                hasConflict = rs.getInt(1) > 0;
            }

            // 体检时间检查
            checkCheckupTime(appointmentDate, hasConflict);
        }

        return hasConflict;
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }

        return false;
    }

    /**
     * 获取指定医护人员在特定时间之后的所有未取消预约
     * 用于级联重排功能，获取需要重新排序的后续预约
     * 
     * @param staffId 医护人员ID
     * @param appointmentDate 基准时间（格式：yyyy-MM-dd'T'HH:mm）
     * @return 后续预约列表
     * @throws SQLException 数据库操作异常
     * @throws ParseException 日期解析异常
     */
    public static List<Appointment> getFollowUpAppointments(int staffId, String appointmentDate) throws SQLException, ParseException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Appointment> followUpAppointments = new ArrayList<>();

        try {
            conn = DBUtil.getConnection();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Date date = sdf.parse(appointmentDate);

            // 查询该医护人员在当前预约时间之后的所有未取消预约
            String sql = "SELECT * FROM appointments " +
                        "WHERE staff_id = ? AND appointment_date > ? AND status != '已取消' " +
                        "ORDER BY appointment_date ASC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, staffId);
            pstmt.setString(2, appointmentDate);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Appointment appointment = new Appointment();
                appointment.setId(rs.getInt("id"));
                appointment.setPatientId(rs.getInt("patient_id"));
                appointment.setStaffId(rs.getInt("staff_id"));
                appointment.setAppointmentDate(rs.getString("appointment_date"));
                appointment.setAppointmentType(rs.getString("appointment_type"));
                appointment.setPurpose(rs.getString("purpose"));
                appointment.setStatus(rs.getString("status"));
                appointment.setUrgency(rs.getInt("urgency"));
                followUpAppointments.add(appointment);
            }
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }

        return followUpAppointments;
    }

    /**
     * 验证重排后等待时间增加是否不超过20%
     * 用于级联重排功能，确保调整不会给患者造成过大不便
     * 
     * @param originalAppointment 原始预约信息
     * @param rescheduledAppointment 重排后的预约信息
     * @return true表示等待时间增加在允许范围内，false表示超出范围
     * @throws ParseException 日期解析异常
     */
    public static boolean validateWaitTimeIncrease(Appointment originalAppointment, Appointment rescheduledAppointment) throws ParseException {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
        Date originalDate = sdf.parse(originalAppointment.getAppointmentDate());
        Date rescheduledDate = sdf.parse(rescheduledAppointment.getAppointmentDate());

        long originalWaitTime = originalDate.getTime() - System.currentTimeMillis();
        long rescheduledWaitTime = rescheduledDate.getTime() - System.currentTimeMillis();

        // 如果原始等待时间为负数（已过期），则允许调整
        if (originalWaitTime <= 0) {
            return true;
        }

        // 计算等待时间增加比例
        double increaseRatio = (rescheduledWaitTime - originalWaitTime) / (double) originalWaitTime;

        // 允许等待时间增加不超过20%
        return increaseRatio <= 0.2;
    }

    /**
     * 级联重排后续预约
     * 获取后续预约的优先级并重新排序，验证调整后等待时间增加不超过20%
     * 
     * @param staffId 医护人员ID
     * @param conflictDate 冲突时间（格式：yyyy-MM-dd'T'HH:mm）
     * @throws SQLException 数据库操作异常
     * @throws ParseException 日期解析异常
     */
    public static void cascadeRescheduleAppointments(int staffId, String conflictDate) throws SQLException, ParseException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();

            // 1. 获取冲突时间之后的所有未取消预约
            List<Appointment> followUpAppointments = getFollowUpAppointments(staffId, conflictDate);
            if (followUpAppointments.isEmpty()) {
                return; // 没有后续预约，无需重排
            }

            // 2. 为每个后续预约计算优先级
            List<Map.Entry<Appointment, Double>> appointmentPriorityList = new ArrayList<>();
            for (Appointment appointment : followUpAppointments) {
                double priority = calculatePriority(
                    appointment.getPatientId(),
                    String.valueOf(appointment.getUrgency()),
                    appointment.getStaffId()
                );
                appointmentPriorityList.add(new AbstractMap.SimpleEntry<>(appointment, priority));
            }

            // 3. 按优先级降序排序
            appointmentPriorityList.sort((a, b) -> Double.compare(b.getValue(), a.getValue()));

            // 4. 重新安排时间并验证等待时间增加
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Calendar cal = Calendar.getInstance();
            cal.setTime(sdf.parse(conflictDate));
            cal.add(Calendar.MINUTE, 30); // 从冲突时间后30分钟开始安排

            for (Map.Entry<Appointment, Double> entry : appointmentPriorityList) {
                Appointment originalAppointment = entry.getKey();
                String newAppointmentDate = sdf.format(cal.getTime());

                // 创建重排后的预约对象用于验证
                Appointment rescheduledAppointment = new Appointment();
                rescheduledAppointment.setAppointmentDate(newAppointmentDate);

                // 验证等待时间增加是否不超过20%
                if (validateWaitTimeIncrease(originalAppointment, rescheduledAppointment)) {
                    // 更新预约时间
                    String updateSql = "UPDATE appointments SET appointment_date = ? WHERE id = ?";
                    pstmt = conn.prepareStatement(updateSql);
                    pstmt.setString(1, newAppointmentDate);
                    pstmt.setInt(2, originalAppointment.getId());
                    pstmt.executeUpdate();

                    // 继续下一个时间槽
                    cal.add(Calendar.MINUTE, 30);
                } else {
                    // 如果等待时间增加超过20%，保留原时间
                    continue;
                }
            }
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
    }

    // 检查患者每月预约次数限制
    public static boolean checkMonthlyLimit(int patientId) throws SQLException { 
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT COUNT(*) FROM appointments WHERE patient_id = ? AND MONTH(appointment_date) = MONTH(CURRENT_DATE()) AND YEAR(appointment_date) = YEAR(CURRENT_DATE()) AND status != '已取消'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, patientId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) < 5; // 每月限5次预约
            }
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }

        return true;
    }

    // 检查是否连续两天预约同一医生
    public static boolean checkConsecutiveDays(int patientId, int doctorId, String appointmentDate) throws SQLException, ParseException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Date date = sdf.parse(appointmentDate);
            Calendar cal = Calendar.getInstance();
            cal.setTime(date);
            cal.add(Calendar.DAY_OF_MONTH, -1);
            String yesterday = new SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());

            String sql = "SELECT COUNT(*) FROM appointments WHERE patient_id = ? AND staff_id = ? AND DATE(appointment_date) = ? AND status != '已取消'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, patientId);
            pstmt.setInt(2, doctorId);
            pstmt.setString(3, yesterday);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) == 0; // 没有连续两天预约
            }
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }

        return true;
    }

    // 检查医生当天预约人数限制
    public static boolean checkDoctorDailyLimit(int doctorId, String appointmentDate, int urgency) throws SQLException, ParseException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Date date = sdf.parse(appointmentDate);
            String appointmentDateStr = new SimpleDateFormat("yyyy-MM-dd").format(date);

            String sql = "SELECT COUNT(*) FROM appointments WHERE staff_id = ? AND DATE(appointment_date) = ? AND status != '已取消'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, doctorId);
            pstmt.setString(2, appointmentDateStr);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                int count = rs.getInt(1);
                if (urgency >= 3) {
                    return count < 40; // 紧急情况可预约40人
                } else {
                    return count < 30; // 普通情况限30人
                }
            }
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }

        return true;
    }

    /**
     * 获取可用医生列表
     * 查询medical_staff表中role为'doctor'且status为'active'的医生
     * 
     * @param conn 数据库连接
     * @param appointmentDate 预约时间（格式：yyyy-MM-dd'T'HH:mm）
     * @param appointmentType 预约类型
     * @return 可用医生列表
     * @throws SQLException 数据库操作异常
     */
    public static List<Doctor> getAvailableDoctors(Connection conn, String appointmentDate, String appointmentType) throws SQLException {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Doctor> availableDoctors = new ArrayList<>();

        try {
            // 查询所有可用的医生（从medical_staff表查询，替代原doctors表）
            String sql = "SELECT * FROM medical_staff WHERE role = 'doctor' AND status = 'active'";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Doctor doctor = new Doctor();
                doctor.setId(rs.getString("id"));
                doctor.setName(rs.getString("name"));
                doctor.setDepartment(rs.getString("department"));
                doctor.setTitle(rs.getString("title"));
                availableDoctors.add(doctor);
            }
        } finally {
            DBUtil.close(null, pstmt, rs);
        }

        return availableDoctors;
    }

    // 检查预约冲突
    public static boolean checkConflict(String doctorId, String appointmentDate, String appointmentType) throws SQLException, ParseException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            String sql;
            if ("doctor".equals(appointmentType) && doctorId != null) {
                sql = "SELECT COUNT(*) FROM appointments WHERE staff_id = ? AND appointment_date = ? AND status != '已取消'";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(doctorId));
                pstmt.setString(2, appointmentDate);
            } else if ("checkup".equals(appointmentType)) {
                sql = "SELECT COUNT(*) FROM appointments WHERE staff_id IS NULL AND appointment_date = ? AND status != '已取消'";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, appointmentDate);
            } else {
                return false; // 其他类型不检查冲突
            }

            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }

        return false;
    }

    /**
     * 解决预约冲突的方法
     * 提供多种冲突解决方案，包括优先级对比、换医生、换时间等
     * 
     * @param doctorId 医生ID（体检时为null）
     * @param appointmentDate 预约时间（格式：yyyy-MM-dd'T'HH:mm）
     * @param appointmentType 预约类型（doctor或checkup）
     * @param patientId 当前预约患者ID
     * @param priority 当前患者优先级
     * @return 冲突解决方案列表
     * @throws SQLException 数据库操作异常
     * @throws ParseException 日期解析异常
     */
    public static List<AppointmentConflictSolution> resolveConflict(String doctorId, String appointmentDate, String appointmentType, int patientId, double priority) throws SQLException, ParseException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<AppointmentConflictSolution> solutions = new ArrayList<>();

        try {
            conn = DBUtil.getConnection();
            // 1. 获取冲突的预约信息
            Appointment conflictingAppointment = null;
            if ("doctor".equals(appointmentType) && doctorId != null) {
                conflictingAppointment = getConflictingAppointment(conn, Integer.parseInt(doctorId), appointmentDate);
            } else if ("checkup".equals(appointmentType)) {
                conflictingAppointment = getConflictingAppointment(conn, null, appointmentDate);
            }

            // 2. 方案1：优先级对比 - 高优先级患者优先获得时间槽
            if (conflictingAppointment != null) {
                double conflictingPriority = calculatePriority(
                    conflictingAppointment.getPatientId(), 
                    String.valueOf(conflictingAppointment.getUrgency()),
                    conflictingAppointment.getStaffId()
                );

                if (priority > conflictingPriority) {
                    // 当前患者优先级更高，创建强制预约方案
                    AppointmentConflictSolution forceSolution = new AppointmentConflictSolution();
                    forceSolution.setSolutionType("强制预约");
                    forceSolution.setDescription("您的优先级高于当前预约的患者，系统将为您安排此时间段。");
                    forceSolution.setDetails("原预约患者将被自动重新安排到其他可用时间段。");
                    forceSolution.setConflictingAppointmentId(conflictingAppointment.getId());
                    forceSolution.setIsForce(true);
                    solutions.add(forceSolution);
                }
            }

            // 3. 方案2：换医生（仅适用于医生预约）
            if ("doctor".equals(appointmentType)) {
                List<Doctor> availableDoctors = getAvailableDoctors(conn, appointmentDate, appointmentType);
                for (Doctor doctor : availableDoctors) {
                    if (!doctor.getId().equals(doctorId)) {
                        AppointmentConflictSolution solution = new AppointmentConflictSolution();
                        solution.setSolutionType("换医生");
                        solution.setDescription("预约该医生的该时间段已被占用，建议您选择其他医生。");
                        solution.setDetails("医生：" + doctor.getName() + "，科室：" + doctor.getDepartment() + "，职称：" + doctor.getTitle());
                        solution.setConflictingAppointmentId(conflictingAppointment != null ? conflictingAppointment.getId() : 0);
                        solution.setIsForce(false);
                        solutions.add(solution);
                    }
                }
            }

            // 4. 方案3：换时间
            List<String> availableTimes = getAvailableTimes(conn, doctorId, appointmentDate, appointmentType);
            for (String time : availableTimes) {
                AppointmentConflictSolution solution = new AppointmentConflictSolution();
                solution.setSolutionType("换时间");
                solution.setDescription("该时间段已被占用，建议您选择其他时间。");
                solution.setDetails("推荐时间：" + time);
                solution.setConflictingAppointmentId(conflictingAppointment != null ? conflictingAppointment.getId() : 0);
                solution.setIsForce(false);
                solutions.add(solution);
            }

        } finally {
            DBUtil.close(conn, pstmt, rs);
        }

        return solutions;
    }

    // 创建预约
    public static void createAppointment(int patientId, String doctorId, String appointmentDate, String appointmentType, String purpose) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBUtil.getConnection();
            String sql = "INSERT INTO appointments (patient_id, staff_id, appointment_date, appointment_type, purpose, status, urgency) VALUES (?, ?, ?, ?, ?, '已预约', 1)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, patientId);
            if (doctorId != null) {
                pstmt.setInt(2, Integer.parseInt(doctorId));
            } else {
                pstmt.setNull(2, java.sql.Types.INTEGER);
            }
            pstmt.setString(3, appointmentDate);
            pstmt.setString(4, appointmentType);
            pstmt.setString(5, purpose);
            pstmt.executeUpdate();
        } finally {
            DBUtil.close(conn, pstmt, null);
        }
    }

    // 获取冲突的预约信息
    public static Appointment getConflictingAppointment(Connection conn, Integer staffId, String appointmentDate) throws SQLException {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Appointment conflictingAppointment = null;

        try {
            String sql;
            if (staffId != null) {
                sql = "SELECT * FROM appointments WHERE staff_id = ? AND appointment_date = ? AND status != '已取消'";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, staffId);
                pstmt.setString(2, appointmentDate);
            } else {
                sql = "SELECT * FROM appointments WHERE staff_id IS NULL AND appointment_date = ? AND status != '已取消'";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, appointmentDate);
            }

            rs = pstmt.executeQuery();
            if (rs.next()) {
                conflictingAppointment = new Appointment();
                conflictingAppointment.setId(rs.getInt("id"));
                conflictingAppointment.setPatientId(rs.getInt("patient_id"));
                conflictingAppointment.setStaffId(rs.getInt("staff_id"));
                conflictingAppointment.setAppointmentDate(rs.getString("appointment_date"));
                conflictingAppointment.setAppointmentType(rs.getString("appointment_type"));
                conflictingAppointment.setPurpose(rs.getString("purpose"));
                conflictingAppointment.setStatus(rs.getString("status"));
                conflictingAppointment.setUrgency(rs.getInt("urgency"));
            }
        } finally {
            DBUtil.close(null, pstmt, rs);
        }

        return conflictingAppointment;
    }

    // 验证等待时间增加是否不超过20%
    public static boolean validateWaitTimeIncrease(Appointment originalAppointment, Appointment rescheduledAppointment) throws ParseException {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
        Date originalDate = sdf.parse(originalAppointment.getAppointmentDate());
        Date rescheduledDate = sdf.parse(rescheduledAppointment.getAppointmentDate());

        long originalWaitTime = originalDate.getTime() - System.currentTimeMillis();
        long rescheduledWaitTime = rescheduledDate.getTime() - System.currentTimeMillis();

        // 如果原始等待时间为负数（已过期），则允许调整
        if (originalWaitTime <= 0) {
            return true;
        }

        // 计算等待时间增加比例
        double increaseRatio = (rescheduledWaitTime - originalWaitTime) / (double) originalWaitTime;

        // 允许等待时间增加不超过20%
        return increaseRatio <= 0.2;
    }

    // 解决冲突的方法
    public static List<AppointmentConflictSolution> resolveConflict(String doctorId, String appointmentDate, String appointmentType, int patientId, double priority) throws SQLException, ParseException {
        List<AppointmentConflictSolution> solutions = new ArrayList<>();

        Connection conn = null;

        try {
            conn = DBUtil.getConnection();

            // 获取冲突的预约信息
            Appointment conflictingAppointment = null;
            if ("doctor".equals(appointmentType)) {
                conflictingAppointment = getConflictingAppointment(conn, Integer.parseInt(doctorId), appointmentDate);
            } else if ("checkup".equals(appointmentType)) {
                conflictingAppointment = getConflictingAppointment(conn, null, appointmentDate);
            }

            // 方案1：优先级对比 - 高优先级患者优先
            if (conflictingAppointment != null) {
                double conflictingPriority = calculatePriority(
                    conflictingAppointment.getPatientId(), 
                    String.valueOf(conflictingAppointment.getUrgency()),
                    conflictingAppointment.getStaffId()
                );

                if (priority > conflictingPriority) {
                    // 当前患者优先级更高，创建强制预约方案
                    AppointmentConflictSolution forceSolution = new AppointmentConflictSolution();
                    forceSolution.setSolutionType("强制预约");
                    forceSolution.setDescription("您的优先级高于当前预约的患者，系统将为您安排此时间段。");
                    forceSolution.setDetails("原预约患者将被自动重新安排到其他可用时间段。");
                    forceSolution.setConflictingAppointmentId(conflictingAppointment.getId());
                    forceSolution.setIsForce(true);
                    solutions.add(forceSolution);
                }
            }

            // 方案2：换医生
            if ("doctor".equals(appointmentType)) {
                List<Doctor> availableDoctors = getAvailableDoctors(conn, appointmentDate, appointmentType);
                for (Doctor doctor : availableDoctors) {
                    if (!doctor.getId().equals(doctorId)) {
                        solutions.add(new AppointmentConflictSolution("换医生", appointmentDate, doctor.getName(), doctor.getId(), "常规就诊"));
                        if (solutions.size() >= 1) break; // 只需要1个换医生方案
                    }
                }
            }

            // 方案2：换时间
            List<String> availableTimes = getAvailableTimes(conn, doctorId, appointmentDate, appointmentType);
            for (String time : availableTimes) {
                solutions.add(new AppointmentConflictSolution("换时间", time, null, doctorId, "常规就诊"));
                if (solutions.size() >= 2) break; // 累计2个方案
            }

            // 方案3：调整时长（假设将30分钟预约改为15分钟）
            if ("doctor".equals(appointmentType)) {
                solutions.add(new AppointmentConflictSolution("调整时长", appointmentDate, null, doctorId, "常规就诊（15分钟）"));
            }

            // 如果方案不足3个，补充其他可能的方案
            while (solutions.size() < 3) {
                if ("doctor".equals(appointmentType)) {
                    // 补充换医生方案
                    List<Doctor> availableDoctors = getAvailableDoctors(conn, appointmentDate, appointmentType);
                    for (Doctor doctor : availableDoctors) {
                        boolean exists = false;
                        for (AppointmentConflictSolution sol : solutions) {
                            if (sol.getDoctorId() != null && sol.getDoctorId().equals(doctor.getId())) {
                                exists = true;
                                break;
                            }
                        }
                        if (!exists) {
                            solutions.add(new AppointmentConflictSolution("换医生", appointmentDate, doctor.getName(), doctor.getId(), "常规就诊"));
                            break;
                        }
                    }
                } else {
                    // 体检补充换时间方案
                    List<String> availableTimes2 = getAvailableTimes(conn, doctorId, appointmentDate, appointmentType);
                    for (String time : availableTimes2) {
                        boolean exists = false;
                        for (AppointmentConflictSolution sol : solutions) {
                            if (sol.getTime().equals(time)) {
                                exists = true;
                                break;
                            }
                        }
                        if (!exists) {
                            solutions.add(new AppointmentConflictSolution("换时间", time, null, doctorId, "体检"));
                            break;
                        }
                    }
                }
            }

        } finally {
            DBUtil.close(conn);
        }

        return solutions;
    }

    // 获取可用医生的方法
    private static List<Doctor> getAvailableDoctors(Connection conn, String appointmentDate, String appointmentType) throws SQLException {
        List<Doctor> doctors = new ArrayList<>();
        String datePart = appointmentDate.split("T")[0];

        String getDoctorsSql = "SELECT d.id, d.staff_name, COUNT(a.id) as appointment_count " +
                "FROM medical_staff d LEFT JOIN appointments a ON d.id = a.staff_id AND DATE(a.appointment_date) = ? AND a.status != '已取消' " +
                "WHERE d.role = 'doctor' GROUP BY d.id, d.staff_name HAVING appointment_count < 30 ORDER BY appointment_count ASC";
        PreparedStatement pstmt = conn.prepareStatement(getDoctorsSql);
        pstmt.setString(1, datePart);
        ResultSet rs = pstmt.executeQuery();

        while (rs.next()) {
            doctors.add(new Doctor(rs.getString("id"), rs.getString("staff_name"), rs.getInt("appointment_count")));
        }

        DBUtil.close(null, pstmt, rs);
        return doctors;
    }

    /**
     * 获取可用的预约时间槽
     * 生成当天和第二天的时间槽（8:00-18:00，每30分钟一个槽），并过滤掉已被占用的时间
     * 
     * @param conn 数据库连接
     * @param doctorId 医生ID（体检时为null）
     * @param appointmentDate 原始预约时间（格式：yyyy-MM-dd'T'HH:mm）
     * @param appointmentType 预约类型（doctor或checkup）
     * @return 可用时间槽列表
     * @throws SQLException 数据库操作异常
     * @throws ParseException 日期解析异常
     */
    private static List<String> getAvailableTimes(Connection conn, String doctorId, String appointmentDate, String appointmentType) throws SQLException, ParseException {
        List<String> availableTimes = new ArrayList<>();
        String datePart = appointmentDate.split("T")[0];
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
        Date originalDate = sdf.parse(appointmentDate);

        // 1. 检查当天的可用时间
        String getAppointmentsSql = "SELECT appointment_date FROM appointments WHERE ";
        if ("doctor".equals(appointmentType)) {
            getAppointmentsSql += "staff_id = ? AND ";
        } else {
            getAppointmentsSql += "staff_id IS NULL AND ";
        }
        getAppointmentsSql += "DATE(appointment_date) = ? AND status != '已取消' ORDER BY appointment_date";

        PreparedStatement pstmt = conn.prepareStatement(getAppointmentsSql);
        if ("doctor".equals(appointmentType)) {
            pstmt.setInt(1, Integer.parseInt(doctorId));
            pstmt.setString(2, datePart);
        } else {
            pstmt.setString(1, datePart);
        }
        ResultSet rs = pstmt.executeQuery();

        // 2. 生成当天的时间槽（8:00-18:00，每30分钟一个槽）
        Calendar cal = Calendar.getInstance();
        cal.setTime(originalDate);
        cal.set(Calendar.HOUR_OF_DAY, 8);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);

        Set<String> busyTimes = new HashSet<>();
        while (rs.next()) {
            busyTimes.add(rs.getString("appointment_date"));
        }

        // 3. 寻找当天可用时间槽
        for (int i = 0; i < 20; i++) { // 8:00-18:00共20个30分钟槽
            String timeSlot = sdf.format(cal.getTime());
            if (!busyTimes.contains(timeSlot)) {
                availableTimes.add(timeSlot);
                if (availableTimes.size() >= 2) break; // 只需要2个可用时间
            }
            cal.add(Calendar.MINUTE, 30);
        }

        // 4. 如果当天没有足够的可用时间，检查第二天
        if (availableTimes.size() < 2) {
            cal.add(Calendar.DAY_OF_MONTH, 1);
            datePart = new SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());

            if ("doctor".equals(appointmentType)) {
                pstmt.setInt(1, Integer.parseInt(doctorId));
                pstmt.setString(2, datePart);
            } else {
                pstmt.setString(1, datePart);
            }
            rs = pstmt.executeQuery();

            busyTimes.clear();
            while (rs.next()) {
                busyTimes.add(rs.getString("appointment_date"));
            }

            cal.set(Calendar.HOUR_OF_DAY, 8);
            for (int i = 0; i < 20; i++) {
                String timeSlot = sdf.format(cal.getTime());
                if (!busyTimes.contains(timeSlot)) {
                    availableTimes.add(timeSlot);
                    if (availableTimes.size() >= 2) break;
                }
                cal.add(Calendar.MINUTE, 30);
            }
        }

        DBUtil.close(null, pstmt, rs);
        return availableTimes;
    }

    // 创建预约的方法
    public static void createAppointment(int patientId, String doctorId, String appointmentDate, String appointmentType, String purpose) throws SQLException {
        String sql = "INSERT INTO appointments (patient_id, staff_id, appointment_date, status, purpose) VALUES (?, ?, ?, '已预约', ?)";
        Object[] params;

        if ("doctor".equals(appointmentType)) {
            params = new Object[]{patientId, Integer.parseInt(doctorId), appointmentDate, purpose};
        } else {
            params = new Object[]{patientId, null, appointmentDate, purpose};
        }

        DBUtil.executeUpdate(sql, params);
    }

    // 已废弃，使用cascadeRescheduleAppointments方法替代
    @Deprecated
    public static void cascadeAdjustAppointments(int doctorId, String conflictDate) throws SQLException, ParseException {
        cascadeRescheduleAppointments(doctorId, conflictDate);
    }

    // 检查学生每月预约次数限制（5次/月）
    public static boolean checkMonthlyLimit(int patientId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM");
            String currentMonth = sdf.format(new Date());
            String checkMonthlyLimitSql = "SELECT COUNT(*) FROM appointments WHERE patient_id = ? AND DATE_FORMAT(appointment_date, '%Y-%m') = ? AND status != '已取消'";
            pstmt = conn.prepareStatement(checkMonthlyLimitSql);
            pstmt.setInt(1, patientId);
            pstmt.setString(2, currentMonth);
            rs = pstmt.executeQuery();
            int monthlyCount = 0;
            if (rs.next()) {
                monthlyCount = rs.getInt(1);
            }

            return monthlyCount < 5;
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
    }

    // 检查是否连续两天约同一医生
    public static boolean checkConsecutiveDays(int patientId, int doctorId, String appointmentDate) throws SQLException, ParseException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();

            String checkConsecutiveDaysSql = "SELECT appointment_date FROM appointments WHERE patient_id = ? AND doctor_id = ? AND status != '已取消' ORDER BY appointment_date DESC LIMIT 1";
            pstmt = conn.prepareStatement(checkConsecutiveDaysSql);
            pstmt.setInt(1, patientId);
            pstmt.setInt(2, doctorId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                Date lastAppointmentDate = rs.getDate("appointment_date");
                Date currentAppointmentDate = new SimpleDateFormat("yyyy-MM-dd").parse(appointmentDate.split("T")[0]);
                long diffDays = (currentAppointmentDate.getTime() - lastAppointmentDate.getTime()) / (1000 * 60 * 60 * 24);
                return diffDays != 1;
            }

            return true;
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
    }

    // 检查医生当天预约人数（限30人/天，紧急可超额）
    public static boolean checkDoctorDailyLimit(int doctorId, String appointmentDate, int urgency) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();

            String datePart = appointmentDate.split("T")[0];
            String checkDoctorDailyLimitSql = "SELECT COUNT(*) FROM appointments WHERE doctor_id = ? AND DATE(appointment_date) = ? AND status != '已取消'";
            pstmt = conn.prepareStatement(checkDoctorDailyLimitSql);
            pstmt.setInt(1, doctorId);
            pstmt.setString(2, datePart);
            rs = pstmt.executeQuery();
            int dailyCount = 0;
            if (rs.next()) {
                dailyCount = rs.getInt(1);
            }

            return dailyCount < 30 || urgency >= 4;
        } finally {
            DBUtil.close(conn, pstmt, rs);
        }
    }

    // 医生类
    public static class Doctor {
        private String id;
        private String name;
        private int appointmentCount;

        public Doctor(String id, String name, int appointmentCount) {
            this.id = id;
            this.name = name;
            this.appointmentCount = appointmentCount;
        }

        public String getId() { return id; }
        public String getName() { return name; }
        public int getAppointmentCount() { return appointmentCount; }
    }

    // 预约冲突解决方案类
    public static class AppointmentConflictSolution {
        private String type; // 换医生、换时间、调整时长
        private String time;
        private String doctorName;
        private String doctorId;
        private String purpose;

        public AppointmentConflictSolution(String type, String time, String doctorName, String doctorId, String purpose) {
            this.type = type;
            this.time = time;
            this.doctorName = doctorName;
            this.doctorId = doctorId;
            this.purpose = purpose;
        }

        public String getType() { return type; }
        public String getTime() { return time; }
        public String getDoctorName() { return doctorName; }
        public String getDoctorId() { return doctorId; }
        public String getPurpose() { return purpose; }
    }

    // 原始预约信息类
    public static class OriginalAppointment {
        private int patientId;
        private String doctorId;
        private String appointmentDate;
        private String appointmentType;
        private String purpose;
        private String urgency;

        public OriginalAppointment(int patientId, String doctorId, String appointmentDate, String appointmentType, String purpose, String urgency) {
            this.patientId = patientId;
            this.doctorId = doctorId;
            this.appointmentDate = appointmentDate;
            this.appointmentType = appointmentType;
            this.purpose = purpose;
            this.urgency = urgency;
        }

        public int getPatientId() { return patientId; }
        public String getDoctorId() { return doctorId; }
        public String getAppointmentDate() { return appointmentDate; }
        public String getAppointmentType() { return appointmentType; }
        public String getPurpose() { return purpose; }
        public String getUrgency() { return urgency; }
    }
}