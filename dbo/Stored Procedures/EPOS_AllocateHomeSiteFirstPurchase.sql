
-- =============================================
-- Author:		
-- Create date: <Create Date,,>
-- Description:if the member has registered via portal which means with SiteRef 9999 (SiteName 9999 Healthi) we change the site with the 1st purchase to the SiteRef where the 1st purchase was made
-- =============================================
CREATE PROCEDURE [dbo].[EPOS_AllocateHomeSiteFirstPurchase] 
	-- Add the parameters for the stored procedure here
	(@TrxId INT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @userId INT
	DECLARE @SiteId INT
	SET @userId=(select top 1 d.userid from trxheader th join device d on th.DeviceId=d.DeviceId  where th.trxid=@TrxId)

	if exists (select 1 from [user] u join site s on u.SiteId=s.siteid where s.siteref='9999' and u.UserId=@userId)
	begin
	Declare @PurchaseCount INT
	SET @PurchaseCount=(select count(th.trxid) from trxheader th join device d on th.deviceid=d.deviceid join trxtype ty on th.trxtypeid=ty.TrxTypeId where d.userid=@userId and ty.Name='PosTransaction')
	if(isnull(@PurchaseCount,0)=1)
	begin
	SET @SiteId=(select siteid from trxheader where trxid=@TrxId)
	UPDATE [User] set SiteId=@SiteId where userid=@userId

	DECLARE @EposUser INT
	set @EposUser=(select userid from [user] u  join usertype uy on  u.usertypeid=uy.usertypeid join client c on uy.clientid=c.clientid where username='unauthsysuser' and uy.name='unauthsysuser' and c.name='baseline')

	INSERT INTO [dbo].[Audit]
           ([Version]
           ,[UserId]
           ,[FieldName]
           ,[NewValue]
           ,[OldValue]
           ,[ChangeDate]
           ,[ChangeBy]
           ,[Reason]
           ,[ReferenceType]
           ,[OperatorId]
           ,[SiteId])
     VALUES
           (1
           ,@userId
           ,'HomeStore'
           ,(select name from site where siteid=@SiteId)
           ,(select name from site where siteref='9999')
           ,getdate()
           ,@EposUser
           ,'First Purchase'
           ,null
           ,null
           ,@SiteId)
	end
	end
    
END







