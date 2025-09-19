-- =============================================
-- Author:		Noel Sebbey
-- Create date: 28 October 2014
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[ComputeAddressMatchingWeightValue]
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
			WHEN @FirstWord IS NOT NULL OR @SecondWord IS NOT NULL
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
															WHEN [dbo].[Jaro](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScoreFirstLetterMatch
																THEN @ScoreFirstLetterMatch
															ELSE
																[dbo].[Jaro](@FirstWord, @SecondWord)*@ScoreExactMatch
														END)
												WHEN @SimilarityMetricId = 2
													THEN
														(CASE
															WHEN [dbo].[JaroWinkler](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScoreFirstLetterMatch
																THEN @ScoreFirstLetterMatch
															ELSE
																[dbo].[JaroWinkler](@FirstWord, @SecondWord)*@ScoreExactMatch
														END)
												WHEN @SimilarityMetricId = 3
													THEN
														(CASE
															WHEN [dbo].[Levenstein](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScoreFirstLetterMatch
																THEN @ScoreFirstLetterMatch
															ELSE
																[dbo].[Levenstein](@FirstWord, @SecondWord)*@ScoreExactMatch
														END)
												WHEN @SimilarityMetricId = 4
													THEN
														(CASE
															WHEN [dbo].[MongeElkan](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScoreFirstLetterMatch
																THEN @ScoreFirstLetterMatch
															ELSE
																[dbo].[MongeElkan](@FirstWord, @SecondWord)*@ScoreExactMatch
														END)
												WHEN @SimilarityMetricId = 5
													THEN
														(CASE
															WHEN [dbo].[NeedlemanWunch](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScoreFirstLetterMatch
																THEN @ScoreFirstLetterMatch
															ELSE
																[dbo].[NeedlemanWunch](@FirstWord, @SecondWord)*@ScoreExactMatch
														END)
												WHEN @SimilarityMetricId = 6
													THEN
														(CASE
															WHEN [dbo].[SmithWaterman](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScoreFirstLetterMatch
																THEN @ScoreFirstLetterMatch
															ELSE
																[dbo].[SmithWaterman](@FirstWord, @SecondWord)*@ScoreExactMatch
														END)
												WHEN @SimilarityMetricId = 7
													THEN
														(CASE
															WHEN [dbo].[SmithWatermanGotoh](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScoreFirstLetterMatch
																THEN @ScoreFirstLetterMatch
															ELSE
																[dbo].[SmithWatermanGotoh](@FirstWord, @SecondWord)*@ScoreExactMatch
														END)
												WHEN @SimilarityMetricId = 8
													THEN
														(CASE
															WHEN [dbo].[SmithWatermanGotohWindowedAffine](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScoreFirstLetterMatch
																THEN @ScoreFirstLetterMatch
															ELSE
																[dbo].[SmithWatermanGotohWindowedAffine](@FirstWord, @SecondWord)*@ScoreExactMatch
														END)
											END)
									ELSE 0
								END)
						ELSE
							(CASE
								WHEN @FirstWord LIKE @SecondWord + '%' OR @SecondWord LIKE @FirstWord + '%'
									THEN
										(CASE
											WHEN @SimilarityMetricId = 1
												THEN
													(CASE
														WHEN [dbo].[Jaro](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScorePartialMatch
															THEN @ScorePartialMatch
														ELSE
															[dbo].[Jaro](@FirstWord, @SecondWord)*@ScoreExactMatch
													END)
											WHEN @SimilarityMetricId = 2
												THEN
													(CASE
														WHEN [dbo].[JaroWinkler](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScorePartialMatch
															THEN @ScorePartialMatch
														ELSE
															[dbo].[JaroWinkler](@FirstWord, @SecondWord)*@ScoreExactMatch
													END)
											WHEN @SimilarityMetricId = 3
												THEN
													(CASE
														WHEN [dbo].[Levenstein](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScorePartialMatch
															THEN @ScorePartialMatch
														ELSE
															[dbo].[Levenstein](@FirstWord, @SecondWord)*@ScoreExactMatch
													END)
											WHEN @SimilarityMetricId = 4
												THEN
													(CASE
														WHEN [dbo].[MongeElkan](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScorePartialMatch
															THEN @ScorePartialMatch
														ELSE
															[dbo].[MongeElkan](@FirstWord, @SecondWord)*@ScoreExactMatch
													END)
											WHEN @SimilarityMetricId = 5
												THEN
													(CASE
														WHEN [dbo].[NeedlemanWunch](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScorePartialMatch
															THEN @ScorePartialMatch
														ELSE
															[dbo].[NeedlemanWunch](@FirstWord, @SecondWord)*@ScoreExactMatch
													END)
											WHEN @SimilarityMetricId = 6
												THEN
													(CASE
														WHEN [dbo].[SmithWaterman](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScorePartialMatch
															THEN @ScorePartialMatch
														ELSE
															[dbo].[SmithWaterman](@FirstWord, @SecondWord)*@ScoreExactMatch
													END)
											WHEN @SimilarityMetricId = 7
												THEN
													(CASE
														WHEN [dbo].[SmithWatermanGotoh](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScorePartialMatch
															THEN @ScorePartialMatch
														ELSE
															[dbo].[SmithWatermanGotoh](@FirstWord, @SecondWord)*@ScoreExactMatch
													END)
											WHEN @SimilarityMetricId = 8
												THEN
													(CASE
														WHEN [dbo].[SmithWatermanGotohWindowedAffine](@FirstWord, @SecondWord)*@ScoreExactMatch <= @ScorePartialMatch
															THEN @ScorePartialMatch
														ELSE
															[dbo].[SmithWatermanGotohWindowedAffine](@FirstWord, @SecondWord)*@ScoreExactMatch
													END)
										END)
								ELSE
									(CASE
										WHEN @SimilarityMetricId = 1
											THEN [dbo].[Jaro](@FirstWord, @SecondWord)*@ScoreExactMatch
										WHEN @SimilarityMetricId = 2
											THEN [dbo].[JaroWinkler](@FirstWord, @SecondWord)*@ScoreExactMatch
										WHEN @SimilarityMetricId = 3
											THEN [dbo].[Levenstein](@FirstWord, @SecondWord)*@ScoreExactMatch
										WHEN @SimilarityMetricId = 4
											THEN [dbo].[MongeElkan](@FirstWord, @SecondWord)*@ScoreExactMatch
										WHEN @SimilarityMetricId = 5
											THEN [dbo].[NeedlemanWunch](@FirstWord, @SecondWord)*@ScoreExactMatch
										WHEN @SimilarityMetricId = 6
											THEN [dbo].[SmithWaterman](@FirstWord, @SecondWord)*@ScoreExactMatch
										WHEN @SimilarityMetricId = 7
											THEN [dbo].[SmithWatermanGotoh](@FirstWord, @SecondWord)*@ScoreExactMatch
										WHEN @SimilarityMetricId = 8
											THEN [dbo].[SmithWatermanGotohWindowedAffine](@FirstWord, @SecondWord)*@ScoreExactMatch
									END)
							END)
					END)
			ELSE 0
		END)
	RETURN @WeightValue;
END
