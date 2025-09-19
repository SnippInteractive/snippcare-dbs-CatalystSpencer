
-- =============================================
-- Author:		Ulisses Franca
-- Create date: 2013-06-06
-- Description:	Creates a Site
-- =============================================
CREATE PROCEDURE [DBHelper].[sp_CreateSite]
	-- Add the parameters for the stored procedure here
	@Name nvarchar(10),
	@ParentId int,
	@StatusName nvarchar(10),
	@SiteTypeName nvarchar(10),
	@ClientId int,
	@SiteRef nvarchar(5),
	@SiteId int OUTPUT
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
INSERT INTO [dbo].[Site]
           ([Name]
           ,[ParentId]
           ,[SiteStatusId]
           ,[SiteTypeId]
           ,[AddressId]
           ,[ClientId]
           ,[ContactDetailsId]
           ,[CompanyName]
           ,[Permission]
           ,[SiteRef]
           ,[LanguageId]
           ,[Channel]
           ,[Display])
     VALUES
           (@Name
           ,@ParentId
           ,(select SiteStatusId from SiteStatus where Name like @StatusName)
           ,(select SiteTypeId from SiteType where Name like @SiteTypeName)
           ,(select top 1 Addressid from [address])
           ,@ClientId
           ,NUll
           ,'me'
           ,NUll
           ,@SiteRef
           ,(select top 1 languageid from [language])
           ,Null
           ,0);
select @SiteId = SCOPE_IDENTITY();
END
