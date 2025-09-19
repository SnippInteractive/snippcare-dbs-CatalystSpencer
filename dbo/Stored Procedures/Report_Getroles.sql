-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Get roles
-- =============================================
CREATE PROCEDURE [dbo].[Report_Getroles] (
	@ClientId int,@language varchar(2)
	
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT     Role.RoleID, r.Description
    FROM   Role INNER JOIN
                      (SELECT Code,[Description] 
     FROM  [dbo].[GetLookup] (@ClientId,'ROLE_TYPE','en')) r 
                      ON Role.RoleID = r.Code where Role.ClientId =@ClientId

END
