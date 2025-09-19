CREATE PROCEDURE [SSISHelper].[Campaign_GetSelMembersFromDW] (@JobID int )
as
Declare @campaignid int 
select @campaignid= campaignid from Baseline_CampaigningDB.dbo.CatalystMail_CampaignJobHeader where jobid = @JobID

delete from dbo.CatalystMail_SelMembers where
 NodeID in (select nodeid from Baseline_CampaigningDB.dbo.CatalystMail_CampaignJobHeader h join Baseline_CampaigningDB.dbo.CatalystMail_CampaignJobdetails d on h.JobId=d.JobId
where campaignid = @campaignid)

insert into dbo.CatalystMail_SelMembers (memberid,nodeid)
select memberid, nodeid from Baseline_CampaigningDB.dbo.CatalystMail_SelMembersTemp 
where nodeid in (select nodeid from Baseline_CampaigningDB.dbo.CatalystMail_CampaignJobHeader h join Baseline_CampaigningDB.dbo.CatalystMail_CampaignJobdetails d on h.JobId=d.JobId
where campaignid = @campaignid)
