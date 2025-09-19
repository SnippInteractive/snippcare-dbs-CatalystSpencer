CREATE Procedure [dbo].[SaveWidgitFieldsConfiguration] 
(
@WidgitsStringData VARCHAR(MAX),
@PublishStatus INT,--1:Save 2:Preview 3:Save&Publish
@WidgitName VARCHAR(100),
@ClientId int
) 
as

BEGIN 
	
	--Update [Widgit] set DisplayStatus = 1 where widgitId = 3472

	DECLARE @xml XML
	DECLARE @WidgitId INT
	DECLARE @ValidationItemsComaSeperated VARCHAR(100)
	DECLARE @IsDisplay BIT

	DECLARE @widgitsTable TABLE ([WidgitId] INT,[IsDisplay] BIT,[ValidationItems] VARCHAR(100))
	SET @xml = @WidgitsStringData
	INSERT @widgitsTable ([WidgitId],[IsDisplay],[ValidationItems])
	SELECT T.a.value('(WidgitId)[1]','int')as [WidgitId],T.a.value('(IsDisplay)[1]','bit')as [IsDisplay],T.a.value('(ValidationItems)[1]','VARCHAR(100)')as [ValidationItems]
	FROM @xml.nodes('/ArrayOfWidgitData/WidgitData') T(a)


	DECLARE widgit_cursor CURSOR FOR     
	SELECT WidgitId,ValidationItems,IsDisplay    
	FROM @widgitsTable    
  
	OPEN widgit_cursor    
  
	FETCH NEXT FROM widgit_cursor     
	INTO @WidgitId,@ValidationItemsComaSeperated,@IsDisplay    
       
  
	WHILE @@FETCH_STATUS = 0    
	BEGIN    
		--print '   ' + CAST(@WidgitId as varchar(10)) +'           '+  cast(@ValidationItemsComaSeperated as varchar(100)) +'  ' + cast(@IsDisplay as varchar(100))
  
		UPDATE [Widgit] SET DisplayStatus = @IsDisplay  WHERE WidgitId= @WidgitId

		IF CHARINDEX('Required',@ValidationItemsComaSeperated) > 0
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM [dbo].[WidgitMetaData] WHERE WidgitId= @WidgitId AND [Key] = 'data-val-required')
			BEGIN
				INSERT INTO [dbo].[WidgitMetaData] (WidgitId, Version, [Key], Value) VALUES (@WidgitId, 0, 'data-val-required', 'Required');
			END
		END
		ELSE
		BEGIN
			DELETE FROM [dbo].[WidgitMetaData] WHERE WidgitId = @WidgitId AND [Key] = 'data-val-required'
		END

		IF CHARINDEX('Email',@ValidationItemsComaSeperated) > 0
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM [dbo].[WidgitMetaData] WHERE WidgitId= @WidgitId AND [Key] = 'data-val-email')
			BEGIN
				INSERT INTO [dbo].[WidgitMetaData] (WidgitId, Version, [Key], Value) VALUES (@WidgitId, 0, 'data-val-email', 'Invalid email');
			END
		END
		ELSE
		BEGIN
			DELETE FROM [dbo].[WidgitMetaData] WHERE WidgitId = @WidgitId AND [Key] = 'data-val-email'
		END
		
		IF CHARINDEX('DigitsOnly',@ValidationItemsComaSeperated) > 0
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM [dbo].[WidgitMetaData] WHERE WidgitId= @WidgitId AND [Key] = 'data-val-digits')
			BEGIN
				INSERT INTO [dbo].[WidgitMetaData] (WidgitId, Version, [Key], Value) VALUES (@WidgitId, 0, 'data-val-digits', 'Digits only');
			END
		END
		ELSE
		BEGIN
			DELETE FROM [dbo].[WidgitMetaData] WHERE WidgitId = @WidgitId AND [Key] = 'data-val-digits'
		END


		IF CHARINDEX('NoFutureDate',@ValidationItemsComaSeperated) > 0
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM [dbo].[WidgitMetaData] WHERE WidgitId= @WidgitId AND [Key] = 'data-val-maxdate')
			BEGIN
				INSERT INTO [dbo].[WidgitMetaData] (WidgitId, Version, [Key], Value) VALUES (@WidgitId, 0, 'data-val-maxdate', 'Date selected in too high');
				INSERT INTO [dbo].[WidgitMetaData] (WidgitId, Version, [Key], Value) VALUES (@WidgitId, 0, 'data-val-maxdate-year', '0');
			END
		END
		ELSE
		BEGIN
			DELETE FROM [dbo].[WidgitMetaData] WHERE WidgitId = @WidgitId AND [Key] = 'data-val-maxdate'
			DELETE FROM [dbo].[WidgitMetaData] WHERE WidgitId = @WidgitId AND [Key] = 'data-val-maxdate-year'
		END

		IF CHARINDEX('ConfirmPassword',@ValidationItemsComaSeperated) > 0
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM [dbo].[WidgitMetaData] WHERE WidgitId= @WidgitId AND [Key] = 'data-val-equalto-other')
			BEGIN
				INSERT INTO [dbo].[WidgitMetaData] (WidgitId, Version, [Key], Value) VALUES (@WidgitId, 0, 'data-val-equalto-other', 'password');
				INSERT INTO [dbo].[WidgitMetaData] (WidgitId, Version, [Key], Value) VALUES (@WidgitId, 0, 'data-val-equalto', 'Password do not match.');
			END
		END
		ELSE
		BEGIN
			DELETE FROM [dbo].[WidgitMetaData] WHERE WidgitId = @WidgitId AND [Key] = 'data-val-equalto-other'
			DELETE FROM [dbo].[WidgitMetaData] WHERE WidgitId = @WidgitId AND [Key] = 'data-val-equalto'
		END
		
      
		FETCH NEXT FROM widgit_cursor     
	INTO @WidgitId,@ValidationItemsComaSeperated,  @IsDisplay  
   
	END     
	CLOSE widgit_cursor;    
	DEALLOCATE widgit_cursor;  

	IF @PublishStatus = 3 -- Save & Publish
	BEGIN
		UPDATE WidgitPublishStatus SET PublishStatus = 1 WHERE WidgitName = @WidgitName AND Clientid = @ClientId
	END

	IF @PublishStatus = 1 -- Save
	BEGIN
		UPDATE WidgitPublishStatus SET PublishStatus = 0 WHERE WidgitName = @WidgitName AND Clientid = @ClientId
	END
	
END