CREATE VIEW [dbo].[VoucherTransactions]
AS
SELECT   ROW_NUMBER() OVER(ORDER BY th.TrxDate DESC) AS TrxId,  --RowNumber as TrxId, Since its used as Id field in hbm (old - td.TrxDetailID AS TrxId,)
					th.TrxStatusTypeId, d.DeviceId AS VoucherId, th.TrxDate AS TransactionDate, d.Reference AS VoucherDescription, s.Name AS StoreName, td.ItemCode, td.Description, 
                     d.UserId AS MemberId,  tvd.VoucherAmount AS VoucherAmount
FROM         dbo.TrxVoucherDetail AS tvd INNER JOIN
                      dbo.TrxDetail AS td ON tvd.TrxDetailId = td.TrxDetailID INNER JOIN
                      dbo.TrxHeader AS th ON th.TrxId = td.TrxID and th.TrxStatusTypeId=2 and th.TrxTypeId =17 INNER JOIN
                      dbo.TrxStatus AS tsp ON th.TrxStatusTypeId = tsp.TrxStatusId INNER JOIN
                      dbo.Device AS d ON d.DeviceId = tvd.TrxVoucherId and d.DeviceStatusId =1 INNER JOIN
                      dbo.Site AS s ON s.SiteId = th.SiteId and tvd.Id > 618594

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[36] 4[25] 2[21] 3) )"
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
         Begin Table = "tvd"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 203
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "td"
            Begin Extent = 
               Top = 6
               Left = 241
               Bottom = 125
               Right = 419
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
         Begin Table = "tsp"
            Begin Extent = 
               Top = 126
               Left = 270
               Bottom = 245
               Right = 430
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "d"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365
               Right = 226
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "s"
            Begin Extent = 
               Top = 246
               Left = 264
               Bottom = 365
               Right = 433
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "amt"
            Begin Extent = 
               Top = 6
               Left = 457
               Bottom = 95
               Right = 617
            End
            DisplayFlags = 280
            TopColumn = 0
         ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VoucherTransactions';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'End
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VoucherTransactions';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VoucherTransactions';

