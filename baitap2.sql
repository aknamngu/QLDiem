-- tạo data base
use master
	if exists(select * from sysdatabases where name='QLDiem')
	drop database QLDiem
go
create database QLDiem
go
use QLDiem

-- tạo các bảng
create table MONHOC
(
	 MaMH char(2) constraint PK_MONHOC primary key,
	 TenMH nVarchar(30) not null,
	 SoTiet Tinyint not null
)
create table KHOA
(
	 MaKhoa char(2) constraint PK_Khoa primary key,
	 TenKhoa nVarChar(20) not null
)
create table SINHVIEN
(
	 MaSV char(3) constraint PK_SINHVIEN primary key,
	 HoSV nvarchar(30),
	 TenSV Nvarchar(10),
	 Phai bit,
	 NgaySinh Date,
	 NoiSinh nvarchar(25),
	 MaKH char(2) constraint FK_SINHVIEN_KHOA foreign key(MaKH)
	references KHOA(MaKhoa),
	 HocBong float
)
create table KETQUA
(
	 MaSV char (3) constraint FK_KETQUA_SINHVIEN foreign key(MaSV) references
	SINHVIEN(MaSV),
	 MaMH char (2) constraint FK_KETQUA_MONHOC foreign key(MaMH) references
	MONHOC(MaMH),
	 LanThi Tinyint,
	 Diem Decimal(4,2) not null,
	 constraint PK_KetQua primary key (MaSV, MaMH, LanThi)
) 


-- nhập dữ liệu vào các bảng
INSERT INTO KHOA (MaKhoa, TenKhoa) VALUES
	('AV', N'Anh văn'),
	('TH', N'Tin Học'),
	('TR', N'Triết'),
	('VL', N'Vật Lý');
SELECT * FROM KHOA;

INSERT INTO MONHOC (MaMH, TenMH, SoTiet) VALUES
	('01', N'Cơ sở dữ liệu', 45),
	('02', N'Trí tuệ nhân tạo', 45),
	('03', N'Truyền tin', 45),
	('04', N'Đồ họa', 60),
	('05', N'Văn phạm', 60),
	('06', N'Kỹ thuật lập trình', 45);
SELECT * FROM MONHOC;



INSERT INTO SINHVIEN (MaSV, HoSV, TenSV, Phai, NgaySinh, NoiSinh, MaKH, HocBong) VALUES
	('A01', N'Nguyễn Thị', N'Hải', 1, '2003-02-23', N'Hà Nội', 'TH', 1300000),
	('A02', N'Trần Văn', N'Chính', 0, '2005-12-24', N'Bình Định', 'VL', 1500000),
	('A03', N'Lê Thu Bạch', N'Yến', 1, '2003-02-21', N'TP HCM', 'TH', 1700000),
	('A04', N'Trần Anh', N'Tuấn', 0, '2004-12-20', N'Hà Nội', 'AV', 800000),
	('B01', N'Trần Thanh', N'Mai', 1, '2003-08-12', N'Hải Phòng', 'TR', 0),
	('B02', N'Trần Thị Thu', N'Thủy', 1, '2004-01-02', N'TP HCM', 'AV', 0);
SELECT * FROM SINHVIEN;

INSERT INTO KETQUA (MaSV, MaMH, LanThi, Diem) VALUES
	('A01', '01', 1, 3),
	('A01', '01', 2, 6),
	('A01', '02', 2, 6),
	('A01', '03', 1, 5),
	('A02', '01', 1, 4.5),
	('A02', '01', 2, 7),
	('A02', '03', 1, 10),
	('A02', '05', 1, 9),
	('A03', '01', 1, 2),
	('A03', '01', 2, 5),
	('A03', '03', 1, 2.5),
	('A03', '03', 2, 4),
	('A04', '05', 2, 10),
	('B01', '01', 1, 7),
	('B01', '03', 1, 2.5),
	('B01', '03', 2, 5),
	('B02', '02', 1, 6),
	('B02', '04', 1, 10);
SELECT * FROM KETQUA;



