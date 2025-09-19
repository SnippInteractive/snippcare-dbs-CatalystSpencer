-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [DBHelper].[sp_GetProfileTypeUsingProfileId]
	-- Add the parameters for the stored procedure here
	@ProfileId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT dt.Name from DeviceProfileTemplateType dt 
                                          inner join DeviceProfileTemplate t on t.DeviceProfileTemplateTypeId=dt.Id 
                                          Where t.Id=@ProfileId;
END
