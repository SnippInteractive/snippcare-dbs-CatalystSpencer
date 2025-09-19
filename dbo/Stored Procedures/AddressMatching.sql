-- ======================================================================================================================================
-- Author:		Noel Sebbey
-- Create date: 28 October 2014
-- Description:	This stored procedure finds the exact and potential duplicates of a query given based on name, date of birth and address.
--				@Firstname				- The first name of user being searched for duplicates
--				@Lastname				- The last name of user being searched for duplicates
--				@DateOfBirth			- The date of birth of user being searched for duplicates
--				@HouseNumber			- The house number of address of user being searched for duplicates
--				@Street					- The street of address of user being searched for duplicates
--				@City					- The city of address of user being searched for duplicates
--				@Zip					- The zip number of address of user being searched for duplicates
--				@Country				- The country of address of user being searched for duplicates
--				@NumberOfResults		- The top number of results to be returned for duplicates
--				@MemberMergeConfigId	- The config id to be used to give the weight values for each parameter being compared
-- ======================================================================================================================================
CREATE PROCEDURE [dbo].[AddressMatching]
	-- Add the parameters for the stored procedure here
	@Firstname nvarchar(50),
	@Lastname nvarchar(70),
	@DateOfBirth datetime = NULL,
	@HouseNumber nvarchar(50) = NULL,
	@Street nvarchar(80) = NULL,
	@City nvarchar(60) = NULL,
	@Zip nvarchar(50) = NULL,
	@Country nvarchar(80),
	@NumberOfResults int = 0,
	@MemberMergeConfigId int
