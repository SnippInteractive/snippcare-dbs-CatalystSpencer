-- =============================================
-- Author		:	BINU
-- Create date	:	03-5-2012
-- Description	:	Save Report Style
-- =============================================
CREATE PROCEDURE [dbo].[SaveReportStyle](
                                       @ClientId int,
                                       @RepLog image,
                                       @BkColor1 varchar(10),
                                       @BkColor2 varchar(10),
                                       @BkColor3 varchar(10),
                                       @BkColor4 varchar(10),
                                       @BkColor5 varchar(10),
                                       @FColor1 varchar(10),
                                       @FColor2 varchar(10),
                                       @FColor3 varchar(10),
                                       @FColor4 varchar(10),
                                       @FColor5 varchar(10)
                                       )
                                       
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--Update ReportStyles set RepLogo=@RepLog where ClientId=1;
   INSERT INTO ReportStyles
               (ClientId,
                RepLogo,
                BkColour1,
                FontColour1,
                BkColour2,
                FontColour2,
                BkColour3,
                FontColour3,
                BkColour4,
                FontColour4,
                BkColour5,
                FontColour5)
   VALUES      (@ClientId,
                @RepLog,
                @BkColor1,
                @FColor1,
                @BkColor2,
                @FColor2,
                @BkColor3,
                @FColor3,
                @BkColor4,
                @FColor4,
                @BkColor5,
                @FColor5) 
   
END
