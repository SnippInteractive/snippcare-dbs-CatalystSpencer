CREATE PROCEDURE [dbo].[UploadEnterCodes]
(
	@DetailsJson				NVARCHAR(MAX),			
	@CodesJson					NVARCHAR(MAX),
	@ClientId					INT
)
AS
BEGIN
	BEGIN TRY
		/*-------------------------------------------------
		CHECKING WHETHER THE GIVEN STRING IS IN JSON FORMAT
		---------------------------------------------------*/
		IF ISJSON(@DetailsJson)= 0 OR ISNULL(ISJSON(@DetailsJson),'')= ''
		BEGIN
			SELECT 'invaliddetails' as Result
			RETURN
		END
		IF ISJSON(@CodesJson)= 0 OR ISNULL(ISJSON(@CodesJson),'')= ''
		BEGIN
			SELECT 'invalidcodes' as Result
			RETURN
		END
		DECLARE @UniqueCodes INT,@TotalCodes INT
		
		--SELECT @TotalCodes = COUNT(Substring([value], 1,Charindex('|', [value])-1)) FROM OPENJSON(@CodesJson)
		--IF @UniqueCodes<@TotalCodes
		--BEGIN
		--	SELECT 'duplicatecodesexist' as Result
		--	RETURN
		--END
	
		BEGIN TRAN
				DECLARE @result varchar(20)
				DECLARE @Codes TABLE(Code NVARCHAR(100))
				INSERT @Codes(Code)
		        SELECT DISTINCT Substring([value], 1,Charindex('|', [value])-1) FROM OPENJSON(@CodesJson)

				IF EXISTS (SELECT 1 FROM VoucherCodes WHERE DeviceID in (SELECT Code FROM @Codes))
				BEGIN
					SET @result = 'codeexists'
				END
				ELSE
				BEGIN

					--SELECT @UniqueCodes = COUNT(DISTINCT Substring([value], 1,Charindex('|', [value])-1)) FROM OPENJSON(@CodesJson)
					SELECT @UniqueCodes = COUNT(Code) FROM @Codes


				
					DECLARE @EntercodeSiteId INT, @ExpirationDate nvarchar(20),@ExtReference nvarchar(100),@EntercodeValue INT,@EntercodeValueType nvarchar(10),@LotId INT, @DeviceStatusID INT, @IsClassical BIT
					DECLARE @ExpDate datetime
					--CAST('2017-08-25' AS datetime);
					SELECT @EntercodeSiteId = CAST(ISNULL([value],'0') as INT) FROM OPENJSON(@DetailsJson)	WHERE [key] = 'EntercodeSiteId'
					SELECT @ExpirationDate = ISNULL([value],'') FROM OPENJSON(@DetailsJson)		WHERE [key] = 'ExpirationDate'
					--SELECT @ExtReference = ISNULL([value],'') FROM OPENJSON(@DetailsJson) WHERE [key] = 'ExtReference'
					SELECT @EntercodeValue = CAST(ISNULL([value],'0') as INT) FROM OPENJSON(@DetailsJson) WHERE [key] = 'EntercodeValue'
					SELECT @EntercodeValueType = ISNULL([value],'') FROM OPENJSON(@DetailsJson) WHERE [key] = 'EntercodeValueType'
					SELECT @LotId = CAST(ISNULL([value],'0')as INT) FROM OPENJSON(@DetailsJson) WHERE [key] = 'LotId'
					--SELECT @IsClassical = CASE ISNULL([value],'false') WHEN 'true' THEN 1 ELSE 0 END  FROM OPENJSON(@DetailsJson) WHERE [key] = 'IsClassical'
					SELECT @IsClassical = 0
					SELECT @DeviceStatusID = DeviceStatusID from DeviceStatus where clientId = @ClientId AND [Name] = 'Active'

					SET @ExpDate =  Cast(@ExpirationDate AS DATETIMEOFFSET(7))
					SET @ExpDate = SMALLDATETIMEFROMPARTS(YEAR(@ExpDate), MONTH(@ExpDate), DAY(@ExpDate), 23, 59);


					WITH DEDUPE AS (
						SELECT  Substring([value], 1,Charindex('|', [value])-1) as Deviceid
								,Substring([value], Charindex('|', [value])+1, LEN([value])- LEN(RIGHT([value],CHARINDEX('|', REVERSE([value]))-1))- LEN(Substring([value], 1,Charindex('|',[value])-1))-2 ) as  ExtReference
								,RIGHT([value],CHARINDEX('|', REVERSE([value]))-1) as  code_id
								,ROW_NUMBER() OVER ( PARTITION BY Substring([value], 1,Charindex('|', [value])-1) ORDER BY Substring([value], 1,Charindex('|', [value])-1)) AS OCCURENCE
						FROM OPENJSON(@CodesJson)
						)


					INSERT VoucherCodes
					(
						DeviceID,					
						ExtReference,
						code_id,
						ClientID,
						SiteID,
						DeviceStatusID,
						ExpirationDate,
						[Value],
						ValueType,
						Classical,
						DeviceLotID 
					)
					SELECT	Deviceid,
							ExtReference,
							code_id,
							@ClientId,
							@EntercodeSiteId,
							@DeviceStatusID,
							@ExpDate,
							@EntercodeValue,
							@EntercodeValueType,
							@IsClassical,
							@LotId
					FROM	DEDUPE
					WHERE   OCCURENCE = 1 
		
					--SELECT @UniqueCodes = count(*) FROM	DEDUPE WHERE   OCCURENCE = 1 
					SET @result = CAST(@UniqueCodes as VARCHAR(20))
				END

				
		
		COMMIT
		
		END TRY
		BEGIN CATCH
			ROLLBACK
			SET @result ='exception'
		END CATCH

		
		SELECT @result as Result
END