AS
BEGIN
DECLARE
	@MinPotentialDupLevel float,
	@MinActualDupLevel float,
	@ScoreExactFirstname float,
	@ScorePartialFirstname float,
	@ScoreFirstLetterFirstname float,
	@ScoreDateOfBirth float,
	@ScoreExactLastname float,
	@ScorePartialLastname float,
	@ScoreExactStreet float,
	@ScorePartialStreet float,
	@ScoreExactHouseNumber float,
	@ScorePartialHouseNumber float,
	@ScoreExactCity float,
	@ScorePartialCity float,
	@ScoreExactZip float,
	@ScorePartialZip float

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
    IF (@NumberOfResults <= 0)
    BEGIN
    SET @NumberOfResults = 100
    END
    
    IF ((SELECT COUNT(MemberMergeConfigId) FROM [dbo].[MemberMergeConfig] WHERE MemberMergeConfigId = @MemberMergeConfigId) = 0)
    BEGIN
    PRINT 'Config id ' + CAST(@MemberMergeConfigId AS VARCHAR(100)) +' is invalid.'
    END
    ELSE
    BEGIN
    SELECT @MinPotentialDupLevel = MinPotentialDupLevel,
		@MinActualDupLevel = MinActualDupLevel,
		@ScoreExactFirstname = ScoreExactFirstname,
		@ScorePartialFirstname = ScorePartialFirstname,
		@ScoreDateOfBirth = ScoreDateOfBirth,
		@ScoreExactLastname = ScoreExactLastname,
		@ScorePartialLastname = ScorePartialLastname,
		@ScoreExactStreet = ScoreExactStreet,
		@ScorePartialStreet = ScorePartialStreet,
		@ScoreExactHouseNumber = ScoreExactHouseNumber,
		@ScorePartialHouseNumber = ScorePartialHouseNumber,
		@ScoreExactCity = ScoreExactCity,
		@ScorePartialCity = ScorePartialCity,
		@ScoreExactZip = ScoreExactZip,
		@ScorePartialZip = ScorePartialZip

    FROM [dbo].[MemberMergeConfig]
	WHERE MemberMergeConfigId = @MemberMergeConfigId
	
	-- Select Table
    SELECT TOP (@NumberOfResults) *,
		(CASE
			WHEN ConfidenceLevel >= @MinPotentialDupLevel AND ConfidenceLevel < @MinActualDupLevel THEN 'P' 
			WHEN ConfidenceLevel >= @MinActualDupLevel THEN 'D'
		END) AS Mark
    FROM
		(SELECT  u.UserId,
			Firstname,
			Lastname,
			DateOfBirth,
			ua.AddressId,
			HouseNumber,
			Street,
			City,
			Zip,
			c.CountryCode AS Country,
			u.CreateDate,
			CASE WHEN @Firstname = Firstname AND @Lastname = Lastname AND @DateOfBirth = DateOfBirth AND @DateOfBirth != '1900/01/01'
				THEN 100
				ELSE
					CASE WHEN PhoneticCityPrimaryKey = (SELECT PrimaryKey FROM [dbo].[ComputeDoubleMetaphoneKeys](@City)) OR Zip = @Zip
						THEN
							([dbo].[GetAddressMatchingScore](2, @Firstname, Firstname, @ScoreExactFirstname, @ScorePartialFirstname, @ScoreFirstLetterFirstname) +
							[dbo].[GetAddressMatchingScore](1, @Lastname, Lastname, @ScoreExactLastname, @ScorePartialLastname, DEFAULT) +
							[dbo].[GetAddressMatchingDOBScore](@DateOfBirth, DateOfBirth, @ScoreDateOfBirth) +
							[dbo].[GetAddressMatchingScore](1, @HouseNumber, HouseNumber, @ScoreExactHouseNumber, @ScorePartialHouseNumber, DEFAULT) +
							[dbo].[GetAddressMatchingScore](2, [dbo].[GetAddressMatchingStandardStreet](@Street, LanguageCode), [dbo].[GetAddressMatchingStandardStreet](a.Street, LanguageCode), @ScoreExactStreet, @ScorePartialStreet, DEFAULT) +
							[dbo].[GetAddressMatchingScore](2, @City, City, @ScoreExactCity, @ScorePartialCity, DEFAULT) +
							[dbo].[GetAddressMatchingScore](2, @Zip, Zip, @ScoreExactZip, @ScorePartialZip, DEFAULT))
							/(CASE WHEN @Firstname IS NOT NULL OR Firstname IS NOT NULL THEN @ScoreExactFirstname ELSE 0 END +
							CASE WHEN @Lastname IS NOT NULL OR Lastname IS NOT NULL THEN @ScoreExactLastname ELSE 0 END +
							@ScoreDateOfBirth +
							CASE WHEN @HouseNumber IS NOT NULL OR HouseNumber IS NOT NULL THEN @ScoreExactHouseNumber ELSE 0 END +
							CASE WHEN @Street IS NOT NULL OR Street IS NOT NULL THEN @ScoreExactStreet ELSE 0 END +
							CASE WHEN @City IS NOT NULL OR City IS NOT NULL THEN @ScoreExactCity ELSE 0 END +
							CASE WHEN @Zip IS NOT NULL OR Zip IS NOT NULL THEN @ScoreExactZip ELSE 0 END)
							*100
						ELSE 0
						END
				END AS ConfidenceLevel
		FROM [dbo].[User] u
		INNER JOIN [dbo].[PersonalDetails] pd
		ON u.PersonalDetailsId = pd.PersonalDetailsId
		INNER JOIN [dbo].[UserAddresses] ua
		ON u.UserId = ua.UserId
		INNER JOIN [dbo].[Address] a
		ON ua.AddressId = a.AddressId
		INNER JOIN [dbo].[Country] c
		ON a.CountryId = c.CountryId
		INNER JOIN [dbo].[Language] l
		ON u.LanguageId = l.LanguageId
		INNER JOIN [dbo].[UserStatus] s
		ON u.UserStatusId = s.UserStatusId
		WHERE c.CountryCode = @Country
		AND s.Name = 'Active' and (pd.Firstname like '%'+@Firstname+'%' or pd.Lastname like'%'+@Lastname+'%')) AS ADDRESSMATCH
	WHERE ConfidenceLevel >= @MinPotentialDupLevel
	ORDER BY ConfidenceLevel DESC
	END
END

-- Sample query
--USE [CatalystMassRoots]
--GO

--EXEC [dbo].[AddressMatching]
--  @Firstname = 'Tanya',
--  @Lastname = 'Krupitsch',
--  @DateOfBirth = '1965-09-27T00:00:00.000',
--  @HouseNumber = NULL,
--  @Street = 'Jägerzeile',
--  @City = 'BadFischau',
--  @Country = 'Austria',
--  @NumberOfResults = 100,
--  @MemberMergeConfigId = 1
--GO
