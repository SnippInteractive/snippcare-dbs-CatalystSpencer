CREATE PROCEDURE [SSISHelper].[UpdateCampaignforJobID](@JobID int)

as

/*
ensure it can't be run again....

*/
Declare @Campaignid INT
select @Campaignid = (SELECT [CampaignId] FROM Baseline_CampaigningDB.dbo.[CatalystMail_CampaignJobHeader] where jobid = @JobID and Test = 0)

update Baseline_CampaigningDB.dbo.[CatalystMail_Campaign] set exporteddate = getdate() where id =@Campaignid 

--Update the contact History
 EXEC [SSISHelper].[CreateCampaignHistory] @CampaignID
