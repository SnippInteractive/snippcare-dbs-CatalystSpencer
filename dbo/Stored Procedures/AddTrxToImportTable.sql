create PROCEDURE [dbo].[AddTrxToImportTable](@clientId int,@reg_num float,@store_num nvarchar(5),@trans_num float,@host_trans_id float,@trx_date datetime,@customer_num nvarchar(20),@loyalty_num nvarchar(10),@item float,@cnt float,@value nvarchar(10),@description nvarchar(200),@file_name nvarchar(200))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	INSERT INTO TrxMissingJob (reg_num,store_num,[pos trans_num],host_trans_id,trans_date,customer_number,loyalty_number,item,cnt,value,item_description,file_name,import_date)values(@reg_num,@store_num,@trans_num,@host_trans_id,@trx_date,@customer_num,@loyalty_num,@item,@cnt,@value,@description,@file_name,getdate())

END