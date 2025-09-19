CREATE PROCEDURE [dbo].[CheckRewardOrderFulFilled]
    @OrderNumber nvarchar(50),
    @ClientId int  
AS
BEGIN

    IF Exists (select 1 from  SSISHelper.OrderFulfillment where [Original Order Number] = @OrderNumber AND [Status] = 'A')
    Begin
        Select 1 as result
    End
    Else
    Begin
        Select 0 as result
    End
END
