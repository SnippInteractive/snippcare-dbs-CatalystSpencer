-- =============================================
-- Author:		Binu Jacob Scaria
-- Create date: 11/02/2020
-- Description:	Promotion Mappimg 
-- =============================================
CREATE PROCEDURE [dbo].[epos_PromotionMapToItem] 
	-- Add the parameters for the stored procedure here
	@PromotionId INT,
	@AnalysisCode1 NVARCHAR(50),
	@AnalysisCode2 NVARCHAR(50),
	@AnalysisCode3 NVARCHAR(50),
	@AnalysisCode4 NVARCHAR(50),
	@AnalysisCode5 NVARCHAR(50),
	@AnalysisCode6 NVARCHAR(50),
	@AnalysisCode7 NVARCHAR(50),
	@AnalysisCode8 NVARCHAR(50),
	@AnalysisCode9 NVARCHAR(50),
	@AnalysisCode10 NVARCHAR(50),
	@AnalysisCode11 NVARCHAR(50),
	@AnalysisCode12 NVARCHAR(50),
	@AnalysisCode13 NVARCHAR(50),
	@AnalysisCode14 NVARCHAR(50),
	@AnalysisCode15 NVARCHAR(50),
	@AnalysisCode16 NVARCHAR(50),
	@ItemCode NVARCHAR(50),
	@Type NVARCHAR(50)
AS
BEGIN	
SET NOCOUNT ON;


SELECT  P.Id,P.PromotionItemFlagAnd,pri.ItemIncludeExclude ,pig.Name AS Groups,pri.Code,pit.Name AS AnalysisCode
INTO #PromotionDetail
FROM   [Promotion] p with(nolock)
       inner join [PromotionItem] pri with(nolock)
         on p.Id = pri.PromotionId
       inner join [PromotionItemType] pit with(nolock)
         on pri.PromotionItemTypeId = pit.Id
       left outer join [PromotionItemGroup] pig with(nolock)
         on pig.Id = pri.PromotionItemGroupId

WHERE  p.Id = @PromotionId

--DROP table #PromotionDetail
--SELECT * FROM #PromotionDetail
SELECT DISTINCT Groups INTO #PromotionGroup FROM #PromotionDetail



DECLARE @GroupCount INT,@ValidGroupCount INT,@PromotionItemFlagAndOut INT,@Result INT = 0,@ItemIncludeExcludeFlag NVARCHAR(50)
DECLARE @ValidGroup TABLE (Value int);

