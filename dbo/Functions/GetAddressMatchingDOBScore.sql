
-- ===========================================================================================================================================
-- Author:		Noel Sebbey
-- Create date: 28 October 2014
-- Update date: 05 March 2015
-- Description:	This function calculates the score of date of birth for address matching based on the similarity of year, day and month
--				of the date and whether it was specified or not
--				The following conditions determine the weight value for the date of birth:
--				1)	Matching specified date																		(ie. both '1980-08-19')				= 100%
--				2)	Matching specified month and day, only one specified year									(ie. '1980-08-19' & '1900-08-19')	= 100%
--				3)	Matching specified month and day, different specified years									(ie. '1980-08-19' & '1960-08-19')	= 50%
--				4)	Matching unspecified date																	(ie. both '1900-01-01')				= 100%
--				5)	Only one specified date																		(ie. '1980-08-19' & '1900-01-01')	= 50%
--				6)	Same specified year but same month and different day, or same day and different month		(ie. '1980-08-19' & '1980-08-09')	= 50%
--				7)	Same unspecified year but same month and different day, or same day and different month		(ie. '1900-08-19' & '1900-08-09')	= 50%
--				8)	Different specified year but same month and different day, or same day and different month	(ie. '1980-08-19' & '1960-06-19')	= 0%
--				9)	Completely different dates																	(ie. '1980-08-19' & '1960-06-16')	= 0%
--
--				@FirstDOB			- The first date of birth to be compared for similarity
--				@SecondDOB			- The second date of birth to be compared for similarity
--				@ScoreDateOfBirth	- The weight value for date of birth if a match of day and month, or day, month and year is found
-- ===========================================================================================================================================
CREATE FUNCTION [dbo].[GetAddressMatchingDOBScore]
(
	@FirstDOB datetime,
	@SecondDOB datetime,
	@ScoreDateOfBirth float
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @WeightValue as float;
	
	SELECT @WeightValue =
	 (CASE
			WHEN @FirstDOB = @SecondDOB
				THEN
					(CASE
						WHEN (YEAR(@FirstDOB) = 1900 AND MONTH(@FirstDOB) = 1 AND DAY(@FirstDOB) = 1)
							THEN @ScoreDateOfBirth --4)
						ELSE @ScoreDateOfBirth --1 )
					END)
			ELSE
				(CASE
					WHEN MONTH(@FirstDOB) = MONTH(@SecondDOB) AND DAY(@FirstDOB) = DAY(@SecondDOB)
						THEN
							(CASE 
								WHEN YEAR(@FirstDOB) = 1900 OR YEAR(@SecondDOB) = 1900
									THEN @ScoreDateOfBirth --2 )
								ELSE @ScoreDateOfBirth*0.5 --3)
							END) 
					ELSE
						(CASE
							WHEN (YEAR(@FirstDOB) = 1900 and YEAR(@SecondDOB) = 1900) 
								AND (MONTH(@FirstDOB) = MONTH(@SecondDOB) AND DAY(@FirstDOB) <> DAY(@SecondDOB))
								OR (MONTH(@FirstDOB) <> MONTH(@SecondDOB) AND DAY(@FirstDOB) = DAY(@SecondDOB))
								THEN @ScoreDateOfBirth*0.25 -- 7)
							WHEN YEAR(@FirstDOB) = 1900 OR YEAR(@SecondDOB) = 1900
								THEN @ScoreDateOfBirth --5) 
									/*(CASE
										WHEN (MONTH(@FirstDOB) = 1 AND DAY(@FirstDOB) = 1) OR (MONTH(@SecondDOB) = 1 AND DAY(@SecondDOB) = 1)
											THEN @ScoreDateOfBirth*0.5 --5)
										ELSE @ScoreDateOfBirth*0.5 --7)
									END)*/
							ELSE
								(CASE
									WHEN YEAR(@FirstDOB) = YEAR(@SecondDOB)	AND (MONTH(@FirstDOB) = MONTH(@SecondDOB) OR DAY(@FirstDOB) = DAY(@SecondDOB))
										THEN @ScoreDateOfBirth*0.5 --6)
									when (YEAR(@FirstDOB) <> YEAR(@SecondDOB)) and ((MONTH(@FirstDOB) = MONTH(@SecondDOB) OR DAY(@FirstDOB) <> DAY(@SecondDOB)) or(MONTH(@FirstDOB) <> MONTH(@SecondDOB) OR DAY(@FirstDOB) = DAY(@SecondDOB)))
									then @ScoreDateOfBirth*0.25 --8)
									ELSE 0 -- 9)
								END)
						END)
				END)
		END)


		--(CASE
		--	WHEN @FirstDOB = @SecondDOB
		--		THEN
		--			(CASE
		--				WHEN (YEAR(@FirstDOB) = 1900 AND MONTH(@FirstDOB) = 1 AND DAY(@FirstDOB) = 1)
		--					THEN @ScoreDateOfBirth --4)
		--				ELSE @ScoreDateOfBirth --1)
		--			END)
		--	ELSE
		--		(CASE
		--			WHEN MONTH(@FirstDOB) = MONTH(@SecondDOB) AND DAY(@FirstDOB) = DAY(@SecondDOB)
		--				THEN
		--					(CASE 
		--						WHEN YEAR(@FirstDOB) = 1900 OR YEAR(@SecondDOB) = 1900
		--							THEN @ScoreDateOfBirth --2)
		--						ELSE @ScoreDateOfBirth*0.5 --3)
		--					END) 
		--			ELSE
		--				(CASE
		--					WHEN YEAR(@FirstDOB) = 1900 OR YEAR(@SecondDOB) = 1900
		--						THEN
		--							@ScoreDateOfBirth*0.5 --5) & 7)
		--							/*(CASE
		--								WHEN (MONTH(@FirstDOB) = 1 AND DAY(@FirstDOB) = 1) OR (MONTH(@SecondDOB) = 1 AND DAY(@SecondDOB) = 1)
		--									THEN @ScoreDateOfBirth*0.5 --5)
		--								ELSE @ScoreDateOfBirth*0.5 --7)
		--							END)*/
		--					ELSE
		--						(CASE
		--							WHEN YEAR(@FirstDOB) = YEAR(@SecondDOB)
		--							AND (MONTH(@FirstDOB) = MONTH(@SecondDOB) OR DAY(@FirstDOB) = DAY(@SecondDOB))
		--								THEN @ScoreDateOfBirth*0.5 --6)
		--							ELSE 0 --8) & 9)
		--						END)
		--				END)
		--		END)
		--END)
	RETURN @WeightValue;
END
