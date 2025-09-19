-- =============================================  
-- Author:  Binu Jacob Scaria  
-- Create date: 20-04-2016  
-- Description: Save Member Merge Details  
-- =============================================  
CREATE PROCEDURE [dbo].[SaveMemberMergeDetails]   
@sourceMemberId INT,  
@destinationMemberId INT,  
@clientid INT,  
@userId INT = null,  
@siteId INT = null,  
@externalUserId NVARCHAR(10),  
@terminalId NVARCHAR(25)  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
  
 BEGIN TRY  
BEGIN TRAN  
DECLARE   
@destinationTitleTypeId INT,  
@destinationContactBySms INT,  
@destinationDateOfBirth DATETIME,  
--@destinationInfoRateId INT,  
@destinationPersonalDetailsId INT,  
--@destinationIsEshop BIT,  
  
@destinationPhone NVARCHAR(100),  
@destinationMobilePhone NVARCHAR(100),  
@destinationStreet NVARCHAR(100),  
@destinationHouseNumber NVARCHAR(100),  
@destinationCity NVARCHAR(100),  
@destinationZip NVARCHAR(100),  
@destinationCountryId INT,  
@destinationAddressLine1 NVARCHAR(100),  
@destinationAddressLine2 NVARCHAR(100),  
@destinationPostBoxNumber NVARCHAR(100),  
@destinationEmail NVARCHAR(100),  
@destinationUsername NVARCHAR(100),  
@destinationPassword NVARCHAR(MAX),  
@destinationEmailStatusId INT,  
--@destinationSendNewsLetter2 INT,  
@destinationContactByEmail INT,  
@destinationContactDetailsId INT,  
@destinationAddressId INT,  
@destinationSiteId INT,  
  
@sourceTitleTypeId INT,  
@sourceContactBySms INT,  
@sourceDateOfBirth DATETIME,  
--@sourceInfoRateId INT,  
--@sourceIsEshop BIT,  
@sourcePersonalDetailsId INT,  
  
@sourcePhone NVARCHAR(100),  
@sourceMobilePhone NVARCHAR(100),  
@sourceStreet NVARCHAR(100),  
@sourceHouseNumber NVARCHAR(100),  
@sourceCity NVARCHAR(100),  
@sourceZip NVARCHAR(100),  
@sourceCountryId INT,  
@sourceAddressLine1 NVARCHAR(100),  
@sourceAddressLine2 NVARCHAR(100),  
@sourcePostBoxNumber NVARCHAR(100),  
@sourceEmail NVARCHAR(100),   
@sourceUsername NVARCHAR(100),   
@sourcePassword NVARCHAR(MAX),  
@sourceEmailStatusId INT,  
--@sourceSendNewsLetter2 INT,  
@sourceContactByEmail INT,  
@sourceContactDetailsId INT,  
@sourceAddressId INT,  
@sourceUserStatusIdMerged INT,  
@sourceSiteId INT,  
  
@AddressTypeIDMain INT,  
@AddressStatusIDCurrent INT,  
@AddressValidStatusIDValid INT,  
@DeviceStatusIdActive INT,  
@DeviceProfileTemplateTypeIdEshop INT  
  
  
SELECT @sourceUserStatusIdMerged = UserStatusId FROM UserStatus WHERE ClientId = @clientid AND name = 'Merged'  
  
SELECT @AddressTypeIDMain = AddressTypeId FROM addresstype WHERE clientid = @clientid AND name = 'Main'  
SELECT @AddressStatusIDCurrent = AddressStatusId FROM addressstatus WHERE clientid = @clientid AND name = 'Current'  
SELECT @AddressValidStatusIDValid = AddressValidStatusId FROM AddressValidStatus WHERE clientid = @clientid AND name = 'Valid'  
  
