use master
	if exists(select * from sysdatabases where name='QLDiem')
drop database QLDiem
go
create database QLDiem
go
use QLDiem
create table KHOA
(
	MaKhoa char(2) constraint PK_KHOA primary key,
	TenKhoa nVarChar(20)
)
create table MONHOC
(
	MaMH char(2) constraint PK_MONHOC primary key,
	TenMH nVarchar(30),
	SoTiet Tinyint
)
create table SINHVIEN
(
	MaSV char(3) constraint PK_SINHVIEN primary key,
	HoSV nvarchar(30) not null,
	TenSV Nvarchar(10) not null,
	Phai bit not null,
	NgaySinh Date not null,
	NoiSinh nvarchar(25),
	MaKH char(2) constraint FK_SINHVIEN_KHOA foreign key references
	KHOA(MaKhoa),
	HocBong int default (0)
)
create table KETQUA
(
	MaSV char (3) constraint FK_KETQUA_SINHVIEN foreign key(masv) references
	SINHVIEN(MaSV),
	MaMH char (2) constraint FK_KETQUA_MONHOC foreign key(MaMH) references
	MONHOC(MaMH),
	LanThi Tinyint,
	Diem Decimal(4,2),
	constraint PK_KETQUA primary key (MaSV,MaMH,LanThi)
)
INSERT INTO KHOA
VALUES
	('AV', N'Anh văn'),
	('TH', N'Tin Học'),
	('TR', N'Triết'),
	('VL', N'Vật Lý')
INSERT INTO MONHOC
VALUES
	('01', N'Cơ sở dữ liệu', 45),
	('02', N'Trí tuệ nhân tạo', 45),
	('03', N'Truyền tin', 45),
	('04', N'Đồ họa', 60),
	('05', N'Văn phạm', 60),
	('06', N'Kỹ thuật lập trình', 45),
	('07', N'Kỹ năng mềm', 30)
set dateformat dmy
INSERT INTO SINHVIEN(MaSV, HoSV, TenSV, Phai, NgaySinh, NoiSinh, MaKh, HocBong)
VALUES
	('A01', N'Nguyễn Thị', N'Hải', 1, '23/2/2001', N'Hà Nội', 'TH', 130000),
	('A02', N'Trần Văn', N'Chính', 0, '20021224', N'Ninh Bình', 'VL', 150000),
	('A03', N'Lê Thu Bạch', N'Yến', 1, '20000221', N'Tp HCM', 'TH', 170000),
	('A04', N'Trần Anh', N'Tuấn', 0, '20031220', N'Hà Nội', 'AV', 80000),
	('A05', N'Lâm Ngọc', N'Hải', 0, '20021011', N'Tp HCM', 'AV', 100000),
	('A06', N'Phạm Văn', N'Hải', 0, '20041005', N'Nha Trang', 'TR', 190000),
	('B01', N'Trần Thanh', N'Mai', 1, '20030812', N'Hải Phòng', 'TR', 0),
	('B02', N'Trần Thị Thu', N'Thủy', 1, '20010102', N'Tp HCM', 'AV', 0)
INSERT INTO KETQUA (MaSV, MaMH, LanThi, Diem)
VALUES
	('A01', '01', 1, 3),
	('A01', '01', 2, 6),
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
	('A05', '05', 1, 8),
	('A05', '07', 1, 9),
	('B01', '01', 1, 7),
	('B01', '03', 1, 2.5),
	('B01', '03', 2, 5),
	('B02', '02', 1, 6),
	('B02', '04', 1, 10)



--Yêu cầu 1:
--1. Tiến hành chạy script để tạo CSDL và nhập liệu.
--2. Sử dụng các lệnh select * from <Tên Table> để xem dữ liệu của tất cả các Table và
--chụp lại các bảng dữ liệu tương ứng và dán vào file word bài làm.
select * from KHOA;
SELECT * FROM MONHOC;
SELECT * FROM SINHVIEN;
SELECT * FROM KETQUA;



