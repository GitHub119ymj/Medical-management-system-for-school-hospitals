-- 数据库结构修复脚本
-- 修复内容：
-- 1. 将users.grade改为从patients.class提取年级
-- 2. 删除cancellation_reason依赖
-- 3. 将doctors表改为medical_staff表

-- 1. 删除users表中的grade字段（如果存在）
ALTER TABLE users DROP COLUMN IF EXISTS grade;

-- 2. 删除cancellation_reason表（如果存在）
DROP TABLE IF EXISTS cancellation_reason;

-- 3. 修改appointments表，删除对cancellation_reason的外键约束（如果存在）
ALTER TABLE appointments DROP FOREIGN KEY IF EXISTS fk_appointments_cancellation_reason;
ALTER TABLE appointments DROP COLUMN IF EXISTS cancellation_reason_id;

-- 4. 创建medical_staff表（如果不存在）
CREATE TABLE IF NOT EXISTS medical_staff (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    title VARCHAR(50),
    role ENUM('doctor', 'nurse', 'admin') NOT NULL DEFAULT 'doctor',
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 5. 从doctors表迁移数据到medical_staff表（如果doctors表存在）
INSERT INTO medical_staff (id, name, department, title, role, status)
SELECT id, name, department, title, 'doctor' as role, 'active' as status
FROM doctors
WHERE NOT EXISTS (SELECT 1 FROM medical_staff WHERE medical_staff.id = doctors.id);

-- 6. 修改appointments表，将doctor_id字段改为staff_id，并添加外键约束
ALTER TABLE appointments CHANGE COLUMN doctor_id staff_id INT NULL;
ALTER TABLE appointments ADD FOREIGN KEY fk_appointments_medical_staff (staff_id) REFERENCES medical_staff(id) ON DELETE SET NULL;

-- 7. 修改appointments表，status字段增加'已取消'选项
ALTER TABLE appointments MODIFY COLUMN status ENUM('已预约', '已完成', '已取消') NOT NULL DEFAULT '已预约';

-- 8. 可选：删除旧的doctors表（如果不再需要）
-- DROP TABLE IF EXISTS doctors;

-- 9. 为medical_staff表添加索引以提高查询性能
CREATE INDEX idx_medical_staff_role_status ON medical_staff(role, status);
CREATE INDEX idx_medical_staff_department ON medical_staff(department);

-- 10. 为appointments表添加索引以提高查询性能
CREATE INDEX idx_appointments_patient_id_status ON appointments(patient_id, status);
CREATE INDEX idx_appointments_staff_id_date_status ON appointments(staff_id, appointment_date, status);
CREATE INDEX idx_appointments_date_status ON appointments(appointment_date, status);

-- 11. 为patients表添加class字段（如果不存在）
ALTER TABLE patients ADD COLUMN IF NOT EXISTS class VARCHAR(50);

-- 12. 可选：更新现有患者的班级信息示例
-- UPDATE patients SET class = '2021级一班' WHERE id = 1;
-- UPDATE patients SET class = '2022级二班' WHERE id = 2;

COMMIT;

-- 脚本执行完成提示
SELECT '数据库结构修复完成！' AS message;