-- PART 1: TRANSACTIONS

-- 1. Insert a new student and an initial record in KETQUA
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO SINHVIEN (MaSV, HoSV, TenSV, Phai, NgaySinh, NoiSinh, MaKH, HocBong) 
    VALUES ('C01', N'Phạm Văn', N'Tùng', 0, '2002-10-15', N'Đà Nẵng', 'TH', 1200000);

    INSERT INTO KETQUA (MaSV, MaMH, LanThi, Diem) 
    VALUES ('C01', '01', 1, 9);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT ERROR_MESSAGE();
END CATCH;


SELECT * FROM SINHVIEN WHERE MaSV = 'C01';
SELECT * FROM KETQUA WHERE MaSV = 'C01';


-- 2. Update a student's HocBong if average score > 8.5
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE SINHVIEN
    SET HocBong = HocBong * 1.10
    WHERE MaSV IN (
        SELECT MaSV FROM KETQUA
        GROUP BY MaSV
        HAVING AVG(ISNULL(Diem, 0)) > 8.5
    );
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT ERROR_MESSAGE();
END CATCH;


SELECT MaSV, HocBong FROM SINHVIEN;


-- 3. Delete student and related KETQUA records
BEGIN TRANSACTION;
BEGIN TRY
    IF EXISTS (SELECT 1 FROM SINHVIEN WHERE MaSV = 'C01')
    BEGIN
        DELETE FROM KETQUA WHERE MaSV = 'C01';
        DELETE FROM SINHVIEN WHERE MaSV = 'C01';
        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        PRINT 'Student not found. Rolling back.';
        ROLLBACK TRANSACTION;
    END
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT ERROR_MESSAGE();
END CATCH;


SELECT * FROM SINHVIEN WHERE MaSV = 'C01';
SELECT * FROM KETQUA WHERE MaSV = 'C01';


-- 4. Update all students' HocBong based on average scores
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE SINHVIEN
    SET HocBong = HocBong * 1.15
    WHERE MaSV IN (
        SELECT MaSV FROM KETQUA GROUP BY MaSV HAVING AVG(Diem) > 9.0
    );

    UPDATE SINHVIEN
    SET HocBong = HocBong * 1.10
    WHERE MaSV IN (
        SELECT MaSV FROM KETQUA GROUP BY MaSV HAVING AVG(Diem) BETWEEN 8.0 AND 9.0
    );

    UPDATE SINHVIEN
    SET HocBong = HocBong * 0.95
    WHERE MaSV IN (
        SELECT MaSV FROM KETQUA GROUP BY MaSV HAVING AVG(Diem) < 5.0
    );
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
END CATCH;


SELECT MaSV, HocBong FROM SINHVIEN;


-- 5. Insert a new exam result with validation
BEGIN TRANSACTION;
BEGIN TRY
    IF EXISTS (SELECT 1 FROM SINHVIEN WHERE MaSV = 'C01') AND
       EXISTS (SELECT 1 FROM MONHOC WHERE MaMH = '01') AND
       (8.5 BETWEEN 0 AND 10)
    BEGIN
        INSERT INTO KETQUA (MaSV, MaMH, LanThi, Diem) VALUES ('C01', '01', 1, 8.5);
        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        PRINT 'Validation failed. Rolling back.';
        ROLLBACK TRANSACTION;
    END
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT ERROR_MESSAGE();
END CATCH;


SELECT * FROM KETQUA WHERE MaSV = 'C01';



-- PART 2: SQL SERVER SCHEDULING


-- 6. Backup database job at 2 AM daily

-- Xóa job nếu đã tồn tại
EXEC msdb.dbo.sp_delete_job @job_name = 'Backup_QLDiem';

-- Tạo lại job
EXEC msdb.dbo.sp_add_job 
    @job_name = 'Backup_QLDiem';

-- Thêm bước thực hiện backup database
EXEC msdb.dbo.sp_add_jobstep 
    @job_name = 'Backup_QLDiem', 
    @step_name = 'Backup Database',  
    @subsystem = 'TSQL', 
    @command = 'BACKUP DATABASE QLDiem TO DISK = ''D:\Backups\QLDiem.bak'' WITH FORMAT, INIT;', 
    @on_success_action = 1, 
    @on_fail_action = 2;  

