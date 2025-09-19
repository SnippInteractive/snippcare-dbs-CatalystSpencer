-- =============================================
-- Author:		Abdul Wahab
-- Create date: 2022-08-19
-- Description:	This SP is used to trigger all type events/actions everytime a transaction is written
				-- This SP is already in place at several features in the system. Such as
			    -- * RedeemPoints 
				-- * ApplyPointsOrRewards 
				-- * EPOS 
				-- * RedeemVoucher 
				-- * ApplyPoints 
				-- * Manual Claim 

 -- =============================================
CREATE PROCEDURE TriggerActionsBasedOnTransactionHit
@ClientId INT,
@UserId INT, 
@TransactionId INT
/*** add more parameters here in case needed, but ensure to give it a default value otherwise the 
     dependent SPs will fail */
AS
BEGIN
	SET NOCOUNT ON;
	
	IF EXISTS(SELECT [Value] FROM ClientConfig WITH (NOLOCK) WHERE [Key]='EnablePointsAgingProcess' AND ClientId = @ClientId AND [value]='true')
	BEGIN
		EXEC [EPOS_UpdatePointsAgeWithTrx] @UserId, @TransactionId
	END	

	IF EXISTS(SELECT [Value] FROM ClientConfig WITH (NOLOCK) WHERE [Key]='EnableTierProcess' AND ClientId = @ClientId AND [value]='true')	
	BEGIN
		EXEC [Tier_GetSQLForTierPoints_SingleUser] @UserId, @TransactionId
	END	
	
END
