CREATE PROCEDURE [dbo].[Campaigning_GetMemberToSend]
AS
BEGIN
    DECLARE @JobId INT, @CampaignJobId INT, @NotificationTemplateId INT, @ScheduleConfig NVARCHAR(MAX);
  
	EXEC [dbo].[Campaigning_PlaceholderDataMapping]

	IF NOT EXISTS(SELECT 1 FROM CommunicationJobStatus  WHERE [STATUS] = 'Processing')
	BEGIN

		SELECT TOP 1 @JobId = Id, @ScheduleConfig = ScheduleConfig, @NotificationTemplateId = NotificationTemplateId, @CampaignJobId = CampaignJobId FROM CommunicationJobStatus  WHERE [STATUS] = 'Queued'

		UPDATE CommunicationJobStatus  SET [Status] = 'Processing' WHERE [STATUS] = 'Queued' AND Id = @JobId
	
		SELECT UserId, cts.[Source], cts.Placeholders INTO #UsersToSend FROM CommunicationToSend cts WHERE sentDate IS NULL AND JobStatusId= @JobId 

		UPDATE CommunicationToSend SET SentDate = GETDATE() WHERE JobStatusId= @JobId 

		UPDATE CatalystMail_CampaignJobHeader SET [Status] = 6 WHERE JobId = @CampaignJobId

		UPDATE  CatalystMail_Campaign
		SET ExportedDate = GETDATE()
		WHERE Id = (
			SELECT CampaignId FROM [CatalystMail_CampaignJobHeader] WHERE JobId = @CampaignJobId
		)

		SELECT @JobId AS JobId, UserId, @NotificationTemplateId AS NotificationTemplateId, [Source], Placeholders, @ScheduleConfig AS ScheduleConfig FROM #UsersToSend

		DROP TABLE #UsersToSend
	END

END;