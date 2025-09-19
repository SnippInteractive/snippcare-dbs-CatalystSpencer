CREATE PROC [dbo].[GetMemberDetailByClientID]  
(  
@ClientId INT  
)  
as  
begin  
---------------TEST-------------------  
--EXEC GetMemberDetailByClientID 1  


 

  
select  
ISNULL((select UserTypeId,[Name], ClientId from UserType where ClientId = @ClientId FOR JSON PATH),N'[]') as UserType,  
ISNULL((select UserSubTypeId,[Name], ClientId from UserSubType where ClientId = @ClientId FOR JSON PATH),N'[]') AS UserSubType,  
ISNULL((select UserStatusId,[Name], ClientId from UserStatus where ClientId = @ClientId FOR JSON PATH),N'[]') AS UserStatus,  
ISNULL((select GenderTypeId,[Name], ClientId from GenderType where ClientId = @ClientId FOR JSON PATH),N'[]') AS GenderType,  
ISNULL((select TitleTypeId,[Name], ClientId from TitleType where ClientId = @ClientId FOR JSON PATH),N'[]') AS TitleType,  
ISNULL((select SalutationTypeId,[Name], ClientId from SalutationType where ClientId = @ClientId FOR JSON PATH),N'[]') AS SalutationType,  
ISNULL((select Id,code from Currency where ClientId = @ClientId FOR JSON PATH),N'[]') AS Currency,  
ISNULL((select ContactDetailsTypeId,[Name], ClientId from ContactDetailsType where ClientId = @ClientId FOR JSON PATH),N'[]') AS ContactDetailsType,  
--ISNULL((select StateId,[Name], ClientId from State where ClientId = @ClientId FOR JSON PATH),N'[]') AS 'State',  
ISNULL((select CountryId, Name, CountryCode, MobilePrefix from Country where ClientId = @ClientId FOR JSON PATH),N'[]') AS Countries,  
ISNULL((select AddressStatusId,[Name], ClientId from AddressStatus where ClientId = @ClientId FOR JSON PATH),N'[]') AS AddressStatus,  
ISNULL((select AddressTypeId,[Name], ClientId from AddressType where ClientId = @ClientId FOR JSON PATH),N'[]') AS AddressType,  
ISNULL((select AddressValidStatusId,[Name], ClientId from AddressValidStatus where ClientId = @ClientId FOR JSON PATH),N'[]') AS AddressValidStatus,  
ISNULL((select DeviceStatusId,[Name], ClientId from DeviceStatus where ClientId = @ClientId FOR JSON PATH),N'[]') AS DeviceStatus,  
ISNULL((select DeviceTypeId,[Name], ClientId from DeviceType where ClientId = @ClientId FOR JSON PATH),N'[]') AS DeviceType  

end  