
CREATE PROCEDURE [SSISHelper].[SelectJobAndUpdateStatus]   

as

Declare @Clientid int  = (select ClientId from client where [Name] = 'baseline')
declare @JobStatusPending int, @JobStatusProcessing int, @JobStatusProcessed int, @JobStatusFailed int
Declare @ReturnJobID   int

select @JobStatusPending = JobStatusId from jobstatus where [name]='Pending' and ClientId = @Clientid
select @JobStatusProcessing = JobStatusId from jobstatus where [name]='Processing' and ClientId = @Clientid
select @JobStatusProcessed = JobStatusId from jobstatus where [name]='Processed' and ClientId = @Clientid
select @JobStatusFailed = JobStatusId from jobstatus where [name]='Failed' and ClientId = @Clientid

Select top 1 @ReturnJobID = JobId from Baseline_CampaigningDB.dbo.CatalystMail_CampaignJobHeader h
where h.Status =@JobStatusPending  and h.ProcessedDate is NULL --and clientid = @clientid
print @ReturnJobID

Update Baseline_CampaigningDB.dbo.CatalystMail_CampaignJobHeader set status =  @JobStatusProcessing where JobId=@ReturnJobID


insert into audit (version, userid, FieldName,NewValue, OldValue, changedate,changeby)
values (1,0,'Step 1','[SSISHelper].[SelectJobAndUpdateStatus]','',getdate(),0)
select @ReturnJobID
