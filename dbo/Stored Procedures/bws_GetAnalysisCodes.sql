-- =============================================
-- Author:		Binu Jacob Scaria
-- Create date: 08-03-2022
-- Description:	BatchTransfer - taskrunner
-- =============================================
CREATE PROCEDURE [dbo].[bws_GetAnalysisCodes] 	(@ClientId int,@productCodes nvarchar(MAX))
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	SELECT DISTINCT ProductID,AnalysisCode1,AnalysisCode2,AnalysisCode3 from ProductInfo WHERE ClientId = @ClientId AND ProductID IN(SELECT value FROM  STRING_SPLIT ( @productCodes , ',' )  )   
END


