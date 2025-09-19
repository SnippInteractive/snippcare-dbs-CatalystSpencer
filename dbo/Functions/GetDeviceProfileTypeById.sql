-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetDeviceProfileTypeById]
(
	-- Add the parameters for the function here
	@ProfileId int
)
RETURNS nvarchar(20)
AS
BEGIN
	declare @id int;
	-- Declare the return variable here
	select @id=f.id from FinancialDeviceProfileTemplate f 
	--inner join DeviceProfileTemplate p on p.id=f.id 
	where f.Id=@ProfileId
	if(@id is not null and @id>0) 
	begin
		return 'Financial'; 
		
	end
	select @id=f.id from PaymentDeviceProfileTemplate f 
	--inner join DeviceProfileTemplate p on p.id=f.id 
	where f.Id=@ProfileId ;
	if(@id is not null and @id>0)
	begin
		return 'Payment'; 
	end
	select @id=f.id from LoyaltyDeviceProfileTemplate f 
	--inner join DeviceProfileTemplate p on p.id=f.id 
	where f.Id=@ProfileId;
	if(@id is not null and @id>0)
	begin
		return 'Loyalty'; 
	end
	select @id=f.id from VoucherDeviceProfileTemplate f 
	--inner join DeviceProfileTemplate p on p.id=f.id 
	where f.Id=@ProfileId;
	if(@id is not null and @id>0)
	begin
		return 'Voucher'; 
	end
	return '';

END
