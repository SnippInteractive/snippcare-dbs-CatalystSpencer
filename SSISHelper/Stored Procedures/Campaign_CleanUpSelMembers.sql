CREATE PROCEDURE [SSISHelper].[Campaign_CleanUpSelMembers] (@JobID int )
as
Declare @campaignid int , @test int
select @campaignid= campaignid from Baseline_CampaigningDB.dbo.CatalystMail_CampaignJobHeader where jobid = @JobID
Select @test = test from Baseline_CampaigningDB.dbo.CatalystMail_CampaignJobHeader where jobid = @JobID

if @test = 0
BEGIN
delete from Baseline_CampaigningDB.dbo.CatalystMail_SelMembersTemp where NodeID in (select nodeid from Baseline_CampaigningDB.dbo.CatalystMail_CampaignJobHeader h 
join Baseline_CampaigningDB.dbo.CatalystMail_CampaignJobdetails d on h.JobId=d.JobId
where campaignid = @campaignid)
END
