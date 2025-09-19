-- =============================================
-- Modified by:		Binu Jacob Scaria
-- Date: 2022-10-11
-- Change a little By Niall
-- Date: 2023-05-08
-- Description:	Include / Exclude
-- Modified Date: 2022-10-11
-- =============================================
CREATE PROCEDURE [dbo].[EPOS_CheckUser_NK](@ClientId int,@SourceAddress nvarchar(50))
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements
SET NOCOUNT ON;
--declare @ClientId int,@SourceAddress nvarchar(50)	
BEGIN TRY                              
DECLARE @UserId INT = 0,@DeviceId NVARCHAR(25),@profileType NVARCHAR(25) = 'Loyalty', @IsVirtual INT = 1,@message NVARCHAR(50)=''

IF ISNULL(@SourceAddress,'') != ''
BEGIN

	Declare @userstatusid int, @UserTypeId INT,@DeviceStatusIdActive INT,@ProfileTypeId INT,@TrxTypeId int;
	--SPENCER Loyalty DeviceProfileId
	SELECT @userstatusid =UserStatusId FROM UserStatus  WHERE [Name]='Active' and clientid = @clientid  
	SELECT @UserTypeId = [UserTypeId] FROM UserType   WHERE [Name]='LoyaltyMember' and clientid = @clientid 
	select @DeviceStatusIdActive = DeviceStatusId from [DeviceStatus]  WHERE [Name]='Active' and clientid = @clientid 
	SET @ProfileTypeId = 1;
	SET @TrxTypeId =17;
	--SET @DeviceStatusIdActive = 2;
	--SET @userstatusid = 2;
	--SET @UserTypeId =3;
	Drop table if exists #DL
	Select devicelotid into #DL from devicelotdeviceprofile where deviceprofileid = @ProfileTypeId	
	
	/*
	--SPENCER Loyalty DeviceProfileId
	SELECT @userstatusid =UserStatusId FROM UserStatus with(nolock) WHERE [Name]='Active' and clientid = @clientid  
	SELECT @UserTypeId = [UserTypeId] FROM UserType with(nolock) WHERE [Name]='LoyaltyMember' and clientid = @clientid 
	select @DeviceStatusIdActive = DeviceStatusId from [DeviceStatus] with(nolock) WHERE [Name]='Active' and clientid = @clientid 
	*/
	/*Check if there is a user for the @SourceAddress */
	--See if it is a NUMBER, therefore a phone number
	if isnumeric(replace(replace(@SourceAddress,'+',''),'-',''))  = 1 --Check the phone number for Userid
	Begin
		set @SourceAddress = replace(replace(@SourceAddress,'+',''),'-','')
		Select top 1 @userid =  u.userid  from contactdetails cd 
		join usercontactdetails ucd on cd.contactdetailsid=ucd.contactdetailsid 
		join [user] u on u.userid = ucd.userid and U.UserStatusId =@userstatusid AND  U.UserTypeId= @UserTypeId 
		where MobilePhone = @SourceAddress or MobilePhone = '+' + @SourceAddress 
		select @userid
	End
	--See if it is a Email, therefore a phone number
	IF ISNULL(@UserId,0) = 0 and isnumeric(replace(replace(@SourceAddress,'+',''),'-',''))=0 --Check on the Email Address for the Userid
	Begin
		Select @userid = u.userid  from contactdetails cd 
		join usercontactdetails ucd on cd.contactdetailsid=ucd.contactdetailsid 
		join [user] u on u.userid = ucd.userid and U.UserStatusId =@userstatusid AND  U.UserTypeId= @UserTypeId 
		where email = @SourceAddress 

	end 
	--print convert(nvarchar(100), isnull(@userid ,'')) + ' is the userid '
	IF ISNULL(@UserId,0) > 0 --If a user is found, get Device and get out
	BEGIN
		SELECT TOP 1 @DeviceId = d.deviceid
		from Device d With(nolock) inner join #DL dl on d.DeviceLotId=dl.DeviceLotId
		where d.UserId = @UserId AND d.DeviceStatusId=@DeviceStatusIdActive 
		If isnull(@DeviceId ,'') ='' -- Device not found for User! --should not happen but....
		Begin
			--Assign a device and send this one back
			/*Niall assign a device*/
			Update d set d.ExtraInfo =@SourceAddress, d.StartDate = GETDATE(),  d.[Owner]='-1' 
			from device d join (
			select top 1 dv.id
			from device dv join #DL dl on dv.devicelotid=dl.devicelotid
			where dv.userid is null and ExtraInfo is null and dv.DeviceStatusId = @DeviceStatusIdActive    
			and ([Owner]!=-1 or [Owner] is null)
			order by newID() ) x on x.id=d.id
			select @DeviceId = deviceid from Device where ExtraInfo=@SourceAddress
			--Also write an error
			EXEC Insert_Audit 'I', 1400012, 1, 'Device', 'ExtraInfo','Error, no availabe device on user, so assigned one', @SourceAddress
		End
	END


	IF ISNULL(@UserId,0) = 0 --No User, check if there is a DEVICE with the source address
	BEGIN
		SELECT TOP 1 @DeviceId = DeviceId FROM Device with(nolock) 
		WHERE ExtraInfo = @SourceAddress AND DeviceStatusId = @DeviceStatusIdActive
		SET @message = 'Unregistered'
		
		IF ISNULL(@DeviceId,'') != ''
		BEGIN
			DECLARE @TrxStatusCompletedId INT
			--SELECT @TrxStatusCompletedId = TrxStatusId From TrxStatus with(nolock) WHERE ClientId = @ClientId AND Name = 'Completed'
			SET @TrxStatusCompletedId = 2;
			IF NOT EXISTS (SELECT 1 FROM TrxHeader with(nolock) Where DeviceId  = @DeviceId AND TrxStatusTypeId = @TrxStatusCompletedId AND TrxTypeId=@TrxTypeId)
			BEGIN
				SET @Message = 'NewUnregistered'
			END
		END

		IF ISNULL(@DeviceId,'') =''
		BEGIN
		
			Update d set d.ExtraInfo =@SourceAddress, d.StartDate = GETDATE(),  d.[Owner]='-1' 
			from device d join (
			select top 1 dv.id
			from device dv join #DL dl on dv.devicelotid=dl.devicelotid
			where dv.userid is null and ExtraInfo is null and dv.DeviceStatusId = 2 and ([Owner]!=-1 or [Owner] is null)
			order by newID() ) x on x.id=d.id
			select @DeviceId = deviceid from Device where ExtraInfo=@SourceAddress

			IF @DeviceId is not null
			BEGIN
				-- Assign the virtual device to the username
				--Update Device set Owner = '-1', ExtraInfo = @SourceAddress ,StartDate = Getdate() where DeviceId = @DeviceId
				-- Audit assigned device
				EXEC Insert_Audit 'I', 1400012, 1, 'Device', 'ExtraInfo',@DeviceId, @SourceAddress

				SET @message = 'NewUnregistered'
			END
			ELSE
			BEGIN
				-- Audit error for no available device assigned 
			EXEC Insert_Audit 'I', 1400012, 1, 'Device', 'ExtraInfo','Error, no availabe device to assign', @SourceAddress
			END
		END
	END
END


SELECT @UserId AS UserId,@DeviceId AS DeviceId,@message AS Message
	                                                      
END TRY                                                        
BEGIN CATCH       
	
	declare @errormsg nvarchar(3000),@line nvarchar(50);
	--SET @errormsg = ERROR_MESSAGE();
	set @line = ERROR_LINE()  
	SET @errormsg = ERROR_MESSAGE() + @line;
	EXEC Insert_Audit 'I', 1400012, 1, 'Device', 'CheckUser',@errormsg , @SourceAddress
END CATCH       
END
