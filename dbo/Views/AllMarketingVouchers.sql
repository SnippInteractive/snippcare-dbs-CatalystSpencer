/* select top (100) * from AllMarketingVouchers*/
CREATE VIEW [dbo].[AllMarketingVouchers]
AS
SELECT     MvId, DeviceId, Name, Description, MarketingCode, MarkMessage, MemberId, Multiplier, StartDate, EndDate, Fixed, CreatedDate, SubType
                      Status, ClientId
FROM         (SELECT     d.Id AS MvId, d.DeviceId, dt.Name, dt.Description, vft.MisCode AS MarketingCode, dt.Description AS MarkMessage, d.UserId AS MemberId, (case vst.Name when 'PointsMultiplier' then vft.OfferValue else 0 end ) as Multiplier, 
                                              dl.StartDate, DATEADD(dd, dep.NumberDaysUntilExpire, dl.StartDate) AS EndDate, (case vst.Name when 'DiscountFixed' then vft.OfferValue else 0 end ) AS Fixed, dt.Created AS CreatedDate, 
                                              vft.VoucherSubTypeId AS SubType, d.DeviceStatusId AS Status, s.ClientId
                       FROM          dbo.Device AS d INNER JOIN
                                              dbo.Site AS s ON s.SiteId = d.HomeSiteId INNER JOIN
                                              dbo.DeviceProfile AS dp ON d.Id = dp.DeviceId INNER JOIN
                                              dbo.DeviceProfileTemplate AS dt ON dp.DeviceProfileId = dt.Id INNER JOIN
                                              dbo.VoucherDeviceProfileTemplate AS vft ON dt.Id = vft.Id INNER JOIN
                                              dbo.DeviceLotDeviceProfile AS dldp ON dldp.DeviceProfileId = dt.Id INNER JOIN
                                              dbo.DeviceLot AS dl ON dl.Id = dldp.DeviceLotId INNER JOIN
                                              dbo.DeviceExpirationPolicy AS dep ON dep.Id = dt.ExpirationPolicyId INNER JOIN
											  dbo.VoucherSubType as vst ON vst.VoucherSubTypeId = vft.VoucherSubTypeId) AS Vouchers

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[36] 4[5] 2[42] 3) )"
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
         Begin Table = "Vouchers"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 199
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'AllMarketingVouchers';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'AllMarketingVouchers';

