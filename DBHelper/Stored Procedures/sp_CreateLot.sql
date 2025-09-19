


-- =============================================
-- Author:		Ulisses Franca
-- Create date: 2013-06-09
-- Description:	creates a lot
-- =============================================
CREATE PROCEDURE [DBHelper].[sp_CreateLot]
	-- Add the parameters for the stored procedure here
	@userId int,
	@StatusName nvarchar(50),
	@NUmberDevices decimal,
	@StartDate datetime,
	@InitialCashBalance decimal,
	@name nvarchar(50),
	@ProfileId int,
	@lotId int
AS
BEGIN

Declare @DeviceStatusID  int = 0
select @DeviceStatusID = devicestatusid from devicestatus where name = 'Created' and clientid = 1 --Hard coded for the moment until we can find out how to pass this also for multi-tenent databases

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET IDENTITY_INSERT [dbo].[DeviceLot] ON;
    -- Insert statements for procedure here
	INSERT INTO [dbo].[DeviceLot]
           (Id,
           [Created]
           ,[Updated]
           ,[CreatedBy]
           ,[UpdatedBy]
           ,[StatusId]
           ,[NumberOfDevices]
           ,[StartDate]
           ,[InitialCashBalance]
           ,[Name]
           ,[Reference]
           ,[InitialPointsBalance]
		   ,Devicestatusid)
     VALUES
           (@lotid,
           GETDATE()
           ,GETDATE()
           ,@userId
           ,@userId
           ,(select id from DeviceLotStatus where Name like @StatusName)
           ,@NUmberDevices
           ,@StartDate
           ,@InitialCashBalance
           ,@name
           ,null
           ,null
		   ,@DeviceStatusID
		   );
          
    SET IDENTITY_INSERT [dbo].[DeviceLot] OFF;
           
    INSERT INTO [dbo].[DeviceLotDeviceProfile]
           ([DeviceLotId]
           ,[DeviceProfileId])
     VALUES
           (@lotId
           ,@ProfileId);
     
     
     return @lotid;
END
