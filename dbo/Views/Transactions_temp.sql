


CREATE VIEW [dbo].[Transactions_temp]  

AS  
SELECT DISTINCT   
                         TH.TrxId, TH.TrxStatusTypeId, CAST(TH.TrxDate AS DATETIME) AS TrxDate,TH.CreateDate, TH.DeviceId, TH.EposTrxId, TrxD.TrxDetailID, TrxD.LineNumber, TH.TerminalId, TH.OpId, site.ClientId, '' AS OperatorName,   
                         TH.Reference, TH.TerminalExtra, TH.TerminalExtra2, TH.TerminalExtra3,TH.ImportUniqueId ,TrxD.AuthorisationNr AS AuthCode, TrxD.HomeCurrencyCode, dbo.TrxType.Name AS TransactionType, TrxD.Description, TrxD.Quantity,   
                         TrxD.Value, TrxD.Points, TrxD.ItemCode, TrxD.Anal1, TrxD.Anal2, TrxD.Anal3, TrxD.Anal4, TrxD.VAT, COALESCE (TrxD.Anal7, N'Not Available') AS brand, COALESCE (TrxD.EposDiscount, 0)   
                         + COALESCE (TrxD.LoyaltyDiscount, 0) AS Discount, '' AS size, amt.TotalPoints, amt.TotalValue, amt.TotalDiscount, amt.TotalBonus, amt.Amount, amt.TotalPromoValue,  
                         de.UserId, TH.SiteId, TH.TrxTypeId, P.TenderTypeId, CASE WHEN (len(P.Currency)) IS NULL THEN TrxD.HomeCurrencyCode ELSE P.Currency END AS Currency, site.Name,   
                         '' AS Department, TH.AccountCashBalance, TH.AccountPointsBalance, site.Name AS CompanyName, '' AS PromotionCode, '' AS Season, '' AS Supplier, COALESCE (TrxD.Anal8,   
                         N'Not Available') AS BenefitID,'' AS OriginalPrice, '' AS CostPrice,   
                         '' AS RealisedPrice, site.Name AS SiteName, dbo.TrxType.Name AS TrxType, TrxD.Anal5, TrxD.Anal6, TrxD.Anal7, TrxD.Anal8, TrxD.Anal9, TrxD.Anal10,   
                         TrxD.Anal11, TrxD.Anal12, TrxD.Anal13, TrxD.Anal14, TrxD.Anal15, TrxD.Anal16 ,de.ExtraInfo ,th.BatchId,ts.Name as TrxStatusName,TH.InitialTransaction, u.Username as CreatedBy,
						 TrxD.PromotionID,TerminalDescription,						
						 --CASE WHEN tdstamp.PunchTrXType in (1,2) THEN promo.[Name] ELSE NULL END as PromotionName,
						 --ISNULL(tdstamp.ValueUsed,0) as StampCount, -- lineitemlvl
						 CASE WHEN tdstamp.PunchTrXType in (1,2)  then detStmp.Promotions ELSE NULL END as PromotionName,
						 detStmp.Stamps as StampCount,  -- lineitemlvl
						 CASE WHEN ISNULL(tdstamp.ChildPunch,0) > 0 THEN CAST(ISNULL(tdstamp.ChildPunch,0) as NVARCHAR(10)) + ' - ' + isnull(childPromo.[Name],'') ELSE NULL END as StampsChild, -- lineitemlvl
						 amt.Stamps --headerlvl
						 --,detStmp.Promotions
						 ,detStmp.StampsInLine
FROM            dbo.TrxHeader AS TH LEFT OUTER JOIN  
                         dbo.Site AS site ON site.SiteId = TH.SiteId LEFT OUTER JOIN  
                         dbo.[user] AS u ON u.UserId = TH.MemberId LEFT OUTER JOIN  
                         dbo.Device as de ON de.DeviceId = TH.DeviceId LEFT OUTER JOIN  
                         dbo.TrxDetail AS TrxD ON TrxD.TrxID = TH.TrxId INNER JOIN  
						 dbo.TrxStatus AS ts ON ts.TrxStatusId = TH.TrxStatusTypeId INNER JOIN 
                         dbo.TrxType ON dbo.TrxType.TrxTypeId = TH.TrxTypeId INNER JOIN  
                             (SELECT        SUM(dbo.TrxDetail.Value) AS TotalValue, SUM(dbo.TrxDetail.Points) AS TotalPoints, SUM(dbo.TrxDetail.BonusPoints) AS TotalBonus,   
                                                         SUM(dbo.TrxDetail.EposDiscount + dbo.TrxDetail.LoyaltyDiscount) AS TotalDiscount, SUM(dbo.TrxDetail.Value) AS Amount,
														  dbo.TrxHeader.TrxId ,SUM(ISNULL(tdp.ValueUsed,0)) as TotalPromoValue, SUM(ISNULL(tdstamp.ValueUsed,0)) as Stamps
                               FROM            dbo.TrxDetail INNER JOIN  
                                               dbo.TrxHeader ON dbo.TrxDetail.TrxID = dbo.TrxHeader.TrxId Left Join 
											   dbo.TrxDetailPromotion tdp on tdp.TrxDetailId = dbo.TrxDetail.TrxDetailId Left Join 
											   dbo.TrxDetailStampCard tdstamp on tdstamp.TrxDetailId = dbo.TrxDetail.TrxDetailId and tdstamp.PunchTrXType in (1,2)
                               GROUP BY dbo.TrxHeader.TrxId) AS amt ON amt.TrxId = TH.TrxId 
							   
							   
						LEFT OUTER JOIN 							   						
                         dbo.TrxPayment AS P ON P.TrxID = TH.TrxId 
						 LEFT JOIN Promotion promo ON TrxD.PromotionId = promo.Id 
						 LEFT JOIN TrxDetailStampCard tdstamp ON tdstamp.TrxDetailId = TrxD.TrxDetailId AND tdstamp.PunchTrXType in (1,2) --tdstamp.ValueUsed > 0
						 LEFT JOIN Promotion childPromo ON tdstamp.ChildPromotionId = childPromo.Id

						 LEFT JOIN (SELECT  SUM(stp.ValueUsed) as Stamps,td.TrxId,STRING_AGG(cast(stp.ValueUsed as nvarchar(5)) + ' | ' + p.[name],',') as promotions,td.TrxDetailId, count(stp.promotionid) as StampsInLine
									FROM	dbo.TrxDetail td INNER JOIN                                          
											dbo.TrxDetailStampCard stp on stp.TrxDetailId = td.TrxDetailId and stp.PunchTrXType in (1,2)	
											   INNER JOIN promotion p on p.id = stp.promotionid
									GROUP BY td.TrxDetailId,td.TrxId) AS detStmp ON detStmp.TrxDetailId = TrxD.TrxDetailId
		 
						 
WHERE        (ts.name <> 'Started') AND (ISNULL(TH.IsAnonymous, 0) <> 1) AND (TrxD.Points <> 0) OR  
                         (ts.name <> 'Started') AND (ISNULL(TH.IsAnonymous, 0) <> 1) 
						 --AND (TrxD.Value <> 0)
