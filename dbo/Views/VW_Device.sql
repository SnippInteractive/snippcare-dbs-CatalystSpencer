CREATE VIEW [dbo].[VW_Device]
AS
SELECT     d.Id AS DeviceId, d.DeviceId AS DeviceDeviceId, d.Reference AS DeviceReference, d.HomeSiteId AS DeviceHomeSiteId, d.UserId AS DeviceUserId, d.Owner AS DeviceOwner, 
                      d.AccountId AS DeviceAccountId, d.ExpirationDate AS DeviceExpirationDate, d.StartDate AS DeviceStartDate, a.UserId AS AccountUserId, a.PointsPending AS AccountPointsPending, 
                      a.PointsBalance AS AccountPointsBalance,
                          (SELECT     Name
                            FROM          dbo.AccountStatus AS acs
                            WHERE      (AccountStatusId = a.AccountStatusTypeId)) AS AccountStatusName,
                          (SELECT     Name
                            FROM          dbo.DeviceProfileStatus AS dps
                            WHERE      (DeviceProfileStatusId = dp.StatusId)) AS DeviceProfileStatusName,
                          (SELECT     Code
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
                            WHERE      (Id = dpt.DeviceProfileTemplateTypeId)) AS DeviceProfileTemplateTypeName, dpt.Id AS DeviceProfileTemplateId,
                          (SELECT     Name
                            FROM          dbo.DeviceType AS dt
                            WHERE      (DeviceTypeId = d.DeviceTypeId)) AS DeviceTypeName,
                          (SELECT     Name
                            FROM          dbo.DeviceProfileExpirationType
                            WHERE      (Id = dpt.DeviceProfileExpirationTypeId)) AS DeviceProfileExpirationType, d.Pin AS DevicePin, ds.ClientId AS DeviceStatusClientId, d.DeviceLotId, ds.Name AS DeviceStatusName, 
                      d.CreateDate, a.MonetaryBalance AS AccountCashBalance, d.PinFailedAttempts, d.LotSequenceNo AS DeviceLotSequenceNo
FROM         dbo.Device AS d INNER JOIN
                      dbo.DeviceProfile AS dp ON d.Id = dp.DeviceId INNER JOIN
                      dbo.DeviceProfileTemplate AS dpt ON dpt.Id = dp.DeviceProfileId INNER JOIN
                      dbo.DeviceStatus AS ds ON d.DeviceStatusId = ds.DeviceStatusId LEFT OUTER JOIN
                      dbo.Account AS a ON a.AccountId = d.AccountId

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
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "d"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 126
               Right = 226
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "dp"
            Begin Extent = 
               Top = 6
               Left = 264
               Bottom = 126
               Right = 425
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "dpt"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 246
               Right = 335
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ds"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 366
               Right = 200
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "a"
            Begin Extent = 
               Top = 246
               Left = 238
               Bottom = 366
               Right = 431
            End
            DisplayFlags = 280
            TopColumn = 0
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VW_Device';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VW_Device';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VW_Device';

