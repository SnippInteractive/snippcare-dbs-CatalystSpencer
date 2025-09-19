-- =============================================
-- Modified by:		Binu Jacob Scaria
-- Date: 2025-06-01
-- Description:	SaveUserNotificationTemplateHistory
-- Modified Date: 2025-06-01
-- =============================================
CREATE PROCEDURE [dbo].[GetNotificationTemplate]
(
	@SearchCriteria		NVARCHAR(MAX) = ''
)
AS
BEGIN

	DECLARE	@Result					NVARCHAR(MAX) = '',
			@ClientId				INT,
			@NotificationId			INT = NULL,
			@NotificationName		NVARCHAR(100) = NULL,
			@NotificationTemplateTypeId		INT = NULL,
			@NotificationStatusId	INT = NULL,
			@UserSegmentId			INT = NULL,
			@StartDate				DATETIME = NULL,
			@EndDate				DATETIME = NULL,
			@Page					INT = 0,
			@PageSize				INT = 10,
			@Offset					INT,
			@TotalCount				INT = 0,
			@Deleted				BIT = NULL

	/*-------------------------------------------------------------------------------------------------------
		Checking whether the search criteria is a JSON string
	-------------------------------------------------------------------------------------------------------*/

	IF ISJSON(ISNULL(@SearchCriteria,'')) = 0
	BEGIN
		 
		SET @NotificationId			= NULL
		SET @NotificationName		= NULL
		SET @NotificationTemplateTypeId		= NULL
		SET @NotificationStatusId	= NULL
		SET @UserSegmentId			= NULL	
		SET @ClientId				= NULL
		SET @StartDate				= NULL
		SET @EndDate				= NULL
		SET @Deleted				= NULL
	END
	ELSE
	BEGIN
		SET @NotificationTemplateTypeId		= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.NotificationTemplateTypeId') AS INT)
		SET @NotificationId					= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.NotificationId') AS INT)
		SET @ClientId						= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.ClientId') AS INT)	
		SET @PageSize						= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.PageSize') AS INT)			
		SET @Page							= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.Page') AS INT)	
		SET @NotificationName				= JSON_VALUE(@SearchCriteria,'$.NotificationName')	

		SET @NotificationTemplateTypeId		= CASE @NotificationTemplateTypeId WHEN 0 THEN NULL ELSE @NotificationTemplateTypeId END
		SET @NotificationId					= CASE @NotificationId WHEN 0 THEN NULL ELSE @NotificationId END
		SET @ClientId						= CASE @ClientId WHEN 0 THEN NULL ELSE @ClientId END
		SET @PageSize						= CASE @PageSize WHEN 0 THEN 10 ELSE @PageSize END

	END

	DECLARE @NotificationTemplateTypeIdPush INT,@NotificationTemplateTypeIdSMS INT
	select @NotificationTemplateTypeIdPush = Id from NotificationTemplateType where clientid = @ClientId AND Name = 'Push'
	select @NotificationTemplateTypeIdSMS = Id from NotificationTemplateType where clientid = @ClientId AND Name = 'SMS'
	/*---------------------------------------------------------------------------------------------------------------------
		Validating the ClientId
	---------------------------------------------------------------------------------------------------------------------*/
	IF @ClientId IS NULL OR @ClientId <= 0
	BEGIN
		SELECT 'INVALID CLIENT' AS Result
		RETURN
	END
	SET @Offset = (CASE WHEN @Page = 0 THEN 0 ELSE  @Page END)*@PageSize

	/*-------------------------------------------------------------------------------------------------------------------
		Fetching the total count that satifies the criteria
	-------------------------------------------------------------------------------------------------------------------*/

	SELECT	@TotalCount = COUNT(n.Id)
	FROM NotificationTemplate n 
	inner join NotificationTemplateType ntt on n.NotificationTemplateTypeId = ntt.Id
	inner join NotificationType nt on n.NotificationTypeId = nt.Id
	inner join NotificationStatus ns on n.NotificationStatusId = ns.NotificationStatusId
	WHERE		ntt.ClientId = @ClientId  AND ntt.Id IN (@NotificationTemplateTypeIdPush,@NotificationTemplateTypeIdSMS)
	AND			(n.Id = @NotificationId OR @NotificationId IS NULL)
	AND			(n.Name = @NotificationName OR @NotificationName IS NULL)
	AND			(n.NotificationTemplateTypeId = @NotificationTemplateTypeId OR @NotificationTemplateTypeId IS NULL)

	/*--------------------------------------------------------------------------------------------------------------------
		Fetching the paginated records and save as JSON string in the @Result variable.
	--------------------------------------------------------------------------------------------------------------------*/
	SET @Result = 
	(
			SELECT		n.Id,	n.NotificationTemplateTypeId,	n.Name,	n.Display,	n.NotificareTemplateId,
			CASE 
				WHEN ISJSON(n.placeholders) = 1 AND n.NotificationTemplateTypeId = @NotificationTemplateTypeIdPush 
				THEN JSON_VALUE(n.placeholders,'$.Body')	
				WHEN ISJSON(n.placeholders) = 1 AND n.NotificationTemplateTypeId = @NotificationTemplateTypeIdSMS 
				THEN JSON_VALUE(n.placeholders,'$.Content')	ELSE n.placeholders END AS Placeholders,
			CASE 
				WHEN ISJSON(n.placeholders) = 1 AND n.NotificationTemplateTypeId = @NotificationTemplateTypeIdPush 
				THEN JSON_VALUE(n.placeholders,'$."Subject"') ELSE null END AS Subject,
			n.NotificationTypeId,ntt.Name AS NotificationTemplateType,@TotalCount TotalCount, 
			CASE 
				WHEN LOWER(nt.Name) = 'campaign' 
				THEN 1 
				ELSE 0 END AS IsCampaign,
			nt.Name  NotificationType,n.ExtraInfo,
			ns.Name AS NotificationStatus,n.NotificationStatusId,
			CASE 
				WHEN (LOWER(ns.Name) = 'draft') --WHEN (LOWER(ns.Name) = 'publish' OR LOWER(ns.Name) = 'sent') 
				THEN 0 ELSE 1 END AS IsPublished,
			n.WeekendVoucherInfo,
			JSON_QUERY(
						(
							SELECT		unot.SegmentId AS UserSegmentId,
										seg.Name AS Segment
							FROM		NotificationTemplateSegment unot
							--INNER JOIN	SegmentAdmin seg
							INNER JOIN	
							(
										SELECT SegmentId,Name
										FROM SegmentAdmin		UNION ALL

										SELECT -1,'All'
							) seg
							ON			unot.SegmentId = seg.SegmentId
							WHERE		unot.NotificationTemplateId = n.Id
							FOR			JSON PATH,INCLUDE_NULL_VALUES
						)
					) AS UserSegments

			FROM NotificationTemplate n 
			inner join NotificationTemplateType ntt on n.NotificationTemplateTypeId = ntt.Id
			inner join NotificationType nt on n.NotificationTypeId = nt.Id
			inner join NotificationStatus ns on n.NotificationStatusId = ns.NotificationStatusId
			WHERE		ntt.ClientId = @ClientId 
			AND ntt.Id IN (@NotificationTemplateTypeIdPush,@NotificationTemplateTypeIdSMS)
			AND			(n.Id = @NotificationId OR @NotificationId IS NULL)
			AND			(n.Name = @NotificationName OR @NotificationName IS NULL)
			AND			(n.NotificationTemplateTypeId = @NotificationTemplateTypeId OR @NotificationTemplateTypeId IS NULL)
			ORDER BY	n.Id DESC
			OFFSET		@Offset ROWS
			FETCH		NEXT @PageSize ROWS ONLY
			FOR			JSON PATH,INCLUDE_NULL_VALUES
	)

	/*-----------------------------------------------------------------------------------------------------------------
		Getting the searched Result.
		PRINT 'dfdfsd'
	-----------------------------------------------------------------------------------------------------------------*/
	SELECT ISNULL(@Result,'') as Result


END
