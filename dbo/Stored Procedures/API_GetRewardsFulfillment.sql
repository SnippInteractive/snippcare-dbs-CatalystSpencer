CREATE PROCEDURE [dbo].[API_GetRewardsFulfillment] (        
@ClientId INT,        
@Result NVARCHAR(max) OUTPUT        
)        
AS        
BEGIN            
SET NOCOUNT ON; 

DECLARE @TrxStatusId INT,      
@SQL NVARCHAR(MAX),      
--@TrxApprovedStatusId INT,      
@TrxTypeId INT        
  
--Marketing: Pending, Approved  
--Rebate: Approved  
          
SELECT @TrxTypeId = TrxTypeId from TrxType WHERE [Name]= 'Reward' and ClientId = @ClientId     
  
SELECT distinct u.UserId,        
CASE WHEN u.username NOT LIKE '_%@__%.__%' THEN cd.email ELSE u.username END AS Email,        
th.trxid as RewardTrxId,        
--thh.trxId as ReceiptTrxId,        
th.ImportUniqueId,        
th.Deviceid,        
th.TrxDate,  
th.BatchId AS ClientReferenceId,  
SUM(td.Value) as RebateAmount,        
cast(td.Quantity as int) Quantity,        
th.Reference,        
td.Anal1 AS BankMethod,      
td.[Description] AS [Description],      
tt.[Name] as [Status],    
td.Anal2 AS Currency
INTO #Recs        
FROM TRXHEADER th        
JOIN trxdetail td on th.trxid = td.trxid        
JOIN trxtype tt on tt.trxtypeid = th.trxtypeid       
JOIN TrxStatus ts on ts.TrxStatusId = th.TrxStatusTypeId      
JOIN device d on d.deviceid = th.deviceid        
JOIN [user] u on u.userid = d.userid        
JOIN Usercontactdetails ucd on ucd.UserId = u.userid        
JOIN contactdetails cd on cd.contactdetailsId = ucd.contactdetailsid        
WHERE tt.[Name] IN ('MktFundsClaim','Rebate')
AND ts.[name] IN ('Approved', (CASE WHEN td.[Description]='marketing' THEN  ('Pending') ELSE '' END))
AND th.BatchId is not null       
GROUP BY u.userid,        
th.trxid ,        
--thh.trxId,        
th.ImportUniqueId,        
th.Deviceid,        
th.TrxDate,        
u.username,cd.email,        
th.opid ,        
th.Reference,        
td.Quantity,            
td.Anal1,      
td.Description,      
tt.Name,    
td.Anal2 ,  
th.BatchId
        
        
SET @SQL = 'SET @JSON = (        
select distinct r.userid, Email, BankMethod, (Select Top 1 RewardTrxId from #Recs rr where rr.UserId = r.UserId order by RewardTrxId asc) as RewardTrxId,        
(Select Top 1 Quantity from #Recs rr where rr.UserId = r.UserId order by RewardTrxId asc) as Quantity ,  ClientReferenceId, [Status] as Type,  RebateAmount,    
( SELECT Convert( Int, SUM(quantity)) totaltTrxQuantity from TrxHeader th        
join TrxDetail td on th.TrxId = td.TrxID        
join trxtype tt on tt.trxtypeid = th.trxtypeid        
join device d on d.deviceid = th.deviceid        
join [user] u on u.userid = d.userid        
where th.CreateDate > ''2021-12-31'' and tt.Name = ''Reward'' and u.UserId = r.userid ) totaltTrxQuantity        
from #Recs r order by RewardTrxId        
for json auto)'        
        
Select distinct UserId into #UserToBeInserted from #Recs r where UserId not in (select UserId from Schedular.Fulfilment)        
        
IF (Select COUNT(*) from #UserToBeInserted) > 0        
BEGIN        
INSERT INTO Schedular.Fulfilment (UserId, QuantityFulfilled, IsMaxLimitReached)        
SELECT UserId, 0, 0 from #UserToBeInserted        
END        
        
        
DECLARE @JSONDATA NVARCHAR(MAX)        
EXECUTE sp_executesql @SQL, N'@JSON NVARCHAR(MAX) OUTPUT', @JSON = @JSONDATA OUTPUT        
SET @Result = @JSONDATA        
        
DROP TABLE #Recs
--DROP TABLE #UserToBeInserted        
END
