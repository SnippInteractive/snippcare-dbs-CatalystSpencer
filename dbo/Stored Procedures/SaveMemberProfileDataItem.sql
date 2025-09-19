
CREATE PROCEDURE [dbo].[SaveMemberProfileDataItem]
(
	@Id		INT = 0,
	@Name   NVARCHAR(150),
	@Display BIT,
	@IsDelete BIT,
	@ByUserId INT,
	@ClientId INT
)
AS
BEGIN
	
	Declare @Result NVARCHAR(50)= ''
	declare @OldName nvarchar(100),@OldDisplayStatus bit

	IF @IsDelete = 1
	BEGIN
		IF @Id > 0
		BEGIN
			--print 'delete'

			IF EXISTS (SELECT 1 FROM PromotionMemberProfileItem WHERE clientid = @ClientId AND ItemId = @Id)
			BEGIN
				SET @Result = 'itemused'
			END
			ELSE
			BEGIN
				select top 1 @OldName = [Name],@OldDisplayStatus = Display from PromotionMemberProfileItemType where Id = @Id

				DELETE FROM PromotionMemberProfileItemType WHERE Id = @Id

				-- Audit
				INSERT INTO AUDIT 
				(
					[Version], UserId, FieldName,NewValue,OldValue,ChangeDate,
					ChangeBy,Reason,ReferenceType,OperatorId,SiteId,AdminScreen,SysUser
				)
				VALUES
				(
					1,@ByUserId,'MemberProfileData','','Id:'+ CAST(@Id as nvarchar(10)) +', OldName:' + @OldName + ', OldDisplay:'+ CONVERT(nvarchar, ISNULL(@OldDisplayStatus,0)) ,GETDATE(), 
					@ByUserId,'Delete MemberProfileData','',NULL,NULL,'ActivityAdmin',-1
				)	
				SET @Result = 'deletesuccess'
			END
			
		END
		ELSE
		BEGIN
			SET @Result = 'notexists'
		END
					
		
	END
	ELSE
	BEGIN

		select @OldName = [Name],@OldDisplayStatus = Display from PromotionMemberProfileItemType where Id = @Id

		IF EXISTS (SELECT 1 FROM PromotionMemberProfileItem WHERE clientid = @ClientId AND ItemName = @OldName)
		BEGIN
			SET @Result = 'itemused'
		END
		ELSE IF EXISTS (SELECT 1 FROM PromotionMemberProfileItemType where Clientid = @ClientId AND [Name] = @Name and Id != @Id)
		BEGIN
			SET @Result = 'nameexists'
		END
		ELSE
		BEGIN
			IF @Id > 0
			BEGIN
				--print 'update'

				UPDATE PromotionMemberProfileItemType
				SET [Name] = @Name, Display = @Display
				WHERE Id = @Id

				-- Audit
				INSERT INTO AUDIT 
				(
					[Version], UserId, FieldName,NewValue,OldValue,ChangeDate,
					ChangeBy,Reason,ReferenceType,OperatorId,SiteId,AdminScreen,SysUser
				)
				VALUES
				(
					1,@ByUserId,'MemberProfileData','Id:'+ CAST(@Id as nvarchar(10)) +', Name:' + @Name + ', Display:' + CONVERT(nvarchar, ISNULL(@Display,0)),
					'Id:'+ CAST(@Id as nvarchar(10)) +', OldName:' + @OldName + ', OldDisplay:' + CONVERT(varchar, ISNULL(@OldDisplayStatus,0)),GETDATE(), 
					@ByUserId,'Update MemberProfileData','',NULL,NULL,'ActivityAdmin',-1
				)
				SET @Result = 'success'
			END
			ELSE
			BEGIN
				--print 'insert'

				declare @CategoryIdMemberProfileData int 
				select TOP 1 @CategoryIdMemberProfileData = Id from PromotionCategory where clientid= @ClientId and [name] = 'MemberProfileData'

				INSERT INTO PromotionMemberProfileItemType([Version],[Name],Display,IsMemberProfileItem,CategoryId,ClientId)
				VALUES(0,@Name,@Display,1,@CategoryIdMemberProfileData,@ClientId)

				-- Audit
				INSERT INTO AUDIT 
				(
					[Version], UserId, FieldName,NewValue,OldValue,ChangeDate,
					ChangeBy,Reason,ReferenceType,OperatorId,SiteId,AdminScreen,SysUser
				)
				VALUES
				(
					1,@ByUserId,'MemberProfileData','Name:' + @Name + ', Display:' + CONVERT(nvarchar, ISNULL(@Display,0)),'',GETDATE(), 
					@ByUserId,'Add MemberProfileData','',NULL,NULL,'Activity Admin',-1
				)
				SET @Result = 'success'
			END
		END
	END

	SELECT @Result AS Result
END
