-- =============================================
-- Author:		Noel Sebbey
-- Create date: 28 October 2014
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[AddressMatchingFull]
	-- Add the parameters for the stored procedure here
	@MemberMergeConfigId int
AS
BEGIN
DECLARE
	@UserId int,
	@Firstname nvarchar(50),
	@Lastname nvarchar(70),
	@HouseNumber nvarchar(50),
	@Street nvarchar(80),
	@City nvarchar(60),
	@Zip nvarchar(50),
	@Country nvarchar(80),

	@MinPotentialDupLevel float,
	@MinActualDupLevel float,
	@ScoreExactFirstname float,
	@ScorePartialFirstname float,
	@ScoreFirstLetterFirstname float,
	@ScoreExactLastname float,
	@ScorePartialLastname float,
	@ScoreExactStreet float,
	@ScorePartialStreet float,
	@ScoreExactHouseNumber float,
	@ScorePartialHouseNumber float,
	@ScoreExactZip float,
	@ScorePartialZip float,
	@ScoreExactCity float,
	@ScorePartialCity float,
	@SimilarityMetricId int

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here    
    IF ((SELECT COUNT(MemberMergeConfigId) FROM [dbo].[MemberMergeConfig] WHERE MemberMergeConfigId = @MemberMergeConfigId) = 0)
    BEGIN
    PRINT '@MemberMergeConfigId is invalid'
    END
    ELSE
    BEGIN
    SELECT @MinPotentialDupLevel = MinPotentialDupLevel,
		@MinActualDupLevel = MinActualDupLevel,
		@ScoreExactFirstname = ScoreExactFirstname,
		@ScorePartialFirstname = ScorePartialFirstname,
		@ScoreExactLastname = ScoreExactLastname,
		@ScorePartialLastname = ScorePartialLastname,
		@ScoreExactStreet = ScoreExactStreet,
		@ScorePartialStreet = ScorePartialStreet,
		@ScoreExactHouseNumber = ScoreExactHouseNumber,
		@ScorePartialHouseNumber = ScorePartialHouseNumber,
		@ScoreExactCity = ScoreExactCity,
		@ScorePartialCity = ScorePartialCity
    FROM [dbo].[MemberMergeConfig]
	WHERE MemberMergeConfigId = @MemberMergeConfigId
	
	-- Select Tables
	SELECT u.UserId,
		pd.Firstname,
		pd.Lastname,
		ua.AddressId,
		a.HouseNumber,
		a.Street,
		a.City,
		a.Zip,
		c.Name AS Country
	INTO #Temp
	FROM [dbo].[User] u
	INNER JOIN [dbo].[PersonalDetails] pd
	ON u.PersonalDetailsId = pd.PersonalDetailsId
	INNER JOIN [dbo].[UserAddresses] ua
	ON u.UserId = ua.UserId
	INNER JOIN [dbo].[Address] a
	ON ua.AddressId = a.AddressId
	INNER JOIN [dbo].[Country] c
	ON a.CountryId = c.CountryId
	
	--Delete existing records from the MemberMerge table that uses the same config id
	DELETE [dbo].[MemberMerge]
	WHERE MemberMergeConfigId = @MemberMergeConfigId
	
	WHILE EXISTS(SELECT * FROM #Temp)
	BEGIN
		SELECT TOP 1 @UserId = UserId,
			@Firstname = Firstname,
			@Lastname = Lastname,
			@HouseNumber = HouseNumber,
			@Street = Street,
			@City = City,
			@Zip = Zip,
			@Country = Country
		FROM #Temp

		--Do some processing here
		INSERT INTO [dbo].[MemberMerge]
		SELECT *,
			(CASE
				WHEN ConfidenceLevel > @MinPotentialDupLevel AND ConfidenceLevel <= @MinActualDupLevel THEN 'P' 
				WHEN ConfidenceLevel > @MinActualDupLevel THEN 'D'
			END) AS Mark,
			@MemberMergeConfigId AS MemberMergeConfigId,
			CURRENT_TIMESTAMP AS TimeRun
		FROM
			(SELECT @UserId AS OriginalUserId,
				u.UserId AS MatchingUserId,
				ua.AddressId,
				([dbo].[ComputeAddressMatchingWeightValue](@SimilarityMetricId, @Firstname, pd.Firstname, @ScoreExactFirstname, @ScorePartialFirstname, @ScoreFirstLetterFirstname) +
				[dbo].[ComputeAddressMatchingWeightValue](@SimilarityMetricId, @Lastname, pd.Lastname, @ScoreExactLastname, @ScorePartialLastname, DEFAULT) +
				[dbo].[ComputeAddressMatchingWeightValue](@SimilarityMetricId, @HouseNumber, a.HouseNumber, @ScoreExactHouseNumber, @ScorePartialHouseNumber, DEFAULT) +
				[dbo].[ComputeAddressMatchingWeightValue](@SimilarityMetricId, @Street, a.Street, @ScoreExactStreet, @ScorePartialStreet, DEFAULT) +
				[dbo].[ComputeAddressMatchingWeightValue](@SimilarityMetricId, @City, a.City, @ScoreExactCity, @ScorePartialCity, DEFAULT) +
				[dbo].[ComputeAddressMatchingWeightValue](@SimilarityMetricId, @Zip, a.Zip, @ScoreExactZip, @ScorePartialZip, DEFAULT))
				/(CASE WHEN @Firstname IS NOT NULL OR pd.Firstname IS NOT NULL THEN @ScoreExactFirstname ELSE 0 END +
				CASE WHEN @Lastname IS NOT NULL OR pd.Lastname IS NOT NULL THEN @ScoreExactLastname ELSE 0 END +
				CASE WHEN @HouseNumber IS NOT NULL OR a.HouseNumber IS NOT NULL THEN @ScoreExactHouseNumber ELSE 0 END +
				CASE WHEN @Street IS NOT NULL OR a.Street IS NOT NULL THEN @ScoreExactStreet ELSE 0 END +
				CASE WHEN @City IS NOT NULL OR a.City IS NOT NULL THEN @ScoreExactCity ELSE 0 END +
				CASE WHEN @Zip IS NOT NULL OR a.Zip IS NOT NULL THEN @ScoreExactZip ELSE 0 END)
				*100 AS ConfidenceLevel
			FROM [User] u
			INNER JOIN [dbo].[PersonalDetails] pd
			ON u.PersonalDetailsId = pd.PersonalDetailsId
			INNER JOIN [dbo].[UserAddresses] ua
			ON u.UserId = ua.UserId
			INNER JOIN [dbo].[Address] a
			ON ua.AddressId = a.AddressId
			INNER JOIN [dbo].[Country] c
			ON a.CountryId = c.CountryId
			WHERE c.Name = @Country
			AND (pd.PhoneticLastnamePrimaryKey = (SELECT PrimaryKey FROM [dbo].[ComputeDoubleMetaphoneKeys](@Lastname))
				AND (a.PhoneticCityPrimaryKey = (SELECT PrimaryKey FROM [dbo].[ComputeDoubleMetaphoneKeys](@City))
					OR a.Zip = @Zip))
			AND u.UserId <> @UserId) AS ADDRESSMATCH
		WHERE ConfidenceLevel > @MinPotentialDupLevel
		ORDER BY ConfidenceLevel DESC

		DELETE #Temp WHERE UserId = @UserId
	END
	
	END
END

-- Sample query
/*USE [CatalystDB]
GO

EXEC	[dbo].[AddressMatchingFull]
		@MemberMergeConfigId = 1
GO*/

-- Sample select
/*USE CatalystDB
GO

SELECT mm.MemberMergeId,
	mm.OriginalUserId,
	pd.Firstname AS OriginalFirstname,
	pd.Lastname AS OriginalLastname,
	pd.DateOfBirth AS OriginalDateOfBirth,
	a.HouseNumber AS OriginalHouseNumber,
	a.Street AS OriginalStreet,
	a.City AS OriginalCity,
	a.Zip AS OriginalZip,
	c.Name AS OriginalCountry,
	mm.MatchingUserId,
	pd2.Firstname AS MatchingFirstname,
	pd2.Lastname AS MatchingLastname,
	pd2.DateOfBirth AS MatchingDateOfBirth,
	a2.HouseNumber AS MatchingHouseNumber,
	a2.Street AS MatchingStreet,
	a2.City AS MatchingCity,
	a2.Zip AS MatchingZip,
	c2.Name AS MatchingCountry,
	mm.ConfidenceLevel,
	mm.MemberMergeConfigId,
	mm.TimeRun
	FROM [dbo].[MemberMerge] mm
	INNER JOIN [dbo].[User] u
	ON mm.OriginalUserId = u.UserId
	INNER JOIN [dbo].[PersonalDetails] pd
	ON u.PersonalDetailsId = pd.PersonalDetailsId
	INNER JOIN [dbo].[Address] a
	ON mm.AddressId = a.AddressId
	INNER JOIN [dbo].[Country] c
	ON a.CountryId = c.CountryId
	INNER JOIN [dbo].[User] u2
	ON mm.MatchingUserId = u2.UserId
	INNER JOIN [dbo].[PersonalDetails] pd2
	ON u2.PersonalDetailsId = pd2.PersonalDetailsId
	INNER JOIN [dbo].[Address] a2
	ON mm.AddressId = a2.AddressId
	INNER JOIN [dbo].[Country] c2
	ON a2.CountryId = c2.CountryId
	WHERE mm.MemberMergeConfigId = 1
GO*/
