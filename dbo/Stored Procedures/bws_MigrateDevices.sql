Create PROCEDURE [dbo].[bws_MigrateDevices]
      -- Add the parameters for the stored procedure here
      @ClientId INT,@LotId INT,@Result INT OUTPUT
AS
BEGIN

      SET NOCOUNT ON;

    DECLARE @DeviceNumberGeneratorTemplateId INT;
      DECLARE @TotalNumbersToCreate int;
      DECLARE @Reference nvarchar(50)=null;
      DECLARE @DeviceProfileId INT;
      DECLARE @Message VARCHAR(100)
      DECLARE @Level VARCHAR(100)
      DECLARE @Stacktrace VARCHAR(MAX)
      DECLARE @Identifier VARCHAR(40)     
      DECLARE @Prefix nvarchar(50);
      DECLARE @NumberLength int ;
      DECLARE @Suffix nvarchar(50);
      DECLARE @DeviceNumberStatusId int;
      DECLARE @CheckSumAlgorithmId int;
      DECLARE @ProfileType VARCHAR(50);
    DECLARE @CurrencyId INT;
    DECLARE @EndDate DATETIME;
    DECLARE @HomeSIteId INT;
      
      SELECT @DeviceProfileId = DeviceProfileId FROM DeviceLotDeviceProfile WHERE DeviceLotId = @LotId
      SELECT @TotalNumbersToCreate = NumberOfDevices,@EndDate=ExpiryDate FROM DeviceLot WHERE id = @LotId
      SELECT @DeviceNumberGeneratorTemplateId = DeviceNumberGeneratorTemplateId,@ProfileType=dpt.Name,@CurrencyId=dp.CurrencyId,@HomeSIteId=SiteId FROM DeviceProfileTemplate dp
      join DeviceProfileTemplateType dpt on dp.DeviceProfileTemplateTypeId=dpt.Id
      WHERE dp.Id = @DeviceProfileId
      
      SELECT @Identifier = cast(@ClientId as nvarchar(2)) + '_'+ cast(NEWID() as nvarchar(40)) 
      print @identifier
      
      --------------------- Loggging----------------------
      SELECT @Message= 'Begin generate device numbers for device number generator template: ' + cast(@DeviceNumberGeneratorTemplateId as nvarchar(5))
      SELECT @Level= 'Info'
      print @message
      SELECT @Stacktrace= ''
      INSERT INTO NLog_Error 
      (time_stamp, host, type, source, message, level, logger, stacktrace) 
      VALUES 
      (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)                     
      --------------------- Loggging----------------------

      SELECT 
      @Prefix=isnull(Prefix,''),
      @Suffix=isnull(Suffix,''),
      @NumberLength=TotalNumberlength,
      @CheckSumAlgorithmId = CheckSumAlgorithmId
      FROM Devicenumbergeneratortemplate WHERE Id = @DeviceNumberGeneratorTemplateId AND ClientId = @ClientId
      print 'Got the devices prefix suffix etc'
      
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

      IF @TotalNumbersToCreate <= 0
      BEGIN
            SELECT @TotalNumbersToCreate = 0
            
            --------------------- Loggging----------------------
            SELECT @Message= 'Sufficent device numbers available for device number generator template: ' + cast(@DeviceNumberGeneratorTemplateId as nvarchar(5))
            SELECT @Level= 'Info'
            print @message
            SELECT @Stacktrace= ''
            INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)                        
            --------------------- Loggging----------------------

      END
      
      -- Get length of number to create depending on length of suffix, prefix 
      -- and if a checksum is required
      IF(@CheckSumAlgorithmId IS NOT NULL)
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
            RAISERROR ('Total number lenght must be greater than 0', 0, 1 )
      END
      print 'Getting each individual number'
      declare @RandomPartOfNumber varchar(20)
      WHILE (@TotalNumbersGenerated < @TotalNumbersToCreate and @NumberSequencialRetries < 100)
      
      BEGIN
            
            BEGIN TRY
                  -- Generate random number
                  print 'Getting each individual number itter'
                  select @RandomPartOfNumber =  right(convert(varchar(6),floor(rand() * 1000000)) + '' +  convert(varchar(6),floor(rand() * 1000000)) + '' +  convert(varchar(6),floor(rand() * 1000000))  ,@Numberlength)
                  IF LEN(@RandomPartOfNumber) < @Numberlength
                  BEGIN
                        SELECT @RandomPartOfNumber = right('0000000' + @RandomPartOfNumber,@Numberlength)
                  END
                  print @RandomPartOfNumber 
                  select @number  = convert(varchar(20),@Prefix) + @RandomPartOfNumber + convert(varchar(20),@Suffix)
                  
                  print 'Random Number with Prefix and suffix ' + convert(varchar(20),@Number)
                  --create checksum if required 
                  IF(@CheckSumAlgorithmId IS NOT NULL)
                  BEGIN
                        SELECT @CheckSum= [dbo].[Modulo10](@number);
            --          SELECT @CheckSum= [dbo].sfn_ean_chkdigit(@number);

                        SELECT @FullNumber = ((@number) + cast(@checkSum as nvarchar(1)))
                        print @FullNumber
                  END
                  ELSE
                  BEGIN
                        SELECT @FullNumber = @number
                  END
                  
                  -- Check if the number already exists in the device number pool before inserting
                  IF((SELECT COUNT(*) FROM Device WHERE DeviceId = @FullNumber) = 0)
                  BEGIN             
                  
                  ---start
                        DECLARE @AccountId INT;
                        DECLARE @DeviceId INT;
                        DECLARE @AccountStatusId INT;
                        DECLARE @CashBalance float;
                        DECLARE @PointsBalance float;
                        DECLARE @DeviceStatusId INT;
                        DECLARE @DeviceProfileStatusId INT;
                        DECLARE @deviceTypeId INT;    
                        DECLARE @DeviceNumberPoolReference NVARCHAR(50);
                        DECLARE @DeviceStatus NVARCHAR(50);
                        DECLARE @DeviceProfileStatus NVARCHAR(50);
                        DECLARE @DevicePoolId INT;
                        DECLARE @ProfileReference VARCHAR(200)
                        SET @DevicePoolId=(select top 1 id from DeviceNumberPool);
                              DECLARE @DEVICELOTSTATUSNUMBERSASSIGNED INT
                      SELECT @DEVICELOTSTATUSNUMBERSASSIGNED = ID from devicelotstatus WHERE NAME = 'Ready' AND CLIENTID = @CLIENTID   
                        Select @AccountStatusId = AccountStatusId from AccountStatus where ClientId = @ClientId and Name = 'Enable';
                        Select @CashBalance = InitialCashBalance,@PointsBalance=InitialPointsBalance from DeviceLot where id = @LotId;
                        SELECT @ProfileReference=description from DeviceProfileTemplate where id=@DeviceProfileId;
                        if(@ProfileType='Loyalty')
                        begin
                              select @DeviceStatusId = DeviceStatusId from DeviceStatus where ClientId = @ClientId AND Name = 'Active';
                              select @DeviceProfileStatusId = DeviceProfileStatusId from DeviceProfileStatus where ClientId = @ClientId AND Name = 'Active';
                        end
                        else if(@ProfileType='Voucher')
                        begin
                           
                            UPDATE DEVICELOT SET STATUSID = @DEVICELOTSTATUSNUMBERSASSIGNED WHERE ID = @LOTID
                              select @DeviceStatusId = DeviceStatusId from DeviceStatus where ClientId = @ClientId AND Name = 'Ready';
                              select @DeviceProfileStatusId = DeviceProfileStatusId from DeviceProfileStatus where ClientId = @ClientId AND Name = 'Created';
                              IF EXISTS(select 1 from VoucherDeviceProfileTemplate where ClassicalVoucher=1 and id=@DeviceProfileId)
                              BEGIN
                              select @DeviceStatusId = DeviceStatusId from DeviceStatus where ClientId = @ClientId AND Name = 'Active';
                              select @DeviceProfileStatusId = DeviceProfileStatusId from DeviceProfileStatus where ClientId = @ClientId AND Name = 'Active';
                              
                              END


                        end
                        SELECT @deviceTypeId = DeviceTypeId from DeviceType where Name = 'Card' and ClientId = @ClientId;

                        INSERT INTO [dbo].[Account] ([AccountStatusTypeId],[Pin],[ProgramId],[PointsPending],[CreateDate],[Version_old],[MonetaryBalance],[PointsBalance],[CurrencyId],[ExtRef])
                        select @AccountStatusId,NULL,NULL,0,GETDATE(),NULL,@CashBalance,@PointsBalance,@CurrencyId,@FullNumber;
                  
                        SELECT @AccountId=SCOPE_IDENTITY();
   
                        -- Insert statements for procedure here
                        INSERT INTO [dbo].[Device]
                                 ([DeviceId],[DeviceStatusId],[DeviceTypeId],[HomeSiteId],[CreateDate],[DeviceNumberPoolId]
                                 ,[ExpirationDate],[AccountId],[StartDate],[DevicelotId],[Reference])
                        select  @FullNumber,@DeviceStatusId,@deviceTypeId,@HomeSIteId,GETDATE(),@DevicePoolId,@EndDate,@AccountId,GETDATE(),@LotId,@ProfileReference;
                        
                        
                      
                        SELECT @DeviceId=SCOPE_IDENTITY();
                        INSERT INTO [dbo].[DeviceProfile]
                        ([StatusId],[DeviceId],[DeviceProfileId])
                        select      @DeviceProfileStatusId,@DeviceId,@DeviceProfileId;
                  
                              
                        Set @TotalNumbersGenerated= @TotalNumbersGenerated +1;
                        set @NumberSequencialRetries = 0;
                        
                        
                  END
                  ELSE
                  BEGIN             
                        SET @NumberSequencialRetries=@NumberSequencialRetries+1;
                  END
            END TRY
            BEGIN CATCH
                  EXECUTE usp_GetErrorInfo;
                  SET @NumberSequencialRetries=@NumberSequencialRetries+1;
            END CATCH
      END
      
      SELECT @DEVICELOTSTATUSNUMBERSASSIGNED = ID from devicelotstatus WHERE NAME = 'NumbersAssigned' AND CLIENTID = @CLIENTID
      UPDATE DEVICELOT SET STATUSID = @DEVICELOTSTATUSNUMBERSASSIGNED WHERE ID = @LOTID


      --------------------- Loggging----------------------
      SELECT @Message= 'Succesfully generated ' + cast(@TotalNumbersToCreate as nvarchar(10)) + ' device numbers for device number generator template: ' + cast(@DeviceNumberGeneratorTemplateId as nvarchar(5))
      SELECT @Level= 'Info'
      print @message
      SELECT @Stacktrace= ''
      INSERT INTO NLog_Error (time_stamp, host, type, source, message, level, logger, stacktrace) VALUES (GETDATE(), (SELECT @@SERVERNAME),@Identifier,(SELECT OBJECT_NAME(@@PROCID)),@Message, @Level, 'BWS', @Stacktrace)                        
      --------------------- Loggging----------------------

      SELECT @Result = 1
      SELECT 1 AS RESULT
    

END
