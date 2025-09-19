create Procedure [dbo].[EPOS_UpdatePointsAgeWithTrx] (@Userid int, @TrxID int) as 
/*
Points for an Earn or burn going to the correct tables. Either to add to the Earn OR to add to burns and update the points remaining on the earns. #
Either way, returns back the ULED fpor the PointsBalance(s)

The TRX is written first and then this SP is called with the TRXID. 

Every Trx that changes a balance must call this in order and also the SITE must be included.

*/


Begin
	declare @EarnTypeTrx int = NULL, @Channel nvarchar(25)=null, @UserLoyaltyDataId int, @Points money, @Siteid int, @TrxDate datetime
	--We are doing this bit for ONE TRXID only, this is not the userid (All Trx)
	select @UserLoyaltyDataId = UserLoyaltyDataId from [user] where userid = @userid
	if @trxID is not null
	Begin
		
		select @EarnTypeTrx = NegativeValue, @Channel = isnull(Channel,'Reckitt'), @Points = Points , @Siteid=siteid, 
		@TrxDate=TrxDate
		from VW_TrxHeaders where trxid = @trxid 
		select @Channel = 
		case when @Channel not in('Shopee','Lazada') --Needs to be distinct Channel from site where FLAG is an Account
		then 'Reckitt'
		else @channel End
		if isnull(@EarnTypeTrx,0) = 0 
		Begin 
			INSERT INTO [TrxPointsAgeEarned]
			([Version],[TrxID],[SiteID],[Channel],[Points],[PointsRemaining],[UserID],[trxdate])
			select 1, v.Trxid,v.Siteid,@channel as Account,v.Points,v.Points,v.UserID,v.TrxDate
			from VW_TrxHeaders v left join [TrxPointsAgeEarned] t on v.trxid=t.trxid
			where Client = 'reckitt-ph' and t.trxid is null and v.trxid=@trxid and v.userid = @userid
			Declare @PeriodAmount int , @PeriodType nvarchar(10)
			select @PeriodType = PeriodType, @PeriodAmount = PeriodAmount from [TrxPointsAgeExpiry] where Channel = @Channel
			if  @PeriodType = 'Year' 
			Begin 
				update [TrxPointsAgeEarned] set ExpiryDate = dateadd(YEAR,@PeriodAmount, TrxDate) where @Trxid = @TrxID 
			End 
			Else 
			If  @PeriodType = 'Month'
			begin 
				update [TrxPointsAgeEarned] set ExpiryDate = dateadd(MONTH,@PeriodAmount, TrxDate) where @Trxid = @TrxID 
				--dateadd ( mm, 19, dateadd(mm, datediff(mm, 0, TrxDate), 0)) -.00001 << this is for the Expire at end of month
			End 
		End
	End
	
	if isnull(@EarnTypeTrx,0) = 1 and @TrxID is not null and  @Channel is not null 
	/*Burning Points*/
	Begin
		if not exists (select * from TrxPointsAgeBurned where trxid = @Trxid)
		Begin
			drop table if exists #PlayPointsUpdater
			drop table if exists #PlayPoints
			select PriorityNo, EarnChannel,tpe.Trxid,Tpe.PointsRemaining,tpe.[TrxPointsAgeID],
			sum(tpe.pointsremaining) over (order by PriorityNo, trxdate) RunningTotal ,
			sum(tpe.pointsremaining) over (order by PriorityNo, trxdate) +@Points as PointsLeftAfter, 
			row_number()over (order by PriorityNo, trxdate) RN    into #PlayPoints from TrxPointsAgePriority prio 
			join TrxPointsAgeEarned tpe on prio.spendchannel = tpe.Channel and prio.SpendChannel = @Channel and tpe.userid = @Userid
			where tpe.pointsremaining !=0 
			order by EarnChannel, trxdate
			Declare @MinRN int
			select @MinRN = min(rn) from #PlayPoints where pointsleftafter>=0
			delete from #PlayPoints where rn > @MinRN

			select case when rn = @MinRN then PointsLeftAfter else 0 end ForEarnPA , 
			case when rn = @MinRN then PointsRemaining-PointsLeftAfter else PointsRemaining end ForBurnPA ,*
			into #PlayPointsUpdater
			from #PlayPoints
			update tpe set tpe.pointsremaining = u.ForEarnPA from 
			trxpointsageearned tpe join #PlayPointsUpdater u on u.TrxPointsAgeID=tpe.TrxPointsAgeID
			insert into TrxPointsAgeBurned([Version],[TrxID],[TrxPointsAgeID],[SiteID],[Channel],[PointsBurnt],[UserID],[TrxDate],[DateChangedLoaded])
			select 1,@TrxID,trxpointsageid,@siteid,@Channel,ForBurnPA,@userid, @TrxDate,GetDate()
			from #PlayPointsUpdater
			drop table if exists #PlayPoints
			drop table if exists #PlayPointsUpdater
		End
	End
	/*
	
	
	*/
	select sum(PointsRemaining) PointsBalancePerChannel,Channel,u.userid,u.UserLoyaltyDataId 
	into #NewBalances
	from [TrxPointsAgeEarned] tpa join [user] u on u.userid=tpa.UserID
	where u.userid = @userid
	group by Channel,u.userid,u.UserLoyaltyDataId

	 select  PropertyName, PropertyValue, @userid userid, @UserLoyaltyDataId UserLoyaltyDataId , uled.ID  
	 into #ExistingBalances  
     from UserLoyaltyExtensionData uled   
     where Propertyname in ('PointsBalance_Lazada','PointsBalance_Shopee','PointsBalance_Reckitt')  
     AND UserLoyaltyDataId=@UserLoyaltyDataId 
	
	--The ones that do not have fields already in the ULED table
	insert into UserLoyaltyExtensionData 
	(Version,UserLoyaltyDataId,[PropertyValue],[PropertyName],GroupId,[DisplayOrder],[Deleted])
	select 1,nb.UserLoyaltyDataId, nb.PointsBalancePerChannel, 'PointsBalance_' + nb.Channel,0,1,0  from  #NewBalances nb 
	left join #ExistingBalances eb on nb.UserLoyaltyDataId = eb.UserLoyaltyDataId 
	and nb.userid=eb.userid and 'PointsBalance_' + nb.Channel=eb.PropertyName collate database_default
	where id is null

	update u set u.propertyvalue=x.PointsBalancePerChannel from   UserLoyaltyExtensionData u join 
	(select id,nb.PointsBalancePerChannel  from  #NewBalances nb 
	join #ExistingBalances eb on nb.UserLoyaltyDataId = eb.UserLoyaltyDataId 
	and nb.userid=eb.userid and 'PointsBalance_' + nb.Channel=eb.PropertyName collate database_default
	and PropertyValue !=PointsBalancePerChannel
	where id is not null) x on x.id=u.id
	/*
	select * from UserLoyaltyExtensionData where UserLoyaltyDataId = @UserLoyaltyDataId
	and propertyname like 'PointsBa%'
	*/
	/* For adding the JSon value
	Declare @Uled_ID int=null, @Json nvarchar(max)

	select @Uled_ID = ID from UserLoyaltyExtensionData uled join 
	[user] u on u.UserLoyaltyDataId=uled.UserLoyaltyDataId
	where userid = @userid and Propertyname ='AdditionalAccounts'

	SELECT @Json = (SELECT Propertyname as Name, PropertyValue as Balance, 'True' as Active
	FROM  UserLoyaltyExtensionData uled join 
	[user] u on u.UserLoyaltyDataId=uled.UserLoyaltyDataId
	where userid = @UserID and Propertyname in ('PointsBalance_Lazada','PointsBalance_Shopee','PointsBalance_Reckitt')
	FOR JSON PATH,root('AdditionalAccounts')) 
	if @Uled_ID is null 
	Begin
		insert into UserLoyaltyExtensionData 
		(Version,UserLoyaltyDataId,[PropertyValue],[PropertyName],GroupId,[DisplayOrder],[Deleted])
		select 1,@UserLoyaltyDataId, @Json, 'AdditionalAccounts', 0,1,0  
	End
	Else 
	Begin
		Update UserLoyaltyExtensionData set Propertyvalue = @Json where id = @Uled_ID
	End
	*/
	
/* For doing all trx together!
	else
	Begin
		INSERT INTO [TrxPointsAgeEarned]
		([Version],[TrxID],[SiteID],[Channel],[Points],[PointsRemaining],[UserID],[trxdate])
		select 1, v.Trxid,v.Siteid,
		case when isnull(v.channel,'Reckitt') not in('Shopee','Lazada') then 'Reckitt' else v.channel End as Account,
		v.Points,v.Points,v.UserID,v.TrxDate
		from VW_TrxHeaders v left join [TrxPointsAgeEarned] t on v.trxid=t.trxid
		where Client = 'reckitt-ph' and t.trxid is null and v.userid = @userid
		and negativevalue =0
	end
	*/
end