--Yêu cầu 2:
--Thực hiện các ví dụ sau
--1. Cho biết sinh viên sinh vào tháng 2 và có tuổi trên 22. 
--Thông tin gồm: Mã số sinh viên, họ tên, giới tính và tuổi

select		masv as 'Mã sinh viên', hosv + ' ' + tensv as 'Họ và tên',
			[Giới tính] = case phai when 0 then 'Nam' else N'Nữ' end,
			Tuổi = year(getdate()) - year(ngaysinh)
from		SinhVien
where		month(ngaysinh) = 2
			and (year(getdate()) - year(ngaysinh)) > 22



--2. Cho biết mã số sinh viên, họ và tên, giới tính và cột ghi chú: ‘Có học bổng’ hoặc ‘Không có học bổng’

select		masv as 'Mã sinh viên', hosv + ' ' + tensv as 'Họ và tên',
			[Giới tính] = case phai when 0 then 'Nam' else N'Nữ' end,
			[Ghi chú] = case when hocbong > 0 then N'Có học bổng'
else		 N'Không có học bổng' end
from		SinhVien




--3. Cho biết mã số sinh viên, họ và tên, giới tính và tên khoa
-- Cách 1
select		masv as 'Mã sinh viên', hosv + ' ' + tensv as 'Họ và tên',
			[Giới tính] = case phai when 0 then 'Nam' else N'Nữ' end,
			tenkhoa as 'Tên khoa'
from		SinhVien, Khoa
where		makh = makhoa

-- Cách 2
select		masv as 'Mã sinh viên', hosv + ' ' + tensv as 'Họ và tên',
			[Giới tính] = case phai when 0 then 'Nam' else N'Nữ' end,
			tenkhoa as 'Tên khoa'
from		SinhVien join Khoa on makh = makhoa


--Yêu cầu 3:
--Mỗi yêu cầu phải trình bày nội dung và kết quả thực hiện lưu trong file word tương tự như Lab03-02
--1. Danh sách sinh viên có nơi sinh ở Hà Nội và sinh vào tháng 02,
--gồm các thông tin: Họ và tên của sinh viên, Nơi sinh và Ngày sinh.
SELECT		HoSV + ' ' + TenSV AS [Họ và tên], NoiSinh, NgaySinh
FROM		SINHVIEN
WHERE		NoiSinh = N'Hà Nội' AND MONTH(NgaySinh) = 2;



