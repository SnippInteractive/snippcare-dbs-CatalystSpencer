
-- =============================================
-- Author:		Neil McAuliffe
-- Create date: 06/08/2014
-- Description:	Monitors the processing Queue and updates the users contact details
-- =============================================
CREATE PROCEDURE [dbo].[bws_UpdateUsersContactHistory]
	-- Add the parameters for the stored procedure here
	@Result INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	BEGIN TRY
	BEGIN TRANSACTION
			DECLARE @ClientId INT
			DECLARE @ClientName NVARCHAR(20)
			DECLARE @Id INT
			DECLARE @UserId INT
			DECLARE @ContactType NVARCHAR(20)
			DECLARE @ContactTypeId INT
			DECLARE @ContactDescription NVARCHAR(500)
			DECLARE @ProcessingDate DATETIME
			DECLARE IDs CURSOR LOCAL FOR 
			SELECT Id, UserId, CommunicationType, ContactDetailsNote, ClientName, ProcessingDate FROM [CatalystMail_ProcessingQueue] WHERE ProcessingSuccessful = 1 AND [ContactDetailsUpdate] = 0

			OPEN IDs
			FETCH NEXT FROM IDs INTO @Id, @UserId, @ContactTypeId, @ContactDescription, @ClientName, @ProcessingDate
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @ClientId = ClientId FROM Client WHERE Name = @ClientName
				SELECT @ContactTypeId = ContactDetailsTypeId FROM ContactDetailsType WHERE Name = (SELECT Name FROM CatalystMail_CommunicationType WHERE Id = @ContactTypeId) AND ClientId = @ClientId
				
				INSERT INTO ContactHistory ([UserId],[ContactTypeId],[ContactDate],[Comments])
				VALUES (@UserId, @ContactTypeId, @ProcessingDate, @ContactDescription)

				UPDATE CatalystMail_ProcessingQueue SET ContactDetailsUpdate = 1 WHERE Id = @Id

				FETCH NEXT FROM IDs INTO @Id, @UserId, @ContactTypeId, @ContactDescription, @ClientName, @ProcessingDate
			END

			CLOSE IDs
			DEALLOCATE IDs
	
	COMMIT TRANSACTION
		SELECT @Result = 1
	END TRY
	BEGIN CATCH
		PRINT ('Unable to update contact details')
		PRINT ERROR_MESSAGE();
		ROLLBACK TRANSACTION
		
		SELECT @Result = -1
	END CATCH
END
