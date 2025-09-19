
CREATE PROCEDURE [dbo].[SaveImportedSegmentUsers]
(
	@XmlDataString			NVARCHAR(MAX), -- List of UserId/DeviceId
	@Header					NVARCHAR(20), -- Column header
	@Source					NVARCHAR(100),
	@IsTier					BIT,
	@SegmentId				INT,
	@ReplaceUsers			BIT,
	@Changeby				INT,
	@Filename				NVARCHAR(100),
	@ClientId				INT
)
AS
BEGIN
	DECLARE	@XMLDATA XML,@ReturnResult NVARCHAR(MAX)=''
	Declare @inactiveuserStatusId int ;
	Select @inactiveuserStatusId = UserStatusId from  UserStatus where name='Inactive' and ClientId=@ClientId
	-- Stop the process if xml data is empty.
	IF LEN(@XmlDataString)= 0
	BEGIN
		SET @ReturnResult =  'Error Data'
		SELECT @ReturnResult AS ReturnResult
		RETURN
	END

	-- Creating required temp tables.
	CREATE TABLE #InputIdList(ID	NVARCHAR(100))
	CREATE TABLE #TempIdList(ID	NVARCHAR(100))
	CREATE TABLE #InvalidUserList(ID	NVARCHAR(100))

	
	SET @XmlDataString = REPLACE(@XmlDataString,'ArrayOfstring','Root')
	SET @XMLDATA = @XmlDataString
	
	-- Fetching the xml data.
	INSERT 	#InputIdList(ID)
	SELECT distinct	T.a.value('.','varchar(100)')	
	FROM	@XMLDATA.nodes('/Root/string') T(a)

	-- Returning Error,if an invalid member Id detected
	/*
	IF EXISTS(SELECT 1 FROM #InputIdList WHERE CAST(ID AS INT) NOT IN(SELECT Userid FROM [USER]))
	BEGIN
		SET @ReturnResult =  'Invalid user detected'
		SELECT @ReturnResult AS ReturnResult
		RETURN
	END
	*/

	-- Checking whether there is any invalid members, if there,it the member id is returned with error message.
	INSERT	#InvalidUserList
	SELECT	inp.ID 
	FROM	#InputIdList inp
	WHERE	NOT EXISTS
	(
		SELECT	UserId 
		FROM	[User] u
		WHERE   Userid IS NOT NULL
		AND     Userid = CAST(inp.ID AS INT)
	)

	IF(SELECT COUNT(1) FROM #InvalidUserList)>0
	BEGIN
		SET @ReturnResult = 'InvalidUserDetected'
		SELECT @ReturnResult =  @ReturnResult + ID +',' FROM #InvalidUserList
		SELECT @ReturnResult AS ReturnResult 
		--SELECT LEFT(@ReturnResult,LEN(@ReturnResult)-1) AS ReturnResult 
		RETURN
	END

	--CHECK FOR INACTIVE USER EXIST IN IMPORT FILE
		SELECT inp.ID  into #inactiveUserList
		FROM	#InputIdList inp inner join [user] u on u.userid=inp.ID
		WHERE UserStatusId = @inactiveuserStatusId 
		IF(SELECT COUNT(1) FROM #inactiveUserList)>0
		BEGIN
			SET @ReturnResult = 'InActiveUserDetected'
			SELECT @ReturnResult =  @ReturnResult + ID +',' FROM #inactiveUserList
			SELECT @ReturnResult AS ReturnResult 
		RETURN
		END

	-- Inserting the segment user if the uploaded csv file contains user ids.
	IF UPPER(@Header) = 'USERID' 
	BEGIN
		IF @ReplaceUsers = 0
		BEGIN 
			INSERT 		#TempIdList(ID)
			SELECT		su.UserId
			FROM		SegmentUsers su	
			WHERE		su.SegmentId =@SegmentId
			AND			su.UserId IN (SELECT CAST(ID AS INT) FROM #InputIdList)	

			-- Returning the list of user ids having given Non-Tier segment, if any
			IF ((SELECT COUNT(1) FROM #TempIdList )> 0)
			BEGIN
				SELECT @ReturnResult = @ReturnResult +  ID +',' FROM #TempIdList
				SELECT LEFT(@ReturnResult,LEN(@ReturnResult)-1) AS ReturnResult
				RETURN
			END
		END
		-- Inserting the segment users
		BEGIN TRY
		IF @ReplaceUsers = 1
		BEGIN
		---DELETE ALL USERS IN SEGMENT AND ADD USERS FROM IMPORT FILE
		Select distinct UserId into #CurrentSegUsers from SegmentUsers where SegmentId=@SegmentId
		DELETE SegmentUsers
				WHERE SegmentID = @SegmentId
		--AUDIT ALL DELETED USERS
		INSERT INTO  AUDIT SELECT 1,UserId,'SegmentId','',@SegmentId,GETDATE(),@Changeby,
							'Replace segment using file -'+@Filename,'SegmentUsers',NULL,NULL from #CurrentSegUsers
		--ADD NEW USERS TO SEGMENT FROM UPLOADED FILE
		INSERT SegmentUsers(SegmentId,UserId,Source,CreatedDate)
				SELECT @SegmentId,CAST(ID AS INT),@Source,GETDATE() FROM #InputIdList
		--AUDIT ALL NEW USERS ADDED TO SEGMENT USING FILE IMPORT
		INSERT INTO  AUDIT SELECT 1,ID,'SegmentId',@SegmentId,'',GETDATE(),@Changeby,
							'Add user to segment using file -'+@Filename,'SegmentUsers',NULL,NULL from #InputIdList
		SET @ReturnResult =  'Success'
				SELECT @ReturnResult AS ReturnResult
		END
		ELSE
		BEGIN
				DELETE SegmentUsers
				WHERE Userid IN(SELECT CAST(ID AS INT) FROM #InputIdList)
				AND SegmentID = @SegmentId
				AND Source = @Source

				INSERT SegmentUsers(SegmentId,UserId,Source,CreatedDate)
				SELECT @SegmentId,CAST(ID AS INT),@Source,GETDATE() FROM #InputIdList
				--AUDIT ALL NEW USERS ADDED TO SEGMENT USING FILE IMPORT
		INSERT INTO  AUDIT SELECT 1,ID,'SegmentId',@SegmentId,'',GETDATE(),@Changeby,
							'Import user from file -'+@Filename,'SegmentUsers',NULL,NULL from #InputIdList
				SET @ReturnResult =  'Success'
				SELECT @ReturnResult AS ReturnResult
		END
		END TRY

		BEGIN CATCH
				SET @ReturnResult = 'ErrorNumber:'+CAST(Error_Number() as VARCHAR(MAX))+
									'ErrorSeverity:'+CAST(ERROR_SEVERITY() as VARCHAR(MAX))+
									'ErrorState:'+CAST(ERROR_STATE() as VARCHAR(MAX))+
									'ErrorProcedure:'+CAST(ERROR_PROCEDURE() as VARCHAR(MAX))+
									'ErrorLine:'+CAST(ERROR_LINE() as VARCHAR(MAX))+
									'ErrorMessage:'+CAST(ERROR_MESSAGE() as VARCHAR(MAX))
		
				SELECT @ReturnResult AS ReturnResult
		END CATCH



	END

		DROP TABLE #TempIdList
		DROP TABLE #InputIdList
		DROP TABLE #InvalidUserList
END
