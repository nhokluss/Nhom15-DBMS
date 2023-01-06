exec TX_danhan_DH @MaDH = 3, @TinhTrang = N'Đã nhận'

select * from DONHANG where MaDH = 3
update DONHANG set  TinhTrang = N'Đang xử lí' where MaDH = 3

