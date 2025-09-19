CREATE VIEW [dbo].[VW_BasicTransacation]
	AS SELECT 
th.*,
tt.Name as TrxTypeName,
ts.Name as TrxStatusName,
s.SiteRef,
s.Name as SiteName,
ss.Name as SiteStatusName,
st.Name as SiteTypeName
 from TRXHEADER th join TrxType tt on th.TrxTypeId = tt.TrxTypeId
 JOIN TrxStatus ts on ts.TrxStatusId = th.TrxStatusTypeId
 JOIN SITE s on s.SiteId = th.SiteId
 JOIN SiteStatus ss on ss.SiteStatusId = s.SiteStatusId
 JOIN SiteType st on st.SiteTypeId = s.SiteTypeId