SELECT @DeviceStatusIdActive = DeviceStatusId FROM DeviceStatus WHERE Name='Active' AND ClientId = @clientid  
SELECT @DeviceProfileTemplateTypeIdEshop = Id FROM DeviceProfileTemplateType WHERE Name = 'Eshop' AND ClientId = @clientid  
--Get destination values  
SELECT   
@destinationTitleTypeId = pd.TitleTypeId,  
@destinationContactBySms = u.ContactBySms,  
@destinationDateOfBirth = pd.DateOfBirth,  
--@destinationInfoRateId = u.InfoRateId,  
@destinationPersonalDetailsId = u.PersonalDetailsId,  
@destinationUsername = u.Username,  
@destinationPassword = u.Password,  
@destinationContactByEmail = u.ContactByEmail,  
--@destinationSendNewsLetter2 = u.SendNewsLetter2,  
@destinationSiteId = u.SiteId  
--@destinationIsEshop = u.IsEshop  
FROM [USER] u INNER JOIN [PersonalDetails] pd ON u.PersonalDetailsId = pd.PersonalDetailsId WHERE UserId = @destinationMemberId  
  
SELECT TOP 1   
@destinationPhone = Phone,  
@destinationMobilePhone = MobilePhone,  
@destinationStreet = Street,  
@destinationCity = City,  
@destinationZip = Zip,  
@destinationCountryId = CountryId,  
@destinationAddressLine1 = AddressLine1,  
@destinationAddressLine2 = AddressLine2,  
@destinationPostBoxNumber = PostBoxNumber,  
@destinationEmail = Email,  
@destinationEmailStatusId = EmailStatusId,  
@destinationContactDetailsId = ISNULL(a.ContactDetailsId,0),  
@destinationAddressId = a.AddressId,  
@destinationHouseNumber = a.HouseNumber  
FROM [Address] a INNER JOIN [UserAddresses] ua ON a.AddressId = ua.AddressId LEFT JOIN ContactDetails cd ON a.ContactDetailsId = cd.ContactDetailsId WHERE a.AddressTypeId = @AddressTypeIDMain AND a.AddressStatusId = @AddressStatusIDCurrent AND a.AddressValidStatusId = @AddressValidStatusIDValid AND ua.UserId=@destinationMemberId  
  
--Get source values  
SELECT   
@sourceTitleTypeId = pd.TitleTypeId,  
@sourceContactBySms = u.ContactBySms,  
@sourceDateOfBirth = pd.DateOfBirth,  
--@sourceInfoRateId = u.InfoRateId,  
@sourcePersonalDetailsId = u.PersonalDetailsId,  
@sourceUsername = u.Username,  
@sourcePassword = u.Password,  
@sourceContactByEmail = u.ContactByEmail,  
--@sourceSendNewsLetter2 = u.SendNewsLetter2,  
@sourceSiteId = u.SiteId 
--@sourceIsEshop = u.IsEshop  
FROM [USER] u INNER JOIN [PersonalDetails] pd ON u.PersonalDetailsId = pd.PersonalDetailsId WHERE UserId = @sourceMemberId  
  
SELECT TOP 1   
@sourcePhone = Phone,  
@sourceMobilePhone = MobilePhone,  
@sourceStreet = Street,  
@sourceCity = City,  
@sourceZip = Zip,  
@sourceCountryId = CountryId,  
@sourceAddressLine1 = AddressLine1,  
@sourceAddressLine2 = AddressLine2,  
@sourcePostBoxNumber = PostBoxNumber,  
@sourceEmail = Email,  
@sourceEmailStatusId = EmailStatusId,  
@sourceContactDetailsId = ISNULL(a.ContactDetailsId,0),  
@sourceAddressId = a.AddressId,  
@sourceHouseNumber = a.HouseNumber  
FROM [Address] a INNER JOIN [UserAddresses] ua ON a.AddressId = ua.AddressId LEFT JOIN ContactDetails cd ON a.ContactDetailsId = cd.ContactDetailsId WHERE a.AddressTypeId = @AddressTypeIDMain AND a.AddressStatusId = @AddressStatusIDCurrent AND a.AddressValidStatusId = @AddressValidStatusIDValid AND ua.UserId = @sourceMemberId  
  
  
--Merge Process  
IF @destinationEmail IS NOT NULL AND @destinationEmail != '' AND @destinationEmail = @sourceEmail  
BEGIN  
 DECLARE @ParentId INT;  
 SET @ParentId = (SELECT Top 1 SiteId FROM Site where Name = 'Humanic Austria HQ' and ClientId = @clientid)  
 IF NOT EXISTS (SELECT 1 FROM Site where ParentId = @ParentId AND SiteId = @destinationSiteId and ClientId = @ClientId)  
 BEGIN  
  SET @destinationSiteId = @sourceSiteId  
 END  
END  
  
--SET @destinationInfoRateId = @sourceInfoRateId  
  
