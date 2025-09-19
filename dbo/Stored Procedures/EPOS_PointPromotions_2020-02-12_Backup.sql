
-- =============================================
-- Author:		ANISH
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EPOS_PointPromotions_2020-02-12_Backup] 
	-- Add the parameters for the stored procedure here
	(@TrxId INT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



-- A procedure call to update homesite
-- One TIME operations, no relations with offers
exec EPOS_AllocateHomeSiteFirstPurchase @TrxId
exec [dbo].[EPOS_AnonymousPreviousTransactionsWithSameReference] @TrxId 




--Offer sections start here
DECLARE @MemberId INT
DECLARE @ClientId INT
SET @ClientId=(select clientid from client where name='baseline')
DECLARE @LoyaltyDevice VARCHAR(50)
DECLARE @SiteId INt
Declare @DeviceStatusActive INT
SET @DeviceStatusActive=(select devicestatusid from Devicestatus where name='Active' and clientid=(select clientid from client where name='baseline'))
select @LoyaltyDevice=deviceid,@SiteId=siteid from trxheader where trxid=@TrxId
SET @MemberId=(select userid from device where deviceid=@LoyaltyDevice)
 
 
 --store all item filters to #table

 select  TrxDetailId,Anal1,anal2,anal3,anal4,anal5,anal6,anal7,anal8,anal9,anal10,anal11,anal12,anal13,Points,LineNumber,@SiteId as SiteId,anal14,anal15,anal16,ItemCode,value
 into #itemcode
 from TrxDetail where trxid=@TrxId
 print 'promoitem'
 --itemcode to #table
 select * into #tempCode from
 (select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode1' and clientid=@ClientId) as TypeId,anal1 as Code,SiteId   from #itemcode where anal1 is not null
 union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode2' and clientid=@ClientId) as TypeId,anal2 as Code,SiteId   from #itemcode where anal2 is not null
 union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode3' and clientid=@ClientId) as TypeId,anal3 as Code,SiteId   from #itemcode where anal3 is not null
 union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode4' and clientid=@ClientId) as TypeId,anal4 as Code,SiteId   from #itemcode where anal4 is not null
 union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode5' and clientid=@ClientId) as TypeId,anal5 as Code,SiteId   from #itemcode where anal5 is not null
 union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode6' and clientid=@ClientId) as TypeId,anal6 as Code,SiteId   from #itemcode where anal6 is not null
 union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode7' and clientid=@ClientId) as TypeId,anal7 as Code,SiteId   from #itemcode where anal7 is not null
 union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode8' and clientid=@ClientId) as TypeId,anal8 as Code,SiteId   from #itemcode where anal8 is not null
 union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode9' and clientid=@ClientId) as TypeId,anal9 as Code,SiteId   from #itemcode where anal9 is not null
 union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode10' and clientid=@ClientId) as TypeId,anal10 as Code,SiteId   from #itemcode where anal10 is not null
 union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode11' and clientid=@ClientId) as TypeId,anal11 as Code,SiteId   from #itemcode where anal11 is not null
 union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode12' and clientid=@ClientId) as TypeId,anal12 as Code,SiteId   from #itemcode where anal12 is not null
 union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode13' and clientid=@ClientId) as TypeId,anal13 as Code,SiteId   from #itemcode where anal13 is not null
  union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode14' and clientid=@ClientId) as TypeId,anal14 as Code,SiteId   from #itemcode where anal14 is not null
  union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode15' and clientid=@ClientId) as TypeId,anal15 as Code,SiteId   from #itemcode where anal15 is not null
   union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='AnalysisCode16' and clientid=@ClientId) as TypeId,anal16 as Code,SiteId   from #itemcode where anal16 is not null
   union
 select TrxDetailId,Points,value,LineNumber,( select id from PromotionItemType where name='ItemCode' and clientid=@ClientId) as TypeId,itemcode as Code,SiteId   from #itemcode where itemcode is not null

 ) t

 
 -- This will give a felexibility of easy mapping

 -- Promotions
 select distinct convert(varchar(50), p.Id )as PromotionId,p.Name,tmp.LineNumber, tmp.TrxDetailID,tmp.Points,case(pop.Name) 
 when 'PointsMultiplier' then 
 
                      case isnull(OverrideBasePointRestriction,0) when 0 then tmp.Points*(p.PromotionOfferValue-1)
					  else tmp.Value*(p.PromotionOfferValue-1) end
 when 'Points' then p.PromotionOfferValue end as BonusPoints,
 pop.Name as OfferType,p.PromotionOfferValue, 0 as PriorityLevel,0 as Processed,'Promotion' as Offer
																				
																				into #Offer  
																				from Promotion p 
 inner join PromotionOfferType pop on p.PromotionOfferTypeId=pop.Id
 inner join PromotionItem pt on p.id=pt.PromotionId
 inner join PromotionSites ps on p.id=ps.PromotionId
 inner join #tempCode tmp on  pt.PromotionItemTypeId=tmp.TypeId
 where  RTRIM(LTRIM(pt.Code))= RTRIM(LTRIM(tmp.Code))
 and p.Id not in(select PromotionId from  VirtualPointPromotions where trxid=@Trxid and PromotionId>0) 
 and p.StartDate<=getdate() and p.EndDate>=getdate() and p.IsTemplate=0 and p.Enabled=1 and pop.Name in('PointsMultiplier','Points') 
 and tmp.SiteId in( select SiteId from GetChildSitesBySiteId(ps.siteid))
  and p.PromotionTypeId!=1

  




 --Vouchers
