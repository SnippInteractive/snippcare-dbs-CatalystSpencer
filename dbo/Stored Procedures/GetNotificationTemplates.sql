CREATE Procedure [dbo].[GetNotificationTemplates] (@ClientId int) as

BEGIN 
	
	SELECT temp.Id,temptype.Name as NotificationTemplateTypeName,temp.Name as Name, isnull(temp.NotificareTemplateId,'') as NotificareTemplateId
	FROM NotificationTemplate temp  
		 INNER JOIN NotificationTemplateType temptype ON temp.NotificationTemplatetypeId = temptype.Id
	WHERE temptype.ClientId = @ClientId AND temptype.Display = 1
	
END