--2. Danh sách sinh viên có tuổi lớn hơn 20, 
--thông tin gồm: Họ tên sinh viên, Tuổi, Học bổng (dùng hàm getdate() để lấy ngày tháng năm hiện tại. Tuoi = YEAR(GETDATE()) - YEAR(NgaySinh)

SELECT		HoSV + ' ' + TenSV AS [Họ và tên],
			YEAR(GETDATE()) - YEAR(NgaySinh) AS Tuổi,
			HocBong
FROM		SINHVIEN
WHERE		YEAR(GETDATE()) - YEAR(NgaySinh) > 20;


--3. Danh sách sinh viên có tuổi từ 20 đến 22, 
--gồm: Họ tên sinh viên, Tuổi, Tên khoa. 

SELECT		SV.HoSV + ' ' + SV.TenSV AS [Họ và tên],
			YEAR(GETDATE()) - YEAR(SV.NgaySinh) AS Tuổi,
			KH.TenKhoa
FROM		SINHVIEN SV
JOIN		KHOA KH ON SV.MaKH = KH.MaKhoa
WHERE		YEAR (GETDATE()) - YEAR(SV.NgaySinh) BETWEEN 20 AND 22;



--4. Danh sách sinh viên đến ngày sinh nhật (trùng ngày và tháng sinh với hiện tại)
SELECT HoSV + ' ' + TenSV AS [Họ và tên], NgaySinh
FROM SINHVIEN
WHERE DAY(NgaySinh) = DAY(GETDATE()) AND MONTH(NgaySinh) = MONTH(GETDATE());


--5. Cho biết thông tin về mức học bổng của các sinh viên, 
--gồm: Mã sinh viên, Phái, Mã khoa, Mức học bổng. Trong đó, mức học bổng sẽ hiển thị là ‘Học bổng cao’ 
--nếu giá trị của học bổng lớn hơn 150,000 và ngược lại hiển thị là ‘Mức trung bình.
SELECT MaSV, 
       CASE Phai WHEN 0 THEN 'Nam' ELSE N'Nữ' END AS [Phái], 
       MaKH, 
       CASE 
           WHEN HocBong > 150000 THEN N'Học bổng cao'
           WHEN HocBong > 0 THEN N'Mức trung bình'
           ELSE N'Không có học bổng' 
       END AS [Mức học bổng]
FROM SINHVIEN;


--6. Danh sách sinh viên sinh vào quý 1, năm 2001, 
--gồm các thông tin: Họ tên sinh viên, Phái (ghi rõ “Nam” hoặc “Nữ”), Ngày sinh. Gợi ý: Dùng hàm datepart(q, ngaysinh)
SELECT HoSV + ' ' + TenSV AS [Họ và tên], 
       CASE Phai WHEN 0 THEN 'Nam' ELSE N'Nữ' END AS [Phái], 
       NgaySinh
FROM SINHVIEN
WHERE DATEPART ( QUARTER, NgaySinh)= 1  AND YEAR(NgaySinh) = 2001;



--7. Cho biết kết quả điểm thi của các sinh viên, 
--gồm các thông tin: Họ tên sinh viên, Mã môn học, lần thi, điểm, kết quả (nếu điểm nhỏ hơn 5 thì rớt ngược lại đậu).
SELECT SV.HoSV + ' ' + SV.TenSV AS [Họ và tên], KQ.MaMH, KQ.LanThi, KQ.Diem, 
       CASE WHEN KQ.Diem < 5 THEN N'Rớt' ELSE N'Đậu' END AS [Kết quả]
FROM KETQUA KQ
JOIN SINHVIEN SV ON KQ.MaSV = SV.MaSV;

--8. Cho biết số lượng sinh viên.
SELECT COUNT(*) AS [Tổng số sinh viên] FROM SINHVIEN;

--9. Cho biết số lượng sinh viên nữ.
SELECT COUNT(*) AS [Số lượng sinh viên nữ] FROM SINHVIEN WHERE Phai = 1;

--10.Số lượng sinh viên của từng khoa.
SELECT K.TenKhoa, COUNT(SV.MaSV) AS [Số lượng sinh viên]
FROM SINHVIEN SV
JOIN KHOA K ON SV.MaKH = K.MaKhoa
GROUP BY K.TenKhoa;


--11.Số lượng sinh viên học từng môn.
SELECT MH.TenMH, COUNT(DISTINCT KQ.MaSV) AS [Số lượng sinh viên]
FROM KETQUA KQ
JOIN MONHOC MH ON KQ.MaMH = MH.MaMH
GROUP BY MH.TenMH;



--12.Số lượng môn học mà mỗi sinh viên đã học.
SELECT SV.HoSV + ' ' + SV.TenSV AS [Họ và tên], COUNT(DISTINCT KQ.MaMH) AS [Số lượng môn học]
FROM SINHVIEN SV
JOIN KETQUA KQ ON SV.MaSV = KQ.MaSV
GROUP BY SV.HoSV, SV.TenSV;


--13.Học bổng cao nhất của mỗi khoa.
SELECT MaKH, MAX(HocBong) AS [Học bổng cao nhất]
FROM SINHVIEN
GROUP BY MaKH;



--14.Số lượng sinh viên nam và sinh viên nữ của mỗi khoa.
SELECT K.TenKhoa, 
       SUM(CASE WHEN SV.Phai = 0 THEN 1 ELSE 0 END) AS [Số lượng Nam],
       SUM(CASE WHEN SV.Phai = 1 THEN 1 ELSE 0 END) AS [Số lượng Nữ]
FROM SINHVIEN SV
JOIN KHOA K ON SV.MaKH = K.MaKhoa
GROUP BY K.TenKhoa;


--15.Số lượng sinh viên theo từng độ tuổi.
SELECT YEAR(GETDATE()) - YEAR(NgaySinh) AS [Độ tuổi], COUNT(*) AS [Số lượng]
FROM SINHVIEN
GROUP BY YEAR(GETDATE()) - YEAR(NgaySinh);


--16.Số lượng sinh viên đậu và số lượng sinh viên rớt của từng môn trong lần thi 1.
SELECT KQ.MaMH, 
       SUM(CASE WHEN KQ.Diem >= 5 THEN 1 ELSE 0 END) AS [Số lượng đậu], 
       SUM(CASE WHEN KQ.Diem < 5 THEN 1 ELSE 0 END) AS [Số lượng rớt]
FROM KETQUA KQ
WHERE KQ.LanThi = 1
GROUP BY KQ.MaMH;


--17.Cho biết năm sinh nào có từ 2 sinh viên đang theo học tại trường.
SELECT YEAR(NgaySinh) AS [Năm sinh], COUNT(*) AS [Số lượng]
FROM SINHVIEN
GROUP BY YEAR(NgaySinh)
HAVING COUNT(*) >= 2;

--18.Cho biết nơi nào có hơn 2 sinh viên đang theo học tại trường.
SELECT NoiSinh, COUNT(*) AS [Số lượng]
FROM SINHVIEN
GROUP BY NoiSinh
HAVING COUNT(*) > 2;

--19.Cho biết môn nào có trên 3 sinh viên dự thi.
SELECT KQ.MaMH, COUNT(DISTINCT KQ.MaSV) AS [Số lượng sinh viên]
FROM KETQUA KQ
GROUP BY KQ.MaMH
HAVING COUNT(DISTINCT KQ.MaSV) > 3;

--20.Cho biết sinh viên thi lại trên 2 lần.
SELECT MaSV
FROM KETQUA
GROUP BY MaSV, MaMH
HAVING COUNT(LanThi) > 2;

--21.Cho biết sinh viên nam có điểm trung bình lần 1 trên 7.0.
SELECT SV.MaSV, SV.HoSV + ' ' + SV.TenSV AS [Họ và tên]
FROM SINHVIEN SV
JOIN KETQUA KQ ON SV.MaSV = KQ.MaSV
WHERE SV.Phai = 0 AND KQ.LanThi = 1
GROUP BY SV.MaSV, SV.HoSV, SV.TenSV
HAVING AVG(KQ.Diem) > 7.0;

-- 22. Danh sách sinh viên rớt trên 2 môn ở lần thi 1
SELECT MaSV, COUNT(*) AS SoMonRot 
FROM KETQUA
WHERE LanThi = 1 AND Diem < 5
GROUP BY MaSV
HAVING COUNT(*) > 2;

-- 23. Khoa có nhiều hơn 2 sinh viên nam
SELECT MaKH, COUNT(*) AS SoSinhVienNam
FROM SINHVIEN
WHERE Phai = 0
GROUP BY MaKH
HAVING COUNT(*) > 2;

-- 24. Khoa có 2 sinh viên đạt học bổng từ 100.000 đến 200.000
SELECT MaKH
FROM SINHVIEN
WHERE HocBong BETWEEN 100000 AND 200000
GROUP BY MaKH
HAVING COUNT(*) = 2;

-- 25. Sinh viên nam học từ 3 môn trở lên
SELECT S.MaSV, S.TenSV, COUNT(DISTINCT K.MaMH) AS SoMonHoc
FROM SINHVIEN S
JOIN KETQUA K ON S.MaSV = K.MaSV
WHERE S.Phai = 0
GROUP BY S.MaSV, S.TenSV
HAVING COUNT(DISTINCT K.MaMH) >= 3;


-- 26. Sinh viên có điểm trung bình lần 1 từ 7 trở lên nhưng không có môn nào < 5
SELECT MaSV
FROM KETQUA
WHERE LanThi = 1
GROUP BY MaSV
HAVING AVG(Diem) >= 7 AND MIN(Diem) >= 5;

-- 27. Môn không có sinh viên rớt ở lần 1
SELECT MaMH
FROM KETQUA
WHERE LanThi = 1
GROUP BY MaMH
HAVING MIN(Diem) >= 5;

-- 28. Sinh viên đăng ký học hơn 3 môn mà thi lần 1 không bị rớt môn nào
SELECT MaSV
FROM KETQUA
WHERE LanThi = 1
GROUP BY MaSV
HAVING COUNT(DISTINCT MaMH) > 3 AND MIN(Diem) >= 5;

-- 29. Sinh viên có nơi sinh cùng với sinh viên tên Hải
SELECT DISTINCT S1.*
FROM SINHVIEN S1
WHERE EXISTS (
    SELECT 1 FROM SINHVIEN S2
    WHERE S1.NoiSinh = S2.NoiSinh AND S2.TenSV LIKE '%Hải%'
);
SELECT * FROM SINHVIEN WHERE TenSV LIKE '%Hải%';



-- 30. Sinh viên có học bổng lớn hơn tất cả sinh viên khoa Anh Văn
SELECT * FROM SINHVIEN
WHERE HocBong > ALL (SELECT HocBong FROM SINHVIEN WHERE MaKH = 'AV');


-- 31. Sinh viên có học bổng lớn hơn bất kỳ sinh viên khoa Anh Văn
SELECT * FROM SINHVIEN
WHERE HocBong > ANY (SELECT HocBong FROM SINHVIEN WHERE MaKH = 'AV');

-- 32. Sinh viên có điểm thi môn CSDL lần 2 > tất cả điểm thi lần 1 môn CSDL của SV khác
SELECT DISTINCT K1.MaSV
FROM KETQUA K1
WHERE K1.LanThi = 2 AND K1.MaMH = 'CSDL' AND K1.Diem > ALL (
    SELECT K2.Diem FROM KETQUA K2 WHERE K2.LanThi = 1 AND K2.MaMH = 'CSDL'
);

-- 33. Điểm thi cao nhất của mỗi sinh viên theo môn
SELECT MaSV, MaMH, MAX(Diem) AS DiemCaoNhat
FROM KETQUA
GROUP BY MaSV, MaMH;

-- 34. Môn có nhiều sinh viên học nhất
SELECT TOP 1 MaMH, COUNT(DISTINCT MaSV) AS SoSinhVien
FROM KETQUA
GROUP BY MaMH
ORDER BY COUNT(DISTINCT MaSV) DESC;

-- 35. Khoa có đông sinh viên nam nhất
SELECT TOP 1 MaKH, COUNT(*) AS SoSinhVienNam
FROM SINHVIEN
WHERE Phai = 0
GROUP BY MaKH
ORDER BY COUNT(*) DESC;

-- 36. Khoa có nhiều và ít sinh viên nhận học bổng nhất
SELECT TOP 1 MaKH, COUNT(*) AS SoSinhVienNhanHB
FROM SINHVIEN
WHERE HocBong > 0
GROUP BY MaKH
ORDER BY COUNT(*) DESC;

SELECT TOP 1 MaKH, COUNT(*) AS SoSinhVienNhanHB
FROM SINHVIEN
WHERE HocBong > 0
GROUP BY MaKH
ORDER BY COUNT(*) ASC;


-- 37. Môn có nhiều sinh viên rớt lần 1 nhất
SELECT TOP 1 MaMH, COUNT(*) AS SoSinhVienRot
FROM KETQUA
WHERE LanThi = 1 AND Diem < 5
GROUP BY MaMH
ORDER BY COUNT(*) DESC;

-- 38. Ba sinh viên học nhiều môn nhất
SELECT TOP 3 MaSV, COUNT(DISTINCT MaMH) AS SoMonHoc
FROM KETQUA
GROUP BY MaSV
ORDER BY COUNT(DISTINCT MaMH) DESC;
