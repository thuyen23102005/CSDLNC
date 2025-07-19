
CREATE DATABASE CSDLNC3;
GO
USE CSDLNC3;
GO

CREATE TABLE LoaiHang (
    MaLoai NVARCHAR(10) PRIMARY KEY,
    TenLoai NVARCHAR(30) NOT NULL UNIQUE
);
CREATE TABLE KhuVuc (
    MaKhuVuc NVARCHAR(10) NOT NULL PRIMARY KEY,
    TenKhuVuc NVARCHAR(30) NOT NULL
);

CREATE TABLE ChiNhanh (
    MaChiNhanh NVARCHAR(10) NOT NULL PRIMARY KEY,
    TenChiNhanh NVARCHAR(30) NOT NULL,
    SoNha NVARCHAR(15) NOT NULL,
    Duong NVARCHAR(30) NOT NULL,
    PhuongXa NVARCHAR(10) NOT NULL,
    TinhTP NVARCHAR(20) NOT NULL,
    MaKhuVuc NVARCHAR(10) NOT NULL,
    FOREIGN KEY (MaKhuVuc) REFERENCES KhuVuc(MaKhuVuc)
);
CREATE TABLE HangHoa (
    MaHang NVARCHAR(10) NOT NULL PRIMARY KEY,
    TenHang NVARCHAR(30) NOT NULL,
    MaLoai NVARCHAR(10) NOT NULL,
    SoLuong INT NOT NULL CHECK (SoLuong >= 0),
    TrangThai NVARCHAR(20) NOT NULL CHECK (TrangThai IN (N'Còn hàng', N'Hết hàng', N'Ngưng bán')),
    DonGia INT NOT NULL CHECK (DonGia >= 0),
    DonViHang NVARCHAR(10) NOT NULL,
    MaChiNhanh NVARCHAR(10) NOT NULL, -- thêm trực tiếp
    FOREIGN KEY (MaLoai) REFERENCES LoaiHang(MaLoai),
    FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh)
);

CREATE TABLE KhachHang (
    MaKH NVARCHAR(10) NOT NULL PRIMARY KEY,
    HoTen NVARCHAR(30) NOT NULL,
    DiemTichLuy INT NOT NULL DEFAULT 0 CHECK (DiemTichLuy >= 0),
    LoaiKH NVARCHAR(10) NOT NULL CHECK (LoaiKH IN (N'Thường', N'Thân thiết', N'VIP'))
);



CREATE TABLE TonKho (
    MaHang NVARCHAR(10) NOT NULL,
    MaChiNhanh NVARCHAR(10) NOT NULL,
    SoLuongTon INT NOT NULL CHECK (SoLuongTon >= 0),
    PRIMARY KEY (MaHang, MaChiNhanh),
    FOREIGN KEY (MaHang) REFERENCES HangHoa(MaHang),
    FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh)
);

CREATE TABLE NhanVien (
    MaNV NVARCHAR(10) NOT NULL PRIMARY KEY,
    HoTenNV NVARCHAR(30) NOT NULL,
    MaChiNhanh NVARCHAR(10) NOT NULL,
    MaKhuVuc NVARCHAR(10) NOT NULL,
    PhanQuyen INT NOT NULL CHECK (PhanQuyen IN (0, 1)),
    QuanLy_MaNV NVARCHAR(10),
    FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh),
    FOREIGN KEY (QuanLy_MaNV) REFERENCES NhanVien(MaNV)
);

CREATE TABLE HoaDon (
    MaHD NVARCHAR(10) NOT NULL PRIMARY KEY,
    MaNV NVARCHAR(10) NOT NULL,
    MaChiNhanh NVARCHAR(10) NOT NULL,
    MaKH NVARCHAR(10) NOT NULL,
    TongTien INT NOT NULL CHECK (TongTien >= 0),
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH),
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
    FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh)
);

CREATE TABLE ChiTietHD (
    MaHD NVARCHAR(10) NOT NULL,
    MaHang NVARCHAR(10) NOT NULL,
    SoLuong INT NOT NULL CHECK (SoLuong > 0),
    DonGia INT NOT NULL CHECK (DonGia >= 0),
    ThanhTien AS (SoLuong * DonGia) PERSISTED,
    PRIMARY KEY (MaHD, MaHang),
    FOREIGN KEY (MaHD) REFERENCES HoaDon(MaHD),
    FOREIGN KEY (MaHang) REFERENCES HangHoa(MaHang)
);

