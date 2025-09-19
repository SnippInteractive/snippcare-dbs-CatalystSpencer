CREATE PROCEDURE [dbo].[GetRewards](@ClientId INT,@Type nvarchar(50))
AS
BEGIN

SELECT ri.rewardname       AS NAME,
       ri.rewarditemid     AS RewardId,
       rio.rewardcostprice AS Value,
	   ri.ItemType AS	Type
FROM   rewarditems ri
       INNER JOIN rewarditemsoptions rio
               ON ri.rewarditemid = rio.rewarditemid
WHERE  ri.clientid = @ClientId and ri.Enabled = 1
         		    
END