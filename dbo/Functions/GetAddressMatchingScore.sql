
-- ===========================================================================================================================================
-- Author:		Noel Sebbey
-- Create date: 28 October 2014
-- Description:	This function calculates the score for address matching based on the similarity of two strings
--				on the conditions of an exact match, partial match or first letter match, or from similarity metric, whichever is the highest.
--				@SimilarityMetricId		- The id given to determine the similarity metric to be used in which 1 = JaroWinkler, 2 = Levenstein
--				@FirstWord				- The first string to be compared for similarity
--				@SecondWord				- The second string to be compared fir similarity
--				@ScoreExactMatch		- The weight value if an exact match is found between the two strings
--				@ScorePartialMatch		- The weight value if a partial match is found between the two strings
--				@ScoreFirstLetterMatch	- The weight value if a first letter match is found between the two strings
-- ===========================================================================================================================================
CREATE FUNCTION [dbo].[GetAddressMatchingScore]
(
	@SimilarityMetricId int,
	@FirstWord nvarchar(80),
	@SecondWord nvarchar(80),
	@ScoreExactMatch float,
	@ScorePartialMatch float,
	@ScoreFirstLetterMatch float = 0
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @WeightValue as float;
	
	SELECT @WeightValue =
		(CASE
			WHEN (@FirstWord IS NOT NULL OR @SecondWord IS NOT NULL) AND (@FirstWord <> '' OR @SecondWord <> '')
				THEN
					(CASE
						WHEN LEN(@FirstWord) = 1 OR LEN(@SecondWord) = 1
							THEN
								(CASE
									WHEN SUBSTRING(@FirstWord, 1, 1) = @SecondWord OR SUBSTRING(@SecondWord, 1, 1) = @FirstWord
										THEN
											(CASE
												WHEN @SimilarityMetricId = 1
													THEN
														(CASE
															WHEN [dbo].[JaroWinkler](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScoreFirstLetterMatch
																THEN @ScoreFirstLetterMatch
															ELSE [dbo].[JaroWinkler](@FirstWord, @SecondWord)*@ScoreExactMatch
														END)
												WHEN @SimilarityMetricId = 2
													THEN
														(CASE
															WHEN [dbo].[Levenstein](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScoreFirstLetterMatch
																THEN @ScoreFirstLetterMatch
															ELSE [dbo].[Levenstein](@FirstWord, @SecondWord)*@ScoreExactMatch
														END)
											END)
									ELSE 0
								END)
						ELSE
							(CASE
								WHEN (@FirstWord LIKE '%' + @SecondWord + '%' AND @SecondWord <> '')
									OR (@SecondWord LIKE '%' + @FirstWord + '%' AND @FirstWord <> '')
									THEN
										(CASE
											WHEN @SimilarityMetricId = 1
												THEN
													(CASE
														WHEN [dbo].[JaroWinkler](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScorePartialMatch
															THEN @ScorePartialMatch
														ELSE [dbo].[JaroWinkler](@FirstWord, @SecondWord)*@ScoreExactMatch
													END)
											WHEN @SimilarityMetricId = 2
												THEN
													(CASE
														WHEN [dbo].[Levenstein](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScorePartialMatch
															THEN @ScorePartialMatch
														ELSE [dbo].[Levenstein](@FirstWord, @SecondWord)*@ScoreExactMatch
													END)
										END)
								ELSE
									(CASE
										WHEN @SimilarityMetricId = 1
											THEN [dbo].[JaroWinkler](@FirstWord, @SecondWord)*@ScoreExactMatch
										WHEN @SimilarityMetricId = 2
											THEN [dbo].[Levenstein](@FirstWord, @SecondWord)*@ScoreExactMatch
									END)
							END)
					END)
			ELSE 0
		END)
	RETURN @WeightValue;
END