--IF @sourceIsEshop = 1  
--BEGIN  
-- SET @destinationIsEshop = 1  
--END  
  
IF @sourceTitleTypeId  > 0  
BEGIN  
 DECLARE @destinationTitleType NVARCHAR(25),@sourceTitleType NVARCHAR(25)  
 SELECT @destinationTitleType = Name FROM TitleType where TitleTypeId = @destinationTitleTypeId  
 SELECT @sourceTitleType = Name FROM TitleType where TitleTypeId = @sourceTitleTypeId  
   
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'TitleType',@sourceTitleType,@destinationTitleType,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
   
 SET @destinationTitleTypeId = @sourceTitleTypeId  
END  
  
IF @sourcePhone IS NOT NULL AND @sourcePhone != ''  
BEGIN  
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'Phone',@sourcePhone,@destinationPhone,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
 SET @destinationPhone = @sourcePhone  
END  
  
IF (@destinationMobilePhone IS NULL OR @destinationMobilePhone = '') AND (@sourceMobilePhone IS NOT NULL OR @sourceMobilePhone != '')   
BEGIN  
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'MobilePhone',@sourceMobilePhone,@destinationMobilePhone,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES (1,'ContactBySms',@sourceContactBySms,@destinationContactBySms,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
 SET @destinationMobilePhone = @sourceMobilePhone  
 SET @destinationContactBySms = @sourceContactBySms  
END  
ELSE IF (@destinationMobilePhone IS NOT NULL OR @destinationMobilePhone != '') AND @destinationContactBySms != 1 AND (@sourceMobilePhone IS NOT NULL OR @sourceMobilePhone != '') AND @sourceContactBySms = 1   
BEGIN  
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'MobilePhone',@sourceMobilePhone,@destinationMobilePhone,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'ContactBySms',@sourceContactBySms,@destinationContactBySms,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
 SET @destinationMobilePhone = @sourceMobilePhone  
 SET @destinationContactBySms = @sourceContactBySms  
END  
  
IF (@destinationEmail IS NULL OR @destinationEmail = '')  
BEGIN  
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'Email',@sourceEmail,@destinationEmail,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
 SET @destinationEmail = @sourceEmail  
END  
  
IF @destinationDateOfBirth IS NULL AND @sourceDateOfBirth IS NOT NULL  
BEGIN  
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'DateOfBirth',@sourceDateOfBirth,@destinationDateOfBirth,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
 SET @destinationDateOfBirth = @sourceDateOfBirth  
END  
ELSE IF @destinationDateOfBirth IS NOT NULL AND @sourceDateOfBirth IS NOT NULL   
BEGIN  
   IF (DATEPART(yyyy,@destinationDateOfBirth )= 1990) OR (@destinationDateOfBirth < @sourceDateOfBirth) AND @destinationDateOfBirth != @sourceDateOfBirth  
   BEGIN  
    INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'DateOfBirth',@sourceDateOfBirth,@destinationDateOfBirth,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
  SET @destinationDateOfBirth = @sourceDateOfBirth  
   END  
END  
  
IF (@sourceStreet IS NOT NULL AND @sourceStreet != '') AND @destinationStreet != @sourceStreet  
BEGIN  
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'Street',@sourceStreet,@destinationStreet,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
 SET @destinationStreet = @sourceStreet  
END  
  
IF (@sourceHouseNumber IS NOT NULL AND @sourceHouseNumber != '') AND @destinationHouseNumber != @sourceHouseNumber  
BEGIN  
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'HouseNumber',@sourceHouseNumber,@destinationHouseNumber,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
 SET @destinationHouseNumber = @sourceHouseNumber  
END  
  
IF (@sourceCity IS NOT NULL AND @sourceCity  != '') AND @destinationCity  != @sourceCity  
BEGIN  
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'City',@sourceCity,@destinationCity,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
 SET @destinationCity  = @sourceCity   
END  
  
IF (@sourceZip IS NOT NULL AND @sourceZip  != '') AND @destinationZip  != @sourceZip  
BEGIN  
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'Zip',@sourceZip,@destinationZip,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
 SET @destinationZip  = @sourceZip  
END  
  
IF (@sourceCountryId IS NOT NULL AND @sourceCountryId  != '') AND @destinationCountryId  != @sourceCountryId  
BEGIN  
  
 DECLARE @destinationCountry NVARCHAR(25),@sourceCountry NVARCHAR(25)  
 SELECT @destinationCountry = Name FROM Country where CountryId = @destinationCountryId  
 SELECT @sourceCountry = Name FROM Country where CountryId = @sourceCountryId  
   
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'Country',@sourceCountry,@destinationCountry,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
 SET @destinationCountryId  = @sourceCountryId  
END  
  
IF (@sourceAddressLine1 IS NOT NULL AND @sourceAddressLine1  != '') AND @destinationAddressLine1  != @sourceAddressLine1  
BEGIN  
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'AddressLine1',@sourceAddressLine1,@destinationAddressLine1,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
 SET @destinationAddressLine1  = @sourceAddressLine1  
END  
  
IF (@sourceAddressLine2 IS NOT NULL AND @sourceAddressLine2  != '') AND @destinationAddressLine2  != @sourceAddressLine2  
BEGIN  
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'AddressLine2',@sourceAddressLine2,@destinationAddressLine2,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
 SET @destinationAddressLine2  = @sourceAddressLine2  
END  
  
IF (@sourcePostBoxNumber IS NOT NULL AND @sourcePostBoxNumber  != '') AND @destinationPostBoxNumber  != @sourcePostBoxNumber  
BEGIN  
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'PostBoxNumber',@sourcePostBoxNumber,@destinationPostBoxNumber,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
 SET @destinationPostBoxNumber  = @sourcePostBoxNumber  
END  
--Switch Email, Username,Password, SendNewsLetter2 and ContactByEmail  
IF (@sourceUsername NOT LIKE('%@dummy.lsag.com'))  
BEGIN  
 DECLARE   
 @username NVARCHAR(100) = @sourceUsername,  
 @password NVARCHAR(MAX) = @sourcePassword,  
 @email NVARCHAR(100) = @sourceEmail,  
 @emailStatusId INT = @sourceEmailStatusId,  
 --@SendNewsLetter2 INT = @sourceSendNewsLetter2,  
 @ContactByEmail INT = @sourceContactByEmail,  
   
 @sourceDeviceIdentity INT,  
 @sourceDeviceId NVARCHAR(50),  
 @destinationDeviceIdentity INT,  
 @destinationDeviceId NVARCHAR(50),  
 @DeviceStatusTransitionTypeId INT,  
 @DeviceActionId INT  
    
 SELECT TOP 1 @sourceDeviceIdentity =  d.Id,@sourceDeviceId = d.DeviceId FROM Device d INNER JOIN DeviceProfile dp ON d.Id = dp.DeviceId INNER JOIN DeviceProfileTemplate dpt ON dp.DeviceProfileId = dpt.Id  WHERE d.DeviceStatusId = @DeviceStatusIdActive AND dpt.DeviceProfileTemplateTypeId = @DeviceProfileTemplateTypeIdEshop AND ISNULL(d.ExtraInfo,'') ='' AND UserId = @sourceMemberId  
 SELECT TOP 1 @destinationDeviceIdentity = d.Id,@destinationDeviceId=d.DeviceId FROM Device d INNER JOIN DeviceProfile dp ON d.Id = dp.DeviceId INNER JOIN DeviceProfileTemplate dpt ON dp.DeviceProfileId = dpt.Id WHERE d.DeviceStatusId = @DeviceStatusIdActive AND dpt.DeviceProfileTemplateTypeId = @DeviceProfileTemplateTypeIdEshop AND ISNULL(d.ExtraInfo,'') ='' AND UserId = @destinationMemberId  
      
    SELECT TOP 1 @DeviceStatusTransitionTypeId = DeviceStatusTransitionTypeId FROM DeviceStatusTransitionType WHERE Name = 'Automatic' AND ClientId = @clientid  
 SELECT TOP 1 @DeviceActionId = DeviceActionId FROM DeviceAction WHERE Name = 'MergeFromUser' AND ClientId = @clientid  
      
    INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'Username',@sourceUsername,@destinationUsername,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
   
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'Username',@destinationUsername,@sourceUsername,getdate(),'Member Merge' ,'MemberMerge' ,@sourceMemberId,@userId,NULL )  
   
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'Email',@sourceEmail,@destinationEmail,getdate(),'Member Merge' ,'MemberMerge' ,@destinationMemberId,@userId,NULL )  
   
 INSERT INTO [Audit](Version, FieldName,NewValue,OldValue,ChangeDate,Reason,ReferenceType,UserId,ChangeBy,OperatorId)  
 VALUES      (1,'Email',@destinationEmail,@sourceEmail,getdate(),'Member Merge' ,'MemberMerge' ,@sourceMemberId,@userId,NULL )  
   
 SET @sourceUsername = @destinationUsername  
 SET @sourcePassword = @destinationPassword  
 SET @sourceEmail = @destinationEmail  
 SET @sourceEmailStatusId = @destinationEmailStatusId  
 --SET @sourceSendNewsLetter2 = @destinationSendNewsLetter2  
 SET @sourceContactByEmail = @destinationContactByEmail  
   
 SET @destinationUsername = @Username  
 SET @destinationPassword = @Password  
 SET @destinationEmail = @Email  
 SET @destinationEmailStatusId = @EmailStatusId  
 --SET @destinationSendNewsLetter2 = @SendNewsLetter2  
 SET @destinationContactByEmail = @ContactByEmail  
   
   
 --<SAVE MEMBERS>  
 --Update Destination Member  
 UPDATE [USER] SET ContactBySms = @destinationContactBySms,Username = @destinationUsername,Password = @destinationPassword ,ContactByEmail = @destinationContactByEmail,SiteId=@destinationSiteId  WHERE userid = @destinationMemberId  
 UPDATE [PersonalDetails] SET TitleTypeId = @destinationTitleTypeId, DateOfBirth = @destinationDateOfBirth WHERE PersonalDetailsId = @destinationPersonalDetailsId  
 UPDATE [Address] SET Street= @destinationStreet,City=@destinationCity,Zip = @destinationZip,CountryId = @destinationCountryId,AddressLine1 = @destinationAddressLine1,AddressLine2 = @destinationAddressLine2,PostBoxNumber = @destinationPostBoxNumber,HouseNumber = @destinationHouseNumber WHERE AddressId = @destinationAddressId  
 UPDATE [ContactDetails] SET Phone =@destinationPhone,MobilePhone = @destinationMobilePhone,Email= @destinationEmail,EmailStatusId = @destinationEmailStatusId WHERE ContactDetailsId = @destinationContactDetailsId   
 --Update Source Member  
    UPDATE [USER] SET ContactBySms = @sourceContactBySms,Username = @sourceUsername,Password = @sourcePassword ,ContactByEmail = @sourceContactByEmail, UserStatusId = @sourceUserStatusIdMerged WHERE userid = @sourceMemberId  
 UPDATE [PersonalDetails] SET TitleTypeId = @sourceTitleTypeId, DateOfBirth = @sourceDateOfBirth WHERE PersonalDetailsId = @sourcePersonalDetailsId  
 UPDATE [Address] SET Street= @sourceStreet,City=@sourceCity,Zip = @sourceZip,CountryId = @sourceCountryId,AddressLine1 = @sourceAddressLine1,AddressLine2 = @sourceAddressLine2,PostBoxNumber = @sourcePostBoxNumber WHERE AddressId = @sourceAddressId  
 UPDATE [ContactDetails] SET Phone =@sourcePhone,MobilePhone = @sourceMobilePhone,Email= @sourceEmail,EmailStatusId = @sourceEmailStatusId WHERE ContactDetailsId = @sourceContactDetailsId   
 --  
