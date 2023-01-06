use DBMS_Demo
go
----------------------------------------------------------------------------------------
---- LOGIN
-- Create Login
exec sp_addLogin 'developer', 'developer'
exec sp_addLogin 'nhanvien', 'nhanvien'
exec sp_addLogin 'taixe', 'taixe'
exec sp_addLogin 'khachhang', 'khachhang'
exec sp_addLogin 'doitac', 'doitac'

---- USER
-- Create User
create user dev for login developer
create user nhanvien for login nhanvien
create user taixe for login taixe
create user khachhang for login khachhang
create user doitac for login doitac

---- ROLE
-- Create Role
exec sp_addrole 'Developer'
exec sp_addrole 'Staff'
exec sp_addrole 'Driver'
exec sp_addrole 'Customer'
exec sp_addrole 'Partner'
-- Add role member
exec sp_addrolemember 'Developer', 'dev'
exec sp_addrolemember 'Staff', 'nhanvien'
exec sp_addrolemember 'Driver', 'taixe'
exec sp_addrolemember 'Customer', 'khachhang'
exec sp_addrolemember 'Partner', 'doitac'

---- GRANT
-- for Developer
alter role db_owner add MEMBER [dev]

-- for Staff
grant select, insert, update, delete on DOITAC		to Staff
grant select, insert, update, delete on CHINHANH	to Staff
grant select, insert, update, delete on SANPHAM		to Staff
grant select, insert, update, delete on DONHANG		to Staff
grant select, insert, update, delete on TAIXE		to Staff
grant select, insert, update, delete on KHUVUC		to Staff
grant select, insert, update, delete on KHACHHANG	TO Staff
grant select, insert, update, delete on THONGTINCANHAN	to Staff	
grant select, insert, update on HOPDONG		to Staff

-- for Driver
grant select on KHUVUC			to Driver
grant select on THUNHAPTAIXE	to Driver
grant select on DONHANG			to Driver
grant select on CHITIETDONHANG	to Driver
grant select on SANPHAM			to Driver
grant select on CHINHANH		to Driver
grant select on TAIXE  to Driver
grant select, update (HoTen, SoDienThoai, DiaChi, Email) on THONGTINCANHAN to Driver

-- for Customer
grant select, insert, update, delete on DONHANG			to Customer
grant select, insert, update, delete on CHITIETDONHANG	to Customer
grant select on SANPHAM		to Customer
grant select on CHINHANH	to Customer
grant select, update (HoTen, SoDienThoai, DiaChi, Email) on THONGTINCANHAN to Customer

--for Partner
grant select, update (TenDT, NguoiDaiDien, ThanhPho, Quan, SLDonHang, LoaiHang, DiaChiKinhDoanh, SoDienThoai) on DOITAC to Partner
grant select, update (DiaChi) on CHINHANH to Partner
grant select, update (SLTonKho) on CUNGCAP_SP to Partner

------------------------------------------------------------------------------
---- Test for khachhang
insert into DONHANG (MaDH) values (N'DH1000000') --fail
delete from DONHANG where MaDH = N'DH1000000' --fail
select * from DONHANG where MaDH = N'DH1000000' --fail

insert into SANPHAM(MaSP) values (N'DH1000000') --fail
delete from SANPHAM where MaSP = N'DH1000000' --fail
select * from SANPHAM where MaSP = N'DH1000000' --fail

select * from THONGTINCANHAN 
update THONGTINCANHAN set HoTen = N'Le Yen Nhi' where ID = 1


-- Test for taixe
select * from TAIXE
select * from KHUVUC

insert into TAIXE (MaTX) values (N'TX1000000') --fail
delete from TAIXE where MaTX = N'TX0007' --fail

-- Test for nhanvien
delete from SANPHAM where MaSP = N'sp1001' --fail
select * from SANPHAM where MaSP = N'sp1001' --fail
delete from HOPDONG where MaHD = N'HD0000' --fail
