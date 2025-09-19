	CREATE PROCEDURE [dbo].[bws_UpdateProfileImagePath](@profileId int,@path varchar(250))
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
BEGIN TRAN
    Update DEviceProfileTemplate set ImageUrl=@path where Id=@profileId;
	COMMIT TRAN
END TRY
BEGIN CATCH
    ROLLBACK TRAN
END CATCH
END

