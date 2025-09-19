-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Get Report Group roles
-- =============================================
CREATE PROCEDURE [dbo].[Report_GetReportGrouproles] (
	@ClientId int,@RgId int,@language varchar(2)
	
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT     r.Description, r.Code as RoleID
	FROM         ReportGroupRole INNER JOIN
                     (SELECT Code,[Description] 
     FROM  [dbo].[GetLookup] (@ClientId,'ROLE_TYPE',@language)) r  
                      ON ReportGroupRole.RoleId = r.Code where ReportGroupRole.RoleId=@RgId

END
