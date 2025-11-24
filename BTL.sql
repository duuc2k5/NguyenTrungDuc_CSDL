USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'QuanLyTuyenDung')
BEGIN
    ALTER DATABASE QuanLyTuyenDung SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuanLyTuyenDung;
END
GO

CREATE DATABASE QuanLyTuyenDung;
GO

USE QuanLyTuyenDung;
GO
CREATE TABLE UNG_VIEN (
    Ma_ung_vien CHAR(10) PRIMARY KEY,
    Ten_ung_vien NVARCHAR(100) NOT NULL,
    Ngay_sinh DATE,
    Email VARCHAR(100) UNIQUE NOT NULL,
    So_dien_thoai VARCHAR(15)
);
GO

CREATE TABLE VI_TRI_TUYEN_DUNG (
    Ma_vi_tri CHAR(10) PRIMARY KEY,
    Ten_vi_tri NVARCHAR(100) NOT NULL,
    Mo_ta_cong_viec NVARCHAR(MAX) DEFAULT N'Đang cập nhật'
);
GO

CREATE TABLE NHA_TUYEN_DUNG (
    Ma_nha_tuyen_dung CHAR(10) PRIMARY KEY,
    Ten_nha_tuyen_dung NVARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    So_dien_thoai VARCHAR(15)
);
GO

CREATE TABLE UNG_TUYEN (
    Ma_ung_tuyen CHAR(10) PRIMARY KEY,
    Ma_ung_vien CHAR(10) NOT NULL,
    Ma_vi_tri CHAR(10) NOT NULL,
    Ngay_nop_ho_so DATE DEFAULT GETDATE(),
    
    CONSTRAINT FK_UT_UV FOREIGN KEY (Ma_ung_vien) REFERENCES UNG_VIEN(Ma_ung_vien),
    CONSTRAINT FK_UT_VT FOREIGN KEY (Ma_vi_tri) REFERENCES VI_TRI_TUYEN_DUNG(Ma_vi_tri)
);
GO
CREATE TABLE PHONG_VAN (
    Ma_phong_van CHAR(10) PRIMARY KEY,
    Ma_ung_vien CHAR(10) NOT NULL,
    Ma_vi_tri CHAR(10) NOT NULL,
    Ngay_phong_van DATETIME NOT NULL,
    Ket_qua NVARCHAR(50),

    CONSTRAINT CK_KetQua CHECK (Ket_qua IN (N'Đạt', N'Không đạt', N'Chờ', N'Hủy')),
    CONSTRAINT FK_PV_UV FOREIGN KEY (Ma_ung_vien) REFERENCES UNG_VIEN(Ma_ung_vien),
    CONSTRAINT FK_PV_VT FOREIGN KEY (Ma_vi_tri) REFERENCES VI_TRI_TUYEN_DUNG(Ma_vi_tri)
);
GO

INSERT INTO UNG_VIEN VALUES 
('UV01', N'Nguyễn Văn A', '1995-01-01', 'a@email.com', '0901111111'),
('UV02', N'Trần Thị B', '1998-05-20', 'b@email.com', '0902222222'),
('UV03', N'Lê Văn C', '2000-10-10', 'c@email.com', '0903333333'),
('UV04', N'Phạm Thị D', '1996-12-12', 'd@email.com', '0904444444'),
('UV05', N'Hoàng Văn E', '1999-03-15', 'e@email.com', '0905555555');

INSERT INTO VI_TRI_TUYEN_DUNG VALUES 
('DEV01', N'Backend Developer', N'Lập trình Java, Spring Boot'),
('DEV02', N'Frontend Developer', N'Lập trình ReactJS, VueJS'),
('TEST01', N'Tester/QA', N'Kiểm thử phần mềm'),
('HR01', N'Chuyên viên Tuyển dụng', N'Tuyển dụng nhân sự IT'),
('BA01', N'Business Analyst', N'Phân tích nghiệp vụ');

