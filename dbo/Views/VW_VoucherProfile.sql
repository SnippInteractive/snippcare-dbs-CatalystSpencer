CREATE VIEW [dbo].[VW_VoucherProfile]
	AS SELECT     (SELECT     Code
                       FROM          dbo.Currency
                       WHERE      (Id = dpt.CurrencyId)) AS AccountCurrencyCode, dpt.Name AS DeviceProfileTemplateName,
                          (SELECT     Name
                            FROM          dbo.DeviceProfileTemplateStatus
                            WHERE      (Id = dpt.StatusId)) AS DeviceProfileTemplateStatusName,
                          (SELECT     Code
                            FROM          dbo.Currency AS Currency_1
                            WHERE      (Id = dpt.CurrencyId)) AS DeviceProfileTemplateCurrencyCode, dpt.Code AS DeviceProfileTemplateCode, dpt.SiteId AS DeviceProfileTemplateSiteId,
                          (SELECT     Name
                            FROM          dbo.DeviceProfileTemplateType AS dptt
                            WHERE      (Id = dpt.DeviceProfileTemplateTypeId)) AS DeviceProfileTemplateTypeName, dpt.Id AS DeviceProfileTemplateId, vp.ClassicalVoucher AS VoucherProfileClassicalVoucher, 
                      vp.DaysEnabled AS VoucherProfileDaysEnabled, vp.EndTime AS VoucherProfileEndTime, vp.IncludePromotionItem AS VoucherProfileIncludePromotionItem, 
                      vp.LogicalAnd AS VoucherProfileLogicalAnd, vp.MisCode AS VoucherProfileMisCode, vp.OfferValue AS VoucherProfileOfferValue, vp.PromotionType AS VoucherProfilePromotionType, 
                      vp.SpendRequired AS VoucherProfileSpendRequired, vp.StartTime AS VoucherProfileStartTime, vp.UseSameSubType AS VoucherProfileUseSameSubType, 
                      vp.UseSameType AS VoucherProfileUseSameType, vp.UseWithOthers AS VoucherProfileUseOthers,
                          (SELECT     Name
                            FROM          dbo.VoucherSubType AS vst
                            WHERE      (VoucherSubTypeId = vp.VoucherSubTypeId)) AS VoucherProfileVoucherSubTypeName,dpt.[Description]
					,(SELECT Name From DeviceProfileExpirationType where Id = dpt.DeviceProfileExpirationTypeId) as DeviceProfileExpirationType,vp.IsSingleLine,vp.CheapestOrDearest,vp.IsStampCard
FROM         dbo.DeviceProfileTemplate AS dpt INNER JOIN
                      dbo.DeviceProfileTemplateType AS dptt ON dptt.Id = dpt.DeviceProfileTemplateTypeId INNER JOIN
                      dbo.VoucherDeviceProfileTemplate AS vp ON vp.Id = dpt.Id
