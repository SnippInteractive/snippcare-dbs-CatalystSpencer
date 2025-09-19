CREATE PROCEDURE [dbo].[bws_CreateDevices]

--exec [bws_CreateDevices] 1,1035, 0

	-- Add the parameters for the stored procedure here
	@ClientId INT,@LotId INT,@Result INT OUTPUT
AS
BEGIN

Declare @SP_Version nvarchar(100) = '2020-11-13.1' 
insert into Audit 
([Version], [UserId], [FieldName], [NewValue], [OldValue], [ChangeDate], [ChangeBy], [Reason], [ReferenceType], [OperatorId], [SiteId])
values (101, 1000001, 'CompletedSelection', 'LotID-' + convert(nvarchar(10),@LotId),'', GETDATE(),1000001,'[dbo].[bws_CreateDevices]',@SP_Version + '-Version Number',1000001,NULL   )

--	declare 	@ClientId INT=1,@LotId INT=1955,@Result  INT 

	Declare @msg1 nvarchar(100)
	set @msg1  = 'Starting' + '-' +  FORMAT(GETDATE() , 'MM/dd/yyyy HH:mm:ss')
	-- RAISERROR(@msg1 , 0, 1) WITH NOWAIT	
	INSERT INTO [dbo].[NLog_Error]
	([time_stamp],[host],[type],[source],[message],[level],[logger],[stacktrace])
	values 	(GetDate(), 'Creating Devices','SP','BWS_CreateDevice',@msg1,'Info','Device','Started' )

	IF OBJECT_ID('tempdb.dbo.#DevicesToInsert', 'U') IS NOT NULL
	DROP TABLE #DevicesToInsert 
	
	IF OBJECT_ID('tempdb.dbo.#DevicesToDedupe', 'U') IS NOT NULL
	DROP TABLE #DevicesToDedupe 
	IF OBJECT_ID('tempdb.dbo.#DevicesCreated', 'U') IS NOT NULL
	DROP TABLE #DevicesCreated 
	IF OBJECT_ID('tempdb.dbo.#PIN', 'U') IS NOT NULL
	DROP TABLE #PIN 
	set @msg1  = 'Dropped Tables' + '-' +  FORMAT(GETDATE() , 'MM/dd/yyyy HH:mm:ss')
	-- RAISERROR(@msg1 , 0, 1) WITH NOWAIT	
	INSERT INTO [dbo].[NLog_Error]
	([time_stamp],[host],[type],[source],[message],[level],[logger],[stacktrace])
	values 	(GetDate(), 'Creating Devices','SP','BWS_CreateDevice',@msg1,'Info','Device','Started' )


    DECLARE @DeviceNumberGeneratorTemplateId INT,@TotalNumbersToCreate int,@Reference nvarchar(50)=null,@DeviceProfileId INT,@Message VARCHAR(100);
	DECLARE @Level VARCHAR(100),@Stacktrace VARCHAR(MAX),@Identifier VARCHAR(40),@Prefix nvarchar(50),@NumberLength int,@Suffix nvarchar(50);
	DECLARE @DeviceNumberStatusId int,@CheckSumAlgorithmId int,@ProfileType VARCHAR(50),@CurrencyId INT,@EndDate DATETIME,@StartDate DATETIME,@HomeSIteId INT;
	DECLARE @AlphaNumeric int=0;

	

	SELECT @DeviceProfileId = DeviceProfileId FROM DeviceLotDeviceProfile WHERE DeviceLotId = @LotId
	SELECT @TotalNumbersToCreate = NumberOfDevices,@EndDate=ExpiryDate,@StartDate = isnull(StartDate,GETDATE()) FROM DeviceLot WHERE id = @LotId
	select @TotalNumbersToCreate = @TotalNumbersToCreate - count(*) from device where devicelotid = @LotId
	SELECT @DeviceNumberGeneratorTemplateId = DeviceNumberGeneratorTemplateId,@ProfileType=dpt.Name,@CurrencyId=dp.CurrencyId,@HomeSIteId=SiteId FROM DeviceProfileTemplate dp
	join DeviceProfileTemplateType dpt on dp.DeviceProfileTemplateTypeId=dpt.Id
	WHERE dp.Id = @DeviceProfileId
	
	SELECT @Identifier = cast(@ClientId as nvarchar(2)) + '_'+ cast(NEWID() as nvarchar(40)) 
	print @identifier
	
	SELECT 
	@Prefix=isnull(Prefix,''),
	@Suffix=isnull(Suffix,''),
	@NumberLength=TotalNumberlength,
	@CheckSumAlgorithmId = CheckSumAlgorithmId,
	@AlphaNumeric=isnull(AlphaNumeric,0)
	FROM Devicenumbergeneratortemplate WHERE Id = @DeviceNumberGeneratorTemplateId AND ClientId = @ClientId
	set @msg1  = 'Got the devices prefix suffix etc' + '-' +  FORMAT(GETDATE() , 'MM/dd/yyyy HH:mm:ss')
	-- RAISERROR(@msg1 , 0, 1) WITH NOWAIT	
	INSERT INTO [dbo].[NLog_Error]
	([time_stamp],[host],[type],[source],[message],[level],[logger],[stacktrace])
	values 	(GetDate(), 'Creating Devices','SP','BWS_CreateDevice',@msg1,'Info','Device','Started' )
	
	SELECT @DeviceNumberStatusId = Id FROM DeviceNumberStatus WHERE ClientId = @ClientId and Name = 'Created'

	DECLARE @TotalNumbersGenerated INT = 0;
	DECLARE @NumberSequencialRetries INT = 0;
	DECLARE @Number NVARCHAR(50);
	DECLARE @FullNumber NVARCHAR(50);
	DECLARE @CheckSum INT;

	-- If the number of devices to create is not specified top up the pool
	IF @TotalNumbersToCreate IS NULL
	BEGIN
		SELECT @TotalNumbersToCreate = MinimumThresholdForPool FROM Devicenumbergeneratortemplate WHERE Id = @DeviceNumberGeneratorTemplateId AND ClientId = @ClientId
		
		DECLARE @AvailableNumbers INT;
		SELECT @AvailableNumbers = AvailableNumbersInPool FROM Devicenumbergeneratortemplate WHERE Id = @DeviceNumberGeneratorTemplateId AND ClientId = @ClientId
		SELECT @TotalNumbersToCreate = @TotalNumbersToCreate - @AvailableNumbers				
	END
	set @msg1  = 'Gonna do ' + convert(nvarchar(10),@TotalNumbersToCreate) + ' Devices -' +  FORMAT(GETDATE() , 'MM/dd/yyyy HH:mm:ss')
	-- RAISERROR(@msg1 , 0, 1) WITH NOWAIT	
	INSERT INTO [dbo].[NLog_Error]
	([time_stamp],[host],[type],[source],[message],[level],[logger],[stacktrace])
	values 	(GetDate(), 'Creating Devices','SP','BWS_CreateDevice',@msg1,'Info','Device','Started' )
	

	-- Get length of number to create depending on length of suffix, prefix 
	-- and if a checksum is required
	IF(@CheckSumAlgorithmId IS NOT NULL) and @AlphaNumeric=0
	BEGIN
		SELECT @NumberLength = @NumberLength - 1
	END

	IF(@Prefix IS NOT NULL)
	BEGIN
		SELECT @NumberLength = @NumberLength - LEN(@Prefix)
	END

	IF(@Suffix IS NOT NULL)
	BEGIN
		SELECT @NumberLength = @NumberLength - LEN(@Suffix)
	END

	--Validate data
	IF @NumberLength <=0 
	BEGIN
		-- RAISERROR('Total number lenght must be greater than 0', 0, 1 )
		INSERT INTO [dbo].[NLog_Error]
	([time_stamp],[host],[type],[source],[message],[level],[logger],[stacktrace])
	values 	(GetDate(), 'Creating Devices','SP','BWS_CreateDevice',@msg1,'Info','Device','Started' )

	END
	set @msg1  = 'Getting each individual number ' + '-' +  FORMAT(GETDATE() , 'MM/dd/yyyy HH:mm:ss')
	-- RAISERROR(@msg1 , 0, 1) WITH NOWAIT	
	INSERT INTO [dbo].[NLog_Error]
	([time_stamp],[host],[type],[source],[message],[level],[logger],[stacktrace])
	values 	(GetDate(), 'Creating Devices','SP','BWS_CreateDevice',@msg1,'Info','Device','Started' )

	
	--declare #DevicesToDedupe table (DeviceIDWithoutCheck nvarchar(49), DeviceID nvarchar(50))
	--declare #DevicesCreated table (DeviceIDWithoutCheck nvarchar(49))
	
	create table #DevicesToDedupe (DeviceIDWithoutCheck nvarchar(49), DeviceID nvarchar(50))

	create table #DevicesCreated  (DeviceIDWithoutCheck nvarchar(49));


	


	SELECT TOP (@TotalNumbersToCreate*2) n = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY s1.[object_id]))
	INTO #Loader
	FROM sys.all_objects AS s1 CROSS JOIN sys.all_objects AS s2 OPTION (MAXDOP 1);
	if @AlphaNumeric = 0
		Begin
			insert into #DevicesCreated (DeviceIDWithoutCheck)
			SELECT  top (@TotalNumbersToCreate*2) convert(varchar(20),@Prefix) + 
			right(convert(varchar(10),ABS(CHECKSUM(NEWID()) % 1000000000000)) + '' 
			+ convert(varchar(10),ABS(CHECKSUM(NEWID()) % 1000000000000)),@Numberlength) + 
			convert(varchar(20),@Suffix) DeviceIDWithoutCheck    
			FROM #Loader
		end 
	else 
		Begin
			insert into #DevicesCreated (DeviceIDWithoutCheck)
			SELECT  top (@TotalNumbersToCreate*2) convert(varchar(20),@Prefix) + 
			right(replace(SUBSTRING(CONVERT(VARCHAR(255), NEWID()),0,40),'-','') ,@Numberlength) 
			+ convert(varchar(20),@Suffix) DeviceIDWithoutCheck    FROM #Loader
		End
	Create CLUSTERED index idx_DeviceIDWithoutCheck on #DevicesCreated(DeviceIDWithoutCheck)
	set @msg1  = 'Getting the DUPES ' + '-' +  FORMAT(GETDATE() , 'MM/dd/yyyy HH:mm:ss')
	-- RAISERROR(@msg1 , 0, 1) WITH NOWAIT
	INSERT INTO [dbo].[NLog_Error]
	([time_stamp],[host],[type],[source],[message],[level],[logger],[stacktrace])
	values 	(GetDate(), 'Creating Devices','SP','BWS_CreateDevice',@msg1,'Info','Device','Started' )

	insert into #DevicesToDedupe (DeviceIDWithoutCheck)
	select DeviceIDWithoutCheck 
	from #DevicesCreated 
	group by DeviceIDWithoutCheck

	set @msg1  = 'Updating the DUPES with Check Digit ' + '-' +  FORMAT(GETDATE() , 'MM/dd/yyyy HH:mm:ss')

	-- RAISERROR(@msg1 , 0, 1) WITH NOWAIT;
	INSERT INTO [dbo].[NLog_Error]
	([time_stamp],[host],[type],[source],[message],[level],[logger],[stacktrace])
	values 	(GetDate(), 'Creating Devices','SP','BWS_CreateDevice',@msg1,'Info','Device','Started' )

	update #DevicesToDedupe set DeviceID =[dbo].[fnGetLuhn](DeviceIDWithoutCheck)
	--update @DevicesToDedupe set DeviceID = DeviceIDWithoutCheck + convert(nvarchar(1),[dbo].[Modulo10](DeviceIDWithoutCheck))
	CREATE INDEX idx_device_DevicesToDedupe ON [#DevicesToDedupe] (DeviceID);
	
	/*Get Random numbers for PINS*/
	set @msg1  = 'Getting the PINS ' + '-' +  FORMAT(GETDATE() , 'MM/dd/yyyy HH:mm:ss')
	-- RAISERROR(@msg1 , 0, 1) WITH NOWAIT	
	INSERT INTO [dbo].[NLog_Error]
	([time_stamp],[host],[type],[source],[message],[level],[logger],[stacktrace])
	values 	(GetDate(), 'Creating Devices','SP','BWS_CreateDevice',@msg1,'Info','Device','Started' )

	--these are all the Devices that we can insert into the Device table
	
	select top (@TotalNumbersToCreate) deviceid into #DevicesToInsert from #DevicesToDedupe where deviceid collate database_default not in (select deviceid collate database_default  from device)
	alter table #DevicesToInsert add ID [int] IDENTITY(1,1)
	alter table #DevicesToInsert add PIN NVARCHAR(3);
	alter table #DevicesToInsert add CVC NVARCHAR(3);
	alter table #DevicesToInsert add PINVerificationValue NVARCHAR(5);

	--select * from #DevicesToInsert
	select top (@TotalNumbersToCreate) 
	right('000' + convert(varchar(10),ABS(CHECKSUM(NEWID()) % 10000000)),3) Pin,  
	right('000' + convert(varchar(10),ABS(CHECKSUM(NEWID()) % 10000000)),3) CVC ,
	right('00000' + convert(varchar(10),ABS(CHECKSUM(NEWID()) % 10000000)),5) PINVerificationValue
	into #PIN FROM #Loader

	alter table #PIN add ID [int] IDENTITY(1,1)
	
	update d set d.Pin=x.pin, d.cvc = x.cvc, d.PINVerificationValue=x.PINVerificationValue  from #Pin x join #DevicesToInsert d on d.id=x.id

	delete from #DevicesToInsert where pin is null

	DECLARE @AccountId INT,@DeviceId INT,@AccountStatusId INT,@CashBalance float,@PointsBalance float,@DeviceStatusId INT,@DeviceProfileStatusId INT;
	DECLARE @deviceTypeId INT,@DeviceNumberPoolReference NVARCHAR(50),@DeviceStatus NVARCHAR(50),@DeviceProfileStatus NVARCHAR(50),@DevicePoolId INT;
	DECLARE @ProfileReference VARCHAR(200),@DEVICELOTSTATUSNUMBERSASSIGNED INT

	SELECT @DEVICELOTSTATUSNUMBERSASSIGNED = ID from devicelotstatus WHERE NAME = 'Ready' AND CLIENTID = @CLIENTID	
	Select @AccountStatusId = AccountStatusId from AccountStatus where ClientId = @ClientId and Name = 'Enable';
	Select @CashBalance = InitialCashBalance,@PointsBalance=InitialPointsBalance from DeviceLot where id = @LotId;
	SELECT @ProfileReference=description from DeviceProfileTemplate where id=@DeviceProfileId;
	SELECT @deviceTypeId = DeviceTypeId from DeviceType where Name = 'Main' and ClientId = @ClientId;
	
	declare @outputAccountDevice table (Accountid int, DeviceID nvarchar(50) );
	declare @outputAccountDeviceWithProfile table (DeviceID nvarchar(50), IDofDevice int);

	set @msg1  = 'Updating Profiles and Lots ' + '-' +  FORMAT(GETDATE() , 'MM/dd/yyyy HH:mm:ss')
	-- RAISERROR(@msg1 , 0, 1) WITH NOWAIT	
	INSERT INTO [dbo].[NLog_Error]
	([time_stamp],[host],[type],[source],[message],[level],[logger],[stacktrace])
	values 	(GetDate(), 'Creating Devices','SP','BWS_CreateDevice',@msg1,'Info','Device','Started' )


	--select * from DeviceLot where Name like 'Campaign Voucher%'
	if(@ProfileType='Loyalty')
	begin
		select @DeviceStatusId = DeviceStatusId from DeviceStatus where ClientId = @ClientId AND Name = 'Active';
		select @DeviceProfileStatusId = DeviceProfileStatusId from DeviceProfileStatus where ClientId = @ClientId AND Name = 'Active';
	end
	else if(@ProfileType='Voucher' or @ProfileType =   'Financial')
	begin
	
		UPDATE DEVICELOT SET STATUSID = @DEVICELOTSTATUSNUMBERSASSIGNED WHERE ID = @LOTID
		select @DeviceStatusId = DeviceStatusId from DeviceStatus where ClientId = @ClientId AND Name = 'Ready';
		select @DeviceProfileStatusId = DeviceProfileStatusId from DeviceProfileStatus where ClientId = @ClientId AND Name = 'Created';
		IF EXISTS(select 1 from VoucherDeviceProfileTemplate where ClassicalVoucher=1 and id=@DeviceProfileId)
		BEGIN
			select @DeviceStatusId = DeviceStatusId from DeviceStatus where ClientId = @ClientId AND Name = 'Active';
			select @DeviceProfileStatusId = DeviceProfileStatusId from DeviceProfileStatus where ClientId = @ClientId AND Name = 'Active';
		END

		IF EXISTS(select 1 from DeviceLot where Name like 'Campaign Voucher%' and id=@LotId)
		BEGIN
			select @DeviceStatusId = DeviceStatusId from DeviceStatus where ClientId = @ClientId AND Name = 'Active';
			select @DeviceProfileStatusId = DeviceProfileStatusId from DeviceProfileStatus where ClientId = @ClientId AND Name = 'Active';
		END
		IF (@ProfileType =   'Financial')
		BEGIN
			select @DeviceStatusId = DeviceStatusId from DeviceStatus where ClientId = @ClientId AND Name = 'Ready';
			select @DeviceProfileStatusId = DeviceProfileStatusId from DeviceProfileStatus where ClientId = @ClientId AND Name = 'Active';
		END

	end
	set @msg1  = 'Accounts now ' + '-' +  FORMAT(GETDATE() , 'MM/dd/yyyy HH:mm:ss')
	-- RAISERROR(@msg1 , 0, 1) WITH NOWAIT	
	INSERT INTO [dbo].[NLog_Error]
	([time_stamp],[host],[type],[source],[message],[level],[logger],[stacktrace])
	values 	(GetDate(), 'Creating Devices','SP','BWS_CreateDevice',@msg1,'Info','Device','Started' )

	INSERT INTO [Account] ([AccountStatusTypeId],[Pin],[ProgramId],[PointsPending],[CreateDate],[Version_old],[MonetaryBalance],[PointsBalance],[CurrencyId],[ExtRef])
	output inserted.accountid, inserted.ExtRef into @outputAccountDevice (Accountid, Deviceid)
	select @AccountStatusId,PIN,NULL,0,GETDATE(),NULL,@CashBalance,@PointsBalance,@CurrencyId,Deviceid from #DevicesToInsert
		
	set @msg1  = 'Devices now ' + '-' +  FORMAT(GETDATE() , 'MM/dd/yyyy HH:mm:ss')
	-- RAISERROR(@msg1 , 0, 1) WITH NOWAIT	
	INSERT INTO [dbo].[NLog_Error]
	([time_stamp],[host],[type],[source],[message],[level],[logger],[stacktrace])
	values 	(GetDate(), 'Creating Devices','SP','BWS_CreateDevice',@msg1,'Info','Device','Started' )

	INSERT INTO [dbo].[Device]
	([DeviceId],[DeviceStatusId],[DeviceTypeId],[HomeSiteId],[CreateDate],[DeviceNumberPoolId],[ExpirationDate],[AccountId],[StartDate],[DevicelotId],[Reference],PIN,cvc, PINVerificationValue)
	output inserted.deviceid, inserted.id into @outputAccountDeviceWithProfile (Deviceid, IDofDevice)
	select  rtrim(d.DeviceID),@DeviceStatusId,@deviceTypeId,@HomeSIteId,GETDATE(),NULL,@EndDate,AccountId, @StartDate,@LotId,@ProfileReference,PIN,cvc, PINVerificationValue from @outputAccountDevice a join #DevicesToInsert d on a.deviceid collate database_default =d.deviceid collate database_default 

--	select  d.DeviceID,@DeviceStatusId,@deviceTypeId,@HomeSIteId,GETDATE(),NULL,@EndDate,AccountId,GETDATE(),@LotId,@ProfileReference,PIN,cvc, PINVerificationValue from @outputAccountDevice a join #DevicesToInsert d on a.deviceid=d.deviceid

	set @msg1  = 'DeviceProfiles now ' + '-' +  FORMAT(GETDATE() , 'MM/dd/yyyy HH:mm:ss')
	-- RAISERROR(@msg1 , 0, 1) WITH NOWAIT	
	INSERT INTO [dbo].[NLog_Error]
	([time_stamp],[host],[type],[source],[message],[level],[logger],[stacktrace])
	values 	(GetDate(), 'Creating Devices','SP','BWS_CreateDevice',@msg1,'Info','Device','Started' )

	INSERT INTO [dbo].[DeviceProfile]([StatusId],[DeviceId],[DeviceProfileId])
	select	@DeviceProfileStatusId,IDofDevice,@DeviceProfileId from @outputAccountDeviceWithProfile
			
			
	SELECT @DEVICELOTSTATUSNUMBERSASSIGNED = ID from devicelotstatus WHERE NAME = 'NumbersAssigned' AND CLIENTID = @CLIENTID
	UPDATE DEVICELOT SET STATUSID = @DEVICELOTSTATUSNUMBERSASSIGNED WHERE ID = @LOTID

	/*set the sequence number which is the lotid plus 6 sequencial digits*/
	select id, convert(nvarchar(4),devicelotid) + right('000000' +  convert(nvarchar(6),ROW_NUMBER() OVER ( order by id)),6) rn into #Dv 
	from device where devicelotid = @LotId order by id 
	update d set LotSequenceNo = RN from #dv  x
	join device d on d.id=x.id
	 
	set @msg1  = 'Sweeeeeeeeeeeeeeeeeet DONE this Lot ' + convert(nvarchar(10),@LotId) + '-' +  FORMAT(GETDATE() , 'MM/dd/yyyy HH:mm:ss')
	-- RAISERROR(@msg1 , 0, 1) WITH NOWAIT	
	INSERT INTO [dbo].[NLog_Error]
	([time_stamp],[host],[type],[source],[message],[level],[logger],[stacktrace])
	values 	(GetDate(), 'Creating Devices','SP','BWS_CreateDevice',@msg1,'Info','Device','Started' )

drop table #Loader	  
 SELECT @Result = 1  
 SELECT 1 AS RESULT  

END
