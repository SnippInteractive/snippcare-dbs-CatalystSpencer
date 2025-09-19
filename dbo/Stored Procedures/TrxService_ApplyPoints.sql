
/****** 
This is used to apply point to user for registration and profile completion
Device and promotion need to be set up in order for the process to work 
Date: 13/01/2020 17:27:18
******/

CREATE PROCEDURE [dbo].[TrxService_ApplyPoints] (@ClientName NVARCHAR(100), @UserId int, @ItemCode NVARCHAR(30),@Description NVARCHAR(200), @PosId NVARCHAR(20), @OpId NVARCHAR(50), @PosTxnId NVARCHAR(20), @Data NVARCHAR(200) OUTPUT)
AS
BEGIN
	
	SET NOCOUNT ON;

	Declare @RegistrationPointValue DECIMAL(8, 2);
	Declare @TrxDetailId int;
	Declare @CurrentPoint int;
	Declare @ClientId int;
	Declare @ProfileField NVARCHAR(1000);
	Declare @Valid int = 0;
	Declare @ValidField NVARCHAR(500);
	--------TrxHeader----------------------------
	Declare @SiteId int;
	Declare @PosDescription NVARCHAR(100) = null;
	Declare @DeviceId NVARCHAR(25);
	Declare @TrxdateTime DATETIME = GETDATE();
	Declare @NewTrxId INT
	--------TrxDetail---------------------------- 
	Declare @LineNumber SMALLINT;
	Declare @Anal1 NVARCHAR(50)= NULL;
	Declare @Anal2 NVARCHAR(50) = NULL;
	Declare @Anal3 NVARCHAR(50) = NULL;
	Declare @Anal4 NVARCHAR(50) = NULL;
	Declare @Quantity FLOAT;
	Declare @LineValue MONEY;
	Declare @EposDiscount MONEY;
	Declare @PromotionId int = 0; 
	Declare @PromotionValue money = 0.00;	
	Declare @LoyaltyDiscount MONEY
	--------------------------------------------
	Select @ClientId = ClientId from Client where [Name] = @ClientName
	Select @DeviceId = DeviceId from Device where UserId = @UserId;
	DECLARE @AddressStatusIdCurrent INT, @UserStatusIdActive INT, @UserStatusIdPotential INT, @addressvalidstatusid INT      
	DECLARE @AddressTypeIdMain INT   
	SELECT @AddressStatusIdCurrent = AddressStatusId FROM   [AddressStatus] WHERE Name = 'Current' and ClientId = @clientId       
	SELECT @AddressTypeIdMain = AddressTypeId FROM   [AddressType] WHERE  Name = 'Main' and ClientId = @clientId      
	SELECT @UserStatusIdActive = UserStatusId  FROM [UserStatus] WHERE ClientId = @clientId and  Name = 'Active'              
	SELECT @addressvalidstatusid = addressvalidstatusid FROM   [addressvalidstatus] WHERE  Name = 'Valid' and ClientId = @clientId

	IF @ItemCode = 'MemberProfileData'
	BEGIN
		Select top 1 @promotionId = p.Id, @RegistrationPointValue = p.PromotionOfferValue, @SiteId = p.SiteId, @ProfileField = pmpi.ItemName from Promotion p
		join PromotionCategory pc on pc.id = p.PromotionCategoryId
		join PromotionMemberProfileItem pmpi on pmpi.PromotionId = p.Id
		where pc.Name = @ItemCode and p.Enabled = 1
		and EndDate > GETDATE()
		order by p.PromotionOfferValue desc

		IF @ProfileField = 'DateOfBirth' 
		BEGIN
			  select @ValidField = @ProfileField from PersonalDetails pd
			  join [User] u on u.PersonalDetailsId = pd.PersonalDetailsId
			  where u.UserId = @UserId

			  IF @ValidField is not null
			  BEGIN
				set @Valid = 1;
			  END
		END
		IF @ProfileField = 'Address' 
		BEGIN
			  set @ProfileField = 'AddressLine1'
			  select @ValidField = @ProfileField from[User] u
			  inner join  [UserAddresses] ua  WITH (NOLOCK) on ua.userid = u.userid                              
			  inner join Address a  WITH (NOLOCK) on ua.AddressId = a.AddressId  
			  where u.UserId = @UserId and a.AddressStatusId = @AddressStatusIdCurrent
			  and a.AddressValidStatusId = @addressvalidstatusid 

			  IF @ValidField is not null
			  BEGIN
				set @Valid = 1;
			  END
		END
		IF @ProfileField = 'Phone' 
		BEGIN
			  select @ValidField = @ProfileField from [User] u
			  join UserContactDetails ucd on ucd.UserId = u.UserId
			  join ContactDetails cd on cd.ContactDetailsId = ucd.ContactDetailsId
			  where u.UserId = @UserId

			  IF @ValidField is not null
			  BEGIN
				set @Valid = 1;
			  END
		END
		IF @ProfileField = 'Mobile' 
		BEGIN
			  set @ProfileField = 'MobilePhone'
			  select @ValidField = @ProfileField from [User] u
			  join UserContactDetails ucd on ucd.UserId = u.UserId
			  join ContactDetails cd on cd.ContactDetailsId = ucd.ContactDetailsId
			  where u.UserId = @UserId

			  IF @ValidField is not null
			  BEGIN
				set @Valid = 1;
			  END
		END
		IF @ProfileField = 'Email' 
		BEGIN
			  select @ValidField = @ProfileField from [User] u
			  join UserContactDetails ucd on ucd.UserId = u.UserId
			  join ContactDetails cd on cd.ContactDetailsId = ucd.ContactDetailsId
			  where u.UserId = @UserId

			  IF @ValidField is not null
			  BEGIN
				set @Valid = 1;
			  END
		END

	END
	ELSE
	BEGIN
		Select top 1 @promotionId = p.Id, @RegistrationPointValue = p.PromotionOfferValue, @SiteId = p.SiteId from Promotion p
		join PromotionCategory pc on pc.id = p.PromotionCategoryId
		where pc.Name = @ItemCode and p.Enabled = 1
		and EndDate > GETDATE()
		order by p.PromotionOfferValue desc
		set @Valid = 1;
	END

	Select @LineNumber = 1;
	Select @Quantity = 1;
	Select @LineValue = 0;
	Select @EposDiscount = 0;
	Select @LoyaltyDiscount = 0;
	---------------------------------------------
	BEGIN TRY
    BEGIN TRANSACTION 	
	  DECLARE @DeviceExist INT,@TrxTypeId INT,@TrxStatusId INT;   
	  SET @TrxTypeId=(select TrxTypeId from trxtype where name='Activation' and clientid = @ClientId)
	  SET @TrxStatusId=(select TrxStatusId from TrxStatus where name='Completed' and clientid = @ClientId)
	  declare @devicestatusId INt
	  set @devicestatusId=(select devicestatusid from devicestatus where name='active' and clientid=@ClientId)

      IF @DeviceId IS NOT NULL and @Valid = 1
        BEGIN
            SELECT @DeviceExist = COUNT(*)
            FROM   Device d 
			join DeviceProfile dp on d.id=dp.DeviceId
			join LoyaltyDeviceProfileTemplate lp on dp.DeviceProfileId=lp.Id
			where d.deviceid = @DeviceId and DeviceStatusId=@devicestatusId                                       			

            IF ( @DeviceExist != 0 )
              BEGIN
                  INSERT INTO TrxHeader
                              (ClientId,DeviceId,TrxTypeId,TrxDate,SiteId,TerminalId,TerminalDescription,Reference,OpId,TrxStatusTypeId)
                  VALUES      (@ClientId,@DeviceId,@TrxTypeId,@TrxdateTime,@SiteId,@PosId,@PosDescription, @PosTxnId,@OpId,@TrxStatusId);

                  SELECT @NewTrxId = Scope_identity();				  
              END
            ELSE
              BEGIN
                  SELECT @NewTrxId = 0;
              END
        END
      ELSE
        BEGIN
            SELECT @NewTrxId = 0;
        END
	   
	------------------------------------------------
	  IF @NewTrxId != 0
		BEGIN

			INSERT INTO TrxDetail
					  ([Version], TrxID,LineNumber,ItemCode,DESCRIPTION,Anal1,Anal2,Anal3,Anal4,Quantity,VALUE,EposDiscount,Points, PromotionId, PromotionalValue,LoyaltyDiscount)--,Anal5,Anal6,Anal7,Anal8,Anal9,Anal10,Anal11,Anal12,Anal13,Anal14,Anal15)
			VALUES ('1', @NewTrxId,@LineNumber,@ItemCode,@Description,@Anal1,@Anal2,@Anal3,@Anal4,@Quantity,@LineValue,@EposDiscount,@RegistrationPointValue, @PromotionId, @PromotionValue,@LoyaltyDiscount);--, @Anal5, @Anal6, @Anal7, @Anal8, @Anal9, @Anal10, @Anal11, @Anal12, @Anal13, @Anal14,@Anal15 );
		
			Select @TrxDetailId = TrxDetailID from TrxDetail where TrxID = @NewTrxId and PromotionID = @PromotionId; 

			insert into TrxDetailPromotion ([Version], PromotionId, TrxDetailId , ValueUsed) values (1, @promotionId, @TrxDetailId, @RegistrationPointValue);

			select @CurrentPoint = PointsBalance from Account where UserId = @UserId and ExtRef = @DeviceId

			update Account set PointsBalance = (@CurrentPoint + @RegistrationPointValue) where  UserId = @UserId and ExtRef = @DeviceId 

			set @Data = 'Success, Point Applied.'
			insert into Audit ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,ChangeBy,Reason,ReferenceType,OperatorId,SiteId)
			Values ('1',@UserId,@ItemCode, @CurrentPoint + @RegistrationPointValue, @CurrentPoint, GETDATE(), '1400006',@Data,'Account',null,@SiteId)
		END
	  ELSE												
		BEGIN 
			set @Data = 'Failed, No Device Found.'
			insert into Audit ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,ChangeBy,Reason,ReferenceType,OperatorId,SiteId)
			Values ('1',@UserId,@ItemCode, @Data, @CurrentPoint, GETDATE(), '1400006',@Data,'Account',null,@SiteId)
		END
	COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
		set @Data = 'Failed, Can not create a transaction.'
		insert into Audit ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,ChangeBy,Reason,ReferenceType,OperatorId,SiteId)
			Values ('1',@UserId,@ItemCode, @Data, @CurrentPoint, GETDATE(), '1400006',@Data,'Account',null,@SiteId)
	END CATCH

END
