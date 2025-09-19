CREATE PROCEDURE [dbo].[GetVoucherCode](@ClientId int,@Code nvarchar(50))
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	DeviceId, 
			UserId,
			convert(varchar(10), 
			ExpirationDate, 120) ExpirationDate ,
			ExtReference,
			[Value],
			ValueType, 
			convert(varchar(10), DateUsed, 120) DateUsed,
			code_id as CodeId,
			usage_id as UsageId,
			isnull(Classical,0) as Classical
	FROM VoucherCodes 
	WHERE DeviceId = @Code 
	AND ClientID = @ClientId
END
