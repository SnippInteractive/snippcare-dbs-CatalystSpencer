
CREATE VIEW [dbo].[VW_LoyaltyProfile]
AS
SELECT        (SELECT        Code
                          FROM            dbo.Currency
                          WHERE        (Id = dpt.CurrencyId)) AS AccountCurrencyCode, dpt.Name AS DeviceProfileTemplateName,
                             (SELECT        Name
                               FROM            dbo.DeviceProfileTemplateStatus
                               WHERE        (Id = dpt.StatusId)) AS DeviceProfileTemplateStatusName,
                             (SELECT        Code
                               FROM            dbo.Currency AS Currency_1
                               WHERE        (Id = dpt.CurrencyId)) AS DeviceProfileTemplateCurrencyCode, dpt.Code AS DeviceProfileTemplateCode, dpt.SiteId AS DeviceProfileTemplateSiteId,
                             (SELECT        Name
                               FROM            dbo.DeviceProfileTemplateType AS dptt
                               WHERE        (Id = dpt.DeviceProfileTemplateTypeId)) AS DeviceProfileTemplateTypeName, lp.PointsToCashThreshold AS LoyaltyProfilePointsToCashThreshold,
                             (SELECT        Name
                               FROM            dbo.PointsCalculationRuleType AS pc
                               WHERE        (Id = lp.PointsCalculationRuleTypeId)) AS LoyaltyProfilePointsCalculationRuleTypeName, lp.InstantPointsRedemption AS LoyaltyProfileInstantPointsRedemption, 
                         lp.SpendToPointsConversionUnit AS LoyaltyProfileSpendToPointsConversionUnit, lp.PaymentCardBonus AS LoyaltyProfilePaymentCardBonus, 
                         lp.RedeemPointsThreshold AS LoyaltyProfileRedeemPointsThreshold, lp.PaymentToBonusConversionUnit AS LoyaltyProfilePaymentToBonusConversionUnit, 
                         lp.LineItemsMaxPointsValue AS LoyaltyProfileLineItemsMaxPointsValue, lp.NumberHoursReservePoints AS LoyaltyProfileNumberHoursReservePoints, dpt.Id AS DeviceProfileTemplateId, 
                         lp.DeviceMustBeRegisteredToRedeemPoints,
                             (SELECT        Name
                               FROM            dbo.DeviceProfileExpirationType
                               WHERE        (Id = dpt.DeviceProfileExpirationTypeId)) AS DeviceProfileExpirationType, dpt.Description,lp.BasketMaxPointsValue AS LoyaltyProfileBasketMaxPointsValue
FROM            dbo.DeviceProfileTemplate AS dpt INNER JOIN
                         dbo.DeviceProfileTemplateType AS dptt ON dptt.Id = dpt.DeviceProfileTemplateTypeId INNER JOIN
                         dbo.LoyaltyDeviceProfileTemplate AS lp ON lp.Id = dpt.Id

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -288
         Left = 0
      End
      Begin Tables = 
         Begin Table = "dpt"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 351
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "dptt"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "lp"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 347
            End
            DisplayFlags = 280
            TopColumn = 7
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VW_LoyaltyProfile';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VW_LoyaltyProfile';

