
CREATE PROCEDURE [dbo].[GetNotifications]
(
	@SearchCriteria		NVARCHAR(MAX) = ''
)
AS
BEGIN

	DECLARE	@Result					NVARCHAR(MAX) = '',
			@ClientId				INT,
			@NotificationId			INT = NULL,
			@NotificationName		NVARCHAR(100) = NULL,
			@NotificationTypeId		INT = NULL,
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
		SET @NotificationTypeId		= NULL
		SET @NotificationStatusId	= NULL
		SET @UserSegmentId			= NULL	
		SET @ClientId				= NULL
		SET @StartDate				= NULL
		SET @EndDate				= NULL
		SET @Deleted				= NULL
	END
	ELSE
	BEGIN
		SET @NotificationTypeId		= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.NotificationTypeId') AS INT)
		SET @NotificationStatusId	= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.NotificationStatusId') AS INT)
		SET @NotificationId			= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.NotificationId') AS INT)
		SET @UserSegmentId			= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.UserSegmentId') AS INT)	
		SET @ClientId				= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.ClientId') AS INT)	
		SET @PageSize				= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.PageSize') AS INT)			
		SET @Page					= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.Page') AS INT)	
		SET @StartDate				= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.StartDate') AS DATETIME)
		SET @EndDate				= TRY_CAST(JSON_VALUE(@SearchCriteria,'$.EndDate') AS DATETIME)	
		SET @Deleted				= CASE JSON_VALUE(@SearchCriteria,'$.Deleted') WHEN 'Deleted' THEN 1 WHEN 'Active' THEN 0 ELSE NULL END
		SET @NotificationName		= JSON_VALUE(@SearchCriteria,'$.NotificationName')	

		SET @NotificationTypeId		= CASE @NotificationTypeId WHEN 0 THEN NULL ELSE @NotificationTypeId END
		SET @NotificationStatusId	= CASE @NotificationStatusId WHEN 0 THEN NULL ELSE @NotificationStatusId END
		SET @NotificationId			= CASE @NotificationId WHEN 0 THEN NULL ELSE @NotificationId END
		SET @UserSegmentId			= CASE @UserSegmentId WHEN 0 THEN NULL ELSE @UserSegmentId END
		SET @ClientId				= CASE @ClientId WHEN 0 THEN NULL ELSE @ClientId END
		SET @PageSize				= CASE @PageSize WHEN 0 THEN 10 ELSE @PageSize END

	END
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

	SELECT		@TotalCount = COUNT( DISTINCT n.NotificationId)
	FROM		Notifications n
	LEFT JOIN	UserNotifications un
	ON			n.NotificationId = un.NotificationId
	WHERE		n.ClientId = @ClientId AND LOWER(n.NotificationName) <> 'system' AND LOWER(n.Subject) <> 'system'
	AND			(n.NotificationId = @NotificationId OR @NotificationId IS NULL)
	AND			(n.NotificationName = @NotificationName OR @NotificationName IS NULL)
	AND			(n.NotificationTypeId = @NotificationTypeId OR @NotificationTypeId IS NULL)
	AND			(n.CreatedDate BETWEEN @StartDate AND @EndDate OR @StartDate IS NULL)
	AND			(n.Deleted = @Deleted OR @Deleted IS NULL)
	AND			(un.UserSegmentId = @UserSegmentId OR @UserSegmentId IS NULL)
	AND			(un.NotificationStatusId = @NotificationStatusId OR @NotificationStatusId IS NULL)

	/*--------------------------------------------------------------------------------------------------------------------
		Fetching the paginated records and save as JSON string in the @Result variable.
	--------------------------------------------------------------------------------------------------------------------*/
	SET @Result = 
	(
			SELECT		DISTINCT
						n.NotificationId AS Id,
						n.NotificationName,
						n.Subject,
						n.Description,
						n.Content,
						n.NotificationTypeId,
						n.Deleted,
						n.CreatedDate,
						n.CreatedBy,
						n.UpdatedBy,
						n.UpdatedDateTime,
						n.ImageUrl,
						n.ExtraInfo,
						JSON_QUERY(
						(
							SELECT		unot.UserSegmentId AS UserSegmentId,
										seg.Name AS Segment,
										unot.Publish AS Publish,
										unot.ExtraInfo AS ExtraInfo,
										ns.NotificationStatusId
							FROM		UserNotifications unot
							INNER JOIN	
							(
										SELECT SegmentId,Name
										FROM SegmentAdmin		UNION ALL

										SELECT -1,'All'
							) seg
							ON			unot.UserSegmentId = seg.SegmentId
							INNER JOIN	NotificationStatus ns
							ON			unot.NotificationStatusId = ns.NotificationStatusId
							WHERE		unot.NotificationId = n.NotificationId
							FOR			JSON PATH,INCLUDE_NULL_VALUES
						)) AS UserSegments,
						@TotalCount AS TotalCount

			FROM		Notifications n
			LEFT JOIN   UserNotifications un
			ON			n.NotificationId = un.NotificationId
			LEFT JOIN	SegmentAdmin us
			ON			un.UserSegmentId = us.SegmentId
			WHERE		n.ClientId = @ClientId AND LOWER(n.NotificationName) <> 'system' AND LOWER(n.Subject) <> 'system'
			AND			(n.NotificationId = @NotificationId OR @NotificationId IS NULL)
			AND			(n.NotificationName = @NotificationName OR @NotificationName IS NULL)
			AND			(n.NotificationTypeId = @NotificationTypeId OR @NotificationTypeId IS NULL)
			AND			(CAST(n.CreatedDate AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE) OR @StartDate IS NULL)
			AND			(n.Deleted = @Deleted OR @Deleted IS NULL)
			AND			(un.UserSegmentId = @UserSegmentId OR @UserSegmentId IS NULL)
			AND			(un.NotificationStatusId = @NotificationStatusId OR @NotificationStatusId IS NULL)
			ORDER BY	n.NotificationId DESC
			OFFSET		@Offset ROWS
			FETCH		NEXT @PageSize ROWS ONLY
			FOR			JSON PATH
	)

	/*-----------------------------------------------------------------------------------------------------------------
		Getting the searched Result.
	-----------------------------------------------------------------------------------------------------------------*/
	SELECT ISNULL(@Result,'') as Result


END
