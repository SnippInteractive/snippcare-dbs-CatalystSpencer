CREATE VIEW vw_Select_ExpiryStampsByDay

as


select tt.name TransactionType, count(distinct Deviceid) CardsUsed, Sum(ValueUsed) StampsTaken,p.name , convert(date,trxdate) DateOfExpiry
from trxheader th join trxdetail td on th.trxid=td.trxid
join TrxDetailStampCard sc on td.trxdetailid =sc.trxdetailid 
join promotion p on sc.promotionid=p.id
join trxtype tt on tt.trxtypeid = th.trxtypeid
where tt.name ='ExpiryStamps'
group by p.name , convert(date,trxdate), tt.name 
--order by convert(date,trxdate) desc, p.name desc