--Print 'Switch Des :' + convert(nvarchar(25),@destinationDeviceIdentity)  
    UPDATE Device SET UserId = @sourceMemberId WHERE Id = @destinationDeviceIdentity  
 IF @@ROWCOUNT >0  
 BEGIN  
  INSERT INTO [DeviceStatusHistory]  
           ([VERSION]  
           ,[DeviceId]  
           ,[DeviceStatusId]  
           ,[ChangeDate]  
           ,[Reason]  
           ,[DeviceStatusTransitionType]  
           ,[ExtraInfo]  
           ,[UserId]  
           ,[ActionId]  
           ,[DeviceTypeResult]  
           ,[ActionResult]  
           ,[ActionDetail]  
           ,[OldValue]  
           ,[NewValue]  
           ,[SiteId]  
           ,[Processed]  
           ,[DeviceIdentity]  
           ,[OpId]  
           ,[TerminalId])  
     VALUES  
           (1  
           ,@destinationDeviceId  
           ,@DeviceStatusIdActive  
           ,GETDATE()  
           ,'Switch OnlineAccountId'  
           ,@DeviceStatusTransitionTypeId  
           ,'Switch OnlineAccountId'  
           ,@userid  
           ,@DeviceActionId  
           ,'MainCard'  
           ,1  
           ,'Switch OnlineAccountId'  
           ,@destinationMemberId  
           ,@sourceMemberId  
           ,@siteId  
           ,0  
           ,@destinationDeviceIdentity  
           ,@externalUserId  
           ,@TerminalId)  
 END  
 --Print 'Switch source :' + convert(nvarchar(25),@sourceDeviceIdentity)  
 UPDATE Device SET UserId = @destinationMemberId WHERE Id = @sourceDeviceIdentity  
 IF @@ROWCOUNT >0  
 BEGIN  
  INSERT INTO [DeviceStatusHistory]  
           ([VERSION]  
           ,[DeviceId]  
           ,[DeviceStatusId]  
           ,[ChangeDate]  
           ,[Reason]  
           ,[DeviceStatusTransitionType]  
           ,[ExtraInfo]  
           ,[UserId]  
           ,[ActionId]  
           ,[DeviceTypeResult]  
           ,[ActionResult]  
           ,[ActionDetail]  
           ,[OldValue]  
           ,[NewValue]  
           ,[SiteId]  
           ,[Processed]  
           ,[DeviceIdentity]  
           ,[OpId]  
           ,[TerminalId])  
     VALUES  
           (1  
           ,@sourceDeviceId  
           ,@DeviceStatusIdActive  
           ,GETDATE()  
           ,'Switch OnlineAccountId'  
           ,@DeviceStatusTransitionTypeId  
           ,'Switch OnlineAccountId'  
           ,@userid  
           ,@DeviceActionId  
           ,'MainCard'  
           ,1  
           ,'Switch OnlineAccountId'  
           ,@sourceMemberId  
           ,@destinationMemberId  
           ,@siteId  
           ,0  
           ,@sourceDeviceIdentity  
           ,@externalUserId  
           ,@TerminalId)  
 END  
