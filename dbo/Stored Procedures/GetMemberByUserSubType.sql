CREATE PROCEDURE [dbo].[GetMemberByUserSubType]    
@Clientid INT NULL = 1 ,  
@Source NVARCHAR(100),  
@Result NVARCHAR(MAX) OUTPUT  
AS  
BEGIN      
  
    SET NOCOUNT ON;  
  
 DECLARE @UserSubTypeId   INT,  
   @AddressTypeId   INT,   
   @AddressStatusId  INT,   
   @AddressValidStatusId INT,    
   @ExtensionJsonData  NVARCHAR(MAX)  
  
    IF @clientid IS NULL   
 BEGIN   
  SET @clientid = 1   
 END   
   
 SELECT @UserSubTypeId = UserSubTypeId   
 FROM USERSUBTYPE   
 WHERE [Name] = @Source   
 AND  ClientId = @Clientid  
   
 SELECT @AddressTypeId = AddressTypeId   
 FROM AddressType   
 WHERE [Name]='Main'  
  
 SELECT @AddressStatusId = AddressStatusId   
 FROM AddressStatus   
 WHERE [Name]='Current'  
  
 SELECT @AddressValidStatusId = AddressValidStatusId   
 FROM AddressValidStatus   
 WHERE [Name]='Valid'  
  
 SELECT  u.userId as MemberId, u.UserLoyaltyDataId, a.City, s.[Name] as [State]   
 INTO  #UserData   
 FROM  [User] u   
 LEFT OUTER  JOIN UserAddresses ua   
 ON   ua.UserId = u.UserId  
 LEFT OUTER  JOIN Address a   
 ON   a.AddressId = ua.AddressId  
 LEFT OUTER  JOIN [State] s   
 ON   s.stateid = a.stateId  
 WHERE  UserSubTypeId = @UserSubTypeId   
 AND   A.AddressTypeId=@AddressTypeId  
 AND   A.AddressStatusId=@AddressStatusId  
 AND   A.AddressValidStatusId=@AddressValidStatusId  
  
  
 SELECT @ExtensionJsonData ='SET @JSON = (  
 SELECT u.MemberId,extension.Name,ISNULL(u.City,'''') City,ISNULL(u.State,'''') State,ISNULL(extension.lat,'''') AS Lat,ISNULL(extension.long,'''') AS Lng,ISNULL(extension.ShelterProfileLogoUrl,'''') AS ProfileLogoUrl,'''+@Source+''' AS Type  
 FROM    #UserData u  
 INNER JOIN  
 (  
  SELECT * FROM  
  (  
   SELECT UserLoyaltyDataId,PropertyName,PropertyValue   
   FROM UserLoyaltyExtensionData   
   WHERE PropertyName IN (''Name'',''Status'',''lat'',''long'',''ShelterProfileLogoUrl'')  
  
  )Table1  
  
  PIVOT  
  (  
   MIN(PropertyValue)  
   FOR   
   PropertyName  
   IN(Name,Status,lat,long,ShelterProfileLogoUrl)  
  )as p  
  
 )as extension  
 ON u.UserLoyaltyDataId = extension.UserLoyaltyDataId  
 WHERE Status=''approved''
    for json PATH  
 )'  
  
 print @ExtensionJsonData  
 DECLARE @JSONDATA NVARCHAR(MAX)  
 EXECUTE sp_executesql @ExtensionJsonData, N'@JSON NVARCHAR(MAX) OUTPUT', @JSON = @JSONDATA OUTPUT  
 SET @Result = @JSONDATA  
  
 Drop table #UserData  
  
  
  
END