SELECT @GroupCount = Count(Groups) FROM #PromotionGroup

		DECLARE @Group NVARCHAR(50)
		DECLARE PromotionGroupCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
		SELECT Groups FROM #PromotionGroup                                     
		OPEN PromotionGroupCursor                                                  
		FETCH NEXT FROM PromotionGroupCursor           
		INTO @Group                                       
		WHILE @@FETCH_STATUS = 0    
		BEGIN
			DECLARE @SQLGroupOR NVARCHAR(MAX) = '('

			DECLARE @Id INT,@PromotionItemFlagAnd INT ,@ItemIncludeExclude NVARCHAR(50) ,@Groups NVARCHAR(50),@Code NVARCHAR(50),@AnalysisCode NVARCHAR(50)                                                                   
			DECLARE PromotionDetailCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
			SELECT Id,PromotionItemFlagAnd,ItemIncludeExclude ,Groups,Code,AnalysisCode FROM #PromotionDetail WHERE  Groups  =  @Group                          
			OPEN PromotionDetailCursor                                                  
			FETCH NEXT FROM PromotionDetailCursor           
			INTO @Id ,@PromotionItemFlagAnd ,@ItemIncludeExclude ,@Groups ,@Code ,@AnalysisCode                                       
			WHILE @@FETCH_STATUS = 0    
			BEGIN
				SET @PromotionItemFlagAndOut = @PromotionItemFlagAnd
				SET @ItemIncludeExcludeFlag = ISNULL(@ItemIncludeExclude,'IncludeItem')
				IF ISNULL(@AnalysisCode,'')='AnalysisCode1'  
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode1,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode1'' AND Code = '''+@AnalysisCode1+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode1,'') = @Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode1'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode1'' AND Code = '''+@AnalysisCode1+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='AnalysisCode2'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode2,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode2'' AND Code = '''+@AnalysisCode2+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode2,'')=@Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode2'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode2'' AND Code = '''+@AnalysisCode2+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='AnalysisCode3'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode3,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode3'' AND Code = '''+@AnalysisCode3+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode3,'')=@Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode3'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode3'' AND Code = '''+@AnalysisCode3+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='AnalysisCode4'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode4,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode4'' AND Code = '''+@AnalysisCode4+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode4,'')=@Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode4'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode4'' AND Code = '''+@AnalysisCode4+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='AnalysisCode5'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode5,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode5'' AND Code = '''+@AnalysisCode5+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode5,'')=@Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode5'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode5'' AND Code = '''+@AnalysisCode5+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='AnalysisCode6'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode6,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode6'' AND Code = '''+@AnalysisCode6+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode6,'') = @Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode6'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode6'' AND Code = '''+@AnalysisCode6+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='AnalysisCode7'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode7,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode7'' AND Code = '''+@AnalysisCode7+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode7,'')=@Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode7'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode7'' AND Code = '''+@AnalysisCode7+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='AnalysisCode8'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode8,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode8'' AND Code = '''+@AnalysisCode8+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode8,'')=@Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode8'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode8'' AND Code = '''+@AnalysisCode8+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='AnalysisCode9'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode9,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode9'' AND Code = '''+@AnalysisCode9+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode9,'')=@Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode9'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode9'' AND Code = '''+@AnalysisCode9+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='AnalysisCode10'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode10,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode10'' AND Code = '''+@AnalysisCode10+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode10,'')=@Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode10'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode10'' AND Code = '''+@AnalysisCode10+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='AnalysisCode11'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode11,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode11'' AND Code = '''+@AnalysisCode11+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode11,'')=@Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode11'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode11'' AND Code = '''+@AnalysisCode11+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='AnalysisCode12'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode12,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode12'' AND Code = '''+@AnalysisCode12+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode12,'')=@Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode12'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode12'' AND Code = '''+@AnalysisCode12+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='AnalysisCode13'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode13,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode13'' AND Code = '''+@AnalysisCode13+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode13,'')=@Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode13'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode13'' AND Code = '''+@AnalysisCode13+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='AnalysisCode14'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode14,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode14'' AND Code = '''+@AnalysisCode14+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode14,'')=@Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode14'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode14'' AND Code = '''+@AnalysisCode14+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='AnalysisCode15'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode15,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode15'' AND Code = '''+@AnalysisCode15+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode15,'')=@Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode15'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode15'' AND Code = '''+@AnalysisCode15+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='AnalysisCode16'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@AnalysisCode16,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode16'' AND Code = '''+@AnalysisCode16+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@AnalysisCode16,'')=@Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode16'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''AnalysisCode16'' AND Code = '''+@AnalysisCode16+''' '
						END
					END
				END
				ELSE IF ISNULL(@AnalysisCode,'')='ItemCode'
				BEGIN
					IF ISNULL(@ItemIncludeExclude,'')='IncludeItem' AND ISNULL(@ItemCode,'')!=''
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						SET @SQLGroupOR += ' AnalysisCode = ''ItemCode'' AND Code = '''+@ItemCode+''' '
					END
					ELSE IF ISNULL(@ItemIncludeExclude,'')='ExcludeItem'
					BEGIN
						IF ISNULL(@SQLGroupOR,'(') !='(' BEGIN SET @SQLGroupOR += ' OR ' END
						IF ISNULL(@ItemCode,'')=@Code
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''ItemCode'' AND Code = '''+@Code+''' '
						END
						ELSE
						BEGIN
							SET @SQLGroupOR += ' AnalysisCode = ''ItemCode'' AND Code = '''+@ItemCode+''' '
						END
					END
				END
			FETCH NEXT FROM PromotionDetailCursor     
			INTO @Id ,@PromotionItemFlagAnd ,@ItemIncludeExclude ,@Groups ,@Code ,@AnalysisCode
			END     
			CLOSE PromotionDetailCursor;    
			DEALLOCATE PromotionDetailCursor; 

			SET @SQLGroupOR += ')'
			PRINT @SQLGroupOR
			IF ISNULL(@SQLGroupOR,'(')!= '(' AND ISNULL(@SQLGroupOR,'()')!= '()' AND ISNULL(@SQLGroupOR,'')!= ''
			BEGIN
				IF ISNULL(@ItemIncludeExcludeFlag,'')='ExcludeItem'
				BEGIN
					DECLARE @ValidExclude TABLE (Value int)
					INSERT INTO @ValidExclude EXEC('SELECT  Count(Distinct AnalysisCode) FROM #PromotionDetail WHERE' +@SQLGroupOR)
					if exists (SELECT 1 FROM @ValidExclude WHERE ISNULL(Value,0) >0)
					BEGIN
						INSERT INTO @ValidGroup Values(0)
						PRINT 'ExcludeItem'
					END 
					ELSE
					BEGIN
						INSERT INTO @ValidGroup Values(1)
						PRINT 'IncludeItem Flag'
						--INSERT INTO @ValidGroup EXEC('SELECT  Count(Distinct AnalysisCode) FROM #PromotionDetail WHERE' +@SQLGroupOR)
					END
				END
				ELSE
				BEGIN
					PRINT 'IncludeItem'
					INSERT INTO @ValidGroup EXEC('SELECT  Count(Distinct AnalysisCode) FROM #PromotionDetail WHERE' +@SQLGroupOR)
				END
			END
			SET @SQLGroupOR = ''
		FETCH NEXT FROM PromotionGroupCursor     
		INTO @Group
		END     
		CLOSE PromotionGroupCursor;    
		DEALLOCATE PromotionGroupCursor; 
		--SELECT * FROM @ValidGroup
		SELECT @ValidGroupCount=Count(Value) FROM @ValidGroup  WHERE Value != 0
		IF ISNULL(@PromotionItemFlagAndOut,0) = 1
		BEGIN
			
			IF @GroupCount = @ValidGroupCount
			BEGIN
				SET @Result = 1
			END
			ELSE
			BEGIN
				SET @Result = 0
			END
		END
		ELSE IF ISNULL(@ValidGroupCount,0)!= 0
		BEGIN
			SET @Result = 1
		END
		ELSE
		BEGIN
			SET @Result = 0
		END

		SELECT @Result AS Result

--exec epos_PromotionMapToItem
--1323 /* @p0 */,
--'AT6661' /* @p1 */,
--'' /* @p2 */,
--'' /* @p3 */,
--'' /* @p4 */,
--'' /* @p5 */,
--'' /* @p6 */,
--'' /* @p7 */,
--'' /* @p8 */,
--'' /* @p9 */,
--'' /* @p10 */,
--'' /* @p11 */,
--'' /* @p12 */,
--'' /* @p13 */,
--'' /* @p14 */,
--'' /* @p15 */,
--'' /* @p16 */,
--'8408015990' /* @p17 */,
--'LineItem' /* @p18 */

END