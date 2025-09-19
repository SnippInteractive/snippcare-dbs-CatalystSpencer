CREATE PROCEDURE [dbo].[GetMissingTrx](@clientId int,@ISSnippTrxId INT = 0)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF ISNULL(@ISSnippTrxId,0) = 0
	BEGIN
		Select Id,store_num,reg_num,[pos trans_num] AS pos_trans_num,host_trans_id,trans_date,customer_number,loyalty_number,item,cnt,ISNULL(value,0) value,linenumber,deviceid,reference,item_description from TrxMissingJOB WHERE ISNULL(is_processed,0) = 0 AND ISNULL(host_trans_id,0) = 0
		and reference is not null and linenumber is not null and Convert(varchar(12), import_date,103)=Convert(varchar(12), getdate(),103)
	END
	--ELSE 
	IF ISNULL(@ISSnippTrxId,0) = 1
	BEGIN
		Select Id,store_num,reg_num,[pos trans_num] AS pos_trans_num,host_trans_id,trans_date,customer_number,loyalty_number,item,cnt,ISNULL(value,0) value,linenumber,deviceid,reference,item_description from TrxMissingJOB WHERE ISNULL(is_processed,0) = 0 AND ISNULL(host_trans_id,0) > 0 
		and reference is not null and linenumber is not null and Convert(varchar(12), import_date,103)=Convert(varchar(12), getdate(),103)
	END
	

END