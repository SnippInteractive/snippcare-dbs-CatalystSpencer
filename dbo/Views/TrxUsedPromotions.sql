CREATE VIEW [dbo].[TrxUsedPromotions]
AS
SELECT DISTINCT 
                      p.Name AS PromotionName, p.Description AS PromotionDescription, CAST(th.TrxDate AS DATETIME) AS TrxDate, CL.MemberId, td.PromotionalValue AS OfferValue, 
                      td.Description AS TrxDetailDescription, s.Name AS SiteName, th.TrxId, td.TrxDetailID, CL.Id
FROM         dbo.CalculateLoyaltyInfo AS CL INNER JOIN
                      dbo.CalculateLoyaltyOffer AS cf ON CL.Id = cf.CalculateLoyaltyInfoId INNER JOIN
                      dbo.TrxHeader AS th ON CL.TrxId = th.TrxId INNER JOIN
                      dbo.TrxDetail AS td ON th.TrxId = td.TrxID INNER JOIN
                      dbo.Promotion AS p ON td.PromotionID = p.Id INNER JOIN
                      dbo.Site AS s ON s.SiteId = th.SiteId

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[23] 4[4] 2[55] 3) )"
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
         Begin Table = "CL"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cf"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 125
               Right = 438
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "th"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 232
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "td"
            Begin Extent = 
               Top = 126
               Left = 270
               Bottom = 245
               Right = 455
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "p"
            Begin Extent = 
               Top = 6
               Left = 476
               Bottom = 125
               Right = 675
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "s"
            Begin Extent = 
               Top = 126
               Left = 493
               Bottom = 245
               Right = 662
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
    ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'TrxUsedPromotions';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'     Output = 720
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'TrxUsedPromotions';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'TrxUsedPromotions';

