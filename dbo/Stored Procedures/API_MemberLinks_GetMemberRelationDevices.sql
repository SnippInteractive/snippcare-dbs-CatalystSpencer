-- =============================================
-- Author:		Kamil Wozniak
-- Create date: 19/02/2018
-- Description:	Gets all devices in a relation by using userid or deviceid
-- =============================================
CREATE PROCEDURE [dbo].[API_MemberLinks_GetMemberRelationDevices]( @UserId int, @DeviceId varchar(20), @ResultsValidation varchar(500) output)
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.#Devices', 'U') IS NOT NULL
		DROP TABLE #Devices; 


	select DeviceId
	into #Devices
	from (
		select d.DeviceId Device, d1.DeviceId Device1
		from Device d 
		left join MemberLink ml on d.UserId = ml.MemberId1
		left join Device d1 on d1.UserId = ml.MemberId2
		where (d.UserId = @UserId or d.DeviceId = @DeviceId)
	) a
	UNPIVOT 
		(DeviceId for col in (a.device, a.device1)
	) AS unpvt;

	select @ResultsValidation = stuff((SELECT ( ',' + t2.DeviceId ) FROM #Devices t2 FOR XML PATH( '' )), 1, 1, '' )

	return;

	IF OBJECT_ID('tempdb.dbo.#Devices', 'U') IS NOT NULL
		DROP TABLE #Devices; 


END
