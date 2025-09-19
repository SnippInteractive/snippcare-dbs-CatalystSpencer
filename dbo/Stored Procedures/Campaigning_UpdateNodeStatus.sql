CREATE PROCEDURE [dbo].[Campaigning_UpdateNodeStatus]
    @JobId INT,
    @Status NVARCHAR(200)
AS
BEGIN
    -- Perform link server update
    exec [Campaigning_UpdateNodeStatusSynony] @JobId, @Status
END;