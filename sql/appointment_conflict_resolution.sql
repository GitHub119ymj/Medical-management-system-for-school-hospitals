-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS hms;
USE hms;

-- 创建医护人员表（如果不存在）
CREATE TABLE IF NOT EXISTS medical_staff (
    id INT PRIMARY KEY AUTO_INCREMENT,
    staff_name VARCHAR(50) NOT NULL,
    specialty VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(50),
    role VARCHAR(20) DEFAULT 'doctor',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 创建用户表（如果不存在）
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    name VARCHAR(50) NOT NULL,
    gender VARCHAR(10),
    age INT,
    phone VARCHAR(20),
    email VARCHAR(50),
    student_id VARCHAR(20),
    class_name VARCHAR(50),
    address VARCHAR(100),
    role VARCHAR(20) DEFAULT 'student',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 创建预约表（如果不存在）
CREATE TABLE IF NOT EXISTS appointments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    staff_id INT,
    appointment_date DATETIME NOT NULL,
    status VARCHAR(20) DEFAULT '已预约',
    purpose VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES users(id),
    FOREIGN KEY (staff_id) REFERENCES medical_staff(id)
);

-- 创建预约冲突表（用于记录冲突历史）
CREATE TABLE IF NOT EXISTS appointment_conflicts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL,
    conflicting_appointment_id INT NOT NULL,
    conflict_type VARCHAR(50) NOT NULL,
    resolution_strategy VARCHAR(50),
    resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES appointments(id),
    FOREIGN KEY (conflicting_appointment_id) REFERENCES appointments(id)
);

-- 创建预约调整历史表（用于记录预约调整历史）
CREATE TABLE IF NOT EXISTS appointment_adjustments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL,
    old_appointment_date DATETIME NOT NULL,
    new_appointment_date DATETIME NOT NULL,
    adjustment_reason VARCHAR(100) NOT NULL,
    adjusted_by VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES appointments(id)
);

-- 创建医护人员日程表（用于记录医护人员的可用时间）
CREATE TABLE IF NOT EXISTS staff_schedules (
    id INT PRIMARY KEY AUTO_INCREMENT,
    staff_id INT NOT NULL,
    day_of_week INT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES medical_staff(id)
);

-- 创建索引以提高查询性能
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_staff_id ON appointments(staff_id);
CREATE INDEX idx_appointments_appointment_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointment_conflicts_appointment_id ON appointment_conflicts(appointment_id);
CREATE INDEX idx_appointment_conflicts_conflicting_appointment_id ON appointment_conflicts(conflicting_appointment_id);
CREATE INDEX idx_appointment_adjustments_appointment_id ON appointment_adjustments(appointment_id);
CREATE INDEX idx_staff_schedules_staff_id ON staff_schedules(staff_id);
CREATE INDEX idx_staff_schedules_day_of_week ON staff_schedules(day_of_week);

-- 插入示例医护人员数据
INSERT INTO medical_staff (staff_name, specialty, phone, email) VALUES
('张医生', '内科', '13800138001', 'zhang@example.com'),
('李医生', '外科', '13800138002', 'li@example.com'),
('王医生', '儿科', '13800138003', 'wang@example.com'),
('赵医生', '妇科', '13800138004', 'zhao@example.com'),
('刘医生', '骨科', '13800138005', 'liu@example.com'),
('陈护士', '护理', '13800138006', 'chen@example.com');

-- 插入示例医护人员日程数据
INSERT INTO staff_schedules (staff_id, day_of_week, start_time, end_time) VALUES
(1, 1, '08:00:00', '12:00:00'),
(1, 1, '14:00:00', '18:00:00'),
(1, 2, '08:00:00', '12:00:00'),
(1, 2, '14:00:00', '18:00:00'),
(1, 3, '08:00:00', '12:00:00'),
(1, 3, '14:00:00', '18:00:00'),
(1, 4, '08:00:00', '12:00:00'),
(1, 4, '14:00:00', '18:00:00'),
(1, 5, '08:00:00', '12:00:00'),
(1, 5, '14:00:00', '18:00:00'),
(2, 1, '08:00:00', '12:00:00'),
(2, 1, '14:00:00', '18:00:00'),
(2, 2, '08:00:00', '12:00:00'),
(2, 2, '14:00:00', '18:00:00'),
(2, 3, '08:00:00', '12:00:00'),
(2, 3, '14:00:00', '18:00:00'),
(2, 4, '08:00:00', '12:00:00'),
(2, 4, '14:00:00', '18:00:00'),
(2, 5, '08:00:00', '12:00:00'),
(2, 5, '14:00:00', '18:00:00');

