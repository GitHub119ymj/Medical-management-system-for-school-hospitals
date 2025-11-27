<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%
    // 获取患者ID和其他预约信息
    String patientId = (String) session.getAttribute("user_id");
    String appointmentType = request.getParameter("appointmentType");  // 预约类型：医生或体检
    String doctorId = request.getParameter("doctorId");  // 医生ID（仅当预约医生时）
    String appointmentDate = request.getParameter("appointmentDate");  // 预约日期
    String purpose = request.getParameter("purpose");  // 预约目的（体检、感冒等）
    String urgency = request.getParameter("urgency");  // 紧急度（1-5）

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    boolean success = false;

    try {
        // 连接数据库
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "123456");
        conn.setAutoCommit(false); // 开始事务

        // 检查学生每月预约次数限制（5次/月）
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM");
        String currentMonth = sdf.format(new Date());
        String checkMonthlyLimitSql = "SELECT COUNT(*) FROM appointments WHERE patient_id = ? AND DATE_FORMAT(appointment_date, '%Y-%m') = ? AND status != '已取消'";
        pstmt = conn.prepareStatement(checkMonthlyLimitSql);
        pstmt.setInt(1, Integer.parseInt(patientId));
        pstmt.setString(2, currentMonth);
        rs = pstmt.executeQuery();
        int monthlyCount = 0;
        if (rs.next()) {
            monthlyCount = rs.getInt(1);
        }
        if (monthlyCount >= 5) {
            throw new Exception("您本月预约次数已达上限（5次），请下月再预约。");
        }

        // 检查是否连续两天约同一医生
        if ("doctor".equals(appointmentType)) {
            String checkConsecutiveDaysSql = "SELECT appointment_date FROM appointments WHERE patient_id = ? AND doctor_id = ? AND status != '已取消' ORDER BY appointment_date DESC LIMIT 1";
            pstmt = conn.prepareStatement(checkConsecutiveDaysSql);
            pstmt.setInt(1, Integer.parseInt(patientId));
            pstmt.setInt(2, Integer.parseInt(doctorId));
            rs = pstmt.executeQuery();
            if (rs.next()) {
                Date lastAppointmentDate = rs.getDate("appointment_date");
                Date currentAppointmentDate = sdf.parse(appointmentDate.split("T")[0]);
                long diffDays = (currentAppointmentDate.getTime() - lastAppointmentDate.getTime()) / (1000 * 60 * 60 * 24);
                if (diffDays == 1) {
                    throw new Exception("不能连续两天预约同一医生，请选择其他日期。");
                }
            }
        }

        // 检查医生当天预约人数（限30人/天，紧急可超额）
        if ("doctor".equals(appointmentType)) {
            String checkDoctorDailyLimitSql = "SELECT COUNT(*) FROM appointments WHERE doctor_id = ? AND DATE(appointment_date) = ? AND status != '已取消'";
            pstmt = conn.prepareStatement(checkDoctorDailyLimitSql);
            pstmt.setInt(1, Integer.parseInt(doctorId));
            pstmt.setString(2, appointmentDate.split("T")[0]);
            rs = pstmt.executeQuery();
            int dailyCount = 0;
            if (rs.next()) {
                dailyCount = rs.getInt(1);
            }
            if (dailyCount >= 30 && (urgency == null || Integer.parseInt(urgency) < 4)) {
                throw new Exception("该医生当天预约已满（30人），紧急情况可超额预约。");
            }
        }

        // 计算患者优先级
        double priority = calculatePriority(conn, Integer.parseInt(patientId), urgency);

        // 检查是否存在冲突
        boolean hasConflict = checkConflict(conn, doctorId, appointmentDate, appointmentType);

        if (hasConflict) {
            // 处理冲突
            List<AppointmentConflictSolution> solutions = resolveConflict(conn, doctorId, appointmentDate, appointmentType, Integer.parseInt(patientId), priority);
            session.setAttribute("conflictSolutions", solutions);
            session.setAttribute("originalAppointment", new OriginalAppointment(Integer.parseInt(patientId), doctorId, appointmentDate, appointmentType, purpose, urgency));
            response.sendRedirect("conflictResolution.jsp");
        } else {
            // 无冲突，直接创建预约
            createAppointment(conn, Integer.parseInt(patientId), doctorId, appointmentDate, appointmentType, purpose);
            success = true;
        }

        if (success) {
            conn.commit();
            out.println("<script>alert('预约成功！'); window.location.href='appointmentConfirmation.jsp';</script>");
        }

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
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 计算优先级的函数
    double calculatePriority(Connection conn, int patientId, String urgencyStr) throws SQLException {
        double priority = 0.0;
        int urgency = (urgencyStr != null) ? Integer.parseInt(urgencyStr) : 1;

        // 获取等待天数（假设从上次预约至今的天数）
        String getLastAppointmentSql = "SELECT appointment_date FROM appointments WHERE patient_id = ? AND status != '已取消' ORDER BY appointment_date DESC LIMIT 1";
        PreparedStatement pstmt = conn.prepareStatement(getLastAppointmentSql);
        pstmt.setInt(1, patientId);
        ResultSet rs = pstmt.executeQuery();
        int waitingDays = 0;
        if (rs.next()) {
            Date lastAppointmentDate = rs.getDate("appointment_date");
            Date currentDate = new Date();
            long diffDays = (currentDate.getTime() - lastAppointmentDate.getTime()) / (1000 * 60 * 60 * 24);
            waitingDays = (int) diffDays;
        }

        // 获取年级（假设从users表获取）
        String getGradeSql = "SELECT grade FROM users WHERE id = ?";
        pstmt = conn.prepareStatement(getGradeSql);
        pstmt.setInt(1, patientId);
        rs = pstmt.executeQuery();
        int grade = 1;
        if (rs.next()) {
            grade = rs.getInt("grade");
        }

        // 获取失约次数
        String getNoShowSql = "SELECT COUNT(*) FROM appointments WHERE patient_id = ? AND status = '已取消' AND cancellation_reason = '失约'";
        pstmt = conn.prepareStatement(getNoShowSql);
        pstmt.setInt(1, patientId);
        rs = pstmt.executeQuery();
        int noShowCount = 0;
        if (rs.next()) {
            noShowCount = rs.getInt(1);
        }

        // 计算优先级
        priority = waitingDays * 0.3 + urgency * 0.2 + grade * 0.1 - noShowCount * 5;

        // 等待每增加1天，优先级自动+5%
        if (waitingDays > 0) {
            priority *= Math.pow(1.05, waitingDays);
        }

        return priority;
    }

    // 检查冲突的函数
    boolean checkConflict(Connection conn, String doctorId, String appointmentDate, String appointmentType) throws SQLException {
        if ("doctor".equals(appointmentType)) {
            String checkConflictSql = "SELECT COUNT(*) FROM appointments WHERE doctor_id = ? AND appointment_date = ? AND status != '已取消' FOR UPDATE";
            PreparedStatement pstmt = conn.prepareStatement(checkConflictSql);
            pstmt.setInt(1, Integer.parseInt(doctorId));
            pstmt.setString(2, appointmentDate);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } else if ("checkup".equals(appointmentType)) {
            // 体检冲突检查（同一时间段是否有其他体检）
            String checkConflictSql = "SELECT COUNT(*) FROM appointments WHERE doctor_id IS NULL AND appointment_date = ? AND status != '已取消' FOR UPDATE";
            PreparedStatement pstmt = conn.prepareStatement(checkConflictSql);
            pstmt.setString(1, appointmentDate);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    // 解决冲突的函数
    List<AppointmentConflictSolution> resolveConflict(Connection conn, String doctorId, String appointmentDate, String appointmentType, int patientId, double priority) throws SQLException, ParseException {
        List<AppointmentConflictSolution> solutions = new ArrayList<>();

        // 方案1：换医生
        if ("doctor".equals(appointmentType)) {
            List<Doctor> availableDoctors = getAvailableDoctors(conn, appointmentDate, appointmentType);
            for (Doctor doctor : availableDoctors) {
                if (!doctor.getId().equals(doctorId)) {
                    solutions.add(new AppointmentConflictSolution("换医生", appointmentDate, doctor.getName(), doctor.getId(), purpose));
                    if (solutions.size() >= 1) break; // 只需要1个换医生方案
                }
            }
        }

        // 方案2：换时间
        List<String> availableTimes = getAvailableTimes(conn, doctorId, appointmentDate, appointmentType);
        for (String time : availableTimes) {
            solutions.add(new AppointmentConflictSolution("换时间", time, null, doctorId, purpose));
            if (solutions.size() >= 2) break; // 累计2个方案
        }

        // 方案3：调整时长（假设将30分钟预约改为15分钟）
        if ("doctor".equals(appointmentType)) {
            solutions.add(new AppointmentConflictSolution("调整时长", appointmentDate, null, doctorId, purpose + "（15分钟）"));
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
                        solutions.add(new AppointmentConflictSolution("换医生", appointmentDate, doctor.getName(), doctor.getId(), purpose));
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
                        solutions.add(new AppointmentConflictSolution("换时间", time, null, doctorId, purpose));
                        break;
                    }
                }
            }
        }

        return solutions;
    }

    // 获取可用医生的函数
    List<Doctor> getAvailableDoctors(Connection conn, String appointmentDate, String appointmentType) throws SQLException {
        List<Doctor> doctors = new ArrayList<>();
        String datePart = appointmentDate.split("T")[0];

        String getDoctorsSql = "SELECT d.id, d.doctor_name, COUNT(a.id) as appointment_count " +
                "FROM doctors d LEFT JOIN appointments a ON d.id = a.doctor_id AND DATE(a.appointment_date) = ? AND a.status != '已取消' " +
                "GROUP BY d.id, d.doctor_name HAVING appointment_count < 30 ORDER BY appointment_count ASC";
        PreparedStatement pstmt = conn.prepareStatement(getDoctorsSql);
        pstmt.setString(1, datePart);
        ResultSet rs = pstmt.executeQuery();

        while (rs.next()) {
            doctors.add(new Doctor(rs.getString("id"), rs.getString("doctor_name"), rs.getInt("appointment_count")));
        }

        return doctors;
    }

    // 获取可用时间的函数
    List<String> getAvailableTimes(Connection conn, String doctorId, String appointmentDate, String appointmentType) throws SQLException, ParseException {
        List<String> availableTimes = new ArrayList<>();
        String datePart = appointmentDate.split("T")[0];
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
        Date originalDate = sdf.parse(appointmentDate);

        // 检查当天的可用时间
        String getAppointmentsSql = "SELECT appointment_date FROM appointments WHERE ";
        if ("doctor".equals(appointmentType)) {
            getAppointmentsSql += "doctor_id = ? AND ";
        } else {
            getAppointmentsSql += "doctor_id IS NULL AND ";
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

        // 生成当天的时间槽（8:00-18:00，每30分钟一个槽）
        Calendar cal = Calendar.getInstance();
        cal.setTime(originalDate);
        cal.set(Calendar.HOUR_OF_DAY, 8);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);

        Set<String> busyTimes = new HashSet<>();
        while (rs.next()) {
            busyTimes.add(rs.getString("appointment_date"));
        }

        // 寻找可用时间槽
        for (int i = 0; i < 20; i++) { // 8:00-18:00共20个30分钟槽
            String timeSlot = sdf.format(cal.getTime());
            if (!busyTimes.contains(timeSlot)) {
                availableTimes.add(timeSlot);
                if (availableTimes.size() >= 2) break; // 只需要2个可用时间
            }
            cal.add(Calendar.MINUTE, 30);
        }

        // 如果当天没有足够的可用时间，检查第二天
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

        return availableTimes;
    }

    // 创建预约的函数
    void createAppointment(Connection conn, int patientId, String doctorId, String appointmentDate, String appointmentType, String purpose) throws SQLException {
        String sql = "INSERT INTO appointments (patient_id, doctor_id, appointment_date, status, purpose) VALUES (?, ?, ?, '已预约', ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, patientId);
        if ("doctor".equals(appointmentType)) {
            pstmt.setInt(2, Integer.parseInt(doctorId));
        } else {
            pstmt.setNull(2, Types.INTEGER);
        }
        pstmt.setString(3, appointmentDate);
        pstmt.setString(4, purpose);
        pstmt.executeUpdate();
    }

    // 辅助类：医生
    class Doctor {
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

    // 辅助类：预约冲突解决方案
    class AppointmentConflictSolution {
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

    // 辅助类：原始预约信息
    class OriginalAppointment {
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
%>