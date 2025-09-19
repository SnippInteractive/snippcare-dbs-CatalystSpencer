CREATE Procedure [dbo].[API_RightToBeForgotten](@deviceId nvarchar(25), @userid int,@remarks Varchar(max)) as   
  
Begin  
	Declare @nameIdentifier as varchar(250) = '';
	Declare @clientName as varchar(250) = '';
	exec [DBHelper].[RightToBeForgotten] @DeviceID,@userid,@remarks  

	Select @nameIdentifier =  NameIdentifier,@clientName = C.[Name] from [User] U 
	Inner Join Site S on U.SiteId = S.SiteId
	Inner Join Client C on C.ClientId = S.ClientId
	where U.UserId = @userId --1870266

	Delete from [AuthServer].[AspNetUsers] where Id = @nameIdentifier and AudienceId = @clientName	
	
END
