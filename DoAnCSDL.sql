Create database CSDLNC
go
use CSDLNC
go

CREATE TABLE HangHoa (
  MaHang NVARCHAR(10) NOT NULL PRIMARY KEY,
  TenHang NVARCHAR(30) NOT NULL,
  LoaiHang NVARCHAR(30) NOT NULL,
  SoLuong INT NOT NULL CHECK (SoLuong >= 0),
  TrangThai NVARCHAR(20) NOT NULL CHECK (TrangThai IN (N'Còn hàng', N'Hết hàng', N'Ngưng bán')),
  DonGia INT NOT NULL CHECK (DonGia >= 0),
  DonViHang NVARCHAR(10) NOT NULL
);

CREATE TABLE KhachHang (
  MaKH NVARCHAR(10) NOT NULL PRIMARY KEY,
  HoTen NVARCHAR(30) NOT NULL,
  DiemTichLuy INT NOT NULL DEFAULT 0 CHECK (DiemTichLuy >= 0),
  LoaiKH NVARCHAR(10) NOT NULL CHECK (LoaiKH IN (N'Thường', N'Thân thiết', N'VIP'))
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
  PhanQuyen INT NOT NULL CHECK (PhanQuyen IN (0, 1)), -- 0: nhân viên, 1: quản lý
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
INSERT INTO KhuVuc (MaKhuVuc, TenKhuVuc) VALUES
(N'KV01', N'TP. Hồ Chí Minh'),
(N'KV02', N'Hà Nội');

INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, SoNha, Duong, PhuongXa, TinhTP, MaKhuVuc) VALUES
(N'CN01', N'Circle K Quận 1', N'123', N'Nguyễn Trãi', N'Phường 1', N'TP. Hồ Chí Minh', N'KV01'),
(N'CN02', N'Circle K Cầu Giấy', N'456', N'Trần Duy Hưng', N'Dịch Vọng', N'Hà Nội', N'KV02');

INSERT INTO HangHoa (MaHang, TenHang, LoaiHang, SoLuong, TrangThai, DonGia, DonViHang) VALUES
(N'H01', N'Coca Cola', N'Nước giải khát', 100, N'Còn hàng', 10000, N'Lon'),
(N'H02', N'Mì Hảo Hảo', N'Thực phẩm', 200, N'Còn hàng', 3500, N'Gói');

INSERT INTO KhachHang (MaKH, HoTen, DiemTichLuy, LoaiKH) VALUES
(N'KH01', N'Nguyễn Văn A', 100, N'Thường'),
(N'KH02', N'Trần Thị B', 250, N'VIP');

INSERT INTO KhachHang_SDT (SDT, MaKH) VALUES
(N'0912345678', N'KH01'),
(N'0987654321', N'KH02');

INSERT INTO NhanVien (MaNV, HoTenNV, MaChiNhanh, MaKhuVuc, PhanQuyen, QuanLy_MaNV) VALUES
(N'NV01', N'Ngô Văn C', N'CN01', N'KV01', 1, NULL),
(N'NV02', N'Phạm Văn D', N'CN01', N'KV01', 0, N'NV01');

INSERT INTO NhanVien_SDT (SDT, MaNV) VALUES
(N'0909090901', N'NV01'),
(N'0909090902', N'NV02');

INSERT INTO TonKho (MaHang, MaChiNhanh, SoLuongTon) VALUES
(N'H01', N'CN01', 60),
(N'H02', N'CN02', 100);

INSERT INTO HoaDon (MaHD, MaNV, MaChiNhanh, MaKH, TongTien) VALUES
(N'HD01', N'NV02', N'CN01', N'KH01', 20000),
(N'HD02', N'NV01', N'CN01', N'KH02', 7000);

INSERT INTO ChiTietHD (MaHD, MaHang, SoLuong, DonGia) VALUES
(N'HD01', N'H01', 2, 10000),
(N'HD02', N'H02', 2, 3500);

INSERT INTO KhuyenMai (MaKM, MoTa, NgayBD, NgayKT, LoaiKM) VALUES
(N'KM01', N'Giảm 10%', '2025-07-01', '2025-07-31', N'Phần trăm'),
(N'KM02', N'Mua 1 tặng 1', '2025-07-10', '2025-07-20', N'Quà tặng');

INSERT INTO KhuVucKM (MaKM, MaKhuVuc) VALUES
(N'KM01', N'KV01'),
(N'KM02', N'KV02');

INSERT INTO ApDung (MaHang, MaKM) VALUES
(N'H01', N'KM01'),
(N'H02', N'KM02');
--Tạo bảng ảo xem tên sản phẩm trong chi tiết hóa đơn
CREATE VIEW ChiTietHD_View AS
SELECT 
  cthd.MaHD,
  cthd.MaHang,
  hh.TenHang,
  cthd.SoLuong,
  cthd.DonGia
FROM 
  ChiTietHD cthd
JOIN 
  HangHoa hh ON cthd.MaHang = hh.MaHang;

  SELECT * FROM ChiTietHD_View;