-- =============================================
-- Author:		Edgar Santos
-- Create date: 08/11/2013
-- Description:	Batch Address Update
--				JIRA CAT-218
--				http://quality.20-20insights.com/jira/browse/CAT-218
-- =============================================
CREATE PROCEDURE [dbo].[BatchAddressUpdate]
	@ClientName VARCHAR(100), 
	@AddressTypeName NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @AddressStatusId_R INT;
	DECLARE @AddressStatusId_C INT;
	DECLARE @AddressStatusId_F INT;
	DECLARE @ClientID INT;
	
	DECLARE @ChangeBy INT;
	
	SELECT @AddressStatusId_R = AddressStatusId 
	FROM AddressStatus ads
	INNER JOIN Client c ON c.ClientId = ads.ClientId AND c.Name = @ClientName AND ads.Name = 'Replaced'

	SELECT @AddressStatusId_C = AddressStatusId 
	FROM AddressStatus ads
	INNER JOIN Client c ON c.ClientId = ads.ClientId AND c.Name = @ClientName AND ads.Name = 'Current'
	
	SELECT @AddressStatusId_F = AddressStatusId 
	FROM AddressStatus ads
	INNER JOIN Client c ON c.ClientId = ads.ClientId AND c.Name = @ClientName AND ads.Name = 'Future'
	
	SELECT @ClientID = ClientId
	FROM Client
	WHERE Name = @ClientName
	
	SELECT @ChangeBy=UserId FROM [User] WHERE ApplicationId IN
		(SELECT ApplicationId FROM Application WHERE ClientId = @ClientID AND Name = 'Catalyst')
		AND Username = 'batchprocessadmin'
	
	-- select all the addresses that are future, and correspondent users
	-- also in the temp table it sets all addresses as Removed/old
	SELECT @AddressStatusId_R AS AddressStatusId,ua.UserId,ad.AddressId,ad.ValidFromDate 
	INTO #temp1
	FROM Address ad
	INNER JOIN AddressStatus ads ON ad.AddressStatusId = ads.AddressStatusId AND ads.Name = 'Future' AND ads.ClientId = @ClientID
	INNER JOIN AddressType at ON at.AddressTypeId = ad.AddressTypeId AND at.Name = @AddressTypeName AND at.ClientId = @ClientID
	INNER JOIN UserAddresses ua ON ua.AddressId = ad.addressid
	GROUP BY ua.UserId,ad.AddressId,ad.ValidFromDate 
	HAVING ad.ValidFromDate <= GETDATE() 
	
	-- select the most recent future address. In case there are two or more future addresses with the same
	-- ValidFromDate it select only one of them, and returns that address as Current.
	;WITH cte AS
	(
	   SELECT *,
			 ROW_NUMBER() OVER (PARTITION BY UserId ORDER BY ValidFromDate DESC) AS rn
	   FROM #temp1
	)
	SELECT @AddressStatusId_C AS AddressStatusId,UserId,AddressId,ValidFromDate
	INTO #temp2
	FROM cte
	WHERE rn = 1
	
	--updates the addressstatusid in addresses in temp1 with the current addresses from temp2
	UPDATE t1 SET t1.AddressStatusId = t2.AddressStatusId FROM #temp1 t1 INNER JOIN #temp2 t2 ON t1.AddressId = t2.AddressId 
	
	
	DECLARE @AddressStatusId INT,@UserId INT,@AddressId INT
	
	DECLARE _cursor CURSOR FAST_FORWARD FOR
	SELECT AddressStatusId,UserId,AddressId FROM #temp1
	
	OPEN _cursor
	
	FETCH NEXT FROM _cursor
	INTO @AddressStatusId,@UserId,@AddressId
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @AddressStatusId = @AddressStatusId_C
		BEGIN
			BEGIN TRAN
			
			UPDATE ad
			SET AddressStatusId = @AddressStatusId_R
			FROM Address ad
			INNER JOIN AddressStatus ads ON ad.AddressStatusId = ads.AddressStatusId AND ads.Name = 'Current' AND ads.ClientId = @ClientID
			INNER JOIN AddressType at ON at.AddressTypeId = ad.AddressTypeId AND at.Name = @AddressTypeName AND at.ClientId = @ClientID
			INNER JOIN UserAddresses ua ON ua.AddressId = ad.addressid
			WHERE ua.UserId = @UserId
			
			INSERT INTO dbo.Audit([Version],[UserId],[FieldName],[NewValue],[OldValue],[ChangeDate],[ChangeBy],[Reason])
			VALUES(1,@UserId,'AddressStatusId',@AddressStatusId_R,@AddressStatusId_C,GETDATE(),@ChangeBy,'BatchAddressUpdate Job - Set Replaced Addr')
			
			UPDATE Address
			SET AddressStatusId = @AddressStatusId
			WHERE AddressId = @AddressId
			
			INSERT INTO dbo.Audit([Version],[UserId],[FieldName],[NewValue],[OldValue],[ChangeDate],[ChangeBy],[Reason])
			VALUES(1,@UserId,'AddressStatusId',@AddressStatusId_C,@AddressStatusId_F,GETDATE(),@ChangeBy,'BatchAddressUpdate Job - Set Current Addr')
			
			COMMIT
		END
		ELSE
		BEGIN
			-- if there are more than one future address for the user that was selected
			-- that future address that is not selected is set as Replaced
			UPDATE Address
			SET AddressStatusId = @AddressStatusId
			WHERE AddressId = @AddressId
		END
		FETCH NEXT FROM _cursor
		INTO @AddressStatusId,@UserId,@AddressId
	END 
	CLOSE _cursor;
	DEALLOCATE _cursor;
	
	--SELECT * FROM #temp1
	
	DROP TABLE #temp1
	DROP TABLE #temp2
    
END
