use master
	if exists(select * from sysdatabases where name='QLDiem')
	drop database QLDiem
go
create database QLDiem
go
use QLDiem

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
--2. nhap dư lieu vào bảng
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
DELETE FROM SINHVIEN;


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

DELETE FROM KETQUA;


-- Part 1: Transactions

-- 1. Insert a new student and an initial record in KETQUA
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO SINHVIEN (MaSV, HoSV, TenSV, Phai, NgaySinh, NoiSinh, MaKH, HocBong) 
    VALUES ('C01', N'Phạm Văn', N'Tùng', 0, '2002-10-15', N'Đà Nẵng', 'TH', 1200000);

    INSERT INTO KETQUA (MaSV, MaMH, LanThi, Diem) 
    VALUES ('C01', '01', 1, NULL);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
END CATCH;

-- 2. Update a student's HocBong if average score > 8.5
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE SINHVIEN
    SET HocBong = HocBong * 1.10
    WHERE MaSV IN (
        SELECT MaSV FROM KETQUA
        GROUP BY MaSV
        HAVING AVG(Diem) > 8.5
    );
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
END CATCH;

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
        ROLLBACK TRANSACTION;
    END
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
END CATCH;

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

-- 5. Insert a new exam result with validation
BEGIN TRANSACTION;
BEGIN TRY
    IF EXISTS (SELECT 1 FROM SINHVIEN WHERE MaSV = 'C01') AND
       EXISTS (SELECT 1 FROM MONHOC WHERE MaMH = '01') AND
       0 <= 8.5 AND 8.5 <= 10
    BEGIN
        INSERT INTO KETQUA (MaSV, MaMH, LanThi, Diem) VALUES ('C01', '01', 1, 8.5);
        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        ROLLBACK TRANSACTION;
    END
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
END CATCH;