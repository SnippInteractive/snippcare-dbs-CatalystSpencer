CREATE PROCEDURE [dbo].[SaveOrUpdateProductInfo]
(
	@ProductInfo   NVARCHAR(MAX) = ''
)
AS
BEGIN
	IF ISJSON(@ProductInfo) = 0
	BEGIN
		PRINT 'Invalid_ProductInfo'
		SELECT 'Invalid_ProductInfo' AS Result
		RETURN
	END
	DECLARE @ClientId			INT				= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.ClientId') AS INT),0)
	DECLARE @Id					INT				= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.Id') AS NVARCHAR(150)),0)
	DECLARE @ProductId			NVARCHAR(150)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.ProductId') AS NVARCHAR(150)),'')
	DECLARE @ProductDescription	NVARCHAR(500)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.ProductDescription') AS NVARCHAR(500)),'')
	DECLARE @AnalysisCode1		NVARCHAR(100)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.AnalysisCode1') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode2		NVARCHAR(100)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.AnalysisCode2') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode3		NVARCHAR(100)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.AnalysisCode3') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode4		NVARCHAR(100)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.AnalysisCode4') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode5		NVARCHAR(100)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.AnalysisCode5') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode6		NVARCHAR(100)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.AnalysisCode6') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode7		NVARCHAR(100)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.AnalysisCode7') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode8		NVARCHAR(100)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.AnalysisCode8') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode9		NVARCHAR(100)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.AnalysisCode9') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode10		NVARCHAR(100)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.AnalysisCode10') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode11		NVARCHAR(100)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.AnalysisCode11') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode12		NVARCHAR(100)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.AnalysisCode12') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode13		NVARCHAR(100)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.AnalysisCode13') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode14		NVARCHAR(100)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.AnalysisCode14') AS NVARCHAR(100)),'')
	DECLARE @AnalysisCode15		NVARCHAR(100)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.AnalysisCode15') AS NVARCHAR(100)),'')
	DECLARE @BaseValue		decimal(18,2)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.BaseValue') AS decimal(18,2)),'')
	DECLARE @RetailPrice		decimal(18,2)	= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.RetailPrice') AS decimal(18,2)),'')
	DECLARE @ImportDate			DATETIME		= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.ImportDate') AS NVARCHAR(100)),GETDATE())
	DECLARE @ChangedBy			INT				= ISNULL(CAST(JSON_VALUE(@ProductInfo,'$.ChangedBy') AS INT),0)
	DECLARE @Result				NVARCHAR(MAX)   = ''
	DECLARE @IsRecordExists		BIT				= 0 
	DECLARE @OldRecordAsJSON    NVARCHAR(MAX)   = ''
	DECLARE @ChangeTracker		TABLE(Id INT IDENTITY(1,1),FieldName NVARCHAR(100),OldValue NVARCHAR(500),NewValue NVARCHAR(500))      
	-- Checking whether the ClientId is null or 0 or valid, If then, return.
	IF @ClientId IS NULL OR @ClientId <= 0 
	BEGIN
		SELECT 'Invalid_ClientId' AS Result
		RETURN
	END

	BEGIN TRY

		-- Fetching the old records as JSON Object.
		SET @OldRecordAsJSON = 
		(
			SELECT	*
			FROM	ProductInfo WITH(NOLOCK) 
			WHERE	((ID = @Id AND @Id > 0)  
			OR		(@Id = 0 AND LEN(ISNULL(@ProductId,'')) > 0 AND ProductID = @ProductId))
			FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
		)

		IF  ISJSON(@OldRecordAsJSON) = 0
		BEGIN
			SELECT 'Invalid_ProductInfo' AS Result
			RETURN			
		END

		-- Fetching whether the record exists with either Id or ProductId.
		SET @IsRecordExists = CASE 
									WHEN @OldRecordAsJSON IS NOT NULL 
										AND (ISNULL(CAST(JSON_VALUE(LOWER(@OldRecordAsJSON),'$.productid') AS NVARCHAR(150)),'') = LOWER(@ProductId)
										OR	ISNULL(CAST(JSON_VALUE(LOWER(@OldRecordAsJSON),'$.id') AS NVARCHAR(150)),0) = LOWER(@Id))
									THEN 1
									ELSE 0
							   END
		-- Fetching the change in old values and updated values if the record already exists
		IF @IsRecordExists = 1
		BEGIN
			INSERT		@ChangeTracker(FieldName,OldValue,NewValue)
			SELECT		name,ISNULL(CAST(JSON_VALUE(LOWER(@OldRecordAsJSON),'$.'+LOWER(name)+'') AS NVARCHAR(500)),''),
						ISNULL(CAST(JSON_VALUE(LOWER(@ProductInfo),'$.'+LOWER(name)+'') AS NVARCHAR(500)),'')
			FROM		sys.columns 
			WHERE		OBJECT_NAME(OBJECT_ID) = 'ProductInfo' 
			AND			name NOT IN ('ClientId','Id','Version')
			ORDER BY	Column_Id
		END

		-- Checking whether the old record with either the Id or ProductId exists or not.
		BEGIN TRANSACTION PITRAN
		IF @Id = 0
		BEGIN
			--Inserting records in the ProductInfo table
			IF @IsRecordExists = 0
			BEGIN
				INSERT ProductInfo
				(
					Version,ClientId,ProductId,ProductDescription,
					AnalysisCode1,AnalysisCode2,AnalysisCode3,AnalysisCode4,
					AnalysisCode5,AnalysisCode6,AnalysisCode7,AnalysisCode8,
					AnalysisCode9,AnalysisCode10,AnalysisCode11,AnalysisCode12,
					AnalysisCode13,AnalysisCode14,analysisCode15,ImportDate,BaseValue,RetailPrice
				)
				VALUES
				(
					0,@ClientId,@ProductId,@ProductDescription,
					@AnalysisCode1,@AnalysisCode2,@AnalysisCode3,@AnalysisCode4,
					@AnalysisCode5,@AnalysisCode6,@AnalysisCode7,@AnalysisCode8,
					@AnalysisCode9,@AnalysisCode10,@AnalysisCode11,@AnalysisCode12,
					@AnalysisCode13,@AnalysisCode14,@AnalysisCode15,@ImportDate,@BaseValue,@RetailPrice
				)

				-- Auditing the operation.
				INSERT INTO AUDIT 
				(
					[Version], UserId, FieldName,NewValue,OldValue,ChangeDate,
					ChangeBy,Reason,ReferenceType,OperatorId,SiteId,AdminScreen,SysUser
				)
				VALUES
				(
					1,@ChangedBy,'Product Info',@ProductId,NULL,GETDATE(), 
					@ChangedBy,'Adding new Product with ProductId -'+@ProductId+'','Product Info',NULL,NULL,'Product Info Admin',-1
				)

				SET @Result =  'ADD_ProductInfo_Success' 

			END
			ELSE
			BEGIN
				SELECT 'ADD_ProductInfo_Failed' AS Result
			END

		END
		ELSE
		BEGIN
			IF @IsRecordExists = 1
			BEGIN
				-- Updating the existing record
				UPDATE	ProductInfo
				SET		ProductDescription			= @ProductDescription,
						AnalysisCode1				= @AnalysisCode1,
						AnalysisCode2				= @AnalysisCode2,
						AnalysisCode3				= @AnalysisCode3,
						AnalysisCode4				= @AnalysisCode4,
						AnalysisCode5				= @AnalysisCode5,
						AnalysisCode6				= @AnalysisCode6,
						AnalysisCode7				= @AnalysisCode7,
						AnalysisCode8				= @AnalysisCode8,
						AnalysisCode9				= @AnalysisCode9,
						AnalysisCode10				= @AnalysisCode10,
						AnalysisCode11				= @AnalysisCode11,
						AnalysisCode12				= @AnalysisCode12,
						AnalysisCode13				= @AnalysisCode13,
						AnalysisCode14				= @AnalysisCode14,
						AnalysisCode15				= @AnalysisCode15,
						BaseValue					= @BaseValue,
						RetailPrice					= @RetailPrice	
						--ImportDate					= @ImportDate
				WHERE   ID  						= @Id 
				AND 	ClientId					= @ClientId
				AND     ProductID					= @ProductId
				AND		LEN(ISNULL(ProductID,''))	> 0 

				-- Auditing the operation.
				INSERT INTO AUDIT 
				(
					[Version], UserId, FieldName,NewValue,OldValue,ChangeDate,
					ChangeBy,Reason,ReferenceType,OperatorId,SiteId,AdminScreen,SysUser
				)
				SELECT	1,@ChangedBy,FieldName,NewValue,OldValue,GETDATE(),
						@ChangedBy,'Updating Product with ProductId -'+@ProductId,'Product Info',NULL,NULL,'Product Info Admin',-1
				FROM	@ChangeTracker
				WHERE	NewValue <> OldValue

				SET @Result =  'UPDATE_ProductInfo_Success'
			END
			ELSE
			BEGIN
				SELECT 'UPDATE_ProductInfo_Failed' AS Result
			END
		END
		COMMIT TRANSACTION PITRAN
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVarChar(4000), 
				@ErrNum Int, 
				@ErrSeverity Int, 
				@ErrState Int, 
				@ErrLine Int, 
				@ErrProc NVarChar(200)

		SELECT	@ErrNum			= ERROR_NUMBER(), 
				@ErrSeverity	= ERROR_SEVERITY(), 
				@ErrState		= ERROR_STATE(), 
				@ErrLine		= ERROR_LINE(), 
				@ErrProc		= ISNULL(ERROR_PROCEDURE(), '-')

		SET		@ErrMsg =	N'ErrLine: '	+ 
							RTRIM(@ErrLine) + 
							', proc: '		+ 
							RTRIM(@ErrProc) + 
							', Message: '	+ ERROR_MESSAGE()

		IF (@@TRANCOUNT) > 0 
		BEGIN
			SET @Result =  'ROLLBACK: ' + SUBSTRING(ISNULL(@ErrMsg,''),1,4000)
			ROLLBACK TRANSACTION PITRAN
		END
		ELSE
		BEGIN  
			SET @Result =  SUBSTRING(ISNULL(@ErrMsg,''),1,4000)
		END
	END CATCH

	SELECT @Result AS Result
END
