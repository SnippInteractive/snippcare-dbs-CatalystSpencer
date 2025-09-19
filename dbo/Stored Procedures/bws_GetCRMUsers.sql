-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[bws_GetCRMUsers] 	(@ClientId int)
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT UserId,Username FROM [User] u join UserType ut 
	         on u.UserTypeId=ut.UserTypeId	        
	         where ut.ClientId=@ClientId and ut.Name='Helpdesk'
END
