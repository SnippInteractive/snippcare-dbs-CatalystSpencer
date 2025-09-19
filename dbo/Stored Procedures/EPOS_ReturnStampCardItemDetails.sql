-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EPOS_ReturnStampCardItemDetails]
	-- Add the parameters for the stored procedure here
	(@TrxId INT, --NEW purchase TrxId
	 @DeviceId NVARCHAR(25),
     @OriginalPurchaseDate NVARCHAR(25),----YYYY-MM-DD (2023-08-02) OLD Purchase Date without time part
     @ItemCodes NVARCHAR(MAX),--Itemcodes as Comma separated String.
	 @PromotionId INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	--1111,'V58120650','2022-08-03','03214541'
	/*declare  @ItemCodes NVARCHAR(MAX) ='03214541,28934762534', @OriginalPurchaseDate nvarchar(25) = '2022-03-08', @DeviceId nvarchar(25) = 'V58120650',@TrxId INT=1111
	*/
	drop table if exists #Items
	Create table  #Items (ItemCodes nvarchar(50))
	

	DECLARE @InsertStatement varchar(max);
	SET  @InsertStatement = 'insert into #Items (ItemCodes) values ('''+REPLACE(@ItemCodes,',','''),(''')+''');';
	--select @InsertStatement
	EXEC (@InsertStatement);
	--select * from #Items

	--select CONVERT(date, @OriginalPurchaseDate)

	SELECT DISTINCT td.ItemCode,ts.ValueUsed ,td.Quantity ,td.Value AS NetValue,th.TrxId,ts.TrxDetailId TrxDetailId,ts.ChildPromotionId,ts.ChildPunch
	--,trxdate, convert(date,th.TrxDate) TrxDate, CONVERT(date, @OriginalPurchaseDate), th.trxdate
	FROM TrxHeader th 
	inner join TrxDetail td on th.TrxId = td.TrxId 
	inner join TrxDetailStampCard ts on td.TrxDetailId = ts.TrxDetailId 
	INNER JOIN #Items i ON td.ItemCode = i.ItemCodes collate database_default 
	WHERE convert(date,th.TrxDate) = CONVERT(date, @OriginalPurchaseDate) AND --YYYY-MM-DD 2023-08-02
	th.DeviceId = @DeviceId	AND
	ts.PromotionId = @PromotionId
	AND ts.PunchTrXType = 1 --(Need to consider only Purchase)
	AND ts.ValueUsed <> 0

	drop table if exists #Items
END
