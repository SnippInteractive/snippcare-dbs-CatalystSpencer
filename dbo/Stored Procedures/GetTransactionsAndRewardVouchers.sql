

CREATE PROCEDURE [dbo].[GetTransactionsAndRewardVouchers]
(
	@Source				NVARCHAR(100)='',
	@ClientId			INT,
	@Profile			NVARCHAR(MAX)=''
)
AS
BEGIN
	/*
		The ExtraInfo column in the device table is searched with the given source.
		Assuming there will be only one device associated with the source.
		Then, the transactions are fetched with the deviceId
		Also, the ExtraInfo that starts with STAMP concatenated with Id column in the 
		device table is searched and the records are fetched as reward vouchers.
	
	*/
	DECLARE @Result					NVARCHAR(MAX) = '',
			@DeviceId				NVARCHAR(100)='',
			@DeviceIdColumn			INT,
			@DeviceActiveStatusId	INT,
			@UserId					INT,
			@TrxCompletedStatusId	INT,
			@ProfileTypeId			INT

	DECLARE @ProfileType		TABLE
	(
		ProfileType NVARCHAR(100),
		ProfileTypeId INT
	)
	SET @Profile = 'Voucher'
	IF LEN(@Source) = 0
	BEGIN
		SET @Result = 'InvalidSource'
		SELECT @Result AS Result
		RETURN
	END

	IF ISNULL(@ClientId,0) = 0
	BEGIN
		SET @Result = 'InvalidClient'
		SELECT @Result AS Result
		RETURN
	END

	IF LEN(@Profile) > 0
	BEGIN
		IF NOT EXISTS(SELECT token COLLATE DATABASE_DEFAULT FROM [dbo].[SplitString](@Profile,','))
		BEGIN
			SET @Result = 'InvalidProfile'
			SELECT @Result AS Result
			RETURN
		END
		IF NOT EXISTS(SELECT token COLLATE DATABASE_DEFAULT FROM [dbo].[SplitString](@Profile,',') WHERE LEN(token) > 0)
		BEGIN
			SET @Result = 'InvalidProfile'
			SELECT @Result AS Result
			RETURN
		END
		IF EXISTS
		(
			SELECT token COLLATE DATABASE_DEFAULT 
			FROM [dbo].[SplitString](@Profile,',') 
			WHERE token COLLATE DATABASE_DEFAULT NOT IN 
			(
				SELECT	Name 
				FROM	DeviceProfileTemplateType 
				WHERE	ClientId = @ClientId
			)
		)
		BEGIN
			SET @Result = 'InvalidProfile'
			SELECT @Result AS Result
			RETURN
		END

		INSERT @ProfileType(ProfileType,ProfileTypeId)
		SELECT	Name,Id
		FROM	DeviceProfileTemplateType 
		WHERE	ClientId = @ClientId 
		AND		Name IN
		(
				SELECT TOKEN COLLATE DATABASE_DEFAULT 
				FROM [dbo].[SplitString](@Profile,',')
		)

	END
	ELSE
	BEGIN
		INSERT @ProfileType(ProfileType,ProfileTypeId)
		SELECT Name,Id
		FROM   DeviceProfileTemplateType
		WHERE  ClientId = @ClientId
	END

	SET @Source = REPLACE(LTRIM(RTRIM(@Source)),' ','')

	SELECT	@DeviceActiveStatusId = DeviceStatusId  
	FROM	DeviceStatus 
	WHERE	ClientId = @ClientId 
	AND		Name = 'Active'

	SELECT	@TrxCompletedStatusId = TrxStatusId 
	FROM	Trxstatus 
	WHERE	ClientId = @ClientId
	AND     Name = 'Completed'

	SELECT	@ProfileTypeId = Id  
	FROM	DeviceProfileTemplateType 
	WHERE	ClientId = @ClientId
	AND		Name = @Profile

	DROP TABLE IF EXISTS #DeviceWithSourceAsExtraInfo

	SELECT	TOP 1 Id,DeviceId,StartDate,UserId,ExtraInfo
	INTO	#DeviceWithSourceAsExtraInfo
	FROM	Device d WITH (NOLOCK) 
	WHERE	REPLACE(LTRIM(RTRIM(ExtraInfo)),' ','') COLLATE DATABASE_DEFAULT = @Source COLLATE DATABASE_DEFAULT
	AND		d.DeviceStatusId = @DeviceActiveStatusId

	IF NOT EXISTS(SELECT 1 FROM #DeviceWithSourceAsExtraInfo)
	BEGIN
		SET @Result = 'DeviceNotFound'
		SELECT @Result AS Result
		RETURN
	END

	SELECT TOP 1 @DeviceId = DeviceId, @DeviceIdColumn = Id,@UserId = ISNULL(UserId,0) FROM #DeviceWithSourceAsExtraInfo

	SET @Result = 
	(
		SELECT	DeviceId,
				StartDate,
				ISNULL(UserId,0) as UserId,
				Isnull(ExtraInfo,'') as ExtraInfo,
				(
					SELECT			DISTINCT trx.TrxId,
									trx.TrxDate TrxDateWithoutFormatting,
									trx.DeviceId,
									trx.TransactionType,
									trx.EposTrxId,
									trx.Stamps

					FROM			Transactions  trx  
					LEFT JOIN       TrxDetailStampCard tdStampCard
					ON				trx.TrxDetailId = tdStampCard.TrxDetailId                                    
					WHERE			TrxId<>-1 
					AND				trx.DeviceId = @DeviceId
					AND				trx.ClientId = @ClientId	
					AND				trx.TrxStatusTypeId = @TrxCompletedStatusId 
					FOR JSON PATH, INCLUDE_NULL_VALUES				
				) AS Transactions,
				(
					SELECT		d.DeviceId,
								dpt.Description,
								StartDate StartDateWithoutFormatting,
								ExpirationDate ExpirationDateWithoutFormatting

					FROM		Device d WITH (NOLOCK)
					INNER JOIN	DeviceProfile dp WITH(NOLOCK)
					ON			dp.DeviceId = d.Id
					INNER JOIN	DeviceProfileTemplate dpt WITH(NOLOCK)
					ON			dp.DeviceProfileId = dpt.Id
					WHERE		((@UserId > 0 AND d.UserId = @UserId) 
					OR			(@UserId = 0 AND d.ExtraInfo COLLATE DATABASE_DEFAULT =  'STAMP-'+ CAST(@DeviceIdColumn AS NVARCHAR(100)) COLLATE DATABASE_DEFAULT))
					AND         d.DeviceStatusId = @DeviceActiveStatusId
					AND			dpt.DeviceProfileTemplateTypeId = @ProfileTypeId
					FOR JSON PATH, INCLUDE_NULL_VALUES
				) AS RewardVouchers
		 
		FROM	#DeviceWithSourceAsExtraInfo
		FOR JSON PATH, INCLUDE_NULL_VALUES
	)

	SELECT @Result AS Result
END










