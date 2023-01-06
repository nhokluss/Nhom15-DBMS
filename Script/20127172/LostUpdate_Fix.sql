use DBMS_Demo
go
----------------------------
alter procedure TX_danhan_DH 
	@MaDH nvarchar(10),
	@TinhTrang nvarchar(20)
as
begin tran 
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
    if not exists (select * from DONHANG where @MaDH = MaDH)
    begin
        raiserror (N'Đơn hàng không tồn tại', 10, 1);
		rollback tran
    end

	else
	begin
		declare @TinhTrang2 nvarchar(20)
		--Kiểm tra xem đơn hàng đã giao chưa
		set @TinhTrang2 = (select dh.TinhTrang FROM DONHANG dh where dh.MaDH = @MaDH)
		if @TinhTrang2 = N'Đã giao hàng' --nếu đã giao thì không làm gì được nữa
		begin
			raiserror(N'Đơn hàng đã giao, không thể cập nhật.', 10, 1);
			rollback tran
		end 

		else
		begin
			if @TinhTrang2 = N'Đã hủy' --nếu đã hủy rồi thì không làm gì được nữa
			begin
				raiserror(N'Đơn hàng đã hủy, không thể cập nhật.', 10, 1);
				rollback tran
			end

			else
			begin
				waitfor delay '00:00:10'
				update DONHANG
				set TinhTrang = @TinhTrang
				where DONHANG.MaDH = @MaDH
				commit tran
			end
		end
	end
go

--Transaction 2: Khách hủy đơn hàng đó
alter procedure KH_huyDH
	@MaDH nvarchar(10),
	@TinhTrang nvarchar(20)
as
begin tran
	-- SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	if not exists (select * from DONHANG where @MaDH = MaDH)
    begin
        raiserror (N'Đơn hàng không tồn tại', 10, 1);
		rollback tran
    end

	else
	begin
		declare @TinhTrang2 nvarchar(20)
		--Kiểm tra xem đơn hàng đã giao chưa
		set @TinhTrang2 = (select dh.TinhTrang FROM DONHANG dh where dh.MaDH = @MaDH)
		if @TinhTrang2 = N'Đã giao hàng' --nếu đã giao thì không làm gì được nữa
		begin
			raiserror(N'Đơn hàng đã giao, không thể cập nhật.', 10, 1);
			rollback tran
		end 

		else
		begin
			if @TinhTrang2 = N'Đã hủy' --nếu đã hủy rồi thì không làm gì được nữa
			begin
				raiserror(N'Đơn hàng đã hủy, không thể cập nhật.', 10, 1);
				rollback tran
			end

			else
			begin
				update DONHANG
				set TinhTrang = @TinhTrang
				where DONHANG.MaDH = @MaDH
				waitfor delay '00:00:11'
				commit tran
			end
		end
	end
go
