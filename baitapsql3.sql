﻿-- tạo data base
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





-- 1. Basic SQL Concepts
-- a. CHAR vs VARCHAR
-- CHAR có độ dài cố định, lưu trữ đúng số ký tự đã khai báo.
-- VARCHAR có độ dài thay đổi, chỉ lưu trữ số ký tự thực tế.
-- Sử dụng CHAR khi biết chính xác độ dài dữ liệu, dùng VARCHAR khi độ dài có thể thay đổi.
CREATE TABLE TestCharVarchar (
    ID INT PRIMARY KEY,
    CharField CHAR(10),  -- Luôn chiếm 10 ký tự dù dữ liệu ngắn hơn
    VarcharField VARCHAR(10) -- Chỉ chiếm số ký tự thực tế
);

INSERT INTO TestCharVarchar VALUES (1, 'ABC', 'ABC');
INSERT INTO TestCharVarchar VALUES (2, 'ABCDEFGHIJ', 'ABCDEFGHIJ');
SELECT * FROM TestCharVarchar;

-- b. DISTINCT vs GROUP BY
-- DISTINCT loại bỏ các bản ghi trùng lặp.
-- GROUP BY nhóm dữ liệu lại để thực hiện các phép toán tổng hợp.
SELECT DISTINCT NoiSinh FROM SINHVIEN;
SELECT NoiSinh FROM SINHVIEN GROUP BY NoiSinh;

-- c. List all students ordered by NgaySinh
-- ORDER BY dùng để sắp xếp kết quả theo một hoặc nhiều cột.
-- Mặc định là ASC (tăng dần), nếu muốn giảm dần thì dùng DESC.
SELECT * FROM SINHVIEN ORDER BY NgaySinh;
SELECT * FROM SINHVIEN ORDER BY NgaySinh DESC;

-- 2. Joins & Relationships
-- a. Types of Joins & INNER JOIN Example
-- INNER JOIN trả về dữ liệu có kết nối giữa hai bảng.
SELECT SV.MaSV, SV.TenSV, K.TenKhoa
FROM SINHVIEN SV
INNER JOIN KHOA K ON SV.MaKH = K.MaKhoa;

-- Modify the query to return only students who belong to the 'Computer Science' department.
SELECT SV.MaSV, SV.TenSV, K.TenKhoa
FROM SINHVIEN SV
INNER JOIN KHOA K ON SV.MaKH = K.MaKhoa
WHERE K.TenKhoa = N'Tin Học';

-- Join without ON condition (CROSS JOIN behavior)
-- Khi sử dụng JOIN mà không có điều kiện ON, nó sẽ tạo ra CROSS JOIN
-- Số dòng trong kết quả sẽ là tích số dòng của hai bảng
SELECT * FROM SINHVIEN CROSS JOIN KHOA;

-- LEFT JOIN & RIGHT JOIN
-- LEFT JOIN: Trả về tất cả từ bảng trái + dữ liệu khớp từ bảng phải, điền NULL nếu không có khớp ở bảng bên phải.
-- được dùng khi muốn lấy tất cả dữ liệu từ bảng bên trái và chỉ lấy dữ liệu khớp từ bảng bên phải.
SELECT SV.MaSV, SV.TenSV, K.TenKhoa
FROM SINHVIEN SV
LEFT JOIN KHOA K ON SV.MaKH = K.MaKhoa;

-- RIGHT JOIN: Trả về tất cả từ bảng phải + dữ liệu khớp từ bảng trái, điền NULL nếu không có khớp ở bảng bên trái.
-- lấy tất cả dữ liệu từ bảng bên phải và chỉ lấy dữ liệu khớp từ bảng bên trái. 
SELECT SV.MaSV, SV.TenSV, K.TenKhoa
FROM SINHVIEN SV
RIGHT JOIN KHOA K ON SV.MaKH = K.MaKhoa;

-- FULL OUTER JOIN
-- Trả về tất cả dữ liệu từ cả hai bảng, điền NULL nếu không có kết nối.
-- được dùng khi muốn lấy tất cả dữ liệu từ cả hai bảng, ngay cả khi không có kết nối giữa chúng
SELECT SV.MaSV, SV.TenSV, K.TenKhoa
FROM SINHVIEN SV
FULL OUTER JOIN KHOA K ON SV.MaKH = K.MaKhoa;

