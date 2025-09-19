CREATE PROCEDURE [SSISHelper].[CalculateABC_Group] (@Clientid int , @SiteID int, @TodaysDate date=null, @ArchieveOnly int=0  ) as 

/*

To run....

SSISHelper.CalculateABC_Group 4,741,'2020-04-30',0
The loyalty customers from Humanic Austria shall be grouped by their turnover (transaction type = PosTransaction) within the last 12 months:

A: turnover >= 300 €
B: 100 <= turnover < 300 €
C: turnover < 100 €

We would like to get the following things:
A daily job which calculates the group (A, B or C) per loyalty customer (= “current” ABC group). 
This job shall run after the datamart is populated in the night run and before the Emarsys export job is running. 

We would like to get the counts per job - how many members per group – if possible (maybe this information can be included somehow in the email about the jobs we are getting every day).•	

This daily job should populate a member field (type: string) which is also passed into the datamart (view member_LS).
*/
Begin
----to run it from here....
--Declare @Clientid int=4 , @SiteID int=741, @TodaysDate date='2020-04-30', @ArchieveOnly int=0  


Declare @PeriodStart DateTime, @PeriodEnd DateTime
Declare @TrxStatusIdStarted int=0, @POS_TrxTypeid int=0, @LoyaltyMember_UT int=0
if @TodaysDate is null
	Begin
		set @TodaysDate = GetDate()
	End
select @PeriodStart =	dateadd(year,	-1,@TodaysDate)
select @PeriodEnd	=	dateadd(year,1,dateadd(SECOND,	-1,@PeriodStart))

select siteid into #SiteList from  [dbo].[GetChildSitesBySiteId](@SiteID) --741 is Austria!

select @TrxStatusIdStarted=TrxStatusId from TrxStatus where name = 'Started' and clientid = @Clientid
select @POS_TrxTypeid= trxtypeid from trxtype where name = 'PosTransaction' and clientid = @Clientid 
select @LoyaltyMember_UT = usertypeid from usertype where name = 'LoyaltyMember' and clientid = @Clientid

select u.userid, u.UserLoyaltyDataId,sum(Value) Spend into #Res from [user] u join device dv on dv.userid=u.UserId
join #SiteList sl on u.siteid=sl.SiteId
join trxheader th on dv.deviceid=th.DeviceId
join trxdetail td on th.trxid=td.trxid
where trxdate between @PeriodStart and @TodaysDate
and TrxStatusTypeId !=@TrxStatusIdStarted 
and TrxTypeid=@POS_TrxTypeid
--and u.UserTypeId=@LoyaltyMember_UT
group by u.userid, u.UserLoyaltyDataId

alter table #Res add GroupingLevel nvarchar(1)
/*
A: turnover >= 300 €
B: 100 <= turnover < 300 €
C: turnover < 100 €
*/

update #Res set groupinglevel='A' where Spend >= 300
update #Res set groupinglevel='B' where Spend >=100 and Spend  < 300
update #Res set groupinglevel='C' where Spend <100 

insert into #res (userid,Spend,GroupingLevel,UserLoyaltyDataId)
select u.userid, 0,'D' Spend,UserLoyaltyDataId  from [user] u 
join #SiteList sl on u.siteid=sl.SiteId
where userid not in (select userid from #Res)

delete from #Res where [UserLoyaltyDataId] is null

select  uled.ID ,uled.[UserLoyaltyDataId],r.GroupingLevel into #Updaters 
from  #Res r join UserLoyaltyExtensionData uled on r.UserLoyaltyDataId=uled.UserLoyaltyDataId and uled.PropertyName='CurrentGroupABC'
and r.groupinglevel != uled.[PropertyValue]

Update uled set PropertyValue = x.groupinglevel from UserLoyaltyExtensionData uled join #Updaters x on uled.ID=x.ID

select UserLoyaltyDataId into #uleds from UserLoyaltyExtensionData uled where uled.PropertyName='CurrentGroupABC'




--delete from UserLoyaltyExtensionData where PropertyName='CurrentGroupABC'

--select * from UserLoyaltyExtensionData where PropertyName='CurrentGroupABC'

if @ArchieveOnly !=1 
BEGIN
	--Update the ones that are there before but are different
	Update uled set PropertyValue = x.groupinglevel from UserLoyaltyExtensionData uled join #Updaters x on uled.ID=x.ID
	--Insert any new ones.
	INSERT INTO [dbo].[UserLoyaltyExtensionData]
		([Version],[UserLoyaltyDataId],[PropertyName],[PropertyValue])
	Select 1,r.UserLoyaltyDataId, 'CurrentGroupABC',r.GroupingLevel from #Res r left join 
	#uleds u on r.UserLoyaltyDataId=u.UserLoyaltyDataId where u.UserLoyaltyDataId is null 
End

--If it is the first date of the month.... then add to the SSISHelper.ArchiveGroupingLevel table


if datepart (day,@TodaysDate)=1 
Begin
/*
•	We also need some kind of archiving / historicisation. Since we need the data for monthly reports also, the groups for every loyalty member for every month shall be saved in a new table. This information shall additionally be available in the datamart, so that the information can be accessed by SAP. The data shall be calculated at the beginning of the month.Example:REFERENCEDATE	MEMBERID	ABC20190101		1234567	B20190201		1234567	B20190301		1234567	A20190401		1234567	A

Explanation:We need the reference date in the format YYYYMMDD (because of SAP).To calculate the ABC groups for reference date 20190101 the period 01.01.2018 – 31.12.2018 has to be taken.On the first day of every month the current ABC group shall be saved in this archive table.
*/
	INSERT INTO [SSISHelper].[ArchiveGroupingLevel]
	([ReferenceDate],[UserID],[PropertyName],[PropertyValue],[LastUpdatedDate])
	Select 
	convert(nvarchar(8),@TodaysDate,112),UserID, 'CurrentGroupABC',GroupingLevel,GetDate() from #Res
End

IF OBJECT_ID('tempdb.dbo.#Updaters', 'U') IS NOT NULL   DROP TABLE #Updaters;
IF OBJECT_ID('tempdb.dbo.#Res', 'U') IS NOT NULL   DROP TABLE #Res;
IF OBJECT_ID('tempdb.dbo.#SiteList', 'U') IS NOT NULL   DROP TABLE #SiteList;
IF OBJECT_ID('tempdb.dbo.#uleds', 'U') IS NOT NULL   DROP TABLE #uleds;
End
