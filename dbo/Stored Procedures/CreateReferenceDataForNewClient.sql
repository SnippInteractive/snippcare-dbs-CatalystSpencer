CREATE PROCEDURE [dbo].[CreateReferenceDataForNewClient](@newClientId int, @existingClientId int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Get all Reference type Tables with column name Display,Version,Name  from existing database 
		select  so.name as TableName into #tempReferenceData
			from sysobjects so 
			where so.type = 'U' -- it's a user's table
			and exists (select * from syscolumns sc where sc.id = so.id and sc.name='Display')
			and exists (select * from syscolumns sc where sc.id = so.id and sc.name='Version')
			and exists (select * from syscolumns sc where sc.id = so.id and sc.name='Name')
			-- seperate script exist for these tables in not in list,as table format not consistent with other reference type tables 
			and so.name not in ('Country','CatalystMail_Widget','Language','Nationality','Site','Currency','County',
			'NotificationTemplate','PromotionCategory','PromotionMemberProfileItemType','PromotionCriteria','State','ProductFamilySubType')
			order by so.name asc
			--drop table  #tempReferenceData
			--select * from #tempReferenceData
	Declare @tableName nvarchar(100)='';
	DECLARE db_cursor CURSOR FOR 
	Select  TableName from #tempReferenceData
	   OPEN db_cursor 
	   FETCH NEXT FROM db_cursor INTO @tableName
	   WHILE @@FETCH_STATUS = 0
		BEGIN

		
			Declare @sqlQuery nvarchar(1000)='';
			Declare @sqlTranslationQry nvarchar(500);
			
			--skip Country ,CatalystMail_Widget ,Language,Nationality,Site,Tier table
			--INSERT REFERENCE DATA FOR NEW CLIENT
			set @sqlQuery= 'insert into '+@tableName+' (Version,Name,ClientId,Display) 
							 select Version,Name,'+cast(@newClientId as nvarchar(2))+',Display from '+@tableName+' where 
							 ClientId='+cast(@existingClientId as nvarchar(2))
			exec (@sqlQuery);
			--DELETE TRANSLATION for table AND IMPORT AGAIN
			DELETE from Translations where TranslationGroup=@tableName and ClientId=@newClientId
			INSERT INTO [dbo].[Translations]
           ([Version]
           ,[ClientId]
           ,[TranslationGroup]
           ,[LanguageCode]
           ,[Value]
           ,[TranslationGroupKey]
           ,[UserEdited]) Select 
           [Version]
           ,@newClientId
           ,[TranslationGroup]
           ,[LanguageCode]
           ,[Value]
           ,[TranslationGroupKey]
           ,[UserEdited] FROM Translations where ClientId=@existingClientId and TranslationGroup=@tableName
			print @sqlQuery;
			print @tableName + 'done'
			FETCH NEXT FROM db_cursor INTO @tableName
		END
END
