
CREATE PROCEDURE [dbo].[GetTransactionsAndRewardVouchers_BJS]
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
			@UserId					INT

	DECLARE @ProfileType		TABLE(ProfileType NVARCHAR(100))
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

		INSERT @ProfileType(ProfileType)
		SELECT TOKEN COLLATE DATABASE_DEFAULT 
		FROM [dbo].[SplitString](@Profile,',')

	END
	ELSE
	BEGIN
		INSERT @ProfileType(ProfileType)
		SELECT Name
		FROM   DeviceProfileTemplateType
		WHERE  ClientId = @ClientId
	END

	SET @Source = REPLACE(LTRIM(RTRIM(@Source)),' ','')

	SELECT	@DeviceActiveStatusId = DeviceStatusId  
	FROM	DeviceStatus 
	WHERE	ClientId = @ClientId 
	AND		Name = 'Active'

	DROP TABLE IF EXISTS #DeviceWithSourceAsExtraInfo

	SELECT TOP 1 Id,DeviceId,StartDate,UserId
	INTO   #DeviceWithSourceAsExtraInfo
	FROM   Device WITH (NOLOCK)
	WHERE  REPLACE(LTRIM(RTRIM(ExtraInfo)),' ','') COLLATE DATABASE_DEFAULT = @Source COLLATE DATABASE_DEFAULT
	AND DeviceStatusid = @DeviceActiveStatusId
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
					AND				LOWER(ISNULL(trx.TrxStatusName,'')) ='completed' 
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
					--INNER JOIN  DeviceProfileTemplateType dptt
					--ON			dpt.DeviceProfileTemplateTypeId = dptt.Id
					WHERE		((@UserId > 0 AND d.UserId = @UserId) 
					OR			(@UserId = 0 AND d.ExtraInfo COLLATE DATABASE_DEFAULT =  'STAMP-'+ CAST(@DeviceIdColumn AS NVARCHAR(100)) COLLATE DATABASE_DEFAULT))
					AND         d.DeviceStatusId = @DeviceActiveStatusId
					And dpt.DeviceProfileTemplateTypeId = 3
					--AND			dptt.Name COLLATE DATABASE_DEFAULT IN 
					--(
					--			SELECT	ProfileType COLLATE DATABASE_DEFAULT
					--			FROM	@ProfileType
					--)
					FOR JSON PATH, INCLUDE_NULL_VALUES
				) AS RewardVouchers
		 
		FROM	#DeviceWithSourceAsExtraInfo
		FOR JSON PATH, INCLUDE_NULL_VALUES
	)

	SELECT @Result AS Result
END



