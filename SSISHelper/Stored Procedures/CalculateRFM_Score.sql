CREATE PROCEDURE [SSISHelper].[CalculateRFM_Score] (@Clientid int , @SiteID int, @TodaysDate Date =null, @ArchieveOnly int=0 ) as 
Begin
/*
select * from site where siteid = parentid
To run....
*/

--DECLARE @Clientid int =1, @SiteID int =2, @TodaysDate Date =getdate(), @ArchieveOnly int=0
/*
exec SSISHelper.[CalculateRFM_Score] 1,2, null,0
We take all TRX (TransactionType = PosTransaction) of the last 24 months to calculate the score value.The score shall be calculated as follows:

R: 1 – 10 points; the number of days since the last TRX is ordered from the smallest to the biggest value. The data is grouped into ten deciles. All members from the first decile get 10 points, from the second decile 9 points… and from the last decile 1 point.
F: 1 – 5 points: grouping by deciles doesn’t make sense for this criteria since almost half of our customers will have only one purchase within the period! 
That’s why we have a different logic based on the number of purchases.Number of purchases with total value > 0:1: 	F = 1 point2 - 3:	F = 3 points>= 4:	F = 5 points
M: 1 – 10 points; the turnover is ranked from the highest to the lowest value. All members from the first decile get 10 points, from the second decile 9 points… and from the last decile 1 point.

At the end, the points from all three parts are summed up per customer. That’s why the minimum value is 3 and the maximum value 25 points.

This daily job should populate a member field (type: string) which is also passed into the datamart (view member_LS).
*/ 
--Begin

--DECLARE @Clientid int =1, @SiteID int =2, @TodaysDate Date =getdate(), @ArchieveOnly int=0

DROP TABLE IF EXISTS #res;
DROP TABLE IF EXISTS #NewBies;
DROP TABLE IF EXISTS #ResTrx;
DROP TABLE IF EXISTS #No24MthTrx;
DROP TABLE IF EXISTS #SiteList;
DROP TABLE IF EXISTS #NonProspects;
DROP TABLE IF EXISTS #LastPositiveTrx;
Declare @PeriodStart DateTime, @PeriodEnd DateTime
Declare @TrxStatusIdStarted int=0, @POS_TrxTypeid int=0, @LoyaltyMember_UT int=0, @Prospect int=0, @DeviceStatus int=0

if @TodaysDate is null
	Begin
		set @TodaysDate = GetDate()
	End
select @PeriodStart =	dateadd(year,-2,@TodaysDate)
select @PeriodEnd	=	dateadd(year,1,dateadd(SECOND,	-1,@PeriodStart))

select siteid into #SiteList from  [dbo].[GetChildSitesBySiteId](@SiteID) --741 is Austria!

select @TrxStatusIdStarted=TrxStatusId from TrxStatus where name = 'Started' and clientid = @Clientid
select @POS_TrxTypeid= trxtypeid from trxtype where name = 'PosTransaction' and clientid = @Clientid 
select @LoyaltyMember_UT = usertypeid from usertype where name = 'LoyaltyMember' and clientid = @Clientid
--Select @Prospect = UserStatusID from UserStatus where name = 'Prospect' and clientid = @clientid
select @DeviceStatus = DeviceStatusID from DeviceStatus where name = 'Active' and clientid = @Clientid



select distinct  u.userid into #NonProspects from [user] u 
inner join device d  WITH (NOLOCK) on d.userid=u.userid          
 inner join devicelot dl on dl.id=d.devicelotid
 inner join devicelotdeviceprofile dldp on dldp.devicelotid=dl.id
 inner join DeviceProfileTemplate dpt on dpt.id=dldp.DeviceProfileId    
 inner join DeviceProfileTemplateType dt on dt.id = dpt.DeviceProfileTemplateTypeId
 inner join [site] s on s.siteid=u.siteid
 where dt.Name in ('Loyalty' , 'EShopLoyalty') and --d.DeviceStatusId =@DeviceStatus and 
 s.clientid = @clientid
 


select u.userid, u.UserLoyaltyDataId,
sum(Value) Spend, 
count(distinct th.trxid) Trx, 
Max(TrxDate) LastTrxDate, 
/*ROW_NUMBER() OVER( ORDER BY  Max(TrxDate)				DESC) */ 0 AS RowNumberRank, 
/*ROW_NUMBER() OVER( ORDER BY  sum(Value)					DESC) */ 0 AS RowNumberMoney

