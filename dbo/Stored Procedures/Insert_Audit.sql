-- =============================================
-- Author:		Abdul Wahab
-- Create date: 2020-05-26
-- Description:	This proceudre is to store all level of audit information. This is a common SP and should be used for all kind of audit in the system.
-- =============================================
CREATE PROCEDURE [dbo].[Insert_Audit]
@Type CHAR(1), -- 'I' =Insert ; 'U'= Update ; 'D'=Delete
@UserId INT,
@SiteId INT,
@TableName NVARCHAR(150),
@FieldName VARCHAR(50),
@NewValue NVARCHAR(MAX),
@OldValue NVARCHAR(MAX)=NULL,
@Reason NVARCHAR(MAX)=NULL


AS
BEGIN
	
	SET NOCOUNT ON;

	SET @Reason = CASE 
				  WHEN (@Type='I' OR LTRIM(RTRIM(@Reason))='')  THEN 'Added'
				  WHEN (@Type='U' OR LTRIM(RTRIM(@Reason))='') THEN 'Modified'
				  WHEN (@Type='D' OR LTRIM(RTRIM(@Reason))='') THEN 'Deleted'
				  ELSE @Reason END

	INSERT INTO [AUDIT] ([Version], UserId, FieldName, NewValue,OldValue,ChangeDate,ChangeBy,Reason,ReferenceType,OperatorId,SiteId)
	VALUES (1,@UserId,@FieldName, @NewValue,@OldValue, GETDATE(), @UserId,@Reason,@TableName,null,@SiteId)
	
END