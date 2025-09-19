
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[GetLookUpData] (@ClientId  INT,
                                       @TableName VARCHAR(50),
                                       @Language  VARCHAR(2))
AS
  BEGIN
      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
      SET NOCOUNT ON;

      DECLARE @DisplayOrder INT

      SET @DisplayOrder=(SELECT TOP(1) Isnull(DisplayOrder, 0)
                         FROM   Lookup
                         WHERE  LookupType = @TableName
                                AND ClientId = @ClientId)

      DECLARE @LayoutType INT

      SET @LayoutType=(SELECT TOP(1) Isnull(LayoutType, 0)
                       FROM   Lookup
                       WHERE  LookupType = @TableName
                              AND ClientId = @ClientId)

      IF( @DisplayOrder = 0 )
        BEGIN
            IF( @LayoutType = 1 )
              BEGIN
                  IF( @TableName = 'ACTIVITY_STATUS' )
                  BEGIN
                  SELECT ( [Description] + '-' + Code ) AS [Description],Code
                  FROM   [dbo].[Getlookup] (@ClientId, @TableName, @Language) WHERE Code <> '-2'
                  END
                  ELSE
                  BEGIN
				 
					
					  SELECT ( [Description] + '-' + Code ) AS [Description],Code
					  FROM   [dbo].[Getlookup] (@ClientId, @TableName, @Language) 
					  
                  END
              END
            ELSE
              BEGIN
                  IF( @TableName = 'ACTIVITY_STATUS' )
                  BEGIN
                  SELECT Code,[Description]
                  FROM   [dbo].[Getlookup] (@ClientId, @TableName, @Language) WHERE Code <> '-2'
                  END
                  ELSE
                  BEGIN
				   IF ( @TableName = 'EXPORT_FIELDTYPE' )
				   BEGIN
				     SELECT Code,[Description]
                  FROM   [dbo].[Getlookup] (@ClientId, @TableName, @Language)
				   --where Code in (1,2,4,5,6,7,13,14,15,17,18,19,20,21,22,25,31,42,87,88,44,45,46,59,60,61,35,23,33,41)
				   END
				   ELSE
						BEGIN
						  SELECT Code,[Description]
						  FROM   [dbo].[Getlookup] (@ClientId, @TableName, @Language)
					    END
                  END
              END
        END
      ELSE
        BEGIN
            IF( @TableName <> 'COUNTRY_TYPE' )
              BEGIN
                  IF( @LayoutType = 1 )
                    BEGIN
                         IF( @TableName = 'ACTIVITY_STATUS' )
                         BEGIN
                        SELECT ( [Description] + '-' + Code ) AS [Description],Code,DisplayOrder
                        FROM   [dbo].[Getlookup] (@ClientId, @TableName, @Language) WHERE Code <> '-2'
                        ORDER  BY DisplayOrder
                        END
                        ELSE
                        BEGIN
                        SELECT ( [Description] + '-' + Code ) AS [Description],Code,DisplayOrder
                        FROM   [dbo].[Getlookup] (@ClientId, @TableName, @Language)
                        ORDER  BY DisplayOrder
                        END
                    END
                  ELSE
                    BEGIN
                    IF( @TableName = 'ACTIVITY_STATUS' )
                    BEGIN
                        SELECT Code,[Description],DisplayOrder
                        FROM   [dbo].[Getlookup] (@ClientId, @TableName, @Language) WHERE Code <> '-2'
                        ORDER  BY DisplayOrder
                    END
                    ELSE
                    BEGIN
                        SELECT Code,[Description],DisplayOrder
                        FROM   [dbo].[Getlookup] (@ClientId, @TableName, @Language)
                        ORDER  BY DisplayOrder
                    END    
                    END
              END
        END
  END
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

