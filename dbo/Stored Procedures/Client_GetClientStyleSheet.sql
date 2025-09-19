CREATE PROCEDURE [dbo].[Client_GetClientStyleSheet] (@Clientid int)
AS
  BEGIN
      SET NOCOUNT ON;
     SELECT 'pkz.css' as DefaultStylesheet from Client 
  END

