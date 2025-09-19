

CREATE PROCEDURE [SSISHelper].[SelectDetailsforJobID](@JobID int)

as

Declare @Clientid int  = (select ClientId from client where [Name] = 'baseline')

insert into audit (version, userid, FieldName,NewValue, OldValue, changedate,changeby)
values (1,0,'Step 4','[SSISHelper].[SelectDetailsforJobID]',@JobID,getdate(),0)

update Baseline_CampaigningDB.dbo.CatalystMail_CampaignJobdetails set FileFormat='EXCELOPENXML' where fileformat='excel' and jobid = @JobID

Select convert(varchar(20),d.ActionId) as ActionId,d.ActionType,d.FieldList,d.FileFormat, 
convert(varchar(20),d.NodeId) NodeId, convert(varchar(20),Test) Test, emailid,--d.JobDetailId
nodename,c.name Campaign, h.ClientId
into #TempJobDetails
from Baseline_CampaigningDB.dbo.CatalystMail_CampaignJobHeader h
join Baseline_CampaigningDB.dbo.CatalystMail_CampaignJobdetails d on h.JobId=d.JobId
join Baseline_CampaigningDB.dbo.[CatalystMail_Campaign] c on c.id=h.CampaignId
join (SELECT f.customdescription NodeName, ft.id campid, f.Id nodeid,ft.Name
  FROM Baseline_CampaigningDB.dbo.[CatalystMail_Filter] f join Baseline_CampaigningDB.dbo.[CatalystMail_FilterTree] ft on ft.id=f.[FilterTreeId]) descs on descs.nodeid= d.nodeid
where h.Status =2 and h.ProcessedDate is NULL --and h.clientid = @clientid
and h.JobId = @Jobid --and actiontype !='AssignVoucher'

update #TempJobDetails set actiontype ='Export' where actiontype ='AssignVoucher' and test = 1
/* 
Niall 2015-04-04
TOOK this out to save the same export being done twice!!!

insert into #TempJobDetails (ActionId,ActionType,FieldList,FileFormat,NodeId,Test,emailid,JobDetailId )
Select convert(varchar(20),min(d.ActionId)) as ActionId,d.ActionType,CAST(fieldlist AS varchar(max))fieldlist
,isnull(d.FileFormat,'')FileFormat
, convert(varchar(20),NodeId) NodeId, 0, emailid,min (d.JobDetailId )JobDetailId 
from dbo.CatalystMail_CampaignJobHeader h
join CatalystMail_CampaignJobdetails d on h.JobId=d.JobId
where h.Status =2 and h.ProcessedDate is NULL and clientid = 3
and h.JobId = @jobid and actiontype ='AssignVoucher' and test = 0
group by actiontype,CAST(fieldlist AS varchar(max)),
fileformat, convert(varchar(20),NodeId), emailid
*/


select * from #TempJobDetails
drop table #TempJobDetails
