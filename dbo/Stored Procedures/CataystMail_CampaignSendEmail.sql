CREATE PROCEDURE [dbo].[CataystMail_CampaignSendEmail] (@JobDetailId int)
AS
BEGIN
	
	IF OBJECT_ID('tempdb.dbo.#CampaignEmailData', 'U') IS NOT NULL
		DROP TABLE #CampaignEmailData; 

	IF OBJECT_ID('tempdb.dbo.#UsersToEmail', 'U') IS NOT NULL
		DROP TABLE #UsersToEmail; 

	DECLARE @JSON NVARCHAR(MAX), @EmailTemplateId INT, @NotificareTemplateId NVARCHAR(MAX), @PlaceHolders NVARCHAR(MAX), @NodeId INT, @CampaignId INT, @SQL NVARCHAR(MAX)

	--GET ALL THE JOB DETAILS AND TYPE IS EMAIL
	SELECT CJH.JobId, CJH.RequestDate, CJH.EmailId, CJH.CampaignId, CJD.NodeId, CMF.NamedValuesJSON, CC.[Name] into #CampaignEmailData 
	FROM [Baseline_CampaigningDB].[dbo].[CatalystMail_CampaignJobHeader]  CJH
	JOIN [Baseline_CampaigningDB].[dbo].[CatalystMail_CampaignJobDetails] CJD ON CJD.JobId = CJH.JobId
	JOIN [Baseline_CampaigningDB].[dbo].[CatalystMail_ActionsFields]  CAF ON CAF.ActionId = CJD.ActionId
	JOIN [Baseline_CampaigningDB].[dbo].[CatalystMail_Field] CMF ON CMF.Id = CAF.FilterId
	JOIN [Baseline_CampaigningDB].[dbo].[CatalystMail_Campaign] CC ON CC.Id = CJH.CampaignId
	WHERE  CJH.Test = 0 AND CJH.[STATUS] = 2
	AND CJD.ACTIONTYPE = 'Email' 
	AND ProcessedDate IS NULL 
	AND CONVERT(VARCHAR, CMF.[Description])  = 'Email Template'
	AND CJD.JobDetailId = @JobDetailId

	SELECT @JSON = NamedValuesJSON, @NodeId = NodeId, @CampaignId = CampaignId FROM #CampaignEmailData

	SELECT @EmailTemplateId = [value] FROM OPENJSON(@JSON)

	--GET DETAILS FROM NOTIFICATION TEMPLATE FOR EMAILING
	SELECT @NotificareTemplateId = NT.NotificareTemplateId, @PlaceHolders = NT.Placeholders FROM notificationtemplate NT
	JOIN notificationtype NTT ON NTT.Id = NT.NotificationTypeId
	WHERE NT.Id = @EmailTemplateId AND NTT.Name = 'Campaign'

	--NOTE: IMPORTANT TO ADD SELECTION WHEN NEW PLACEHOLDER NEEDED!! 
	--CURRENT ONLY WORKS WITH PlaceHolders:
		--FirstName
		--PointsBalance
	SELECT CST.MemberID, 
	@NotificareTemplateId AS NotificareTemplateId,
	--CASE WHEN U.Username NOT LIKE '_%@__%.__%' THEN CD.Email ELSE U.Username END AS Username , 
	CASE WHEN CD.Email IS NULL THEN U.Username ELSE CD.Email END as Email, 
	PD.Firstname AS FirstName, 
	A.PointsBalance,
	'test' AS VerificationUrl
	INTO #UsersToEmail
	FROM [Baseline_CampaigningDB].[dbo].[CatalystMail_selmembersTemp] CST
	JOIN [User] U on U.UserId = CST.MemberID 
	JOIN [Account] A on A.UserId = U.UserId
	JOIN UserContactDetails UCD on UCD.UserId = CST.MemberID
	JOIN ContactDetails CD on CD.ContactDetailsId = UCD.ContactDetailsId
	JOIN PersonalDetails PD on PD.PersonalDetailsId = U.PersonalDetailsId
	WHERE CST.nodeId = @NodeId

	--PREVENT DUPLICATE SENDING FROM THE SAME CAMPAIGN AND SAME EMAIL TEMPLATE
	DELETE FROM #UsersToEmail where MemberID in (select UserId from contacthistory where Comments = 'CampaignId:' + CONVERT(VARCHAR, @CampaignId) AND SegmentName = 'TemplateId:' + @NotificareTemplateId)

	--KEEP A RECORD FOR THOSE EMAIL THAT ARE SENT IN CONTACTHISTORY
	INSERT INTO Contacthistory (Version, UserId, ContactTypeId, ContactDate, Comments, segmentname)
	SELECT 0 , MemberId, 1, GETDATE(), 'CampaignId:' + CONVERT(VARCHAR, @CampaignId) , 'TemplateId:' + @NotificareTemplateId from #UsersToEmail
	
	SELECT * FROM #UsersToEmail

	--IF @PlaceHolders is null or @PlaceHolders = ''
	--BEGIN
	--	--NO PLACEHOLDERS JUST REQUIRE USER ID, EMAIL, AND TEMPLATE ID
	--	SELECT MemberID, Email,  @NotificareTemplateId AS NotificareTemplateId FROM #UsersToEmail
	--END
	--ELSE
	--BEGIN
	--	--DYNAMICALLY SELECT THE PLACEHOLDERS FOR EMAILING
	--	SET @SQL = 'SELECT MemberID, Email, ''' + @NotificareTemplateId + ''' AS NotificareTemplateId,' +  @PlaceHolders + ','''+ @PlaceHolders +'''as PlaceHolders FROM #UsersToEmail'
	--	PRINT @SQL
	--	EXEC(@SQL)
	--END
END