-- 插入示例用户数据
INSERT INTO users (username, password, name, gender, age, phone, email, student_id, class_name, grade, address, role) VALUES
('student1', '123456', '学生1', '男', 20, '13900139001', 'student1@example.com', '2021001', '一班', 2021, '北京市朝阳区', 'student'),
('student2', '123456', '学生2', '女', 19, '13900139002', 'student2@example.com', '2021002', '一班', 2021, '北京市海淀区', 'student'),
('student3', '123456', '学生3', '男', 21, '13900139003', 'student3@example.com', '2020001', '二班', 2020, '北京市东城区', 'student'),
('doctor1', '123456', '张医生', '男', 40, '13800138001', 'zhang@example.com', NULL, NULL, NULL, '北京市西城区', 'doctor'),
('admin', '123456', '管理员', '男', 30, '13700137001', 'admin@example.com', NULL, NULL, NULL, '北京市丰台区', 'admin');

-- 插入示例医生日程数据
INSERT INTO doctor_schedules (doctor_id, day_of_week, start_time, end_time) VALUES
(1, 1, '08:00:00', '12:00:00'),
(1, 1, '14:00:00', '18:00:00'),
(1, 2, '08:00:00', '12:00:00'),
(1, 2, '14:00:00', '18:00:00'),
(1, 3, '08:00:00', '12:00:00'),
(1, 3, '14:00:00', '18:00:00'),
(1, 4, '08:00:00', '12:00:00'),
(1, 4, '14:00:00', '18:00:00'),
(1, 5, '08:00:00', '12:00:00'),
(1, 5, '14:00:00', '18:00:00'),
(2, 1, '08:00:00', '12:00:00'),
(2, 1, '14:00:00', '18:00:00'),
(2, 2, '08:00:00', '12:00:00'),
(2, 2, '14:00:00', '18:00:00'),
(2, 3, '08:00:00', '12:00:00'),
(2, 3, '14:00:00', '18:00:00'),
(2, 4, '08:00:00', '12:00:00'),
(2, 4, '14:00:00', '18:00:00'),
(2, 5, '08:00:00', '12:00:00'),
(2, 5, '14:00:00', '18:00:00');

-- 插入示例预约数据
INSERT INTO appointments (patient_id, doctor_id, appointment_date, status, purpose) VALUES
(1, 1, '2023-10-01 08:30:00', '已预约', '常规体检'),
(2, 1, '2023-10-01 09:00:00', '已预约', '感冒就诊'),
(3, 2, '2023-10-01 08:30:00', '已预约', '骨折复查'),
(1, 3, '2023-10-02 10:00:00', '已预约', '儿科就诊'),
(2, 4, '2023-10-02 14:00:00', '已预约', '妇科检查');

-- 插入示例预约冲突数据
INSERT INTO appointment_conflicts (appointment_id, conflicting_appointment_id, conflict_type, resolution_strategy, resolved) VALUES
(1, 2, '时间冲突', '调整时间', TRUE),
(3, 4, '医生冲突', '换医生', TRUE);

-- 插入示例预约调整历史数据
INSERT INTO appointment_adjustments (appointment_id, old_appointment_date, new_appointment_date, adjustment_reason, adjusted_by) VALUES
(2, '2023-10-01 08:30:00', '2023-10-01 09:00:00', '时间冲突', '系统自动调整'),
(4, '2023-10-01 08:30:00', '2023-10-01 09:30:00', '医生冲突', '系统自动调整');

-- 提交事务
COMMIT;