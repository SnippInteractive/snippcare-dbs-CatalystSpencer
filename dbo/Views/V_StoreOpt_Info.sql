

Create view [V_StoreOpt_Info]
as
	with temp as(Select  Distinct u.UserId,s.SiteId StoreId,s.SiteRef,s.Name StoreName,s1.SiteId DistrictId,
 s1.Name District,s2.SiteId RegionId,s2.Name Region
	--into #temp 
	from TrxHeader fti
	join [Site] s on s.SiteId = fti.SiteId
	join [Site] s1 on s1.SiteId = s.ParentId
	join [Site] s2 on s2.SiteId = s1.ParentId
	join Device d on d.DeviceId = fti.DeviceId
	join [User] u on u.UserId = d.UserId
	where
	u.UserTypeId = 3 --LoyaltyMember
	and TrxTypeId = 17
	and TrxStatusTypeId =2
	and s.SiteRef in ('02320','02332','02304','02323','02234','02203','02318','02233','02325',
	'02313','02227','02326','02327','02232','02310','02235','02250','02199','02215','02226',
	'02329','02136','02315','02213','02331','02254','02258','02239','02243','02336','02319',
	'02229','02333','02176','02240','02247','02309','02085','02259','02314','02305','02306',
	'02311','02202','02307','02114','02231','02246','02321','02225','02242','02249','02251',
	'02245','02228','02248','02256','02312','02324','02316','02205','02257','02322','02335',
	'02253','02230','02334','02328','02317')
	and Cast(fti.TrxDate as Date) < Convert(Date,GetDate())
	--and s2.SiteId in (select Code from String2INTTable(@Region)) and s1.SiteId in (select Code from String2INTTable(@District))
	--and s.SiteId in (select Code from String2INTTable(@Store)) 
	),

    temp1 as (Select  u.UserId,uled.*,
	SubString(REPLACE(PropertyValue,'\',''),CharIndex('{',PropertyValue),2000)Property_new1 
	--into #temp1
	from [dbo].[User] u 
	join UserloyaltyExtensionData uled on u.userloyaltydataid = uled.userloyaltydataid
	where 
	uled.PropertyName = 'NotificationAndReminderJSON'
	and Cast(u.CreateDate as Date) < Convert(Date,Getdate())
	),

	 temp2 as(Select   t.*,
	JSON_Value(Property_new1,'$.Notifications[0].Scenarios[0].Notifications.Email')Punches_Email,
	JSON_Value(Property_new1,'$.Notifications[0].Scenarios[0].Notifications.SMS')Punches_SMS,
	JSON_Value(Property_new1,'$.Notifications[1].Scenarios[0].Notifications.Email')Free_Merch_Available_Email,
	JSON_Value(Property_new1,'$.Notifications[1].Scenarios[0].Notifications.SMS')Free_Merch_Available_SMS,
	JSON_Value(Property_new1,'$.Notifications[1].Scenarios[1].Notifications.Email')Free_Items_Redeemed_Email,
	JSON_Value(Property_new1,'$.Notifications[1].Scenarios[1].Notifications.SMS')Free_Items_Redeemed_SMS
	--into #temp2
	from temp1 t
	where 
	SUBSTRING(Property_new1,3,1)<>'0'
	)
	
    Select t.StoreId,t.SiteRef,t.StoreName,t.District,t.Region,
	Sum(case when Punches_Email='True' then 1 else 0 end) Punches_Email,
	Sum(case when Punches_SMS='True' then 1 else 0 end) Punches_SMS,
	Sum(case when Free_Merch_Available_Email='True' then 1 else 0 end) Free_Merch_Available_Email,
	Sum(case when Free_Merch_Available_SMS='True' then 1 else 0 end) Free_Merch_Available_SMS,
	Sum(case when Free_Items_Redeemed_Email='True' then 1 else 0 end) Free_Items_Redeemed_Email,
	Sum(case when Free_Items_Redeemed_SMS='True' then 1 else 0 end)Free_Items_Redeemed_SMS
	--into #temp3
	from temp t
	join temp2 t2 on t.UserId = t2.UserId
	Group by SiteRef,StoreName,t.District,t.Region,t.StoreId
	
	--Select * from #temp3