END  
ELSE  
BEGIN  
--Update Destination Member  
 UPDATE [USER] SET ContactBySms = @destinationContactBySms,Username = @destinationUsername,Password = @destinationPassword ,ContactByEmail = @destinationContactByEmail,SiteId=@destinationSiteId WHERE userid = @destinationMemberId  
 UPDATE [PersonalDetails] SET TitleTypeId = @destinationTitleTypeId, DateOfBirth = @destinationDateOfBirth WHERE PersonalDetailsId = @destinationPersonalDetailsId  
 UPDATE [Address] SET Street= @destinationStreet,City=@destinationCity,Zip = @destinationZip,CountryId = @destinationCountryId,AddressLine1 = @destinationAddressLine1,AddressLine2 = @destinationAddressLine2,PostBoxNumber = @destinationPostBoxNumber,HouseNumber = @destinationHouseNumber WHERE AddressId = @destinationAddressId  
 UPDATE [ContactDetails] SET Phone =@destinationPhone,MobilePhone = @destinationMobilePhone,Email= @destinationEmail,EmailStatusId = @destinationEmailStatusId WHERE ContactDetailsId = @destinationContactDetailsId   
 --Update Source Member UserStatus  
 UPDATE [USER] SET UserStatusId = @sourceUserStatusIdMerged WHERE userid = @sourceMemberId  
