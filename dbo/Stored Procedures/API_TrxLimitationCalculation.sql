-- =============================================
-- Author:		Wei Liu
-- Create date: 20/09/2022
-- Description:	Calculate rebate limitation 
-- =============================================

CREATE PROCEDURE [dbo].[API_TrxLimitationCalculation] (@ClientId int = 1, @UserId int = 0, @TrxSource  nvarchar(max) ='',  @Limited INT output, @SendEmail nvarchar(max) output)
as 
BEGIN
	SET NOCOUNT ON;

	-- Ticket : https://snipp-interactive.atlassian.net/browse/VOY-725
	-- Rebate limitation requirement 
	---------------------------------------------------
	-- Return 1 equals (not limited)
	-- Return 0 equals (limited)
	-- Return -1 equals error/not applicable (limited)

	
	--declare @Limit int, @SendEmail nvarchar(max)
	--exec [API_TrxLimitationCalculation] 1, 1403406, 'TrxType', @Limit output, @SendEmail output
	--select @Limit, @SendEmail


	DECLARE @JSONCONFIG NVARCHAR(MAX), @RebateLimitEnabled bit, @TrxSourceType nvarchar(max) = '', @EmailConfig NVARCHAR(MAX), @EmailTemplate NVARCHAR(1000) = null, @LimitAmount INT = 0

	-- DEFAULT TO -1
	SET	@Limited = -1
	
	SET @SendEmail = ''

	IF OBJECT_ID('tempdb..#UserTrxTypeDetails') IS NOT NULL
		BEGIN  DROP TABLE #UserTrxTypeDetails END;

	IF OBJECT_ID('tempdb..#UserTrxDetails') IS NOT NULL
		BEGIN  DROP TABLE #UserTrxDetails END;
	
	IF EXISTS(SELECT * FROM ClientConfig WHERE CLIENTID = @ClientId AND [key] = 'TrxLimitConfig')
	BEGIN

		SELECT @JSONCONFIG = [Value] FROM ClientConfig WHERE CLIENTID = @ClientId AND [key] = 'TrxLimitConfig' 

		SELECT @RebateLimitEnabled = RebateLimitEnabled, @EmailConfig = EmailConfig, @LimitAmount = LimitAmt, @TrxSourceType = TrxSourceType FROM OPENJSON(@JSONCONFIG)
		WITH(
			RebateLimitEnabled bit '$.TrxLimitEnabled',
			LimitAmt int '$.LimitAmt',
			EmailConfig nvarchar(max) '$.EmailConfig' AS JSON,
			TrxSourceType nvarchar(max) '$.TrxSourceType'
		)

		IF @RebateLimitEnabled = 0
		BEGIN
			RETURN -1
		END

		IF @EmailConfig is not null
		BEGIN
			SELECT @EmailTemplate = Template FROM OPENJSON(@EmailConfig)
			WITH(
				SourceType NVARCHAR(1000) '$.SourceType',
				Template NVARCHAR(1000) '$.Template'
			)
			WHERE lower(SourceType) = lower(@TrxSource)

		END

		IF NOT EXISTS (SELECT * FROM [USER] WHERE UserId = @UserId)
		BEGIN
			SET	@Limited = -1
		END
		ELSE
		BEGIN
			IF lower(@TrxSource) = 'trxtype'
			BEGIN
				SELECT d.DeviceId, TH.TrxId INTO #UserTrxTypeDetails FROM DEVICE D
				LEFT JOIN TrxHeader TH ON TH.DeviceId = D.DeviceId
				JOIN TrxType TT ON TH.TrxTypeId = TT.TrxTypeId
				WHERE D.UserId = @UserId AND TT.Name IN ( SELECT value FROM string_split(REPLACE(@TrxSourceType, ' ', ''), ',') )
				AND TT.ClientId = @ClientId

				IF @LimitAmount > (Select Count(*) from #UserTrxTypeDetails)
				BEGIN
					-- If limit is not reached then return 1 and return null for email
					SET	@Limited = 1
					SET @SendEmail = ''
				END
				ELSE
				BEGIN
					-- If limit reached then return 0 (limited) and return email template for the type passed
					SET @Limited = 0
					IF @EmailTemplate is not null
					BEGIN
						SET @SendEmail = @EmailTemplate
					END
				END
			END
			ELSE IF lower(@TrxSource) = 'lineitems'
			BEGIN
				SELECT d.DeviceId, TH.TrxId INTO #UserTrxDetails FROM DEVICE D
				JOIN TrxHeader TH ON TH.DeviceId = D.DeviceId
				JOIN TrxDetail TD on TH.Trxid = TD.Trxid
				JOIN TrxType TT ON TH.TrxTypeId = TT.TrxTypeId
				WHERE D.UserId = @UserId AND TD.ItemCode IN ( SELECT value FROM string_split(REPLACE(@TrxSourceType, ' ', ''), ',') )
				AND TT.ClientId = @ClientId

				IF @LimitAmount > (Select Count(*) from #UserTrxDetails)
				BEGIN
					-- If limit is not reached then return 1 and return null for email
					SET	@Limited = 1
					SET @SendEmail = ''
				END
				ELSE
				BEGIN
					-- If limit reached then return 0 (limited) and return email template for the type passed
					SET @Limited = 0
					IF @EmailTemplate is not null
					BEGIN
						SET @SendEmail = @EmailTemplate
					END
				END
			END
		END
	END
	ELSE
	BEGIN
		RETURN -1
	END
	
END