CREATE TABLE KhuyenMai (
    MaKM NVARCHAR(10) NOT NULL PRIMARY KEY,
    MoTa NVARCHAR(30) NOT NULL,
    NgayBD DATE NOT NULL,
    NgayKT DATE NOT NULL,
    LoaiKM NVARCHAR(10) NOT NULL,
    CHECK (NgayKT >= NgayBD)
);

CREATE TABLE KhuVucKM (
    MaKM NVARCHAR(10) NOT NULL,
    MaKhuVuc NVARCHAR(10) NOT NULL,
    PRIMARY KEY (MaKM, MaKhuVuc),
    FOREIGN KEY (MaKM) REFERENCES KhuyenMai(MaKM),
    FOREIGN KEY (MaKhuVuc) REFERENCES KhuVuc(MaKhuVuc)
);

CREATE TABLE ApDung (
    MaHang NVARCHAR(10) NOT NULL,
    MaKM NVARCHAR(10) NOT NULL,
    PRIMARY KEY (MaHang, MaKM),
    FOREIGN KEY (MaHang) REFERENCES HangHoa(MaHang),
    FOREIGN KEY (MaKM) REFERENCES KhuyenMai(MaKM)
);

CREATE TABLE Con (
    MaHang NVARCHAR(10) NOT NULL,
    MaChiNhanh NVARCHAR(10) NOT NULL,
    PRIMARY KEY (MaHang, MaChiNhanh),
    FOREIGN KEY (MaHang) REFERENCES HangHoa(MaHang),
    FOREIGN KEY (MaChiNhanh) REFERENCES ChiNhanh(MaChiNhanh)
);

CREATE TABLE KhachHang_SDT (
    SDT NVARCHAR(10) NOT NULL CHECK (LEN(SDT) = 10),
    MaKH NVARCHAR(10) NOT NULL,
    PRIMARY KEY (SDT, MaKH),
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
);

CREATE TABLE NhanVien_SDT (
    SDT NVARCHAR(10) NOT NULL CHECK (LEN(SDT) = 10),
    MaNV NVARCHAR(10) NOT NULL,
    PRIMARY KEY (SDT, MaNV),
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);

------------------------------------------------------------------------------
IF OBJECT_ID('trg_KhongTrungTenLoaiTrongCN', 'TR') IS NOT NULL
    DROP TRIGGER trg_KhongTrungTenLoaiTrongCN;
