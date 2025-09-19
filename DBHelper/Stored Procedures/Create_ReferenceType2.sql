 CREATE PROCEDURE [DBHelper].[Create_ReferenceType2] 
(
@TypeName nvarchar(100),
@TypeValues2 string_list2 READONLY,
@ClientId INT
)
AS

BEGIN

DECLARE @stmt nvarchar(500)
DECLARE @paramDefs nvarchar(500)

SET @stmt = N' INSERT INTO ' +  @TypeName + ' (ClientId, Display, Name) 
			   select  @clientIdS, display , value from @TypeValuesS'

SET @paramDefs = N'@ClientIdS INT, @TypeValuesS string_list2 READONLY'

exec sp_executesql  @stmt, @paramDefs, @ClientIdS = @ClientId, @TypeValuesS = @TypeValues2

END
