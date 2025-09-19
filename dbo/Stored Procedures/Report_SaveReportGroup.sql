-- =============================================
-- Author:		Ashna
-- Create date: 27-4-2012
-- Description:	Save Report Group
-- =============================================
CREATE PROCEDURE [dbo].[Report_SaveReportGroup] (@ClientId INT,@ReportGroupId INT,@Description VARCHAR(1000),@Language CHAR(2),@SysuserId BIGINT,@NewReportGroupId BIGINT OUT)
AS
  BEGIN
      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
      SET NOCOUNT ON;

      IF ( @ReportGroupId = 0 )
        BEGIN
        DECLARE @NewRgId int
        DECLARE @LookUpId BIGINT
            --insert into ReportGroup(AppId ,ClientId  )values(@ApplicationId,@Description );  
           INSERT INTO ReportGroup
                       (ClientId)
           VALUES      (@ClientId);
           SELECT @NewRgId = Scope_identity()
           INSERT INTO Lookup VALUES(@ClientId,'REPORT_GROUP',@NewRgId,1,'',0,0)
            SELECT @LookUpId= SCOPE_IDENTITY();
            INSERT INTO LookupI8n VALUES(@LookUpId,'en',@Description)
            INSERT INTO LookupI8n VALUES(@LookUpId,'de',@Description)
            INSERT INTO LookupI8n VALUES(@LookUpId,'fr',@Description)
            INSERT INTO LookupI8n VALUES(@LookUpId,'it',@Description)
            
           
      --     INSERT INTO ReportGroupI8n
      --                 (RgId,
      --                 [Language],
      --                  [Description])
      --     VALUES      (@NewRgId ,
						--@Language,
      --                  @Description);
           
           SELECT @NewReportGroupId = @NewRgId
           
           INSERT INTO [SysuserLog]
                       ([Sysuserid],
                        [Action],
                        [Datetime],
                        [Entity],
                        [Entity_Id])
           VALUES      (@SysuserId,
                        'REPORTS_SAVE',
                        Getdate(),
                        'REPORTS',
                        @NewReportGroupId) 
           
           

        END
      ELSE
        BEGIN
        
           DECLARE @LookId BIGINT
            SET @LookId=(SELECT LookupId FROM Lookup WHERE Code=@ReportGroupId and ClientId=@ClientId and LookupType='REPORT_GROUP')
           
            UPDATE LookupI8n SET Description=@Description WHERE Language=@Language and LookUpId=@LookId
            --update ReportGroup set Description =@Description where ReportGroupId =@ReportGroupId; 
            --UPDATE ReportGroupI8n
            --SET    [Description] = @Description
            --WHERE  RgId = @ReportGroupId;

            SELECT @NewReportGroupId = @ReportGroupId;
        END
  END