insert into  #Offer
 select distinct d.DeviceId as PromotionId,dpt.Name,tmp.LineNumber, tmp.TrxDetailID,tmp.Points,case(vsp.Name) when 'PointsMultiplier' then tmp.Points*(vdpt.OfferValue-1)
                                                                                when 'PointsFixed' then vdpt.OfferValue end as BonusPoints,vsp.Name as OfferType,vdpt.offervalue as PromotionOfferValue, 0 as PriorityLevel,0 as Processed,'Voucher' as Offer
																				
																				  from
																				  #tempCode tmp  inner join TrxVoucherDetail tv on tmp.TrxDetailID=tv.TrxDetailId
																				  inner join device d on tv.TrxVoucherId=d.DeviceId
																				 inner join DeviceProfile dp on d.id=dp.deviceid
																				 inner join deviceprofiletemplate dpt on  dp.DeviceProfileId=dpt.Id
																				 inner join VoucherDeviceProfileTemplate vdpt on dpt.id=vdpt.id
																				 inner join DeviceProfileTemplateSite vs on dpt.id=vs.deviceprofiletemplateid
																				 inner join [VoucherProfileItem] vt on dpt.id=vt.voucherprofileid
																				 inner join VoucherSubType vsp on vdpt.vouchersubtypeid=vsp.vouchersubtypeid
												
 where vt.voucherprofileitemtypeid=tmp.TypeId and  RTRIM(LTRIM(vt.Code))= RTRIM(LTRIM(tmp.Code)) and d.StartDate<=getdate() and d.EXpirationdate>=getdate()  and d.devicestatusid=@DeviceStatusActive and vsp.Name in('PointsMultiplier','PointsFixed') and tmp.SiteId in( select SiteId from GetChildSitesBySiteId(vs.siteid))
 and tv.TrxVoucherId not in(select voucherid from  VirtualPointPromotions where trxid=@Trxid)


  
  DECLARE @VoucherPId INT
  DECLARE @TRXDETAILID INT
  DECLARE @PromotionId varchar(50),@OfferTypeP varchar(50)
  Declare @trxCount INT
  Declare @itemcount int
  DECLARE @Offer varchar(50)
 if exists(select 1 from #Offer)
 begin
 DECLARE db_cursor CURSOR FOR  
 SELECT TrxDetailID, PromotionId,Offer
 FROM #Offer order by PriorityLevel desc
 OPEN db_cursor  
 FETCH NEXT FROM db_cursor INTO @TRXDETAILID,@PromotionId,@Offer  

WHILE @@FETCH_STATUS = 0  
BEGIN  
  
	 if(@Offer='Promotion')	 
	 begin
	 --logical and checking
	 if exists(select * from promotion where id=convert(int,@PromotionId) and PromotionItemFlagAnd=1)
	 begin
	 select PromotionItemTypeId,code,0 as processed 
	 into #filteritems from PromotionItem where promotionId=convert(int,@PromotionId)
	 
	 SET @itemcount=(select  count(distinct promotionitemtypeid) from #filteritems)

	

	 SET @trxCount=(select count(distinct t.TypeId) from #tempCode t inner join #filteritems f on t.TypeId=f.PromotionItemTypeId where t.Code=f.Code and t.TrxDetailID=@TRXDETAILID)

	 if(@trxCount<>@itemcount)
	 begin
	 delete from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
	 end
	  drop table #filteritems
	 end 	

	 --promotion segments filter
	 if exists(select 1 from PromotionSegments p join segmentadmin s on p.segmentid=s.segmentid where validto>=getdate() and PromotionId=convert(int,@PromotionId) )
	 begin
			   if not exists(select 1 from PromotionSegments ps join SegmentUsers s on ps.SegmentId=s.SegmentId where ps.PromotionId=convert(int,@PromotionId) and s.UserId=@MemberId)
			   begin
				delete from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
			   end
	 end

	 -- Promotion Usage Filter Per Member
			 Declare @PromotionLimitCount INT
			 SET @PromotionLimitCount=(select isnull(MaxUsagePerMember,0) from Promotion where Id =@PromotionId)
			 if(@PromotionLimitCount>0)
			 begin				 
				 Declare @UsedCount INT=0
				 SET @UsedCount=(select count(promotionid) from [PromotionRedemptionCount] where [MemberId]=@MemberId and  PromotionId=@PromotionId)
				 if (isnull(@UsedCount,0)>=@PromotionLimitCount)
				 begin
				 delete from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
				 end
				 
			 end	
			 
		--	  Max Trx Limit for Promotion
			Declare @maxTrxCountforPromtion INT
			Declare @PromotionUsageLimit INT
			Declare @trxStatus int;
			 SET @PromotionUsageLimit=(select isnull(PromotionUsageLimit,0) from Promotion where Id =@PromotionId)
			 if(@PromotionUsageLimit>0)
			 begin				 
				  Select @trxStatus= TrxStatusId  from TrxStatus where Name='Completed';
				--select total completed trx which hit the passed in promotion 
				with cte as (
					  select th.TrxId  as TotalTrxCount from  TrxDetailPromotion tp
						inner join trxdetail td on td.TrxDetailID = tp.TrxDetailId 
						inner join trxheader th on th.trxid= td.TrxId		
						 where tp.promotionid=@PromotionId and th.TrxStatusTypeId = @trxStatus
						 group by th.trxid
							)

				select @maxTrxCountforPromtion = count(TotalTrxCount) from cte 
					-- if trx count > promotionusage limit remove the trxdetails with that particular promotion  
				 if (@maxTrxCountforPromtion>= @PromotionUsageLimit)
				 begin
				 -- remove the promotion for the trxdetail temptable,so it will not be considered in bestoffer rule
				 delete from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
				 end
				 
			 end	
			 
	 end
	 
	 if(@Offer='Voucher')	 
	 begin --logical and checking
	 if exists(select 1 from device d inner join DeviceProfile dp on d.id=dp.DeviceId
	 inner join VoucherDeviceProfileTemplate vdp on dp.DeviceProfileId=vdp.id where d.deviceid=@PromotionId and vdp.logicaland=1)
	 begin
	
	 SET @VoucherPId=(select dp.DeviceProfileId from device d inner join DeviceProfile dp on d.id=dp.DeviceId where d.DeviceId=@PromotionId)
	
	 insert into #filteritems  select voucherprofileitemtypeid ,code,0 as processed  from [VoucherProfileItem] where VoucherProfileId=@VoucherPId
	 
	 SET @itemcount=(select  count(distinct voucherprofileitemtypeid) from #filteritems)

	

	 SET @trxCount=(select count(distinct t.TypeId) from #tempCode t inner join #filteritems f on t.TypeId=f.voucherprofileitemtypeid where t.Code=f.Code and t.TrxDetailID=@TRXDETAILID)

	 if(@trxCount<>@itemcount)
	 begin
	 delete from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
	 end
	  drop table #filteritems
	 end 	
	 
	 
	 --voucher segments filter
	 if exists(
     select 1 from VoucherSegments v join segmentadmin s on v.segmentid=s.segmentid  where validto>=getdate() and VoucherId=(select dp.DeviceProfileId from device d inner join DeviceProfile dp on d.id=dp.DeviceId where d.deviceid=@PromotionId))
	 begin
			   if not exists(select 1 from VoucherSegments ps join SegmentUsers s on ps.SegmentId=s.SegmentId where ps.VoucherId=(select dp.DeviceProfileId from device d inner join DeviceProfile dp on d.id=dp.DeviceId where d.deviceid=@PromotionId) and s.UserId=@MemberId)
			   begin
				delete from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
			   end
	 end
	 
	 end

	 FETCH NEXT FROM db_cursor INTO @TRXDETAILID,@PromotionId,@Offer  

	 
END  

CLOSE db_cursor  
DEALLOCATE db_cursor 
end




print 'Best Offer Ordering'
--select * from #Offer
  update #Offer set PriorityLevel=100001 where OfferType='PointsMultiplier' and PromotionOfferValue=0 and Offer='Promotion' --1
  update #Offer set PriorityLevel=99999 where OfferType='PointsMultiplier' and PromotionOfferValue=1 and Offer='Promotion' --3
  update #Offer set PriorityLevel=100000 where OfferType='PointsMultiplier' and PromotionOfferValue=0 and Offer='Voucher' --2
  update #Offer set PriorityLevel=99998 where OfferType='PointsMultiplier' and PromotionOfferValue=1 and Offer='Voucher' --4

  update #Offer set PriorityLevel=BonusPoints+2 where OfferType='PointsMultiplier' and PromotionOfferValue not in(0,1) and Offer='Promotion'
  update #Offer set PriorityLevel=BonusPoints+2 where OfferType='Points' and Offer='Promotion'
  update #Offer set PriorityLevel=BonusPoints+1 where OfferType='PointsMultiplier' and PromotionOfferValue not in(0,1) and Offer='Voucher'
  update #Offer set PriorityLevel=BonusPoints+1 where OfferType='Points' and Offer='Voucher'
 
--  select * from #Offer
--print 3000
declare @ovdpoints decimal(18,2)=0
 if exists(select 1 from #Offer)
 begin

 DECLARE db_cursor CURSOR FOR  
 SELECT TrxDetailID,PromotionId,Offer,OfferType
 FROM #Offer order by PriorityLevel desc

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @TRXDETAILID,@PromotionId,@Offer ,@OfferTypeP 

WHILE @@FETCH_STATUS = 0  
BEGIN  
     if(@Offer='Promotion')
	 begin

	 if exists(select 1 from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId and Processed=0)
	 begin
	 if not exists( select 1 from VirtualPointPromotions vp join trxdetail td on vp.trxid=td.trxid where td.trxdetailid=@TRXDETAILID and td.linenumber=vp.LineNumber)
	 BEGIN
	 if exists(select 1 from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId)
	 begin

	 if exists(select 1 from promotion where id=@PromotionId and isnull(OverrideBasePointRestriction,0)=1)
	 begin
	 select @ovdpoints=@ovdpoints+TrxDetail.value-isnull(TrxDetail.points,0) from #Offer t join TrxDetail on TrxDetail.TrxDetailID=t.TrxDetailID where TrxDetail.TrxDetailID=t.TrxDetailID and t.PromotionId=@PromotionId and TrxDetail.TrxDetailID=@TRXDETAILID 
	 
	 update TrxDetail  set Points=case @OfferTypeP when 'Points' then value * Quantity else value end from #Offer t where TrxDetail.TrxDetailID=t.TrxDetailID and t.PromotionId=@PromotionId and TrxDetail.TrxDetailID=@TRXDETAILID
   	 update #Offer set Points=case @OfferTypeP when 'Points' then value * Quantity else value end from TrxDetail where TrxDetail.TrxDetailID=#Offer.TrxDetailID and #Offer.PromotionId=@PromotionId and TrxDetail.TrxDetailID=@TRXDETAILID
	 end
	 
	  
	 update TrxDetail  set Points=TrxDetail.Points+t.BonusPoints,BonusPoints=TrxDetail.BonusPoints+t.BonusPoints from #Offer t where TrxDetail.TrxDetailID=t.TrxDetailID and t.PromotionId=@PromotionId and TrxDetail.TrxDetailID=@TRXDETAILID
     end 

	 update #Offer set processed=1 where TrxDetailID=@TRXDETAILID
	 update #Offer set processed=2 where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
	 END
    end
	end

	 if(@Offer='Voucher')
	 begin
	
	 if exists(select 1 from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId and Processed=0)
	 begin
	  if not exists( select 1 from VirtualPointPromotions vp join trxdetail td on vp.trxid=td.trxid where td.trxdetailid=@TRXDETAILID and td.linenumber=vp.LineNumber)
	BEGIN
	 if exists(select 1 from #Offer where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId)
	 begin
	 update TrxDetail  set Points=TrxDetail.Points+t.BonusPoints,BonusPoints=TrxDetail.BonusPoints+t.BonusPoints 
	 from #Offer t inner join TrxVoucherDetail tv on t.TrxDetailID=tv.TrxDetailId 
	 where TrxDetail.TrxDetailID=t.TrxDetailID  and TrxDetail.TrxDetailID=@TRXDETAILID and t.PromotionId=@PromotionId
     end 

	 update #Offer set processed=1 where TrxDetailID=@TRXDETAILID
	 update #Offer set processed=2 where TrxDetailID=@TRXDETAILID and PromotionId=@PromotionId
	 END
    end
	end
	   FETCH NEXT FROM db_cursor INTO @TRXDETAILID,@PromotionId,@Offer ,@OfferTypeP 
END  

CLOSE db_cursor  
DEALLOCATE db_cursor 

Declare @DeviceId VARCHAR(50)
DECLARE @TotalBonusPoints Decimal(18,2)=0
 if exists(select 1 from #Offer where processed=2 )
 begin

  if exists(select 1 from #Offer where processed=2 and Offer='Promotion')
 begin
insert into TrxDetailPromotion
select 1,PromotionId,TrxDetailId,BonusPoints from  #Offer where processed=2 and Offer='Promotion'
end

 if exists(select 1 from #Offer where processed=2 and Offer='Voucher')
begin

update TrxVoucherDetail set VoucherAmount=f.BonusPoints from #Offer f where TrxVoucherDetail.trxdetailid=f.trxdetailid and TrxVoucherDetail.TrxVoucherId=f.PromotionId and Offer='Voucher'
end

if exists(select 1 from #Offer where processed=2 )
begin
SET @TotalBonusPoints=(select sum(bonuspoints) from #Offer where processed=2)
end
end
end

SET @DeviceId=(select deviceid from TrxHeader where trxid=@TrxId)
if exists(select 1 from trxdetail td 
	join VirtualPointPromotions v on td.LineNumber=v.linenumber 
	inner join trxvoucherdetail tv on td.trxdetailid=tv.trxdetailid where v.trxid=@TrxId and td.trxid=@Trxid and VoucherId is not null and tv.trxvoucherid!='')
begin

	select td.trxdetailid,v.promotionvalue,v.voucherid,v.linenumber into #pointvouchers from trxdetail td 
	join VirtualPointPromotions v on td.LineNumber=v.linenumber 
	inner join trxvoucherdetail tv on td.trxdetailid=tv.trxdetailid where v.trxid=@TrxId and td.trxid=@Trxid	
	update TrxDetail set BonusPoints=isnull(BonusPoints,0)+isnull(v.promotionvalue,0),Points=isnull(Points,0)+isnull(v.promotionvalue,0) from #pointvouchers v where trxdetail.TrxDetailID=v.TrxDetailID and trxdetail.trxid=@TrxId
	update TrxVoucherDetail set VoucherAmount=isnull(VoucherAmount,0)+isnull(v.promotionvalue,0) from  #pointvouchers v where TrxVoucherDetail.TrxDetailID=v.TrxDetailID 
	set @TotalBonusPoints=isnull(@TotalBonusPoints,0)+(select isnull(sum(promotionvalue),0) from #pointvouchers)

	print @TotalBonusPoints
end

if exists(select 1 from VirtualPointPromotions where trxid=@TrxId and PromotionId>0)
begin
	select td.trxdetailid,v.promotionvalue,v.PromotionId,v.linenumber,isnull(p.OverrideBasePointRestriction,0) OverrideBasePointRestriction
	into #pointpromotions from trxdetail td 
	join VirtualPointPromotions v on td.LineNumber=v.linenumber 
	join Promotion p on v.PromotionId=p.Id
	where v.trxid=@TrxId and td.trxid=@Trxid and v.PromotionId>0
	Declare @OverridePoints decimal(18,2)
	select @OverridePoints=sum(value)-sum(points) from TrxDetail join  #pointpromotions v on trxdetail.TrxDetailID=v.TrxDetailID where OverrideBasePointRestriction=1
	update TrxDetail set Points=Value from #pointpromotions v where trxdetail.TrxDetailID=v.TrxDetailID and OverrideBasePointRestriction=1
		
	update TrxDetail 
	set BonusPoints=isnull(BonusPoints,0)+isnull(v.promotionvalue,0),Points=isnull(Points,0)+isnull(v.promotionvalue,0) 
	from #pointpromotions v where trxdetail.TrxDetailID=v.TrxDetailID 
	and trxdetail.trxid=@TrxId
	
	
	insert into TrxDetailPromotion
    select 1,PromotionId,TrxDetailId,isnull(promotionvalue,0) from #pointpromotions

	set @TotalBonusPoints=isnull(@TotalBonusPoints,0)+(select sum(promotionvalue) from #pointpromotions)
end

update trxheader set [AccountPointsBalance]=isnull([AccountPointsBalance],0)+(isnull(@TotalBonusPoints,0)) where trxid=@TrxId
update account set PointsBalance=isnull(PointsBalance,0)+(isnull(@TotalBonusPoints,0)) where accountid=(select accountid from device where deviceid=@DeviceId)
update account set PointsBalance=isnull(PointsBalance,0)+(isnull(@OverridePoints,0)) where accountid=(select accountid from device where deviceid=@DeviceId)
update account set PointsBalance=isnull(PointsBalance,0)+(isnull(@ovdpoints,0)) where accountid=(select accountid from device where deviceid=@DeviceId)



    Declare @UserId INT
	SET @Userid=(select userid from device where deviceid=@LoyaltyDevice)

	if exists(select 1 from memberlink m inner join 
	memberlinktype mt on m.linktype=mt.MemberLinkTypeId where name='Community' and MemberId2=@Userid and CommunityId is not null)
	begin
	
	exec EPOS_ShadowPointTransfer @Userid,@LoyaltyDevice,@TrxId	
	end



Declare @DeviceStatusBlocked INT
SET @DeviceStatusBlocked=(select devicestatusid from Devicestatus where name='Inactive' and clientid=(select clientid from client where name='baseline'))
Declare @Maxusage INT=0
Declare @VoucherId varchar(50)
DECLARE db_cursor CURSOR FOR  
select trxdetailid from Trxdetail where trxid=@TrxId

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @TRXDETAILID  

WHILE @@FETCH_STATUS = 0  
BEGIN  
             --Maximum Voucher usage check and insertion
			   SET @VoucherId=(select top 1 TrxVoucherId from TrxVoucherDetail where TrxDetailid=@TRXDETAILID order by VoucherAmount desc)
			   delete from TrxVoucherDetail where TrxVoucherId <> @VoucherId and TrxDetailId=@TRXDETAILID 

			SET @Maxusage=(select top 1 isnull(MaximumUsage,0) from  
			device d join deviceprofile dp on d.id=dp.deviceid 
			join deviceprofiletemplate dpt on dp.deviceprofileid=dpt.id 
			join deviceprofiletemplatetype dpty on dpt.deviceprofiletemplatetypeId=dpty.id
			join voucherdeviceprofiletemplate vdp on dpt.id=vdp.id where dpty.name='Voucher' and d.DeviceId=@VoucherId and vdp.ClassicalVoucher=1)
			if(@Maxusage>0)
			begin
			if not exists(select 1 from [ClassicalVoucherRedemptionCount] where trxid=@Trxid and MemberId=@Userid and VoucherId=@VoucherId)
					  begin
					  INSERT INTO [dbo].[ClassicalVoucherRedemptionCount]
					   ([MemberId]
					   ,[VoucherId]
					   ,[LastRedemptionDate]           
					   ,[TrxId])
					   select @Userid,@VoucherId,getdate(),@Trxid
					   end
			end
			else
			begin
			if not exists(select 1 from  
			device d join deviceprofile dp on d.id=dp.deviceid 
			join deviceprofiletemplate dpt on dp.deviceprofileid=dpt.id 
			join deviceprofiletemplatetype dpty on dpt.deviceprofiletemplatetypeId=dpty.id
			join voucherdeviceprofiletemplate vdp on dpt.id=vdp.id where dpty.name='Voucher' and d.DeviceId=@VoucherId and vdp.ClassicalVoucher=1)
			begin
			update device set devicestatusid=@DeviceStatusBlocked where deviceid=@VoucherId
			end
			end
			           
			           select * into #usedpromotion from 
					   (select distinct p.id from TrxDetailPromotion tp join Promotion p on tp.promotionid=p.id where trxdetailid=@TRXDETAILID
					   union 
					   select p.id from TrxUsedPromotions tp join Promotion p on tp.PromotionName=p.Name where trxdetailid=@TRXDETAILID) up

					   INSERT INTO [dbo].[PromotionRedemptionCount]
					   ([MemberId]
					   ,[PromotionId]
					   ,[LastRedemptionDate]           
					   ,[TrxId])
					   select @Userid,p.Id,getdate(),@Trxid from #usedpromotion p  where not exists(select 1 from [PromotionRedemptionCount] where promotionid=p.Id and trxid=@Trxid)
			           drop table #usedpromotion
		

   FETCH NEXT FROM db_cursor INTO @TRXDETAILID  
END  

select BonusPoints,LineNumber,convert(varchar(50),PromotionId) collate database_default as PromotionId ,Name ,Points+BonusPoints as TotalPoints,@TotalBonusPoints as TotalBonusPoints from #Offer where processed  = 2 
union
select promotionvalue as BonusPoints,td.LineNumber,voucherid as PromotionId,dpt.Name as Name,td.Points as TotalPoints,@TotalBonusPoints as TotalBonusPoints from VirtualPointPromotions v
join trxdetail td on v.linenumber=td.linenumber
inner join trxvoucherdetail tv on td.trxdetailid=tv.trxdetailid
inner join device d on tv.TrxVoucherId=d.DeviceId
inner join DeviceProfile dp on d.id=dp.DeviceId
inner join DeviceProfileTemplate dpt on dp.DeviceProfileId=dpt.Id where v.trxid=@TrxId and td.trxid=@TrxId

union
select distinct promotionvalue as BonusPoints,td.LineNumber,convert(varchar(50),p.id) as PromotionId,p.Name as Name,td.Points as TotalPoints,@TotalBonusPoints as TotalBonusPoints from VirtualPointPromotions v
join trxdetail td on v.linenumber=td.linenumber
inner join TrxDetailPromotion tv on td.trxdetailid=tv.trxdetailid
inner join Promotion p on tv.PromotionId=p.Id
where v.trxid=@TrxId and td.trxid=@TrxId




	END
