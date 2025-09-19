

CREATE VIEW [dbo].[EtlDevice]
AS
select
	isnull(d.[DeviceId], 'UNKNOWN') as [DeviceAK],
	isnull(d.[DeviceId], 'UNKNOWN') as [DeviceName],
	isnull(d.[Id], -1) as [DeviceId],
	cast (case 
		when isnull(dptt.[Name], 'UNKNOWN') = 'Financial' and isnull(fdptt.IsGiftCard, 0) = 0 then 1
		when isnull(dptt.[Name], 'UNKNOWN') = 'Financial' and isnull(fdptt.IsGiftCard, 0) = 1 then 2
		when isnull(dptt.[Name], 'UNKNOWN') = 'Loyalty' then 3
		when isnull(dptt.[Name], 'UNKNOWN') = 'Payment' then 4
		when isnull(dptt.[Name], 'UNKNOWN') = 'Voucher' then 5
		else -1
	end as int) as [DeviceTypeAK],	
	cast (case 
		when isnull(dptt.[Name], 'UNKNOWN') = 'Financial' and isnull(fdptt.IsGiftCard, 0) = 0 then 'Financial Voucher'
		when isnull(dptt.[Name], 'UNKNOWN') = 'Financial' and isnull(fdptt.IsGiftCard, 0) = 1 then 'Giftcard'
		when isnull(dptt.[Name], 'UNKNOWN') = 'Loyalty' then 'Loyalty'
		when isnull(dptt.[Name], 'UNKNOWN') = 'Payment' then 'Payment'
		when isnull(dptt.[Name], 'UNKNOWN') = 'Voucher' then 'Marketing Voucher'
		else 'UNKNOWN'
	end as nvarchar(255)) as [DeviceTypeName],
	isnull(d.[DeviceStatusId], -1) as [DeviceStatusAK],
	cast(isnull(ds.[Name], 'UNKNOWN') as nvarchar(255)) as [DeviceStatusName],
	isnull(dl.[Id], -1) as [DeviceLotAK],
	isnull(dl.[Name], 'UNKNOWN') as [DeviceLotName],
	isnull(dl.[Reference], '') as [DeviceLotReference],
	isnull(dpt.[Id], -1) as [DeviceProfileTemplateAK],
	isnull(dpt.[Name], 'UNKNOWN') as [DeviceProfileTemplateName], 
	isnull(dpt.[Description], 'UNKNOWN') as [DeviceProfileTemplateDescription], 
	isnull(dl.[NumberOfDevices], 0) as [NumberOfDevices],
	CAST(0 AS smallint) AS DeletedAK,
	CAST('Active' as nvarchar(20)) AS DeletedName,
	isnull(d.[UserId], -1)  as MemberAK,
	isnull(dptt.[Id], -1) as DeviceProfileTemplateTypeAK,
	CAST(isnull(dptt.[Name], 'UNKNOWN') as nvarchar(50)) AS DeviceProfileTemplateTypeName,
	CAST(isnull(d.[StartDate], '1900-01-01') as datetime) as StartDate,
	CAST(isnull(d.[ExpirationDate], '1900-01-01') as datetime) as ExpirationDate,
	--CAST(isnull(d.[ImageUrl], '') as nvarchar(500)) 
	''AS [URL_Barcode],
	CAST(isnull(dpt.[ImageUrl], '') as nvarchar(500)) AS [URL_Image],
	case 
		when d.[LotSequenceNo] is null then 0
		when ISNUMERIC(d.[LotSequenceNo]) = 0 then 0
		else CAST(isnull(d.[LotSequenceNo], 0) as bigint) 
	end AS [LotSequenceNo],
	isnull(d.[AccountId], -1) as [AccountId],
	isnull(ht.HasTransactions, 0) as HasTransactions,
	cast(isnull(dpst.[LoyaltyProfileStatusAK], 5) as int) as [LoyaltyProfileStatusAK],
	cast(isnull(dpst.[LoyaltyProfileStatusName], 'Undefined') as nvarchar(50)) as [LoyaltyProfileStatusName],
	cast(isnull(dpst.[PaymentProfileStatusAK], 5) as int) as [PaymentProfileStatusAK],
	cast(isnull(dpst.[PaymentProfileStatusName], 'Undefined') as nvarchar(50)) as [PaymentProfileStatusName]
from
	[dbo].[Device] d
left join
	[dbo].[DeviceType] dt
	on d.[DeviceTypeId] = dt.[DeviceTypeId]
left join
	[dbo].[DeviceStatus] ds
	on d.[DeviceStatusId] = ds.[DeviceStatusId]
outer apply
(
	select top 1 DeviceProfileId from [dbo].[DeviceProfile] dpf
	left join [dbo].[DeviceProfileStatus] dps on dps.DeviceProfileStatusId = dpf.StatusId
	where dpf.DeviceId=d.Id
	order by (case when dps.Name = 'Active' then 0 else 1 end)
) dp
left join 
	[dbo].[DeviceProfileTemplate] dpt 
	on dp.DeviceProfileId=dpt.Id and ParentId is null
left join
	[dbo].[DeviceProfileTemplateType] dptt
	on dptt.[Id] = dpt.[DeviceProfileTemplateTypeId]
left join
	[dbo].[FinancialDeviceProfileTemplate] fdptt
	on fdptt.[Id] = dpt.[DeviceProfileTemplateTypeId]
left join
	dbo.devicelot dl
	on d.[DeviceLotId] = dl.[Id]
outer apply
(
	select top 1 1 as HasTransactions from [dbo].[TrxHeader] th where th.[DeviceId] = d.[DeviceId]
) ht
outer apply
(
	select 
		dps.[DeviceId],
		isnull(max([LoyaltyProfileStatusAK]), 5) as [LoyaltyProfileStatusAK],
		isnull(max([LoyaltyProfileStatusName]), 'Undefined') as [LoyaltyProfileStatusName],
		isnull(max([PaymentProfileStatusAK]), 5) as [PaymentProfileStatusAK],
		isnull(max([PaymentProfileStatusName]), 'Undefined') as [PaymentProfileStatusName]
	from
	(
		select
			dpf.[DeviceId],
			case when dptt.[Name] = 'Loyalty' then dps.[DeviceProfileStatusId] else null end as [LoyaltyProfileStatusAK],
			case when dptt.[Name] = 'Loyalty' then dps.[Name] else null end as [LoyaltyProfileStatusName],
			case when dptt.[Name] = 'Payment' then dps.[DeviceProfileStatusId] else null end as [PaymentProfileStatusAK],
			case when dptt.[Name] = 'Payment' then dps.[Name] else null end as [PaymentProfileStatusName]
		from 
			[dbo].[DeviceProfile] dpf
		left join 
			[dbo].[DeviceProfileStatus] dps 
			on dps.DeviceProfileStatusId = dpf.StatusId
		left join 
			[dbo].[DeviceProfileTemplate] dpt 
			on dpf.DeviceProfileId=dpt.Id and ParentId is null
		left join
			[dbo].[DeviceProfileTemplateType] dptt
			on dptt.[Id] = dpt.[DeviceProfileTemplateTypeId]
		where 
			dpf.DeviceId = d.Id and
			dptt.Name in ('Loyalty', 'Payment')
	) dps
	group by dps.[DeviceId]
) dpst


