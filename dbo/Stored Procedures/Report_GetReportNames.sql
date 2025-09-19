-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Get Report Names
-- =============================================
CREATE PROCEDURE [dbo].[Report_GetReportNames](@ClientId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  select ActualName from Report where ClientId=@ClientId;
  
END
