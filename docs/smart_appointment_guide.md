# 智能预约冲突解决系统使用指南

## 系统概述

智能预约冲突解决系统是一个基于JSP+纯JDBC的医疗预约系统，它能够自动处理预约冲突，根据优先级算法重新安排所有受影响的预约。

## 核心功能

### 1. 优先级算法

系统使用以下公式计算预约优先级：

```
优先级 = 等待天数 × 0.3 + 紧急度 × 0.2 + 年级 × 0.1 - 失约次数 × 5
```

- **等待天数**：从当前日期到预约日期的天数
- **紧急度**：用户选择的紧急程度（1-5级）
- **年级**：学生的年级（如2021级为2021）
- **失约次数**：用户过去的失约次数

此外，等待每增加1天，优先级自动增加5%。

### 2. 冲突解决

当多个学生同时预约同一医生时，系统会自动生成3个备选方案：

1. **换医生**：为用户推荐其他同科室的医生
2. **换时间**：为用户推荐同一医生的其他可用时间
3. **调整时长**：缩短当前预约的时长，为后续预约腾出时间

系统会考虑医生疲劳度，当医生连续接诊超过5人时，效率会下降10%。

### 3. 约束条件

- **医生限30人/天**：每个医生每天最多只能接诊30个患者
- **学生限5次/月**：每个学生每月最多只能预约5次
- **体检时间限制**：体检必须在上午且空腹，但冲突时可安排在下午
- **连续预约限制**：学生不能连续两天预约同一医生

### 4. 并发事务处理

系统使用纯JDBC事务处理10人同时点击同一时间槽的情况，确保数据一致性。如果事务失败，系统会完整回滚所有操作。

系统还使用数据库行锁防止超售，确保同一时间槽不会被多个用户预约。

## 使用流程

### 1. 预约流程

1. 用户登录系统
2. 点击"预约挂号"或"体检预约"
3. 选择预约类型（医生或体检）
4. 选择医生和预约时间
5. 选择紧急度（1-5级）
6. 提交预约请求

### 2. 冲突处理流程

1. 系统检测到预约冲突
2. 系统计算所有冲突预约的优先级
3. 系统生成3个备选方案
4. 用户选择一个方案
5. 系统自动级联调整后续所有受影响的预约
6. 系统完成预约并通知用户

### 3. 预约调整流程

1. 用户查看预约详情
2. 用户申请调整预约
3. 系统检测是否有冲突
4. 系统生成调整方案
5. 用户选择方案
6. 系统完成调整

## 数据库结构

系统使用以下主要表：

### 1. users表

存储用户信息，包括学生和医生。

| 字段名 | 类型 | 描述 |
|--------|------|------|
| id | INT | 用户ID（主键） |
| username | VARCHAR(50) | 用户名（唯一） |
| password | VARCHAR(100) | 密码 |
| name | VARCHAR(50) | 姓名 |
| gender | VARCHAR(10) | 性别 |
| age | INT | 年龄 |
| phone | VARCHAR(20) | 电话 |
| email | VARCHAR(50) | 邮箱 |
| student_id | VARCHAR(20) | 学号（学生） |
| class_name | VARCHAR(50) | 班级（学生） |
| grade | INT | 年级（学生） |
| address | VARCHAR(100) | 地址 |
| role | VARCHAR(20) | 角色（student/doctor/admin） |

### 2. doctors表

存储医生信息。

| 字段名 | 类型 | 描述 |
|--------|------|------|
| id | INT | 医生ID（主键） |
| doctor_name | VARCHAR(50) | 医生姓名 |
| specialty | VARCHAR(50) | 专业 |
| phone | VARCHAR(20) | 电话 |
| email | VARCHAR(50) | 邮箱 |

### 3. appointments表

存储预约信息。

| 字段名 | 类型 | 描述 |
|--------|------|------|
| id | INT | 预约ID（主键） |
| patient_id | INT | 患者ID（外键） |
| doctor_id | INT | 医生ID（外键） |
| appointment_date | DATETIME | 预约时间 |
| status | VARCHAR(20) | 状态（已预约/已取消/已完成） |
| purpose | VARCHAR(100) | 预约目的 |
| cancellation_reason | VARCHAR(100) | 取消原因 |

### 4. appointment_conflicts表

存储预约冲突历史。

| 字段名 | 类型 | 描述 |
|--------|------|------|
| id | INT | 冲突ID（主键） |
| appointment_id | INT | 预约ID（外键） |
| conflicting_appointment_id | INT | 冲突预约ID（外键） |
| conflict_type | VARCHAR(50) | 冲突类型 |
| resolution_strategy | VARCHAR(50) | 解决策略 |
| resolved | BOOLEAN | 是否已解决 |

### 5. appointment_adjustments表

存储预约调整历史。

| 字段名 | 类型 | 描述 |
|--------|------|------|
| id | INT | 调整ID（主键） |
| appointment_id | INT | 预约ID（外键） |
| old_appointment_date | DATETIME | 旧预约时间 |
| new_appointment_date | DATETIME | 新预约时间 |
| adjustment_reason | VARCHAR(100) | 调整原因 |
| adjusted_by | VARCHAR(50) | 调整人 |

