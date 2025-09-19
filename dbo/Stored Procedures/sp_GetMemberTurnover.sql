-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetMemberTurnover](@clientId int,
                                               @userId int)
	
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @value money;

    -- Insert statements for procedure here
	select @value = sum(td.value) 
	from Device d, TrxHeader th, TrxDetail td, DeviceStatus ds
	where d.devicestatusid  = ds.DeviceStatusId 
	and ds.name = 'Active'
	and ds.ClientId = @clientId
	and th.DeviceId = d.DeviceId
	and th.TrxId = td.TrxID
	and d.StartDate >= DATEADD(mm, -12, GETDATE())
	and th.CreateDate >= DATEADD(mm, -12, GETDATE())
	and userid = @userId;
	return @value;
END
