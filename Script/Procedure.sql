use HQT-CSDL_ThucHanh_Nhom15 
go
-----------------------------------------------------------------------------------------
-- Thêm nhân viên mới
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure insertNV
	@HoTen nvarchar(50),
	@SoDT varchar(15),
	@DiaChi nvarchar(150),
	@Email nvarchar(50)
as
begin tran
	if exists (select * from THONGTINCANHAN where SoDienThoai = @SoDT) 
	begin
		raiserror (N'Số điện thoại đã tồn tại', 10, 1)
		rollback tran
	end

	else
	begin
		insert into THONGTINCANHAN (HoTen, SoDienThoai, DiaChi, Email) values (@HoTen, @SoDT, @DiaChi, @Email)
		insert into NHANVIEN (ID) select tt.ID from THONGTINCANHAN tt where tt.SoDienThoai = @SoDT
		commit tran
	end
go

--exec insertNV @HoTen = 'LYN', @SoDT = '0918319976', @DiaChi = 'Le Loi', @Email = Null
--go

-- Update thông tin cá nhân của nhân viên
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure updateNV
	@MaNV int,
	@HoTen nvarchar(50),
	@SoDienThoai varchar(15),
	@DiaChi nvarchar(150),
	@Email varchar(50)
as
begin tran
	UPDATE THONGTINCANHAN set HoTen=@HoTen, SoDienThoai=@SoDienThoai, DiaChi=@DiaChi, Email=@Email 
	where ID=(select NV.ID from NHANVIEN NV where NV.MaNV=@MaNV)
	commit tran
go

--select * from THONGTINCANHAN tt, NHANVIEN nv where nv.id = tt.id and nv.MaNV = 278974
--exec updateNV 278974, N'Quang Trường', '0854693777', 'Test', 'aaa'
--go

-- Tìm nhân viên với số điện thoại cho trước
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure lookupNV_SDT
	@SDT varchar(15)
as
begin tran
	select NV.MANV, TT.HOTEN, TT.SoDienThoai,TT.DIACHI,TT.EMAIL 
	from NHANVIEN NV, THONGTINCANHAN TT 
	where TT.SoDienThoai = @SDT and NV.ID = TT.ID
	commit tran
go

--exec lookupNV_SDT N'07624466063'
--go

-- Xóa 1 nhân viên với mã NV và số điện thoại cho trước
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure deleteNV
	@MaNV int,
	@SoDienThoai nvarchar(50)
as
begin tran
	Delete NHANVIEN where MANV=@MaNV
	Delete THONGTINCANHAN where SoDienThoai = @SoDienThoai
commit tran
go

--exec deleteNV 278974, '0854693777'
--go

-- Xem danh sách NV với n dòng 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc ViewStaffListWith_n_Rows
	@offset int,
	@rows int
As
begin tran
	begin
		select nv.MaNV,tt.HoTen,tt.SoDienThoai,tt.DiaChi,tt.Email 
		from NHANVIEN nv, THONGTINCANHAN tt 
		where nv.ID=tt.ID 
		Order by nv.MaNV,tt.HoTen,tt.SoDienThoai,tt.DiaChi,tt.Email offset @offset rows fetch next @rows rows only
		commit tran
	end
go

-- Xem danh sách SP với n dòng  
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc ViewProductListWith_n_Rows
	@offset int,
	@rows int
As
begin tran
	begin
		select * from SANPHAM 
		order by MaSP offset @offset rows fetch next @rows rows only
		commit tran
	end
go
--exec ViewProductListWith_n_Rows 0,10
--go

-- Xem SP với mã sản phẩm cho trước
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure lookupSP
	@MaSP int
as
begin tran
	select * from SANPHAM where MaSp = @MaSP
commit tran
go

-- Xóa SP với mã sản phẩm cho trước
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure deleteSP
	@MaSP int
as
begin tran
	delete from SANPHAM where MaSP = @MaSP
commit tran
go

-- Update SP
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure updateSP
	@MaSP int,
	@TenSP nvarchar(150),
	@Gia bigint,
	@MoTa nvarchar(200)
as
begin tran
	update SANPHAM set TenSP = @TenSP, Gia = @Gia, MoTa = @MoTa where MaSP = @MaSP
commit tran
go

-- Thêm SP
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure addSP
	@TenSP nvarchar(150),
	@Gia bigint,
	@MoTa nvarchar(200)
as
begin tran
	insert into SANPHAM (TenSP, Gia, MoTa) values (@TenSP, @Gia, @MoTa)
	commit tran
go

-- Hủy Đơn hàng
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create or alter procedure Cancel_Order
	@MaDH int
as
begin tran
	update DONHANG set TinhTrang = N'Đã hủy' where MaDH = @MaDH
commit tran

--xem danh sách đối tác với n dòng
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc ViewPartnerListWith_n_Rows
	@offset int,
	@rows int
As
begin tran
	begin
		select * from DOITAC 
		order by MaDT offset @offset rows fetch next @rows rows only
		commit tran
	end
go

--Them DoiTac
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Or alter procedure addDT
	@TenDT nvarchar(150),
	@NguoiDD nvarchar(100),
	@TP nvarchar(60),
	@Quan nvarchar(60),
	@SoCN int,
	@SLDonHang int,
	@LoaiHang nvarchar(50),
	@DIACHIKD nvarchar(150),
	@SDT nvarchar(12)

as
begin tran
	if exists (select * from DOITAC where SoDienThoai = @SDT) 
		begin
			raiserror (N'Số điện thoại đã tồn tại', 10, 1)
			rollback tran
		end
	else if exists (select * from DOITAC where DiaChiKinhDoanh = @DIACHIKD) 
		begin
			raiserror (N'Địa Chỉ kinh doanh đã được đăng ký', 10, 1)
			rollback tran
		end
	else if exists (select * from DOITAC where TenDT = @TenDT) 
		begin
			raiserror (N'Đối tác đã được đăng ký', 10, 1)
			rollback tran
		end
	else
		begin
			insert into DOITAC(TenDT,NguoiDaiDien,ThanhPho,Quan,SoChiNhanh,SLDonHang,LoaiHang,DiaChiKinhDoanh,SoDienThoai) values(@TenDT,@NguoiDD,@TP,@Quan,@SoCN,@SLDonHang,@LoaiHang,@DIACHIKD,@SDT)
			commit tran
		end
go

--Xóa Đoi Tác
create procedure deleteDT
	@MaDT int
as
begin tran
	delete from HOPDONG where MaDT = @MaDT
	delete from DOITAC where MaDT = @MaDT
commit tran
go