into #Res from [user] u join device dv on dv.userid=u.UserId
join #NonProspects np on u.userid =np.userid
join #SiteList sl on u.siteid=sl.SiteId
join trxheader th on dv.deviceid=th.DeviceId
join trxdetail td on th.trxid=td.trxid
where trxdate between @PeriodStart and @TodaysDate
and TrxStatusTypeId !=@TrxStatusIdStarted 
and TrxTypeid=@POS_TrxTypeid
and UserTypeId = @LoyaltyMember_UT
--and userstatusid != @Prospect -- 492,795
group by u.userid, u.UserLoyaltyDataId
--select COUNT(*) from #RES
select r.UserLoyaltyDataId into #NewBies from #Res r left join UserLoyaltyExtensionData uled on r.UserLoyaltyDataId=uled.UserLoyaltyDataId and propertyname = 'RFM' and uled.id is null

delete from UserLoyaltyExtensionData where PropertyName='RFM' and UserLoyaltyDataId in (select UserLoyaltyDataId from #NewBies)
delete from UserLoyaltyExtensionData where PropertyName='R' and UserLoyaltyDataId in (select UserLoyaltyDataId from #NewBies)
delete from UserLoyaltyExtensionData where PropertyName='F' and UserLoyaltyDataId in (select UserLoyaltyDataId from #NewBies)
delete from UserLoyaltyExtensionData where PropertyName='M' and UserLoyaltyDataId in (select UserLoyaltyDataId from #NewBies)


INSERT INTO [dbo].[UserLoyaltyExtensionData] ([Version],[UserLoyaltyDataId],[PropertyName],[PropertyValue]) Select 1,UserLoyaltyDataId, 'RFM',0 from #NewBies
INSERT INTO [dbo].[UserLoyaltyExtensionData] ([Version],[UserLoyaltyDataId],[PropertyName],[PropertyValue])	Select 1,UserLoyaltyDataId, 'R',0 from #NewBies
INSERT INTO [dbo].[UserLoyaltyExtensionData] ([Version],[UserLoyaltyDataId],[PropertyName],[PropertyValue]) Select 1,UserLoyaltyDataId, 'F',0 from #NewBies
INSERT INTO [dbo].[UserLoyaltyExtensionData]([Version],[UserLoyaltyDataId],[PropertyName],[PropertyValue]) Select 1,UserLoyaltyDataId, 'M',0 from #NewBies

select max(trxdate) LastPositiveTrx, userid into #LastPositiveTrx from (
select  trxdate , dv.userid  , h.trxid, sum(Value) Value
from trxheader h join trxdetail d on h.trxid=d.trxid
join device dv on h.deviceid=dv.deviceid
where trxdate between @PeriodStart and @TodaysDate
and TrxStatusTypeId !=@TrxStatusIdStarted 
and TrxTypeid=@POS_TrxTypeid  
--and dv.userid = 4646966
--and UserTypeId = @LoyaltyMember_UT
--and userstatusid != @Prospect -- 492,795
group by dv.userid, h.trxid, h.trxdate) x
where value > 0
group by userid


--select * from #Res order by lasttrxdate desc

update r set r.LastTrxDate = l.LastPositiveTrx from 
#res r join #LastPositiveTrx l on r.userid=l.userid
--select * from #res where userid = (select userid from device where deviceid = '2204343616')

update r set r.RowNumberRank = u.rn from #res r join (
select 
ROW_NUMBER() OVER( ORDER BY  LastTrxDate DESC) rn, userid from 
#res	) u on u.userid=r.userid

alter table #Res add NegTrx		int

select u.userid,th.trxid
into #ResTrx from [user] u join device dv on dv.userid=u.UserId
join #SiteList sl on u.siteid=sl.SiteId
join trxheader th on dv.deviceid=th.DeviceId
join trxdetail td on th.trxid=td.trxid
where trxdate between @PeriodStart and @TodaysDate
and TrxStatusTypeId !=@TrxStatusIdStarted 
and TrxTypeid=@POS_TrxTypeid
and UserTypeId = @LoyaltyMember_UT
group by u.userid, th.trxid
having sum(Value)<=0

update r set r.NegTrx=o.NegValue
from #Res r join (select userid, count(trxid) NegValue from #ResTrx
group by userid
) o on r.userid=o.userid
--Remove the ones where the returns made them zero or negative.
delete from #Res where Trx-isnull(NegTrx,0) <=0

update r set r.RowNumberMoney = u.rn from #res r join (
select 
ROW_NUMBER() OVER( ORDER BY  Spend DESC) rn, userid from 
#res	) u on u.userid=r.userid



/*
update #Res  set Trx = TrxUnfiltered where Trx is null
*/



alter table #Res add R			int
alter table #Res add F			int
alter table #Res add M			int
alter table #Res add RFM		int

CREATE INDEX idx_RFM_Rank ON #Res(RowNumberRank);

select top 10 percent userid into #updater from #Res order by RowNumberRank
update #res set R = 10 where userid in (select userid from #updater)
drop table #updater
select top 20 percent userid into #updater20 from #Res order by RowNumberRank
delete from #updater20 where userid in (select top 10 percent userid from #Res order by RowNumberRank)
update #res set R =  9 where userid in (select userid from #updater20)
drop table #updater20
select top 30 percent userid into #updater30 from #Res order by RowNumberRank
delete from #updater30 where userid in (select top 20 percent userid from #Res order by RowNumberRank)
update #res set R =  8 where userid in (select userid from #updater30)
drop table #updater30
select top 40 percent userid into #updater40 from #Res order by RowNumberRank
delete from #updater40 where userid in (select top 30 percent userid from #Res order by RowNumberRank)
update #res set R =  7 where userid in (select userid from #updater40)
drop table #updater40
select top 50 percent userid into #updater50 from #Res order by RowNumberRank
delete from #updater50 where userid in (select top 40 percent userid from #Res order by RowNumberRank)
update #res set R =  6 where userid in (select userid from #updater50)
drop table #updater50
select top 60 percent userid into #updater60 from #Res order by RowNumberRank
delete from #updater60 where userid in (select top 50 percent userid from #Res order by RowNumberRank)
update #res set R =  5 where userid in (select userid from #updater60)
drop table #updater60
select top 70 percent userid into #updater70 from #Res order by RowNumberRank
delete from #updater70 where userid in (select top 60 percent userid from #Res order by RowNumberRank)
update #res set R =  4 where userid in (select userid from #updater70)
drop table #updater70
select top 80 percent userid into #updater80 from #Res order by RowNumberRank
delete from #updater80 where userid in (select top 70 percent userid from #Res order by RowNumberRank)
update #res set R =  3 where userid in (select userid from #updater80)
drop table #updater80
select top 90 percent userid into #updater90 from #Res order by RowNumberRank
delete from #updater90 where userid in (select top 80 percent userid from #Res order by RowNumberRank)
update #res set R =  2 where userid in (select userid from #updater90)
drop table #updater90
update #res set R =  1 where r is null
PRINT 'R dONE'
----------thats the R's done. 

--M next!
CREATE INDEX idx_Money_Rank ON #Res(RowNumberMoney);

select top 10 percent userid into #updatem from #Res order by RowNumberMoney
update #res set M = 10 where userid in (select userid from #updatem)
drop table #updatem
select top 20 percent userid into #updatem20 from #Res order by RowNumberMoney
delete from #updatem20 where userid in (select top 10 percent userid from #Res order by RowNumberMoney)
update #res set M =  9 where userid in (select userid from #updatem20)
drop table #updatem20
select top 30 percent userid into #updatem30 from #Res order by RowNumberMoney
delete from #updatem30 where userid in (select top 20 percent userid from #Res order by RowNumberMoney)
update #res set M =  8 where userid in (select userid from #updatem30)
drop table #updatem30
select top 40 percent userid into #updatem40 from #Res order by RowNumberMoney
delete from #updatem40 where userid in (select top 30 percent userid from #Res order by RowNumberMoney)
update #res set M =  7 where userid in (select userid from #updatem40)
drop table #updatem40
select top 50 percent userid into #updatem50 from #Res order by RowNumberMoney
delete from #updatem50 where userid in (select top 40 percent userid from #Res order by RowNumberMoney)
update #res set M =  6 where userid in (select userid from #updatem50)
drop table #updatem50
select top 60 percent userid into #updatem60 from #Res order by RowNumberMoney
delete from #updatem60 where userid in (select top 50 percent userid from #Res order by RowNumberMoney)
update #res set M =  5 where userid in (select userid from #updatem60)
drop table #updatem60
select top 70 percent userid into #updatem70 from #Res order by RowNumberMoney
delete from #updatem70 where userid in (select top 60 percent userid from #Res order by RowNumberMoney)
update #res set M =  4 where userid in (select userid from #updatem70)
drop table #updatem70
select top 80 percent userid into #updatem80 from #Res order by RowNumberMoney
delete from #updatem80 where userid in (select top 70 percent userid from #Res order by RowNumberMoney)
update #res set M =  3 where userid in (select userid from #updatem80)
drop table #updatem80
select top 90 percent userid into #updatem90 from #Res order by RowNumberMoney
delete from #updatem90 where userid in (select top 80 percent userid from #Res order by RowNumberMoney)
update #res set M =  2 where userid in (select userid from #updatem90)
drop table #updatem90
update #res set M =  1 where M is null

PRINT 'M dONE'

--Finally the F

/*F: 1 – 5 points: grouping by deciles doesn’t make sense for this criteria since almost half of our customers will have only one purchase within the period! That’s why we have a different logic based on the number of purchases.
Number of purchases with total value > 0:1: 	F = 1 
point 2 - 3:	F = 3 
points>= 4:	F = 5 points*/
update #res set F =  1 where Trx-isnull(NegTrx,0)=1
update #res set F =  3 where Trx-isnull(NegTrx,0)IN (2,3)
update #res set F =  5 where Trx-isnull(NegTrx,0)>=4


--SET THE RFM SCORE

UPDATE #res SET RFM = R+F+M



/*
select * from #res order by RowNumberMoney desc
select trxdate, trxstatustypeid,sum(value) from trxheader h join trxdetail d on h.trxid=d.trxid where deviceid = '2204343616'
group by trxdate,trxstatustypeid
having sum(value)>0
*/


/*
select * from UserLoyaltyExtensionData


delete from UserLoyaltyExtensionData where PropertyName='RFM'
delete from UserLoyaltyExtensionData where PropertyName='R'
delete from UserLoyaltyExtensionData where PropertyName='F'
delete from UserLoyaltyExtensionData where PropertyName='M'

*/
delete from #Res where [UserLoyaltyDataId] is null

if @ArchieveOnly !=1 
begin

Update uled set propertyvalue = isnull(x.R,0) from UserLoyaltyExtensionData uled join (
select u.UserLoyaltyDataId,R from #res r join UserLoyaltyExtensionData u on r.UserLoyaltyDataId = u.UserLoyaltyDataId
and u.PropertyName='R' and propertyvalue !=r.R) x on x.UserLoyaltyDataId=uled.UserLoyaltyDataId and uled.propertyname='R'

Update uled set propertyvalue = isnull(x.F,0) from UserLoyaltyExtensionData uled join (
select u.UserLoyaltyDataId,F from #res r join UserLoyaltyExtensionData u on r.UserLoyaltyDataId = u.UserLoyaltyDataId
and u.PropertyName='F' and propertyvalue !=r.F) x on x.UserLoyaltyDataId=uled.UserLoyaltyDataId and uled.propertyname='F'

Update uled set propertyvalue = isnull(x.M,0) from UserLoyaltyExtensionData uled join (
select u.UserLoyaltyDataId,M from #res r join UserLoyaltyExtensionData u on r.UserLoyaltyDataId = u.UserLoyaltyDataId
and u.PropertyName='M' and propertyvalue !=r.M) x on x.UserLoyaltyDataId=uled.UserLoyaltyDataId and uled.propertyname='M'

Update uled set propertyvalue = isnull(x.RFM,0) from UserLoyaltyExtensionData uled join (
select u.UserLoyaltyDataId,RFM from #res r join UserLoyaltyExtensionData u on r.UserLoyaltyDataId = u.UserLoyaltyDataId
and u.PropertyName='RFM' and propertyvalue !=r.RFM) x on x.UserLoyaltyDataId=uled.UserLoyaltyDataId and uled.propertyname='RFM'


	INSERT INTO [dbo].[UserLoyaltyExtensionData]
		([Version],[UserLoyaltyDataId],[PropertyName],[PropertyValue])
	Select 1,UserLoyaltyDataId, 'RFM',isnull(RFM,0) from #Res
	INSERT INTO [dbo].[UserLoyaltyExtensionData]
		([Version],[UserLoyaltyDataId],[PropertyName],[PropertyValue])
	Select 1,UserLoyaltyDataId, 'R',isnull(R,0) from #Res
	INSERT INTO [dbo].[UserLoyaltyExtensionData]
		([Version],[UserLoyaltyDataId],[PropertyName],[PropertyValue])
	Select 1,UserLoyaltyDataId, 'F',isnull(F,0) from #Res
	INSERT INTO [dbo].[UserLoyaltyExtensionData]
		([Version],[UserLoyaltyDataId],[PropertyName],[PropertyValue])
	Select 1,UserLoyaltyDataId, 'M',isnull(M,0) from #Res

end 
----Now for the ones that were not in the Selection, no transaction in the last 24 months

select u.userid, UserLoyaltyDataId into #No24MthTrx from [user] u 
join #SiteList sl on u.siteid=sl.SiteId
where userid not in (select userid from #Res) and UserLoyaltyDataId is not null

if @ArchieveOnly !=1 
begin
	update UserLoyaltyExtensionData set PropertyValue=0
	where id in (Select uled.ID from #No24MthTrx t left join [UserLoyaltyExtensionData] uled on t.UserLoyaltyDataId=uled.UserLoyaltyDataId and propertyname = 'RFM' where id is not null and PropertyValue!=0)
	update UserLoyaltyExtensionData set PropertyValue=0
	where id in (Select uled.ID from #No24MthTrx t left join [UserLoyaltyExtensionData] uled on t.UserLoyaltyDataId=uled.UserLoyaltyDataId and propertyname = 'R' where id is not null and PropertyValue!=0)
	update UserLoyaltyExtensionData set PropertyValue=0
	where id in (Select uled.ID from #No24MthTrx t left join [UserLoyaltyExtensionData] uled on t.UserLoyaltyDataId=uled.UserLoyaltyDataId and propertyname = 'F' where id is not null and PropertyValue!=0)
	update UserLoyaltyExtensionData set PropertyValue=0
	where id in (Select uled.ID from #No24MthTrx t left join [UserLoyaltyExtensionData] uled on t.UserLoyaltyDataId=uled.UserLoyaltyDataId and propertyname = 'M' where id is not null and PropertyValue!=0)
	

	INSERT INTO [UserLoyaltyExtensionData]
		([Version],[UserLoyaltyDataId],[PropertyName],[PropertyValue])
	Select 1,t.UserLoyaltyDataId, 'RFM','0' from #No24MthTrx t left join [UserLoyaltyExtensionData] uled on t.UserLoyaltyDataId=uled.UserLoyaltyDataId and propertyname = 'RFM' where id is null 
	INSERT INTO [UserLoyaltyExtensionData]
		([Version],[UserLoyaltyDataId],[PropertyName],[PropertyValue])
	Select 1,t.UserLoyaltyDataId, 'R','0' from #No24MthTrx t left join [UserLoyaltyExtensionData] uled on t.UserLoyaltyDataId=uled.UserLoyaltyDataId and propertyname = 'R' where id is null 
	INSERT INTO [UserLoyaltyExtensionData]
		([Version],[UserLoyaltyDataId],[PropertyName],[PropertyValue])
	Select 1,t.UserLoyaltyDataId, 'F','0' from #No24MthTrx t left join [UserLoyaltyExtensionData] uled on t.UserLoyaltyDataId=uled.UserLoyaltyDataId and propertyname = 'F' where id is null 
	INSERT INTO [UserLoyaltyExtensionData]
		([Version],[UserLoyaltyDataId],[PropertyName],[PropertyValue])
	Select 1,t.UserLoyaltyDataId, 'M','0' from #No24MthTrx t left join [UserLoyaltyExtensionData] uled on t.UserLoyaltyDataId=uled.UserLoyaltyDataId and propertyname = 'M' where id is null 

end 
drop table #No24MthTrx


/*

--If it is the first date of the month.... then add to the SSISHelper.ArchiveGroupingLevel table

*/
print datepart (day,@TodaysDate) 
if datepart (day,@TodaysDate)=1 
Begin
	INSERT INTO [SSISHelper].[ArchiveGroupingLevel]
	([ReferenceDate],[UserID],[PropertyName],[PropertyValue],[LastUpdatedDate])
	Select 	convert(nvarchar(8),@TodaysDate,112),UserID, 'RFM',RFM,GetDate() from #Res
End


DROP TABLE IF EXISTS #res;
DROP TABLE IF EXISTS #NewBies;
DROP TABLE IF EXISTS #ResTrx;
DROP TABLE IF EXISTS #No24MthTrx;
DROP TABLE IF EXISTS #SiteList;
DROP TABLE IF EXISTS #NonProspects;
DROP TABLE IF EXISTS #LastPositiveTrx;

End