INSERT INTO NHA_TUYEN_DUNG VALUES 
('REC01', N'Nguyễn Thu Hà', 'ha.rec@company.com', '0911111111'),
('REC02', N'Trần Minh Tuấn', 'tuan.rec@company.com', '0922222222'),
('REC03', N'Lê Thanh Hương', 'huong.rec@company.com', '0933333333'),
('REC04', N'Phạm Quốc Bảo', 'bao.rec@company.com', '0944444444'),
('REC05', N'Hoàng Thùy Linh', 'linh.rec@company.com', '0955555555');

INSERT INTO UNG_TUYEN VALUES 
('UT01', 'UV01', 'DEV01', '2023-10-01'),
('UT02', 'UV02', 'DEV01', '2023-10-02'),
('UT03', 'UV03', 'TEST01', '2023-10-03'),
('UT04', 'UV04', 'BA01', '2023-10-04'),
('UT05', 'UV05', 'DEV02', '2023-10-05'),
('UT06', 'UV01', 'DEV02', '2023-10-06');

INSERT INTO PHONG_VAN VALUES 
('PV01', 'UV01', 'DEV01', '2023-10-10 09:00:00', N'Đạt'),
('PV02', 'UV02', 'DEV01', '2023-10-10 14:00:00', N'Không đạt'),
('PV03', 'UV03', 'TEST01', '2023-10-11 10:30:00', N'Chờ'),
('PV04', 'UV04', 'BA01', '2023-10-12 09:00:00', N'Đạt'),
('PV05', 'UV05', 'DEV02', '2023-10-15 15:00:00', N'Hủy');
GO

CREATE NONCLUSTERED INDEX IDX_TenUngVien 
ON UNG_VIEN(Ten_ung_vien);
GO

CREATE VIEW v_DanhSachTrungTuyen AS
SELECT 
    UV.Ma_ung_vien,
    UV.Ten_ung_vien,
    UV.Email,
    VT.Ten_vi_tri,
    PV.Ngay_phong_van
FROM PHONG_VAN PV
JOIN UNG_VIEN UV ON PV.Ma_ung_vien = UV.Ma_ung_vien
JOIN VI_TRI_TUYEN_DUNG VT ON PV.Ma_vi_tri = VT.Ma_vi_tri
WHERE PV.Ket_qua = N'Đạt';
GO

CREATE PROCEDURE sp_LayLichSuPhongVan
    @MaUV CHAR(10)
AS
BEGIN
    SELECT 
        UV.Ten_ung_vien,
        VT.Ten_vi_tri,
        PV.Ngay_phong_van,
        PV.Ket_qua
    FROM PHONG_VAN PV
    JOIN VI_TRI_TUYEN_DUNG VT ON PV.Ma_vi_tri = VT.Ma_vi_tri
    JOIN UNG_VIEN UV ON PV.Ma_ung_vien = UV.Ma_ung_vien
    WHERE PV.Ma_ung_vien = @MaUV;
END;
GO

CREATE FUNCTION f_DemHoSoUngTuyen (@MaViTri CHAR(10))
RETURNS INT
AS
BEGIN
    DECLARE @SoLuong INT;
    SELECT @SoLuong = COUNT(*) 
    FROM UNG_TUYEN 
    WHERE Ma_vi_tri = @MaViTri;
    
    RETURN @SoLuong;
END;
GO

CREATE TRIGGER tg_KiemTraNgayPhongVan
ON PHONG_VAN
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @NgayPV DATETIME;
    SELECT @NgayPV = Ngay_phong_van FROM INSERTED;

    IF (@NgayPV < GETDATE())
    BEGIN
        PRINT N'Lỗi: Ngày phỏng vấn không được nhỏ hơn thời điểm hiện tại!';
        ROLLBACK TRANSACTION;
    END
END;
GO

SELECT * FROM v_DanhSachTrungTuyen;

EXEC sp_LayLichSuPhongVan @MaUV = 'UV01';


SELECT dbo.f_DemHoSoUngTuyen('DEV01') AS [Số lượng hồ sơ DEV01];

