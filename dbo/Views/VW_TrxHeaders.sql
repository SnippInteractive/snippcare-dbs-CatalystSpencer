
CREATE     View [dbo].[VW_TrxHeaders] as
select tt.name TrxType, tt.trxtypeid,u.userid,u.CreateDate UserCreateDate, ts.name TrxStatus, ts.TrxStatusId, th.Trxid, th.trxdate, th.CreateDate TrxCreateDate,
s.name Site, s.SiteRef,s.siteid,s.channel, c.Name Client,sum(td.points) Points, sum(td.BonusPoints) BonusPoints, sum(td.value) Value, tt.NegativeValue
from trxheader th  join trxdetail td on th.trxid=td.trxid
join trxtype tt on tt.trxtypeid=th.trxtypeid
join trxstatus ts on ts.TrxStatusId=th.TrxStatusTypeId
join site s on s.siteid = th.siteid
join Client c on c.ClientId=s.ClientId
join device dv on dv.deviceid = th.deviceid
join [user] u on u.userid=dv.userid
group by tt.name, tt.trxtypeid, ts.name, ts.TrxStatusId, th.Trxid, th.trxdate, th.CreateDate,
s.name, s.SiteRef,s.siteid,s.channel, c.Name,u.userid, u.CreateDate, tt.NegativeValue