-- Lên lịch chạy hàng ngày vào lúc 2:00 sáng
EXEC msdb.dbo.sp_add_jobschedule 
    @job_name = 'Backup_QLDiem', 
    @name = 'Daily Backup Schedule',  
    @freq_type = 4,  
    @freq_interval = 1, 
    @active_start_time = 020000;  

-- Gán job cho SQL Server Agent
EXEC msdb.dbo.sp_add_jobserver 
    @job_name = 'Backup_QLDiem', 
    @server_name = '(local)';  


-- 7. Reset scholarships every Monday at 8 AM
-- Xóa job nếu đã tồn tại
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'Reset_HocBong')
    EXEC msdb.dbo.sp_delete_job @job_name = 'Reset_HocBong';

-- Tạo job mới
EXEC msdb.dbo.sp_add_job 
    @job_name = 'Reset_HocBong', 
    @enabled = 1, 
    @notify_level_eventlog = 2, 
    @delete_level = 3;

-- Thêm bước chạy procedure usp_UpdateScholarships
EXEC msdb.dbo.sp_add_jobstep 
    @job_name = 'Reset_HocBong', 
    @step_name = 'Run Scholarship Update',  
    @subsystem = 'TSQL', 
    @command = 'EXEC usp_UpdateScholarships',
    @retry_attempts = 3, 
    @retry_interval = 5;

-- Lên lịch chạy job vào **8:00 AM mỗi thứ Hai**
EXEC msdb.dbo.sp_add_jobschedule 
    @job_name = 'Reset_HocBong', 
    @name = 'Weekly Scholarship Reset',  
    @freq_type = 8,  -- Chạy hàng tuần
    @freq_interval = 2,  -- 2 = Thứ Hai
    @freq_recurrence_factor = 1, -- Chạy mỗi tuần
    @active_start_time = 080000;

-- Gán job cho SQL Server Agent
EXEC msdb.dbo.sp_add_jobserver 
    @job_name = 'Reset_HocBong';


-- 8. Delete exam records where Diem = 0 every Friday at 6 PM
-- Xóa job nếu đã tồn tại
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'Delete_Zero_Scores')
    EXEC msdb.dbo.sp_delete_job @job_name = 'Delete_Zero_Scores';

-- Tạo job mới
EXEC msdb.dbo.sp_add_job 
    @job_name = 'Delete_Zero_Scores', 
    @enabled = 1, 
    @notify_level_eventlog = 2, 
    @delete_level = 3;

-- Thêm bước xóa điểm 0 trong KETQUA
EXEC msdb.dbo.sp_add_jobstep 
    @job_name = 'Delete_Zero_Scores', 
    @step_name = 'Delete_Zero_Scores_Step',  -- Thêm step_name
    @subsystem = 'TSQL', 
    @command = 'DELETE FROM KETQUA WHERE Diem = 0',
    @retry_attempts = 3, 
    @retry_interval = 5;

-- Lên lịch chạy job vào **6:00 PM mỗi thứ Sáu**
EXEC msdb.dbo.sp_add_jobschedule 
    @job_name = 'Delete_Zero_Scores', 
    @name = 'Weekly_Delete_Zero_Scores',  -- Thêm name cho schedule
    @freq_type = 8,  -- Chạy hàng tuần
    @freq_interval = 5,  -- 5 = Thứ Sáu
    @freq_recurrence_factor = 1, -- Chạy mỗi tuần
    @active_start_time = 180000;

-- Gán job cho SQL Server Agent
EXEC msdb.dbo.sp_add_jobserver 
    @job_name = 'Delete_Zero_Scores';

-- 9. Generate student report every 1st of the month
-- Xóa job nếu đã tồn tại
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'Generate_Student_Report')
    EXEC msdb.dbo.sp_delete_job @job_name = 'Generate_Student_Report';

