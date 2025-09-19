CREATE Procedure [dbo].[Tier_GetSQLForTierPoints_SingleUser] @UserID int, @TrxID int as 
/*
Ticket https://snipp-interactive.atlassian.net/browse/VOY-585
For Ballys!
Date:	2022-08-12
Author:	Niall
Description

As the Points for Bally coin is just that, Points, there will be no change in that and the account will remain the same. 
These are the points available to spend.

Tier points are different….

When points are awarded for a Transaction of the TrxTypes setup in Tieradmin, we pass the TrxID as well as the USERID A new SP. 
This SP will first find which Tier the user is in and get the appropriate Multiplier for that tier (QualifiedTierMultiplier). 
If there is NO tier that the user is part of, then they are added to the first tier and the Multiplier for that tier is used.

A transaction HEAD is written with the amount of TRX Points * the Multiplier into the TRXPointsAgeEarned Table. 
The sum of these points is calculatged based on the Start and End Date of the TierAdmin. 
From this, we check if the USER moves UP a tier and if so THEN we will move the user from Tier X to Tier Y and update the PROFILE of the users 
Device and Audit the change. 
We do NOT store a Tier calculation Points Balance, but the SP can return the Current calculated points as well as the points needed for next level etc.

To Run



*/
Begin 
	Declare --@userid int=1406345, @Trxid int = 8286, 
	@trxTypeid int,@TierPointsNOW money, @Trxid_Check int, @UserLoyaltyDataID int, @UledID bigint, @Clientid int
	Declare @TierID int/*Current Tier for the user*/, @EndOfPeriod datetime, @ThresholdTo money, @QualifiedTierMultiplier money, @StartMonth datetime
	select @TierID=TierID from TierUsers where userid = @userid and Enabled = 1
	if @TierID is null
	Begin
	/*User is not in a Tier Yet, so put them in the smallest Tier */
		select @TierID=ID, @ThresholdTo=ThresholdTo,@EndOfPeriod = dateadd(second,-1,dateadd(Month,TierDuration,StartMonth)),@StartMonth = StartMonth,
		@QualifiedTierMultiplier=QualifiedTierMultiplier
		from TierAdmin ta where id in (
		select top 1 id from TierAdmin order by Thresholdfrom )

		INSERT INTO [dbo].[TierUsers]
		([TierId],[UserId],[StartOfPeriod],[EndOfPeriod],[Enabled],[ThresholdTo])
		select @TierID, @userid, GetDate(),@EndOfPeriod,1,@ThresholdTo
	End
	Else
	Begin
		select @ThresholdTo=ThresholdTo,@EndOfPeriod = dateadd(second,-1,dateadd(Month,TierDuration,StartMonth)),@StartMonth = StartMonth,
		@QualifiedTierMultiplier=QualifiedTierMultiplier
		from TierAdmin where id =@TierID
	End
	select @UserLoyaltyDataID = UserLoyaltyDataID, @Clientid = clientid from [User] u join Site s on s.siteid=u.siteid
	
	where UserId = @userid
	/*
	print 'ULED'
	print @UserLoyaltyDataID
	*/
	/*
	select @QualifiedTierMultiplier
	*/
	Declare @sqlTrxType nvarchar(max) , @ActivityCategoryId int, @GroupID int, @sqlWhere nvarchar(max), @SQLMain nvarchar(max)
	Declare TrxTypeCur CURSOR FAST_FORWARD FOR 
	/*Cursors are SLOW, but we are using them here just to get the SQL, it is NOT do with many itterations, just joining strings*/
	select tqi.TrxTypeId, tqi.ActivityCategoryId, tqi.GroupId from TierQualifierItems tqi join trxtype tt on tqi.TrxTypeId=tt.trxtypeid
	where tqi.tierid = @TierID

	set @sqlTrxType =''
	OPEN TrxTypeCur
	fetch next from TrxTypeCur into @TrxTypeID, @ActivityCategoryId, @GroupID
	While @@FETCH_STATUS = 0
	Begin
		if @sqlTrxType = ''
		begin
			set @sqlTrxType  =  @sqlTrxType + ' and ('
		end
		else
		begin
			set @sqlTrxType  =  @sqlTrxType + ' or '
		end 
		set @sqlTrxType  =  @sqlTrxType	+  ' (th.TrxTypeid = ' + convert(nvarchar(5),@TrxTypeID)
		if @ActivityCategoryId is not NULL 
		begin 
			set @sqlTrxType  =  @sqlTrxType	+ ' and Ac.Id= ' + convert(nvarchar(5),@ActivityCategoryId)
		end
		set @sqlTrxType  =  @sqlTrxType	+  ' ) '
		fetch next from TrxTypeCur into @TrxTypeID, @ActivityCategoryId, @GroupID
	End
	Close TrxTypeCur
	Deallocate TrxTypeCur
	if @sqlTrxType !=''
	begin
	set @sqlTrxType  =  @sqlTrxType	+  ' ) '
	end 

	--The Cirterias that are selected by the Tier and by the detail line.
	set @sqlWhere =' AND TrxDate between  ''' + convert(nvarchar(50),@StartMonth,21) + ''' and ''' 
	+ convert(nvarchar(50),@EndOfPeriod,21) + ''''
	/*
	select @sqlwhere
	select @sqlTrxType
	*/
	--The complex is the Trxtype (or detail lines for each in Activities and Grouping)

	--validity is YEARS.
	select @SQLMain = 'Insert into TrxpointsageEarned ([Version],[TrxID],[SiteID],[Channel],[Points],[PointsRemaining],[UserID], 
	[TrxDate],[ExpiryDate],[DateChangedLoaded])
	select 1 as Version, th.trxid,th.siteid,s.channel, sum(points) * ' 
	+ convert(nvarchar(10),@QualifiedTierMultiplier  ) +' , sum(points) * ' 
	+ convert(nvarchar(10),@QualifiedTierMultiplier  ) +',' + convert(nvarchar(10),@userid) +
	', + th.trxdate,'''+ convert(nvarchar(20),@EndOfPeriod) +''', GetDate() from trxheader th join trxdetail td on th.trxid=td.trxid join site s on s.siteid=th.siteid
	join device dv on dv.deviceid=th.deviceid 
	left join TrxDetailPromotion tdp on td.TrxDetailID=tdp.TrxDetailId
	left join promotion p on tdp.PromotionId=p.id
	left join ActivityCategoryType act on act.Id=p.ActivityCategoryTypeId 
	left join ActivityCategory ac on p.ActivityCategoryId=ac.Id
	where th.TrxId = ' + convert(nvarchar(20),@Trxid )
	+ @sqlTrxType + @sqlWhere + ' and ' + convert(nvarchar(20),@Trxid ) + ' not in (select trxid from trxpointsageearned) 
	group by th.trxid, th.siteid,s.channel, th.trxdate ' --+ @sqlHaving
	print @SQLmain
	exec  (@SQLMain)

	select @TierPointsNOW = sum(PointsRemaining), @Trxid_Check = Max(Trxid) from TrxPointsAgeEarned where UserID = @userid
	/*
	print @TierPointsNOW
	*/
	--if @Trxid_Check = @Trxid --Only move them IF a TRXID has been entered into the TrxPointsAgeEarned
	--Begin
		/*
		Create the ULED
		*/

	select @UledID = uled.id from UserLoyaltyExtensionData [uled] 
	where uled.UserLoyaltyDataId =@UserLoyaltyDataID and uled.propertyName = 'TierPoints'
	if @UledID is not null
	Begin
		update UserLoyaltyExtensionData set PropertyValue = convert(nvarchar(50),@TierPointsNOW) where id = @UledID
	End
	Else
	Begin
		INSERT into UserLoyaltyExtensionData ([Version],userloyaltyDataid,PropertyValue,PropertyName,[GroupId],[DisplayOrder],[Deleted])
		values( 1, @UserLoyaltyDataID, convert(nvarchar(50),@TierPointsNOW), 'TierPoints',1,1,0 );
	End
	/*
	Move the USER to a different tier if they qualify
	*/
	if @ThresholdTo < @TierPointsNOW --they need to move UP a tier!!!
	begin
		Print 'Move the User'
		Declare @NewProfileID int
		select @TierID=ID , @NewProfileID= [LoyaltyProfileId], @ThresholdTo=[ThresholdTo], 
		@EndOfPeriod= dateadd(second,-1,dateadd(Month,TierDuration,StartMonth))
		from TierAdmin
		where id = (
		select top 1 id from TierAdmin where thresholdfrom > @ThresholdTo order by ThresholdFrom)

		Update TierUsers set TierID = @TierID, EndOfPeriod= @EndOfPeriod, [Enabled]=1,ThresholdTo=@ThresholdTo
		where userid = @userid
		/*
		Update the DeviceProfile
		*/
		Update dp set DeviceProfileid = @NewProfileID  from deviceprofileTemplatetype dptt join DeviceProfileTemplate dpt on dptt.id=dpt.[DeviceProfileTemplateTypeId]
		join deviceprofile dp on dp.[DeviceProfileId]=dpt.Id
		join Device dv on dv.id=dp.deviceid
		where clientid = @clientid and dptt.name = 'Loyalty' and dv.userid = @userid
		--Move the user
	end
		/*
		Audit the change

		
		*/
--	end
End
