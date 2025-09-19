CREATE PROCEDURE [SSISHelper].[CreateCampaignHistory](@CampaignID int)
as 
delete from [ContactHistory] where campaignid = @CampaignID 

/*needs to be changed for the Client id of the */
declare @clientid int = 0
select @clientid=ClientId from Baseline_CampaigningDB.dbo.CatalystMail_Campaign where ID = @CampaignID

declare @ContactTypeId int = (select contacttypeid from contacttype where name = 'Mail' and clientid = @clientid)

INSERT INTO [ContactHistory] ([Version],[UserId],[ContactTypeId],[ContactDate],[Comments],[CampaignId],[SegmentId], ControlGroup)				
				

(select 1,memberid, @ContactTypeId, RequestDate, actiontype, campaignid, d.nodeid, case Actiontype when 'ControlGroup' then 1 else 0 end cg FROM Baseline_CampaigningDB.dbo.[CatalystMail_CampaignJobHeader] h 
join Baseline_CampaigningDB.dbo.CatalystMail_CampaignJobDetails d on h.jobid=d.jobid
join dbo.CatalystMail_SelMembers s on d.nodeid=s.nodeid
where test =0 and
 clientid = @clientid and campaignid =@CampaignID
)
INSERT INTO [dbo].[Audit]
           ([Version]
           ,[UserId]
           ,[FieldName]
           ,[NewValue]
           ,[OldValue]
           ,[ChangeDate]
           ,[ChangeBy]
           ,[Reason]
           ,[ReferenceType]
           ,[OperatorId])
     VALUES
           (1,1400001
           ,'CreateCampaignHistory'
           ,@CampaignID
           , @clientid
           ,GETDATE()
           ,1400001
           ,''
           ,''
           ,'')
