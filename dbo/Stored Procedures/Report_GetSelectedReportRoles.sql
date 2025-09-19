-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Get Selected Report Roles
-- =============================================
CREATE PROCEDURE [dbo].[Report_GetSelectedReportRoles](@ClientID INT, @RgId INT,@ReportId int)
AS
  BEGIN
						/*SELECT RoleI8n.RoleID, RoleI8n.Description FROM Role INNER JOIN RoleI8n ON Role.RoleID = RoleI8n.RoleID INNER JOIN ReportRole 
						ON Role.RoleID = ReportRole.RoleId
						WHERE     Role.ClientId = @ClientId and ReportRole.ReportId=@ReportId*/

                SELECT     r.Code as RoleID, r.Description
             FROM         (select Code,Description FROM Lookup INNER JOIN LookupI8n ON Lookup.LookupId=LookupI8n.LookupId where  Lookup.ClientId=@ClientID  and LookupType='ROLE_TYPE' and Language='en')   r INNER JOIN
                      ReportRole ON r.Code = ReportRole.RoleId INNER JOIN
                      ReportGroupRole ON ReportRole.RoleId = ReportGroupRole.RoleId
                      where ReportRole.ReportId=@ReportId and ReportGroupRole.RoleId=@RgId
  END
