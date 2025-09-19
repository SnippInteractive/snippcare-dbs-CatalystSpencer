
-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Get Report List
-- =============================================
CREATE PROCEDURE [dbo].[Report_GetReportList] (@ReportGroup INT,
                                              @UserId      BIGINT)
AS
  BEGIN
      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
      SET NOCOUNT ON;

      DECLARE @RoleId INT
      DECLARE @ClientId INT

      SET @RoleId=(SELECT TOP(1)RoleID
                   FROM   SysuserRole
                   WHERE  SysuserID = @UserId)
      SET @ClientId=(SELECT Site.ClientId
                     FROM   Site
                            INNER JOIN [User]
                              ON Site.SiteId = [User].SiteId
                     WHERE  UserId = @UserId)

      IF( @ClientId = 23 )
        BEGIN
            DECLARE @RoleType VARCHAR(50)

            SET @RoleType=(SELECT Description
                           FROM   Lookup
                                  INNER JOIN LookupI8n
                                    ON Lookup.LookupId = LookupI8n.LookupId
                           WHERE  Code = @RoleId
                                  AND LookupType = 'ROLE_TYPE'
                                  AND ClientId = @ClientId
                                  AND Language = 'en')

            IF( @RoleType = 'S_ADMIN' )
              BEGIN
                  SELECT Report.*
                  FROM   Report
                         INNER JOIN ReportGroupDetails
                           ON Report.ReportId = ReportGroupDetails.ReportId
                  WHERE  ReportGroupDetails.ReportGroupId = @ReportGroup
                         AND ClientId = @ClientId
                  ORDER  BY Report.ReportIndex
              END
            ELSE
              BEGIN
                  SELECT Report.*
                  FROM   Report
                         INNER JOIN ReportGroupDetails
                           ON Report.ReportId = ReportGroupDetails.ReportId
                         INNER JOIN ReportRole
                           ON Report.ReportId = ReportRole.ReportId
                  WHERE  ReportGroupDetails.ReportGroupId = @ReportGroup
                         AND ClientId = @ClientId
                         AND ReportRole.RoleId = @RoleId
                  ORDER  BY Report.ReportIndex
              END
        END
      ELSE
        BEGIN
            SELECT Report.*
            FROM   Report
                   INNER JOIN ReportGroupDetails
                     ON Report.ReportId = ReportGroupDetails.ReportId
            WHERE  ReportGroupDetails.ReportGroupId = @ReportGroup
                   AND ClientId = @ClientId
            ORDER  BY Report.ReportIndex
        END
  END
