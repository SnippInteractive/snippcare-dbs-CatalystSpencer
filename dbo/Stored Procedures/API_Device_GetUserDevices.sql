-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <02/12/2016>
-- Description:	<Returns number of devices assigned to the member>
-- =============================================
CREATE PROCEDURE [dbo].[API_Device_GetUserDevices](
		@UserId int,
		@DeviceProfileName nvarchar(30)
)
AS
BEGIN
	SET NOCOUNT ON;
	
		Declare @DeviceStatusId int;
		Declare @UserDevices int;

		select top 1 @DeviceStatusId = DeviceStatusId from DeviceStatus where Name = 'Active';

    	select @UserDevices = count(1) 
		from Device d 
		join DeviceProfile dp on dp.DeviceId = d.Id
		join DeviceProfileTemplate dpt on dpt.Id = dp.DeviceProfileId
		join DeviceProfileTemplateType dptt on dptt.Id = dpt.DeviceProfileTemplateTypeId
		where dptt.Name = @DeviceProfileName
		and d.UserId = @UserId
		and d.DeviceStatusId = @DeviceStatusId
		print @UserDevices
		return @UserDevices;
END

