# 智能预约系统

一个基于Java Web的智能预约系统，提供医生预约和体检预约功能，并实现了多种智能优化算法。

## 功能特性

### 1. 基本预约功能
- **医生预约**：患者可以预约不同科室的医生
- **体检预约**：患者可以预约体检服务
- **紧急预约**：支持紧急情况的优先预约

### 2. 智能预约限制
- **每月预约次数限制**：每位患者每月最多预约5次
- **连续预约限制**：不能连续两天预约同一医生
- **医生日预约人数限制**：每位医生每天最多预约30人，紧急情况可超额至40人

### 3. 体检时间检查
- **常规时间**：体检必须在上午8:00-12:00进行
- **冲突例外**：如果存在时间冲突，可以允许下午13:00-17:00体检

### 4. 优先级计算系统
- **等待天数**：等待时间越长，优先级越高（占30%权重）
- **紧急程度**：紧急度越高，优先级越高（占20%权重）
- **年级因素**：高年级学生优先级更高（占10%权重）
- **失约惩罚**：失约次数越多，优先级越低（每次失约扣5分）
- **等待补偿**：等待每增加1天，优先级自动增加5%

### 5. 医生疲劳度管理
- **连续接诊监控**：实时查询医生连续接诊次数
- **优先级调整**：如果医生连续接诊≥5人，优先级降低10%

### 6. 冲突解决机制
- **优先级对比**：高优先级患者优先获得时间槽
- **换医生方案**：推荐其他可用医生
- **换时间方案**：推荐其他可用时间段
- **强制预约**：高优先级患者可以强制占用低优先级患者的时间槽

### 7. 级联重排功能
- **后续预约获取**：自动获取冲突时间之后的所有未取消预约
- **优先级重新排序**：根据患者优先级重新安排预约顺序
- **等待时间验证**：确保调整后等待时间增加不超过20%
- **智能时间安排**：从冲突时间后30分钟开始重新安排

## 技术架构

### 前端技术
- JSP + Servlet
- JavaScript + jQuery
- CSS + Bootstrap

### 后端技术
- Java SE
- JDBC
- MySQL数据库

### 核心组件

#### 1. AppointmentService.java
核心业务逻辑处理类，包含以下主要方法：

**优先级计算**
```java
// 计算患者预约优先级
double calculatePriority(int patientId, String urgencyStr, int staffId)

// 查询医生连续接诊数
int getDoctorConsecutiveAppointments(int staffId, String appointmentDate)
```

**预约限制检查**
```java
// 检查每月预约次数限制
boolean checkMonthlyLimit(int patientId)

// 检查连续两天预约同一医生
boolean checkConsecutiveDays(int patientId, int doctorId, String appointmentDate)

// 检查医生当天预约人数限制
boolean checkDoctorDailyLimit(int doctorId, String appointmentDate, int urgency)

// 检查体检时间是否符合规定
boolean checkCheckupTime(String appointmentDate, boolean hasConflict)
```

**冲突处理**
```java
// 检查是否存在预约冲突
boolean checkConflict(String doctorId, String appointmentDate, String appointmentType)

// 解决预约冲突
List<AppointmentConflictSolution> resolveConflict(String doctorId, String appointmentDate, String appointmentType, int patientId, double priority)
```

**级联重排**
```java
// 获取后续预约列表
List<Appointment> getFollowUpAppointments(int staffId, String appointmentDate)

// 验证等待时间增加是否不超过20%
boolean validateWaitTimeIncrease(Appointment originalAppointment, Appointment rescheduledAppointment)

// 级联重排后续预约
void cascadeRescheduleAppointments(int staffId, String conflictDate)
```

**数据操作**
```java
// 创建预约记录
void createAppointment(int patientId, String doctorIdStr, String appointmentDate, String appointmentType, String purpose)

// 获取可用医生列表
List<Doctor> getAvailableDoctors(Connection conn, String appointmentDate, String appointmentType)

// 获取可用时间槽
List<String> getAvailableTimes(Connection conn, String doctorId, String appointmentDate, String appointmentType)
```

#### 2. SmartAppointmentServlet.java
处理预约请求的Servlet，主要流程：
1. 验证用户登录状态
2. 获取预约信息
3. 检查各种预约限制
4. 计算患者优先级
5. 检查预约冲突
6. 处理冲突或直接创建预约

## 数据库结构

### 主要表结构

#### 1. users（用户表）
```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    role ENUM('patient', 'doctor', 'admin') NOT NULL DEFAULT 'patient',
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### 2. patients（患者表）
```sql
CREATE TABLE patients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    class VARCHAR(50), -- 用于提取年级信息
    student_id VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### 3. medical_staff（医护人员表）
```sql
CREATE TABLE medical_staff (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    title VARCHAR(50),
    role ENUM('doctor', 'nurse', 'admin') NOT NULL DEFAULT 'doctor',
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### 4. appointments（预约表）
```sql
CREATE TABLE appointments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    staff_id INT NULL, -- 医生ID，体检时为null
    appointment_date DATETIME NOT NULL,
    appointment_type ENUM('doctor', 'checkup') NOT NULL,
    purpose TEXT,
    status ENUM('已预约', '已完成', '已取消') NOT NULL DEFAULT '已预约',
    urgency INT DEFAULT 1, -- 1-5，5为最紧急
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES medical_staff(id) ON DELETE SET NULL
);
```

## 数据库修复

如果需要修复数据库结构，可以执行以下SQL脚本：

```bash
mysql -u username -p database_name < sql/database_fix.sql
```

修复内容包括：
1. 删除users表中的grade字段
2. 删除cancellation_reason表及其依赖
3. 创建medical_staff表并从doctors表迁移数据
4. 修改appointments表结构
5. 添加必要的索引

## 使用方法

### 1. 系统部署
1. 将项目部署到Tomcat服务器
2. 配置数据库连接信息
3. 执行数据库初始化脚本

### 2. 用户操作流程

**患者预约流程：**
1. 登录系统
2. 选择预约类型（医生或体检）
3. 填写预约信息
4. 系统检查预约限制
5. 系统计算优先级
6. 如果有冲突，选择解决方案
7. 确认预约

**冲突解决流程：**
1. 系统检测到时间冲突
2. 显示冲突解决方案
   - 强制预约（高优先级患者）
   - 换医生
   - 换时间
3. 患者选择解决方案
4. 系统执行相应操作

### 3. 管理员功能
- 用户管理
- 医生管理
- 预约管理
- 系统配置

## 系统优化建议

### 1. 性能优化
- 定期清理过期预约数据
- 优化数据库查询语句
- 添加适当的索引

### 2. 功能扩展
- 添加短信/邮件提醒功能
- 支持在线支付
- 实现电子病历系统
- 添加数据分析和报表功能

### 3. 安全改进
- 加强密码加密
- 添加验证码功能
- 实现访问控制
- 定期备份数据

## 常见问题

### Q: 为什么体检只能在上午进行？
A: 体检需要空腹，所以通常安排在上午。如果存在时间冲突，可以允许下午体检。

### Q: 医生连续接诊5人后为什么优先级会降低？
A: 这是为了防止医生过度疲劳，保证医疗质量。

### Q: 级联重排时为什么等待时间增加不能超过20%？
A: 这是为了平衡高优先级患者的需求和其他患者的利益，避免给其他患者造成过大不便。

### Q: 如何计算患者优先级？
A: 优先级计算公式：等待天数*0.3 + 紧急度*0.2 + 年级*0.1 - 失约次数*5 + 等待补偿（每天+5%）

## 技术支持

如有问题或建议，请联系开发团队。