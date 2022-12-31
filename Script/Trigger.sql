use HQT-CSDL_ThucHanh_Nhom15
go
----------------------------------------------------------------------------------------
-- 1) ThanhTien = (SoLuong * Gia) 
-- update SoLuong CHITIETDONHANG
create trigger trigger_ThanhTien_updateSL
on CHITIETDONHANG
for insert, update, delete as
if update (SoLuong) 
begin
	if exists (select ctdh.SoLuong from CHITIETDONHANG ctdh where ctdh.SoLuong <= 0)
	begin
		 raiserror(N'Số lượng sản phẩm không hợp lệ', 10, 1)
		 rollback transaction
	end
	
	update CHITIETDONHANG
	set ThanhTien = (ctdh.SoLuong * sp.Gia)
	from CHITIETDONHANG ctdh, inserted i, SANPHAM sp
	where sp.MaSP = i.MaSP and
			ctdh.MaSP = sp.MaSP 
end

-- update Gia SANPHAM
create trigger trigger_ThanhTien_updateSP
on SANPHAM
for insert, update, delete as
if update (Gia)
begin
	if exists (select sp.Gia from SANPHAM sp where sp.Gia <= 0)
	begin
		 raiserror(N'Giá sản phẩm không hợp lệ', 10, 1)
		 rollback transaction
	end
	
	update CHITIETDONHANG
	set ThanhTien = ctdh.SoLuong * sp.Gia
	from CHITIETDONHANG ctdh, inserted i, SANPHAM sp
	where sp.MaSP = i.MaSP and
			ctdh.MaSP = sp.MaSP 
end


-- 2) Tổng tiền = PhiVanChuyen + sum(CHITIETHOADON.ThanhTien)
-- update CHITIETDONHANG
create trigger trigger_TongTien
on CHITIETDONHANG
for insert, update, delete as
begin
	update DONHANG
	set TongTien = PhiVanChuyen + (select sum(ctdh.ThanhTien)
									from CHITIETDONHANG ctdh
									where ctdh.MaDH = DONHANG.MaDH)
	where 
		exists (select * from inserted i where i.MaDH = DONHANG.MaDH) or
		exists (select * from deleted d where d.MaDH = DONHANG.MaDH) 
end

-- update PhiVanChuyen DONHANG
create trigger trigger_TongTien_updatePVC
on DONHANG
for insert, update, delete as
if update (PhiVanChuyen)
begin
	if exists (select dh.PhiVanChuyen from DONHANG dh where dh.PhiVanChuyen < 0)
	begin
		 raiserror(N'Phí vận chuyển không hợp lệ', 10, 1)
		 rollback transaction
	end
	update DONHANG
	set TongTien = PhiVanChuyen + (select sum(ctdh.ThanhTien)
									from CHITIETDONHANG ctdh
									where ctdh.MaDH = DONHANG.MaDH)
	where 
		exists (select * from inserted i where i.MaDH = DONHANG.MaDH) or
		exists (select * from deleted d where d.MaDH = DONHANG.MaDH) 
end

----------------------------------------------------------------------------------
-- Test for triggers
insert into SANPHAM (TenSP, Gia) values (N'Chocolate', 10000)
insert into CHITIETDONHANG (MaDH, MaSP, SoLuong) values (N'1', N'2001', 10)

delete from CHITIETDONHANG where MaDH = N'1' and MaSP = N'2001'
delete from SANPHAM where MaSP = N'2001'

update CHITIETDONHANG set SoLuong = -3 where MaDH = N'1' and MaSP = N'2001'	-- fail

update SANPHAM set Gia = 20000  where MaSP = N'2001' 		-- success

update SANPHAM set Gia = -10000 where MaSP = N'2001'		-- fail

update DONHANG set PhiVanChuyen = -10 where MaDH = N'1'		-- fail

select * from CHITIETDONHANG where MaDH = '1'
select * from DONHANG where MaDH = '1'
select * from SANPHAM where MaSP = '2001'