-- Self-Join
-- Self-Join dùng để nối một bảng với chính nó.
-- thường được sử dụng khi muốn so sánh các hàng trong cùng một bảng. ví dụ tìm sinh viên cùng quê.
SELECT A.TenSV AS Student1, B.TenSV AS Student2, A.NoiSinh
FROM SINHVIEN A
INNER JOIN SINHVIEN B ON A.NoiSinh = B.NoiSinh AND A.MaSV <> B.MaSV;

-- CROSS JOIN
-- Kết hợp tất cả sinh viên với tất cả môn học (tạo tất cả tổ hợp có thể có).
SELECT SV.TenSV, MH.TenMH
FROM SINHVIEN SV
CROSS JOIN MONHOC MH;

-- Joins with Aggregation( tập hợp)
-- Trả về sinh viên có điểm trung bình trên 7.
SELECT SV.MaSV, SV.TenSV, AVG(KQ.Diem) AS AvgScore
FROM SINHVIEN SV
INNER JOIN KETQUA KQ ON SV.MaSV = KQ.MaSV
GROUP BY SV.MaSV, SV.TenSV
HAVING AVG(KQ.Diem) > 7;

-- Count students per department (include zero students)
-- Đếm số lượng sinh viên theo khoa, bao gồm khoa không có sinh viên.
SELECT K.TenKhoa, COUNT(SV.MaSV) AS StudentCount
FROM KHOA K
LEFT JOIN SINHVIEN SV ON K.MaKhoa = SV.MaKH
GROUP BY K.TenKhoa;

-- Highest score per subject
-- Tìm điểm cao nhất của mỗi môn học.
SELECT MH.TenMH, MAX(KQ.Diem) AS HighestScore
FROM KETQUA KQ
INNER JOIN MONHOC MH ON KQ.MaMH = MH.MaMH
GROUP BY MH.TenMH;

-- Student with highest score per subject
-- Tìm sinh viên có điểm cao nhất cho từng môn.
SELECT KQ.MaMH, SV.TenSV, KQ.Diem
FROM KETQUA KQ
INNER JOIN SINHVIEN SV ON KQ.MaSV = SV.MaSV
WHERE KQ.Diem = (SELECT MAX(Diem) FROM KETQUA WHERE MaMH = KQ.MaMH);

-- Students who took at least two different subjects
-- Lấy danh sách sinh viên học ít nhất 2 môn.
SELECT KQ.MaSV, SV.TenSV
FROM KETQUA KQ
INNER JOIN SINHVIEN SV ON KQ.MaSV = SV.MaSV
GROUP BY KQ.MaSV, SV.TenSV
HAVING COUNT(DISTINCT KQ.MaMH) >= 2;

-- Replace NULL department names with 'No Department Assigned'
SELECT SV.MaSV, SV.TenSV, COALESCE(K.TenKhoa, N'Chưa có khoa') AS Department
FROM SINHVIEN SV
LEFT JOIN KHOA K ON SV.MaKH = K.MaKhoa;

-- 3. Advanced Queries (Subqueries, Aggregations)
-- Find students who have taken a subject multiple times (LanThi > 1)
SELECT MaSV, MaMH, COUNT(*) AS ExamCount
FROM KETQUA
GROUP BY MaSV, MaMH
HAVING COUNT(*) > 1;

-- Find students who scored above the average in any exam
SELECT MaSV, MaMH, Diem
FROM KETQUA
WHERE Diem > (SELECT AVG(Diem) FROM KETQUA);

-- Find students who scored in the top 10%
SELECT MaSV, MaMH, Diem 
FROM (
    SELECT MaSV, MaMH, Diem, 
           PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY Diem) 
           OVER () AS Top10Percentile
    FROM KETQUA
	) AS Subquery
WHERE Diem >= Top10Percentile;

-- Find the top 3 students with the highest scores
SELECT TOP 3 MaSV, AVG(Diem) AS AvgScore
FROM KETQUA
GROUP BY MaSV
ORDER BY AvgScore DESC;

-- Retrieve the second-highest scholarship from SINHVIEN
SELECT DISTINCT HocBong
FROM SINHVIEN
ORDER BY HocBong DESC
OFFSET 1 ROW FETCH NEXT 1 ROW ONLY;
