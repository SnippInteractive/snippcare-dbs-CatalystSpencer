CREATE FUNCTION GetProductFamilyTypes
(
    @clientid int,
	@productFamilyTypes nvarchar(max),
	@productFamilySubTypes nvarchar(max)
)
returns @tblProductFamily table 
(
	PromotionId int, 
	ProductFamilyName nvarchar(200),
	ProductFamilySubType nvarchar(200)
)
as
begin
--select * from GetProductFamilyTypes(12,'Brand,pettype','Catit|Cat Love,Cat')
--select * from GetProductFamilyTypes(12,'Brand','Catit|Cat Love,Cat')
--select * from GetProductFamilyTypes(12,'Brand','Catit')
--select * from GetProductFamilyTypes(12,'pettype','Catit,Cat|dog')
--select * from GetProductFamilyTypes(12,'pettype','Cat')
--declare @productFamilyTypes varchar(max)
--declare @productFamilySubTypes varchar(max)
declare @productFamilyTypeCount int
declare @productFamilySubTypeCount int
--declare @clientid int
--set @productFamilyTypes = 'Brand,pettype'
--set @productFamilySubTypes = 'Catit|Cat Love|Hari|Living World|Living World Green|Nutrience|Zoe,Dog|Cat|Hamster|Rabbit|Bird|GuineaPig|OtherSmallAnimal'
--set @clientid=12
declare @hashproductfamilyType table(Id int,Version int, Name nvarchar(200), ClientId int,Display bit)
declare @hashproductFamilySubType1 table(value nvarchar(max))
declare @hashtempfamilyType table(Id int,Version int, Name nvarchar(200), ClientId int,Display bit)
declare @hashtempsubfamilyType table(value nvarchar(max))
--Drop table if exists #productfamilyType
--Drop table if exists #productFamilySubType1
--Drop table if exists #tempfamilyType
--Drop table if exists #tempsubfamilyType
insert into @hashproductfamilyType(Id,Version,Name, ClientId,Display)
select * from ProductfamilyType where 
name in(Select trim(value) From string_split(@productFamilyTypes, ',')) and clientid=@clientid
declare @productFamilySubType table(Id int,Version int, Name nvarchar(200), 
ProductFamilyTypeId int,ClientId int,Display bit)
insert into @hashproductFamilySubType1(value)
Select value From string_split(@productFamilySubTypes, ',')
insert into @hashtempsubfamilyType(value)
select * from @hashproductFamilySubType1
declare @productFamilySubType1Count int
select @productFamilySubType1Count=count(*) from @hashproductFamilySubType1
while (@productFamilySubType1Count>0)
begin
declare @productFamilySubTypes1 varchar(max)
select top 1 @productFamilySubTypes1=value from @hashproductFamilySubType1
insert into @productFamilySubType(Id,[Version],Name,ProductFamilyTypeId,ClientId,Display)
select * from ProductFamilySubType 
where name in(Select trim(value) From string_split(@productFamilySubTypes1, '|'))
and clientid=@clientid
delete from @hashproductFamilySubType1 where value=@productFamilySubTypes1
set @productFamilySubType1Count=@productFamilySubType1Count-1
end
insert into @hashtempfamilyType(Id,Version,Name, ClientId,Display)
select * from @hashproductfamilyType
select @productFamilyTypeCount=count(*) from @hashproductfamilyType
declare @familyTypeId int
declare @Num int
set @Num=0
declare @tmpFamily table(pName varchar(50),Promotionid int, Num int)
while (@productFamilyTypeCount>0)
begin
select top 1 @familyTypeId=Id from @hashproductfamilyType
insert into @tmpFamily(pName,Promotionid,Num)
select pfst.name,ppf.promotionid,@Num from @productFamilySubType pfst
join PromotionProductFamilies ppf on pfst.id = ppf.ProductFamilySubTypeId
where ProductFamilyTypeId=@familyTypeId
delete from @hashproductfamilyType where Id=@familyTypeId
set @productFamilyTypeCount=@productFamilyTypeCount-1
set @Num=@Num+1
end
select @productFamilyTypeCount=count(*) from @hashtempfamilyType
declare @productSubFamilyTypeCount int
select @productSubFamilyTypeCount=count(*) from @hashtempsubfamilyType
if(@productFamilyTypeCount>1 and @productSubFamilyTypeCount>1)
begin
    insert into @tblProductFamily(PromotionId,ProductFamilyName,ProductFamilySubType)
	select distinct c.promotionid as Promotionid,c.pName as ProductFamilyName, t.pName as ProductFamilySubType 
	from @tmpFamily c inner join  @tmpFamily t on c.promotionid=t.promotionid 
	where c.pName<>t.pName and c.Num=0
end
else
begin
   insert into @tblProductFamily(PromotionId,ProductFamilyName,ProductFamilySubType)
	select distinct p.Id PromotionId, pft.Name ProductFamilyName, pfst.Name ProductFamilySubType
	from promotion p
	join PromotionProductFamilies ppf on p.id = ppf.promotionid
	join ProductFamilySubType pfst on pfst.id = ppf.ProductFamilySubTypeId
	join ProductFamilyType pft on pft.id = pfst.productfamilytypeid
	where pft.Name  in (Select name from @hashtempfamilyType) and
	pfst.Name in (Select Name from @productFamilySubType)
end
----------------
--select * from @productFamilySubType
--select * from @hashproductfamilyType
--select * from @hashproductFamilySubType1
--select * from @hashtempfamilyType
 --select * from @tmpFamily
 return
 end