END  
--Merge Devices  
  
DECLARE @CursorDeviceIdentity INT,@CursorDeviceId NVARCHAR(50),@CursorDeviceProfileTemplateTypeId INT  
  
DECLARE userDevicesCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR    
SELECT d.Id ,d.DeviceId,dpt.DeviceProfileTemplateTypeId FROM Device d INNER JOIN DeviceProfile dp ON d.Id = dp.DeviceId INNER JOIN DeviceProfileTemplate dpt ON dp.DeviceProfileId = dpt.Id  WHERE UserId = @sourceMemberId  
OPEN userDevicesCursor  
  
FETCH NEXT FROM userDevicesCursor   
INTO @CursorDeviceIdentity, @CursorDeviceId,@CursorDeviceProfileTemplateTypeId  
WHILE @@FETCH_STATUS = 0  
BEGIN  
IF(@CursorDeviceProfileTemplateTypeId = @DeviceProfileTemplateTypeIdEshop)  
BEGIN  
 UPDATE Device SET userId = @destinationMemberId, ExtraInfo = @sourceMemberId WHERE id = @CursorDeviceIdentity  
 update [dbo].[Account] set Userid = @destinationMemberId where AccountId IN (SELECT TOP 1 AccountId FROM Device Where Id = @CursorDeviceIdentity)  
