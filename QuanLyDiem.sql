if exists (select * from sysdatabases where name = 'QLDiem')
    drop database QLDiem
go 

create database QLDiem
go

ALTER DATABASE QlyDIem SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE QlyDIem MODIFY NAME = QlyDiem;
ALTER DATABASE QlyDiem SET MULTI_USER;
GO
CREATE DATABASE QlyDiem
GO




USE QlyDiem
GO
IF OBJECT_ID('SINHVIEN', 'U') IS NULL
BEGIN
CREATE TABLE SINHVIEN (
MaSV CHAR(3) PRIMARY KEY,
HoSV nVARCHAR(30) NOT NULL,
TenSV nVARCHAR(10) NOT NULL,
Phai bit DEFAULT 1, -- 1 = Active, 0 = Inactive,
NgaySinh DATE,
NoiSinh nVARCHAR(25),
MaKH CHAR(2),
HocBong INT
);
END
SELECT OBJECT_ID('SINHVIEN', 'U') AS ObjectID;


USE QlyDiem
GO
INSERT INTO SINHVIEN (MaSV, HoSV, TenSV, Phai, NgaySinh, NoiSinh, MaKH, HocBong)  
VALUES  
('A01', N'Nguyễn Thị', N'Hải', 1, '1993-02-23', N'Hà Nội', 'TH', 130000),  
('A02', N'Trần Văn', N'Chính', 0, '1992-12-24', N'Ninh Bình', 'VL', 150000),  
('A03', N'Lê Thu Bạch', N'Yến', 1, '1993-02-21', N'Tp HCM', 'TH', 170000),  
('A04', N'Trần Anh', N'Tuấn', 0, '1994-12-20', N'Hà Nội', 'AV', 80000),  
('A05', N'Lâm Ngọc', N'Hải', 0, '1993-10-11', N'Tp HCM', 'AV', 100000),  
('B01', N'Trần Thanh', N'Mai', 1, '1992-11-03', N'Hà Nội', 'PH', 0),  
('B02', N'Trần Thị Thu', N'Thủy', 1, '1994-01-02', N'Tp HCM', 'AV', 0);
GO
SELECT * FROM SINHVIEN;
DELETE FROM SINHVIEN;


USE QlyDiem
GO
IF OBJECT_ID('KHOA', 'U') IS NULL
BEGIN
CREATE TABLE KHOA (
MaKhoa CHAR(2) PRIMARY KEY,
TenKhoa nVARCHAR(20) NOT NULL
);
END
INSERT INTO KHOA (MaKhoa, TenKhoa)  
VALUES  
('AV', N'Anh văn'),  
('TH', N'Tin Học'),  
('TR', N'Triết'),  
('VL', N'Vật Lý');
SELECT * FROM KHOA;
DELETE FROM KHOA; 


IF OBJECT_ID('MONHOC', 'U') IS NULL
BEGIN
CREATE TABLE MONHOC (
MaMH CHAR(2) PRIMARY KEY,
TenMH nVARCHAR(30) NOT NULL,
SoTiet TINYINT
);
END
INSERT INTO MONHOC (MaMH, TenMH, SoTiet)  
VALUES  
('01', N'Cơ sở dữ liệu', 45),  
('02', N'Trí tuệ nhân tạo', 45),  
('03', N'Truyền tin', 45),  
('04', N'Đồ họa', 60),  
('05', N'Văn phạm', 60),  
('06', N'Kỹ thuật lập trình', 45),  
('07', N'Kỹ năng mềm', 30);

SELECT * FROM MONHOC;
DELETE FROM MONHOC;

IF OBJECT_ID('KETQUA', 'U') IS NULL
BEGIN
CREATE TABLE KETQUA (
MaSV CHAR(3),
MaMH CHAR(2) ,
LanThi TINYINT,
Diem DECIMAL(4,2),
PRIMARY KEY (MaSV, MaMH, LanThi));
END

INSERT INTO KETQUA (MaSV, MaMH, LanThi, Diem)  
VALUES  
('A01', '01', 1, 3.00),  
('A01', '01', 2, 7.00),  
('A02', '01', 1, 7.00),  
('A03', '01', 1, 2.00),  
('A03', '01', 2, 5.00),  
('A03', '03', 1, 2.50),  
('A03', '03', 2, 9.00),  
('A05', '07', 1, 7.00),  
('B01', '01', 1, 7.00),  
('B01', '03', 1, 2.50),  
('B02', '04', 1, 10.00);


IF OBJECT_ID('KETQUA', 'U') IS NULL
BEGIN
ALTER TABLE KETQUA 
ADD CONSTRAINT FK_KETQUA_SINHVIEN 
FOREIGN KEY (MaSV) REFERENCES SINHVIEN(MaSV);

ALTER TABLE KETQUA 
ADD CONSTRAINT FK_KETQUA_MONHOC 
FOREIGN KEY (MaMH) REFERENCES MONHOC(MaMH);
END

SELECT * FROM KETQUA;
DELETE FROM KETQUA;

ALTER TABLE KHOA  
DROP CONSTRAINT PK_KHOA;  
ALTER TABLE KHOA  
ALTER COLUMN MAKHOA CHAR(3) NOT NULL;
ALTER TABLE KHOA  
ADD CONSTRAINT PK_KHOA PRIMARY KEY (MAKHOA)
GO;
ALTER TABLE SINHVIEN  
ADD CONSTRAINT FK_SINHVIEN_MAKHOA  
FOREIGN KEY (MaKH) REFERENCES KHOA(MaKhoa);

DELETE FROM SINHVIEN;
SELECT * 
FROM information_schema.tables
WHERE table_name = 'SINHVIEN';

CREATE INDEX idx_TenSv
ON SINHVIEN (TenSV);
GO


USE QlyDiem
GO
CREATE FUNCTION DoStudentHaveScholarship (@MaSV VARCHAR(10))  
RETURNS BIT  
AS  
BEGIN  
    DECLARE @Result BIT;  

    -- Kiểm tra giá trị học bổng của sinh viên
    IF EXISTS (SELECT 1 FROM SINHVIEN WHERE MaSV = @MaSV AND HocBong > 0)  
        SET @Result = 1;  -- True (có học bổng)  
    ELSE  
        SET @Result = 0;  -- False (không có học bổng)  

    RETURN @Result;  
END;

SELECT MaSV, dbo.DoStudentHaveScholarship(MaSV) AS HaveScholarship  
FROM SINHVIEN;

CREATE VIEW V_SinhVien_HocBong AS  
SELECT  
    MaSV,  
    HoSV,  
    TenSV,  
    Phai,  
    MaKH,  
    HocBong,  
    dbo.DoStudentHaveScholarship(MaSV) AS HaveScholarship  
FROM SINHVIEN;
SELECT * FROM V_SinhVien_HocBong;