GO
CREATE TRIGGER trg_KhongTrungTenLoaiTrongCN
ON HangHoa
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN HangHoa h ON 
            h.TenHang = i.TenHang AND 
            h.MaLoai = i.MaLoai AND 
            h.MaChiNhanh = i.MaChiNhanh
    )
    BEGIN
        RAISERROR(N'Không được thêm hàng trùng Tên Hàng và Loại Hàng trong cùng một chi nhánh.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Nếu không trùng thì cho phép insert
    INSERT INTO HangHoa (MaHang, TenHang, MaLoai, SoLuong, TrangThai, DonGia, DonViHang, MaChiNhanh)
    SELECT MaHang, TenHang, MaLoai, SoLuong, TrangThai, DonGia, DonViHang, MaChiNhanh
    FROM inserted;
END
go
--Không cho lập hóa đơn nếu hàng không đủ tồn kho tại chi nhánh đang giao dịch.
IF OBJECT_ID('trg_CheckTonKho', 'TR') IS NOT NULL
    DROP TRIGGER trg_CheckTonKho;
GO
CREATE TRIGGER trg_CheckTonKho
ON ChiTietHD
AFTER INSERT, update
AS
BEGIN
    -- Biến để lấy dữ liệu từ bảng inserted
    DECLARE @MaHang NVARCHAR(10), @SoLuong INT, @MaChiNhanh NVARCHAR(10);
    -- Giả sử mỗi hóa đơn thuộc về một chi nhánh (lấy từ bảng HoaDon)
    SELECT 
        @MaHang = i.MaHang,
        @SoLuong = i.SoLuong,
        @MaChiNhanh = h.MaChiNhanh
    FROM inserted i
    JOIN HoaDon h ON i.MaHD = h.MaHD;
    -- Kiểm tra số lượng tồn kho
    IF EXISTS (
        SELECT * FROM TonKho
        WHERE MaHang = @MaHang AND MaChiNhanh = @MaChiNhanh AND SoLuongTon < @SoLuong
    )
    BEGIN
        RAISERROR(N'Số lượng tồn kho không đủ để bán!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END

--Tự động cập nhật lại bảng TonKho khi thêm một dòng mới trong ChiTietHD.
-- Xóa trigger cũ nếu tồn tại
IF OBJECT_ID('trg_UpdateTonKho', 'TR') IS NOT NULL
    DROP TRIGGER trg_UpdateTonKho;
GO

CREATE TRIGGER trg_UpdateTonKho
ON ChiTietHD
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Cập nhật lại tồn kho dựa trên chênh lệch số lượng (mới - cũ)
    UPDATE tk
    SET tk.SoLuongTon = tk.SoLuongTon - (ISNULL(i.SoLuong, 0) - ISNULL(d.SoLuong, 0))
    FROM TonKho tk
    JOIN inserted i ON i.MaHang = tk.MaHang
    JOIN HoaDon h ON i.MaHD = h.MaHD AND h.MaChiNhanh = tk.MaChiNhanh
    LEFT JOIN deleted d ON i.MaHD = d.MaHD AND i.MaHang = d.MaHang;
END;
GO

-------------------------

--Cập nhật trạng thái hàng hóa (ví dụ: chuyển TrangThai thành "Hết hàng") nếu sau bán mà tồn kho = 0.
-- Xoá trigger cũ nếu tồn tại
IF OBJECT_ID('trg_CapNhatTrangThai', 'TR') IS NOT NULL
    DROP TRIGGER trg_CapNhatTrangThai;
GO

-- Tạo trigger mới
CREATE TRIGGER trg_CapNhatTrangThai
ON TonKho
AFTER UPDATE
AS
BEGIN
    DECLARE @MaHang NVARCHAR(10);
    DECLARE @SoLuongTon INT;

    -- Giả định chỉ cập nhật 1 dòng mỗi lần (nếu nhiều dòng thì phải dùng CURSOR hoặc JOIN)
    SELECT TOP 1 @MaHang = i.MaHang, @SoLuongTon = i.SoLuongTon
    FROM inserted i;

    IF @SoLuongTon = 0
    BEGIN
        UPDATE HangHoa
        SET TrangThai = N'Hết hàng'
        WHERE MaHang = @MaHang;
    END
END;
GO
--Không cho nhập hàng nếu đã tồn tại sản phẩm có cùng TenHang và LoaiHang trong cùng chi nhánh.
IF OBJECT_ID('trg_KiemTraHangTrung', 'TR') IS NOT NULL
    DROP TRIGGER trg_KiemTraHangTrung;
GO

CREATE TRIGGER trg_KiemTraHangTrung
ON HangHoa
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem có hàng nào trùng tên + loại + chi nhánh chưa
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN HangHoa h
            ON i.TenHang = h.TenHang
            AND i.MaLoai = h.MaLoai
            AND i.MaChiNhanh = h.MaChiNhanh
            AND i.MaHang <> h.MaHang  -- bỏ qua chính nó khi update
    )
    BEGIN
        RAISERROR(N'Không thể thêm hoặc cập nhật: đã tồn tại hàng trùng tên, loại và chi nhánh.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
-- =============================
-- 4. PROC: Thêm hàng + cập nhật CON & TONKHO
-- =============================
IF OBJECT_ID('sp_ThemHangVaTon', 'P') IS NOT NULL
    DROP PROCEDURE sp_ThemHangVaTon;
GO

CREATE PROCEDURE sp_ThemHangVaTon
    @MaHang NVARCHAR(10),
    @TenHang NVARCHAR(30),
    @MaLoai NVARCHAR(10),
    @SoLuong INT,
    @TrangThai NVARCHAR(20),
    @DonGia INT,
    @DonViHang NVARCHAR(10),
    @MaChiNhanh NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM LoaiHang WHERE MaLoai = @MaLoai)
    BEGIN
        RAISERROR(N'Mã loại hàng không tồn tại.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MaChiNhanh)
    BEGIN
        RAISERROR(N'Chi nhánh không tồn tại.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM HangHoa
        WHERE TenHang = @TenHang AND MaLoai = @MaLoai AND MaChiNhanh = @MaChiNhanh
    )
    BEGIN
        RAISERROR(N'Trùng tên hàng trong loại hàng tại chi nhánh.', 16, 1);
        RETURN;
    END

    INSERT INTO HangHoa (MaHang, TenHang, MaLoai, SoLuong, TrangThai, DonGia, DonViHang, MaChiNhanh)
    VALUES (@MaHang, @TenHang, @MaLoai, @SoLuong, @TrangThai, @DonGia, @DonViHang, @MaChiNhanh);

    IF NOT EXISTS (SELECT 1 FROM Con WHERE MaHang = @MaHang AND MaChiNhanh = @MaChiNhanh)
        INSERT INTO Con VALUES (@MaHang, @MaChiNhanh);

    IF NOT EXISTS (SELECT 1 FROM TonKho WHERE MaHang = @MaHang AND MaChiNhanh = @MaChiNhanh)
        INSERT INTO TonKho VALUES (@MaHang, @MaChiNhanh, @SoLuong);
END;
GO
--------------------------------------------------------------------------

INSERT INTO LoaiHang (MaLoai, TenLoai)
VALUES 
(N'L01', N'Bánh kẹo'),
(N'L02', N'Đồ uống'),
(N'L03', N'Gia vị');

INSERT INTO KhuVuc (MaKhuVuc, TenKhuVuc)
VALUES 
(N'KV01', N'TP.HCM'),
(N'KV02', N'Hà Nội');

INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, SoNha, Duong, PhuongXa, TinhTP, MaKhuVuc)
VALUES 
(N'CN01', N'Chi nhánh Q1', N'123', N'Nguyễn Huệ', N'P.Bến Nghé', N'TP.HCM', N'KV01'),
(N'CN02', N'Chi nhánh Ba Đình', N'456', N'Kim Mã', N'P.Ngọc Khá', N'Hà Nội', N'KV02');


INSERT INTO KhachHang (MaKH, HoTen, DiemTichLuy, LoaiKH)
VALUES 
(N'KH01', N'Nguyễn Văn A', 100, N'Thường'),
(N'KH02', N'Trần Thị B', 200, N'Thân thiết'),
(N'KH03', N'Lê Văn C', 500, N'VIP');

EXEC sp_ThemHangVaTon N'H04', N'Bánh Chocopie', N'L01', 40, N'Còn hàng', 12000, N'Hộp', N'CN01';
EXEC sp_ThemHangVaTon N'H05', N'Pepsi', N'L02', 70, N'Còn hàng', 9000, N'Chai', N'CN01';
EXEC sp_ThemHangVaTon N'H06', N'Nước mắm Nam Ngư', N'L03', 30, N'Còn hàng', 25000, N'Chai', N'CN01';

EXEC sp_ThemHangVaTon N'H07', N'Bánh AFC', N'L01', 60, N'Còn hàng', 11000, N'Gói', N'CN02';
EXEC sp_ThemHangVaTon N'H08', N'Trà xanh C2', N'L02', 90, N'Còn hàng', 8000, N'Chai', N'CN02';
EXEC sp_ThemHangVaTon N'H09', N'Muối i-ốt', N'L03', 50, N'Còn hàng', 5000, N'Gói', N'CN02';



INSERT INTO NhanVien (MaNV, HoTenNV, MaChiNhanh, MaKhuVuc, PhanQuyen, QuanLy_MaNV)
VALUES 
(N'NV01', N'Nguyễn Thị Quỳnh', N'CN01', N'KV01', 1, NULL),
(N'NV02', N'Trần Văn Hùng', N'CN01', N'KV01', 0, N'NV01'),
(N'NV03', N'Lê Hữu Tài', N'CN02', N'KV02', 0, NULL);

INSERT INTO HoaDon (MaHD, MaNV, MaChiNhanh, MaKH, TongTien)
VALUES 
(N'HD01', N'NV02', N'CN01', N'KH01', 30000),
(N'HD02', N'NV03', N'CN02', N'KH02', 7000);

INSERT INTO ChiTietHD (MaHD, MaHang, SoLuong, DonGia)
VALUES 
(N'HD01', N'H04', 2, 15000),
(N'HD02', N'H05', 2, 3500);

INSERT INTO KhuyenMai (MaKM, MoTa, NgayBD, NgayKT, LoaiKM)
VALUES 
(N'KM01', N'Khuyến mãi Tết', '2025-01-01', '2025-02-01', N'Trực tiếp'),
(N'KM02', N'Giảm giá hè', '2025-06-01', '2025-08-01', N'Chiết khấu');

INSERT INTO KhuVucKM (MaKM, MaKhuVuc)
VALUES 
(N'KM01', N'KV01'),
(N'KM02', N'KV02');

INSERT INTO ApDung (MaHang, MaKM)
VALUES 
(N'H04', N'KM01'),
(N'H05', N'KM02');

INSERT INTO KhachHang_SDT (SDT, MaKH)
VALUES 
(N'0901234567', N'KH01'),
(N'0912345678', N'KH02');

INSERT INTO NhanVien_SDT (SDT, MaNV)
VALUES 
(N'0987654321', N'NV01'),
(N'0976543210', N'NV02');

-- 9. Tồn kho
SELECT * FROM TonKho;
SELECT * FROM ChiTietHD;
update ChiTietHD
set SoLuong = 3
where MaHang = N'H04'