### 6. doctor_schedules表

存储医生的可用时间。

| 字段名 | 类型 | 描述 |
|--------|------|------|
| id | INT | 日程ID（主键） |
| doctor_id | INT | 医生ID（外键） |
| day_of_week | INT | 星期几（1-7） |
| start_time | TIME | 开始时间 |
| end_time | TIME | 结束时间 |
| is_available | BOOLEAN | 是否可用 |

## 系统架构

### 1. 技术栈

- **前端**：JSP、HTML、CSS、JavaScript
- **后端**：Java Servlet、纯JDBC
- **数据库**：MySQL
- **服务器**：Tomcat

### 2. 核心类

#### 2.1 DBUtil.java

数据库工具类，提供数据库连接、关闭资源和事务管理功能。

主要方法：
- `getConnection()`：获取数据库连接
- `closeConnection(Connection conn)`：关闭数据库连接
- `closeStatement(Statement stmt)`：关闭Statement
- `closeResultSet(ResultSet rs)`：关闭ResultSet
- `startTransaction(Connection conn)`：开始事务
- `commitTransaction(Connection conn)`：提交事务
- `rollbackTransaction(Connection conn)`：回滚事务

#### 2.2 AppointmentService.java

预约服务类，封装预约相关的业务逻辑。

主要方法：
- `calculatePriority(int waitingDays, int urgency, int grade, int noShowCount)`：计算优先级
- `checkConstraints(int patientId, int doctorId, Date appointmentDate)`：检查约束条件
- `detectConflicts(int doctorId, Date appointmentDate)`：检测冲突
- `generateSolutions(int patientId, int doctorId, Date appointmentDate, String purpose, int urgency)`：生成解决方案
- `adjustSubsequentAppointments(int doctorId, Date originalDate, Date newDate)`：级联调整后续预约
- `createAppointment(int patientId, int doctorId, Date appointmentDate, String purpose)`：创建预约

#### 2.3 SmartAppointmentServlet.java

智能预约Servlet，处理预约请求。

主要功能：
- 接收预约请求参数
- 检查约束条件
- 检测冲突
- 生成解决方案
- 跳转至冲突解决方案页面

#### 2.4 ConfirmSolutionServlet.java

确认解决方案Servlet，处理用户选择的解决方案。

主要功能：
- 接收用户选择的解决方案
- 执行预约调整
- 级联调整后续预约
- 跳转至预约确认页面

### 3. JSP页面

#### 3.1 appointmentForm.jsp

预约表单页面，用户可以选择预约类型、医生、时间和紧急度。

#### 3.2 conflictResolution.jsp

冲突解决方案页面，显示系统生成的3个备选方案，用户可以选择其中一个。

#### 3.3 appointmentConfirmation.jsp

预约确认页面，显示预约成功的信息。

## 部署说明

### 1. 环境要求

- JDK 1.8或以上
- Tomcat 8.5或以上
- MySQL 5.7或以上

### 2. 部署步骤

1. 创建MySQL数据库：
   ```sql
   CREATE DATABASE hms;
   ```

2. 执行数据库脚本：
   ```bash
   mysql -u root -p hms < sql/appointment_conflict_resolution.sql
   ```

3. 配置数据库连接：
   - 修改`src/DBUtil.java`中的数据库连接参数
   - 确保数据库URL、用户名和密码正确

4. 部署到Tomcat：
   - 将项目打包为WAR文件
   - 将WAR文件复制到Tomcat的webapps目录
   - 启动Tomcat服务器

5. 访问系统：
   - 打开浏览器，访问`http://localhost:8080/JavaWeb_Final`
   - 使用示例用户登录：
     - 学生：username=student1, password=123456
     - 医生：username=doctor1, password=123456
     - 管理员：username=admin, password=123456

## 注意事项

1. 确保数据库服务正在运行
2. 确保Tomcat服务器配置正确
3. 定期备份数据库
4. 监控系统性能，特别是在高并发情况下
5. 根据实际需求调整优先级算法参数

## 常见问题

### 1. 预约失败怎么办？

- 检查是否超过了每月预约次数限制
- 检查是否连续两天预约了同一医生
- 检查医生是否已经约满
- 联系管理员解决

### 2. 如何调整预约？

- 登录系统
- 查看预约详情
- 点击"调整预约"按钮
- 选择调整方案
- 确认调整

### 3. 如何处理紧急情况？

- 在预约时选择高紧急度（4-5级）
- 系统会优先处理高紧急度的预约
- 如果需要紧急就诊，可以联系医院直接安排

## 技术支持

如果您在使用过程中遇到问题，请联系技术支持：

- 邮箱：support@example.com
- 电话：13800138000
- 地址：北京市海淀区中关村大街1号

---

**版本**：1.0
**发布日期**：2023-10-01
**版权**：© 2023 智能预约冲突解决系统