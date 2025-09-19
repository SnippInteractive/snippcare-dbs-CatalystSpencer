CREATE PROCEDURE [DBHelper].[Create_ReferenceType] 
(
@TypeName nvarchar(100),
@TypeValues string_list READONLY,
@ClientId INT
)
AS

BEGIN

DECLARE @stmt nvarchar(500)
DECLARE @paramDefs nvarchar(500)

SET @stmt = N' INSERT INTO ' +  @TypeName + ' (ClientId, Display, Name) 
			   select  @clientIdS, display , value from @TypeValuesS'

SET @paramDefs = N'@ClientIdS INT, @TypeValuesS string_list READONLY'

exec sp_executesql  @stmt, @paramDefs, @ClientIdS = @ClientId, @TypeValuesS = @TypeValues 

END
