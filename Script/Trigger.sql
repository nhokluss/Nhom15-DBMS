USE DBMS_Demo
GO
----------------------------------------------------------------------------------------
---- 1) ThanhTien = (SoLuong * Gia) 
-- update SoLuong CHITIETDONHANG
CREATE TRIGGER trigger_ThanhTien_updateSL
ON CHITIETDONHANG
FOR INSERT, UPDATE, DELETE AS
IF UPDATE (SoLuong) 
BEGIN
	IF EXISTS (SELECT ctdh.SoLuong FROM CHITIETDONHANG ctdh WHERE ctdh.SoLuong <= 0)
	BEGIN
		 RAISERROR(N'Số lượng sản phẩm không hợp lệ', 10, 1)
		 ROLLBACK TRANSACTION
	END
	
	UPDATE CHITIETDONHANG
	SET ThanhTien = (ctdh.SoLuong * td.Gia)
	FROM CHITIETDONHANG ctdh, inserted i, THUCDON td
	WHERE td.IDMonAn = i.IDMonAn AND
			ctdh.IDMonAn = td.IDMonAn 
END

-- update Gia SANPHAM
CREATE TRIGGER trigger_ThanhTien_updateMonAn
ON THUCDON
FOR INSERT, UPDATE, DELETE AS
IF UPDATE (Gia)
BEGIN
	IF EXISTS (SELECT td.Gia FROM THUCDON td WHERE td.Gia <= 0)
	BEGIN
		 RAISERROR(N'Giá sản phẩm không hợp lệ', 10, 1)
		 ROLLBACK TRANSACTION
	END
	
	UPDATE CHITIETDONHANG
	SET ThanhTien = ctdh.SoLuong * td.Gia
	FROM CHITIETDONHANG ctdh, inserted i, THUCDON td
	WHERE td.IDMonAn = i.IDMonAn AND
			ctdh.IDMonAn = td.IDMonAn 
END


---- 2) Tổng tiền = PhiVanChuyen + sum(CHITIETHOADON.ThanhTien)
-- update CHITIETDONHANG
CREATE TRIGGER trigger_TongTien
ON CHITIETDONHANG
FOR INSERT, UPDATE, DELETE AS
BEGIN
	UPDATE DONHANG
	SET TongTien = PhiVanChuyen + (SELECT SUM(ctdh.ThanhTien)
									FROM CHITIETDONHANG ctdh
									WHERE ctdh.MaDH = DONHANG.MaDH)
	WHERE 
		EXISTS (SELECT * FROM inserted i WHERE i.MaDH = DONHANG.MaDH) OR
		EXISTS (SELECT * FROM deleted d WHERE d.MaDH = DONHANG.MaDH) 
END

-- update PhiVanChuyen DONHANG
CREATE TRIGGER trigger_TongTien_updatePVC
ON DONHANG
FOR INSERT, UPDATE, DELETE AS
IF UPDATE (PhiVanChuyen)
BEGIN
	IF EXISTS (SELECT dh.PhiVanChuyen FROM DONHANG dh WHERE dh.PhiVanChuyen < 0)
	BEGIN
		 RAISERROR(N'Phí vận chuyển không hợp lệ', 10, 1)
		 ROLLBACK TRANSACTION
	END
	UPDATE DONHANG
	SET TongTien = PhiVanChuyen + (SELECT SUM(ctdh.ThanhTien)
									FROM CHITIETDONHANG ctdh
									WHERE ctdh.MaDH = DONHANG.MaDH)
	WHERE 
		EXISTS (SELECT * FROM inserted i WHERE i.MaDH = DONHANG.MaDH) OR
		EXISTS (SELECT * FROM deleted d WHERE d.MaDH = DONHANG.MaDH) 
END

----------------------------------------------------------------------------------
-- Test for triggers
INSERT INTO THUCDON (MonAN, Gia) VALUES (N'mắm cá thu', 10000)
INSERT INTO CHITIETDONHANG (MaDH, IDMonAn, SoLuong) VALUES (N'1', N'1002', 10)

DELETE FROM CHITIETDONHANG WHERE MaDH = N'1' AND IDMonAn = N'1001'
DELETE FROM THUCDON WHERE IDMonAn = N'1002'

UPDATE CHITIETDONHANG SET SoLuong = -3 WHERE MaDH = N'1' AND IDMonAn = N'1001'	-- fail

UPDATE THUCDON SET Gia = 20000  WHERE MaSP = N'1001' 		-- success

UPDATE THUCDON SET Gia = -10000 WHERE MaSP = N'1001'		-- fail

UPDATE DONHANG SET PhiVanChuyen = -10 WHERE MaDH = N'1'		-- fail

SELECT * FROM CHITIETDONHANG WHERE MaDH = '1'
SELECT * FROM DONHANG WHERE MaDH = '1'
SELECT * FROM dbo.THUCDON where IDMonAn = '1001'
