
CREATE PROCEDURE [dbo].[CheckVoucherStatus]
(
	@ClientId	INT,
	@VoucherCode	NVARCHAR(100),
	@Status bit OUTPUT
)
AS
BEGIN
	Declare @VoucherStatusId int

	SELECT @VoucherStatusId = DeviceStatusId FROM devicestatus where [Name] = 'Active' and ClientId = @ClientId

	IF EXISTS (SELECT TOP 1  DeviceId FROM [vouchercodes] where DeviceId = @VoucherCode AND ExpirationDate > GETDATE() AND DateUsed is null)
	BEGIN
		SET @Status = 1;
	END
	ELSE
	BEGIN
		SET @Status = 0;
	END
END