-- Tạo procedure để lấy báo cáo sinh viên
IF OBJECT_ID('usp_Schedule_Student_Report', 'P') IS NOT NULL
    DROP PROCEDURE usp_Schedule_Student_Report;
GO

CREATE PROCEDURE usp_Schedule_Student_Report 
AS
BEGIN
    SELECT MaSV, COUNT(*) AS TotalExams, AVG(Diem) AS AvgScore 
    FROM KETQUA 
    GROUP BY MaSV;
END;
GO

-- Tạo job
EXEC msdb.dbo.sp_add_job 
    @job_name = 'Generate_Student_Report', 
    @enabled = 1, 
    @notify_level_eventlog = 2, 
    @delete_level = 3;

-- Thêm bước chạy procedure
EXEC msdb.dbo.sp_add_jobstep 
    @job_name = 'Generate_Student_Report', 
    @step_name = 'Generate_Student_Report_Step',  -- Thêm step_name
    @subsystem = 'TSQL', 
    @command = 'EXEC usp_Schedule_Student_Report',
    @retry_attempts = 3, 
    @retry_interval = 5;

-- Lên lịch chạy vào **7:00 AM ngày 1 hàng tháng**
EXEC msdb.dbo.sp_add_jobschedule 
    @job_name = 'Generate_Student_Report', 
    @name = 'Monthly_Student_Report',  -- Thêm name cho schedule
    @freq_type = 16,  -- Chạy hàng tháng
    @freq_interval = 1,  -- Ngày 1 mỗi tháng
    @freq_recurrence_factor = 1,  -- Đảm bảo chạy mỗi tháng một lần
    @active_start_time = 070000;

-- Gán job cho SQL Server Agent
EXEC msdb.dbo.sp_add_jobserver 
    @job_name = 'Generate_Student_Report';

-- tétt
SELECT * FROM msdb.dbo.sysjobschedules 
WHERE job_id IN (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = 'Generate_Student_Report');



-- 10. Log total students every Sunday at midnight
-- Xóa job nếu đã tồn tại
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'Log_Total_Students')
    EXEC msdb.dbo.sp_delete_job @job_name = 'Log_Total_Students';

-- Tạo bảng lưu log số lượng sinh viên
IF OBJECT_ID('StudentLog', 'U') IS NULL
BEGIN
    CREATE TABLE StudentLog (
        LogID INT IDENTITY PRIMARY KEY, 
        LogDate DATETIME DEFAULT GETDATE(), 
        TotalStudents INT
    );
END;

-- Tạo job
EXEC msdb.dbo.sp_add_job 
    @job_name = 'Log_Total_Students', 
    @enabled = 1, 
    @notify_level_eventlog = 2, 
    @delete_level = 3;

-- Thêm bước ghi log số sinh viên
EXEC msdb.dbo.sp_add_jobstep 
    @job_name = 'Log_Total_Students', 
    @step_name = 'Log_Student_Count_Step',  -- Thêm step_name
    @subsystem = 'TSQL', 
    @command = 'INSERT INTO StudentLog (LogDate, TotalStudents) SELECT GETDATE(), COUNT(*) FROM SINHVIEN',
    @retry_attempts = 3, 
    @retry_interval = 5;

-- Lên lịch chạy vào **12:00 AM mỗi Chủ Nhật**
EXEC msdb.dbo.sp_add_jobschedule 
    @job_name = 'Log_Total_Students', 
    @name = 'Weekly_Log_Student_Count',  -- Thêm name cho schedule
    @freq_type = 8,  -- Chạy hàng tuần
    @freq_interval = 1,  -- 1 = Chủ Nhật
    @freq_recurrence_factor = 1, -- Chạy mỗi tuần
    @active_start_time = 000000;

-- Gán job cho SQL Server Agent
EXEC msdb.dbo.sp_add_jobserver 
    @job_name = 'Log_Total_Students';

-- 11. Cancel scheduled Backup_QLDiem job
EXEC msdb.dbo.sp_delete_job @job_name = 'Backup_QLDiem';