END  
ELSE  
BEGIN  
 UPDATE Device SET userId = @destinationMemberId WHERE id = @CursorDeviceIdentity  
 update [dbo].[Account] set Userid = @destinationMemberId where AccountId IN (SELECT TOP 1 AccountId FROM Device Where Id = @CursorDeviceIdentity)  
END  
  
IF @@ROWCOUNT >0  
 BEGIN  
  INSERT INTO [DeviceStatusHistory]  
           ([VERSION]  
           ,[DeviceId]  
           ,[DeviceStatusId]  
           ,[ChangeDate]  
           ,[Reason]  
           ,[DeviceStatusTransitionType]  
           ,[ExtraInfo]  
           ,[UserId]  
           ,[ActionId]  
           ,[DeviceTypeResult]  
           ,[ActionResult]  
           ,[ActionDetail]  
           ,[OldValue]  
           ,[NewValue]  
           ,[SiteId]  
           ,[Processed]  
           ,[DeviceIdentity]  
           ,[OpId]  
           ,[TerminalId])  
     VALUES  
           (1  
           ,@CursorDeviceId  
           ,@DeviceStatusIdActive  
           ,GETDATE()  
           ,'Switch OnlineAccountId'  
           ,@DeviceStatusTransitionTypeId  
           ,'Switch OnlineAccountId'  
           ,@userid  
           ,@DeviceActionId  
           ,'MainCard'  
           ,1  
           ,'Switch OnlineAccountId'  
           ,@sourceMemberId  
           ,@destinationMemberId  
           ,@siteId  
           ,0  
           ,@CursorDeviceIdentity  
           ,@externalUserId  
           ,@TerminalId)  
 END  
  
FETCH NEXT FROM userDevicesCursor   
INTO @CursorDeviceIdentity, @CursorDeviceId,@CursorDeviceProfileTemplateTypeId  
END  
  
--MemberLink Entry  
INSERT INTO [MemberLink]  
           ([MemberId1]  
           ,[MemberId2]  
           ,[LinkType]  
           ,[ParentChild]  
           ,[CreatedBy]  
           ,[CreatedDate]  
           ,[VERSION]  
           ,[ConfidenceLevel]  
           --,[MergeSource]
           )  
     VALUES  
           (@destinationMemberId  
           ,@sourceMemberId  
           ,(SELECT TOP 1 MemberLinkTypeId FROM MemberLinkType WHERE ClientId = @clientid AND Name = 'Merger')  
           ,0  
           ,@userId  
           ,GETDATE()  
           ,1  
           ,0  
           )  
  
--Merge Avatar  
--DECLARE @AvatarStatusIdActive INT, @AvatarStatusIdInActive INT  
  
--SELECT @AvatarStatusIdActive = AvatarStatusId FROM AvatarStatus WHERE ClientId = @clientid AND Name = 'Active'  
--SELECT @AvatarStatusIdInActive = AvatarStatusId FROM AvatarStatus WHERE ClientId = @clientid AND Name = 'InActive'  
  
--UPDATE Avatar SET UserId = @destinationMemberId WHERE Id IN(SELECT Id FROM Avatar WHERE AvatarStatusId = @AvatarStatusIdActive AND  Created IS NOT NULL AND UserId = @sourceMemberId)  
  
--UPDATE Avatar SET AvatarStatusId = @AvatarStatusIdInActive WHERE Id IN(SELECT Id FROM Avatar WHERE AvatarStatusId = @AvatarStatusIdActive AND  Created IS NULL AND UserId = @sourceMemberId)  
  
--Call Another SP  
EXEC  bws_MembermergeActions @destinationMemberId,@sourcememberId,'MemberRegisteration',@clientId,0  
 COMMIT TRAN  
END TRY  
BEGIN CATCH  
    ROLLBACK TRAN  
END CATCH  
END
