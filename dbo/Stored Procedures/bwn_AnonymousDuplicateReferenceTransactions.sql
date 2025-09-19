-- =============================================
-- Author:		Anish
-- Create date: 10.05.2017
-- Description:	This procedure will update the IsAnonymous Flag to True. TOP-269
-- CASE1:
--1. Purchase
--2. Void
--Should we need to show both transactions? YES

--CASE2
--1.Purchase
--2.Void
--3.Purchase
--4.Void
--Again, in this case, Only 3 & 4 right? YES

--CASE3:
--1.Purchase
--2.Void
--3. Purchase
--In this case, 3 only. Right? YES
-- =============================================
CREATE PROCEDURE [dbo].[bwn_AnonymousDuplicateReferenceTransactions] 
AS	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--morethan one void
select reference,count(reference) as count,deviceid into #VoidRp  from TrxHeader 
where TrxTypeId=22 and isnull(IsAnonymous,0)=0 
--and trxdate>getdate()-2
group by reference,deviceid
having count(reference)>1

--morethan 1 purchase
select reference,count(reference) as count,deviceid into #PurchaseRp  from TrxHeader 
where TrxTypeId=17 and isnull(IsAnonymous,0)=0 
--and trxdate>getdate()-2
group by reference,deviceid
having count(reference)>1

-- case with purchase,void,purchase
select reference,count(reference) as count,deviceid into #tmpvoidone  from TrxHeader 
where TrxTypeId=22 and isnull(IsAnonymous,0)=0 
--and trxdate>getdate()-2
group by reference,deviceid
having count(reference)=1

select #tmpvoidone.Reference,#tmpvoidone.count,#tmpvoidone.DeviceId into #purchaseVoidPurchase from #PurchaseRp join #tmpvoidone on #tmpvoidone.reference=#PurchaseRp.Reference


END

