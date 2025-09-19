CREATE PROCEDURE [DBHelper].[PopulateWidgitRoles] 
(
@ClientID INT,
@WidgitID INT,
@RoleNames string_list READONLY
)
AS

BEGIN
 
 
INSERT INTO WidgitRoles (WidgitId, RoleId)
SELECT @WidgitID,  ( select RoleId from [Role] where ClientId = @ClientId and Name in (select Value from @RoleNames))

END
