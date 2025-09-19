CREATE VIEW [dbo].[VW_FinancialProfile]
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
                            WHERE      (Id = dpt.DeviceProfileTemplateTypeId)) AS DeviceProfileTemplateTypeName, dpt.Id AS DeviceProfileTemplateId, f.AllowsAmountToBeReserved AS FinancialReserveAmount, 
                      f.MaxBalance AS FinancialMaxBalance, f.MinBalance AS FinancialMinBalance, f.NumberHoursToReserveAmount AS FinancialNumberHoursReserveAmount, 
                      dpt.CanUserChangePin AS FinancialCanUserChangePin, dpt.IsRefundable AS FinancialIsRefundable, dpt.IsReloadable AS FinancialIsReloadable, dpt.IsReusable AS FinancialIsReusable, 
                      dpt.PinNumberRetries AS FinancialPinNumberRetries, dpt.PinRequired AS FinancialPinRequired, dpt.PinValidationRegularEx AS FinancialPinValidationRegularEx, 
                      de.NumberDaysUntilExpire AS FinancialProfileNumberDaysExpire,
                          (SELECT     Name
                            FROM          dbo.DeviceExpirationPolicyType
                            WHERE      (Id = de.ExpirationPolicyTypeId)) AS FinancialExpirationPolicyType
							,(SELECT Name From DeviceProfileExpirationType where Id = dpt.DeviceProfileExpirationTypeId) as DeviceProfileExpirationType,
							f.ReCalculateExpiryDateOnReload as ReCalculateExpiryDateOnReload, f.ApplyToAllBrands, s.CountryId as DeviceProfileTemplateSiteCountryId, dpt.[Description]
FROM         dbo.DeviceProfileTemplate AS dpt INNER JOIN
                      dbo.DeviceProfileTemplateType AS dptt ON dptt.Id = dpt.DeviceProfileTemplateTypeId INNER JOIN
                      dbo.FinancialDeviceProfileTemplate AS f ON f.Id = dpt.Id LEFT OUTER JOIN
                      dbo.DeviceExpirationPolicy AS de ON de.Id = dpt.ExpirationPolicyId JOIN
					  dbo.Site s ON s.SiteId = dpt.SiteId
