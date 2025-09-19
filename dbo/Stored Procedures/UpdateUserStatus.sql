-- =============================================
-- Author:		Bibin
-- Create date: 28/07/2020
-- Description:	Update User status from ActiveUnverifiedAddress to Active & Active to Inactive
-- =============================================
CREATE PROCEDURE UpdateUserStatus ( @userId int,@clientId int,@userStatus nvarchar(30),@updatedBy int,@reason nvarchar(500))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @newUserStatus int,@olduserStatus int;

	Select @newUserStatus=UserStatusId from UserStatus 
						where Name=@userStatus and ClientId=@clientId;
	select @olduserStatus = UserStatusId from [User] where Userid=@userId
	--Update user status to new updated Status (Active/InActive)
   Update [User] set UserStatusId=@newUserStatus where Userid=@userId
   --Audit chnages from ActiveUnverifiedAddress to Active / Active to Inactive
   Insert into Audit (Version,UserId,FieldName,OldValue,NewValue,ChangeDate,ChangeBy,Reason) values
   (0,@userId,'UserStatus',(select Name from UserStatus where UserStatusId=@olduserStatus),@userStatus,GETDATE(),@updatedBy,@reason)
END
