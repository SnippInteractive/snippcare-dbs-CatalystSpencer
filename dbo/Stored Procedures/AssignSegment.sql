--EXEC [dbo].[AssignSegment] 1 , 2107871
CREATE PROCEDURE [dbo].[AssignSegment] (@clientid INT , @userid INT) AS
BEGIN

    -- Declare variables for segment IDs and configuration values

    DECLARE @AllUserSegmentId INT = 0;
    DECLARE @CountryUserSegmentId INT = 0;
    DECLARE @Config NVARCHAR(MAX);
    DECLARE @AssignAllUsersSegement BIT = 0;
    DECLARE @AssignUSUsersSegement BIT = 0;
    DECLARE @AssignCAUsersSegement BIT = 0;
    DECLARE @CountryCode VARCHAR(4) = '';

	-- Get member country code
	SELECT TOP 1 @CountryCode = c.countryCode from country c 
	INNER JOIN [Address] ad ON ad.CountryId = c.CountryId 
	INNER JOIN [UserAddresses] ua ON ua.AddressId = ad.AddressId 
	INNER JOIN [User] u ON u.UserId = ua.UserId
	WHERE u.UserId = @userid

    -- Fetch configuration JSON
    SELECT @Config = [Value]
    FROM ClientConfig
    WHERE [Key] = 'MemberRegistrationConfiguration';

    -- Parse JSON for configuration values
    SET @AssignAllUsersSegement = JSON_VALUE(@Config, '$.AssignAllUsersSegement');
    SET @AssignUSUsersSegement = JSON_VALUE(@Config, '$.AssignUSUsersSegement');
    SET @AssignCAUsersSegement = JSON_VALUE(@Config, '$.AssignCAUsersSegement');

    -- Check if userId is valid and countryCode is not empty
    IF @userid > 0 AND @CountryCode IS NOT NULL AND LTRIM(RTRIM(@CountryCode)) <> ''
    BEGIN
	    -- If a user is connected via a VPN and their country code is neither US nor CA, we must verify their last transaction's store location to determine the country code.
	    IF @CountryCode NOT IN ('US','CA')
        BEGIN
	        SELECT DISTINCT
            @CountryCode =  c.countrycode
            FROM [User] u WITH (NOLOCK)
            INNER JOIN [Device] d WITH (NOLOCK) ON u.userid = d.userid
            LEFT JOIN [Trxheader] th WITH (NOLOCK) ON th.deviceid = d.deviceid
            INNER JOIN [Site] s WITH (NOLOCK) ON s.siteid = th.siteid
            Inner join country c on c.countryid = s.countryid
            WHERE u.userstatusid = 2 and u.userid = @userid
	    END

        -- Fetch "All Users" segment
        IF @AssignAllUsersSegement = 1
        BEGIN
            SELECT @AllUserSegmentId = SegmentId
            FROM SegmentAdmin
            WHERE [Name] = 'All_Users';
        END

        -- Fetch country-specific segments
        IF @AssignUSUsersSegement = 1 AND UPPER(@CountryCode) = 'US'
        BEGIN
            SELECT @CountryUserSegmentId = SegmentId
            FROM SegmentAdmin
            WHERE [Name] = 'US_Users';
        END
        ELSE IF @AssignCAUsersSegement = 1 AND UPPER(@CountryCode) = 'CA'
        BEGIN
            SELECT @CountryUserSegmentId = SegmentId
            FROM SegmentAdmin
            WHERE [Name] = 'CA_Users';
        END

        -- Insert into SegmentUsers for "All Users" segment
        IF @AllUserSegmentId > 0
        BEGIN
			PRINT('INSERT INTO SegmentUsers -- All Users')
            INSERT INTO SegmentUsers (UserId, SegmentId, Source, CreatedDate)
            VALUES (@userid, @AllUserSegmentId, 'SegmentTab', GETDATE());
        END

        -- Insert into SegmentUsers for country-specific segment
        IF @CountryUserSegmentId > 0
        BEGIN
		    PRINT('INSERT INTO SegmentUsers -- conuntry specific : ' + @CountryCode)
            INSERT INTO SegmentUsers (UserId, SegmentId, Source, CreatedDate)
            VALUES (@userid, @CountryUserSegmentId, 'SegmentTab', GETDATE());
        END
    END
End