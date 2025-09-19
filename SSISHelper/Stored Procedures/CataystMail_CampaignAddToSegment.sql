CREATE PROCEDURE [SSISHelper].[CataystMail_CampaignAddToSegment] (@JobDetailId int)
AS
BEGIN
	
	IF OBJECT_ID('tempdb.dbo.#CampaignSegment', 'U') IS NOT NULL
		DROP TABLE #CampaignSegment; 

	IF OBJECT_ID('tempdb.dbo.#UsersToSegment', 'U') IS NOT NULL
		DROP TABLE #UsersToSegment; 

	DECLARE @JSON NVARCHAR(MAX), @SegmentId INT, @NotificareTemplateId NVARCHAR(MAX),  @NodeId INT, @CampaignId INT, @SegmentName NVARCHAR(MAX), @UserId INT, @ActionType NVARCHAR(MAX)

	--GET ALL THE JOB DETAILS AND TYPE IS Add TO Segment

	SELECT CJH.JobId, CJH.RequestDate, CJH.EmailId, CJH.CampaignId, CJD.NodeId, CMF.NamedValuesJSON, CC.[Name], CJD.ActionType AS ActionType
	INTO #CampaignSegment
	FROM [Baseline_CampaigningDB].[dbo].[CatalystMail_CampaignJobHeader]  CJH
	JOIN [Baseline_CampaigningDB].[dbo].[CatalystMail_CampaignJobDetails] CJD ON CJD.JobId = CJH.JobId
	JOIN [Baseline_CampaigningDB].[dbo].[CatalystMail_ActionsFields]  CAF ON CAF.ActionId = CJD.ActionId
	JOIN [Baseline_CampaigningDB].[dbo].[CatalystMail_Field] CMF ON CMF.Id = CAF.FilterId
	JOIN [Baseline_CampaigningDB].[dbo].[CatalystMail_Campaign] CC ON CC.Id = CJH.CampaignId
	WHERE  CJH.Test = 1 AND CJH.[STATUS] = 2
	AND CJD.ACTIONTYPE = 'AddToSegment' 
	AND ProcessedDate IS NULL 
	AND CJD.JobDetailId = 42

	SELECT @UserId = UserId FROM [User] WHERE Username = (SELECT EmailId FROM #CampaignSegment)

	SELECT @JSON = NamedValuesJSON, @NodeId = NodeId, @CampaignId = CampaignId, @ActionType = ActionType FROM #CampaignSegment

	SELECT @SegmentId = [value] FROM OPENJSON(@JSON)

	SELECT @SegmentName = [Name] FROM SegmentAdmin WHERE SegmentId = @SegmentId

	SELECT CST.MemberID INTO #UsersToSegment
	FROM [Baseline_CampaigningDB].[dbo].[CatalystMail_selmembersTemp] CST
	WHERE CST.nodeId = @NodeId

	IF @ActionType = 'AddToSegment'
	BEGIN 
		--CHECK IF MEMBER ALREADY EXIST IN THE SEGMENT, IF YES, THEN REMOVE IT FROM TEMP TABLE
		DELETE FROM #UsersToSegment WHERE MemberID in (SELECT UserId FROM SegmentUsers WHERE SegmentId = @SegmentId)
	
		--ADD MEMBER THAT DOES NOT EXIST IN THE SEGMENT
		INSERT INTO SegmentUsers (SegmentId, UserId, Source, CreatedDate)
		SELECT @SegmentId, MemberID, 'Campaigning Tool', GETDATE() FROM #UsersToSegment

		--KEEP A RECORD 
		INSERT INTO [Audit] (Version, UserId, FieldName, NewValue, OldValue, ChangeDate, ChangeBy, Reason, ReferenceType, SiteId)
		SELECT 0 , MemberId, @CampaignId, @SegmentName, '',  GETDATE(), ISNULL(@UserId, '1400006'), 'Added', 'AddToSegment', 2 from #UsersToSegment
	END
	ELSE IF @ActionType = 'ReplaceSegment'
	BEGIN
		--REPLACE SEGMENT NEED TO REMOVE ENTIRE SEGMENT USERS WITH THE SEGMENT ID GIVEN 
		DELETE FROM SegmentUsers WHERE SegmentId = @SegmentId

		--REPLACE THE SEGMENT WITH THE SELECTED MEMBERS
		INSERT INTO SegmentUsers (SegmentId, UserId, Source, CreatedDate)
		SELECT @SegmentId, MemberID, 'Campaigning Tool', GETDATE() FROM #UsersToSegment

		--KEEP A RECORD 
		INSERT INTO [Audit] (Version, UserId, FieldName, NewValue, OldValue, ChangeDate, ChangeBy, Reason, ReferenceType, SiteId)
		SELECT 0 , MemberId, @CampaignId, @SegmentName, '',  GETDATE(), ISNULL(@UserId, '1400006'), 'Modified', 'ReplaceSegment', 2 from #UsersToSegment
	END

END
