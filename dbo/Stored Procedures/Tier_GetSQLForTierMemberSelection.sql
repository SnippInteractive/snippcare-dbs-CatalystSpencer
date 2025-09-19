CREATE Procedure [dbo].[Tier_GetSQLForTierMemberSelection] @ClientID Int as 
Begin
      IF OBJECT_ID('SSISHelper.[_TierTempForDedupe]', 'U') IS NOT NULL   DROP TABLE SSISHelper.[_TierTempForDedupe]; 
      Create table SSISHelper.[_TierTempForDedupe] (ID [Int] Identity(1,1), [UserId] [int] NULL,TierID [int] NULL,Priority [bit] NULL)
      
      declare @TierID int /* for each active Tier */, @Description nvarchar(100), @ThresholdToOverAll money, @ThresholdFromOverAll money, @Rn int
      Declare ActiveTiersSorted CURSOR FAST_FORWARD FOR
      select id,Description, ThresholdTo,ThresholdFrom, 
            row_number() Over (order by ThresholdTo desc) Rn /*The RN is used to Prioritise the Tiers*/
            from tieradmin ta join tiertype tt on tt.TierTypeId=ta.TierTypeId 
            where startmonth < getdate() and dateadd(month, tierduration,startmonth) >= getdate()
            and tt.ClientId =@clientid
            order by ThresholdFrom desc
      
      OPEN ActiveTiersSorted
      FETCH NEXT FROM ActiveTiersSorted INTO @TierID,@Description, @ThresholdToOverAll,@ThresholdFromOverAll,@Rn
      WHILE @@FETCH_STATUS = 0
      BEGIN
            Declare @SQLMain nvarchar(max)
            declare @sqlWhere nvarchar(200), @StartMonth datetime, @TierDuration int, @deviceprofiletemplateid int, @TierType nvarchar(15), 
            @TierLink nvarchar(10), @sqlHaving nvarchar(200),@ThresholdFrom money, @ThresholdTo Money
            Declare @TrxTypeID int , @ActivityCategoryId int , @GroupID int, @sqlTrxType  nvarchar(500)
      
            select @TierDuration =isnull(ta.TierDuration,2000) ,@StartMonth= isnull(ta.StartMonth,'1980-01-01'), @deviceprofiletemplateid = ta.LoyaltyProfileId, 
            @ThresholdFrom = ta.ThresholdFrom, @ThresholdTo = ta.ThresholdTo, @TierType = tlt.Name
            from tieradmin ta join tiertype tt on ta.TierTypeId=tt.TierTypeId
            join TierLinkType tlt on tlt.TierLinkTypeId=ta.TierLinkTypeId
            /*as the Criterias are complex, we have taken out the simple WHERE and added the loop below for all criteria */
            --join TierQualifierItems tqi on tqi.TierId=ta.Id
            --join trxtype txt on txt.TrxTypeId=tqi.TrxTypeId
            where ta.id=@TierID 
            Declare TrxTypeCur CURSOR FAST_FORWARD FOR --A Cursor Again!!
            /*Cursors are SLOW, but we are using them here just to get the SQL, it is NOT do with many itterations, just joining strings*/
            select tqi.TrxTypeId, tqi.ActivityCategoryId, tqi.GroupId from TierQualifierItems tqi --join trxtype tt on tqi.TrxTypeId=tt.trxtypeid
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
                  set @sqlTrxType  =  @sqlTrxType     +  ' (th.TrxTypeid = ' + convert(nvarchar(5),@TrxTypeID)
                  if @ActivityCategoryId is not NULL 
                  begin 
                        set @sqlTrxType  =  @sqlTrxType     + ' and Ac.Id= ' + convert(nvarchar(5),@ActivityCategoryId)
                  end
                  set @sqlTrxType  =  @sqlTrxType     +  ' ) '
                  fetch next from TrxTypeCur into @TrxTypeID, @ActivityCategoryId, @GroupID
            End
            Close TrxTypeCur
            Deallocate TrxTypeCur
            if @sqlTrxType !=''
            begin
            set @sqlTrxType  =  @sqlTrxType     +  ' ) '
            end 
            --select @sqlTrxType
            --The Cirterias that are selected by the Tier and by the detail line.
            set @sqlWhere =' AND TrxDate between  ''' + convert(nvarchar(50),@StartMonth,21) + ''' and ''' 
            + convert(nvarchar(50),dateadd(second,-1,dateadd(month,@TierDuration,@StartMonth)),21) + ''''
            --select @sqlWhere 
            set @sqlHaving = case @TierType when 'Points' then 'Points' else 'Value' end 
            set @sqlHaving = 'Having sum(td.[' + @sqlHaving +']) between ' + convert(nvarchar(10), @ThresholdFrom) + ' and ' + convert(nvarchar(10), @ThresholdTo) + ''
            --The complex is the Trxtype (or detail lines for each in Activities and Grouping)
            --select @sqlHaving

            --validity is YEARS.
      --Took this out!!!/*join deviceprofile dp on dp.deviceid=dv.id*/
            select @SQLMain = 'insert into SSISHelper.[_TierTempForDedupe] ([UserId] ,TierID ,Priority)
            select dv.userid, ' + convert(nvarchar(4),@TierID) + ' as TierID, ' + convert(nvarchar(4),@Rn) + ' as Priority from trxheader th join trxdetail td on th.trxid=td.trxid 
            join device dv on dv.deviceid=th.deviceid 
            left join TrxDetailPromotion tdp on td.TrxDetailID=tdp.TrxDetailId
            left join promotion p on tdp.PromotionId=p.id
            left join ActivityCategoryType act on act.Id=p.ActivityCategoryTypeId 
            left join ActivityCategory ac on p.ActivityCategoryId=ac.Id
            where dv.userid is not null ' + @sqlTrxType + @sqlWhere + ' group by dv.userid ' + @sqlHaving
            print @SQLmain
            exec  (@SQLMain)
       



      


            --select * from DeviceProfileTemplate


      /*
            select ta.id,tt.name TierType,tlt.Name TierLinkType, ta.TierDuration, ta.StartMonth , txt.name TrxType,
            txt.TrxTypeId,dpt.Name ProfileTemplate,dpt.id,
            ta.* from tieradmin ta join tiertype tt on ta.TierTypeId=tt.TierTypeId
            join TierLinkType tlt on tlt.TierLinkTypeId=ta.TierLinkTypeId
            join TierQualifierItems tqi on tqi.TierId=ta.Id
            join trxtype txt on txt.TrxTypeId=tqi.TrxTypeId
            join DeviceProfileTemplate dpt on ta.LoyaltyProfileId=dpt.Id
            where ta.id=1 --ta.id=@TierID 
            --order by groupid*/

            

            FETCH NEXT FROM ActiveTiersSorted INTO @TierID,@Description, @ThresholdToOverAll,@ThresholdFromOverAll,@Rn
      END
      
      CLOSE ActiveTiersSorted
      DEALLOCATE ActiveTiersSorted

      delete from SSISHelper.[_TierTempForDedupe] where id in(
      select tt.id from SSISHelper.[_TierTempForDedupe] tt join Tieradmin t on tt.tierid=t.id
      join TierUsers tu on tu.userid=tt.userid and tu.Enabled=1 and t.ThresholdTo >= tu.ThresholdTo)
      insert into  TierUsers (TierID, UserID,StartOfPeriod,EndOfPeriod, [Enabled],ThresholdTo)
      select TierID, UserID,StartMonth,convert(nvarchar(50),dateadd(second,-1,dateadd(month,TierDuration,StartMonth)),21), 1 as [Enabled],ThresholdTo from SSISHelper.[_TierTempForDedupe] tt join Tieradmin t on tt.tierid=t.id
      
      select * from TierUsers
--    truncate table TierUsers
      --IF OBJECT_ID('SSISHelper.[_TierTempForDedupe]', 'U') IS NOT NULL   DROP TABLE SSISHelper.[_TierTempForDedupe]; 

END
