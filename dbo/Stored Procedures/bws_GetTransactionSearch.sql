

CREATE PROCEDURE [dbo].[bws_GetTransactionSearch] (  
											@FromDate      VARCHAR(50)=NULL,
                                              @ToDate        VARCHAR(50)=NULL,
                                              @TrxType       INT=NULL,
                                              @SiteId        VARCHAR(max)=NULL,
                                              @PosId         VARCHAR(50) =NULL,
                                              @Reference        VARCHAR(50)=NULL,
                                              @TotalValueFrom   VARCHAR(50)=NULL,
                                              @TotalValueTo   VARCHAR(50)=NULL,
                                              @ItemCode      VARCHAR(50)=NULL,                                            
                                              @AnalysisCode1  VARCHAR(50)=NULL,
                                              @AnalysisCode2 VARCHAR(50)=NULL,
                                              @AnalysisCode3 VARCHAR(50)=NULL,
                                              @AnalysisCode4 VARCHAR(50)=NULL,                                             
                                              @DeviceId      VARCHAR(max)=NULL,											  											  
                                              @MaxResult INT=100,
											  @ApplicationNumber NVARCHAR(50)=NULL,
											  @CreateDate VARCHAR(50)=NULL,
											  @Source VARCHAR(50) = NULL,
											  @ClientId       INT=NULL,
											  @BatchId VARCHAR(100) =NULL,
											  @PromotionId		INT=NULL
                                             )
                                              
                                              
AS
  BEGIN
  
      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
      SET NOCOUNT ON;

      DECLARE @sql VARCHAR(MAX);
      DECLARE @where VARCHAR(MAX);     
      DECLARE @totalcount INt;
	  declare @PromotionSpecificFields nvarchar(250), @PromotionSpecificGroupBy nvarchar(max)
      SET @where = '';
      SET @PosId = Replace(@PosId, '*', '%');
      SET @ItemCode = Replace(@ItemCode, '*', '%');
      SET @Reference = Replace(@Reference, '*', '%');
      SET @AnalysisCode1 = Replace(@AnalysisCode1, '*', '%');
      SET @AnalysisCode2 = Replace(@AnalysisCode2, '*', '%');
      SET @AnalysisCode3 = Replace(@AnalysisCode3, '*', '%');
      SET @AnalysisCode4 = Replace(@AnalysisCode4, '*', '%');
      SET @ApplicationNumber =  Replace(@ApplicationNumber, '*', '%');  
	  SET @Source =  Replace(@Source, '*', '%'); 
	   
      SET @PosId = Replace(@PosId, '''', '''''');
      SET @ItemCode = Replace(@ItemCode, '''', '''''');
      SET @Reference = Replace(@Reference, '''', '''''');
      SET @DeviceId = Replace(@DeviceId, '''', '''''');
      SET @DeviceId = Replace(@DeviceId, ',', ''',''');
      SET @SiteId = Replace(@SiteId, '''', '''''');
      SET @AnalysisCode1 = Replace(@AnalysisCode1, '''', '''''');
      SET @AnalysisCode2 = Replace(@AnalysisCode2, '''', '''''');
      SET @AnalysisCode3 = Replace(@AnalysisCode3, '''', '''''');
      SET @AnalysisCode4 = Replace(@AnalysisCode4, '''', '''''');
    

      -- Search Filter
  

        IF ( Len(@DeviceId) > 0 )
        BEGIN
            SET @where = @where + ' AND DeviceId IN (''' + @DeviceId + ''')';
        END

        IF( Len(@fromDate) > 0
          AND Len(@toDate) > 0 )
        BEGIN
            SET @where = @where + ' AND  (TrxDate BETWEEN ''' + @fromDate + ''' AND dateadd(DAY, 1, ''' + @toDate + '''))';
        END

		IF LEN(@CreateDate) > 0
		BEGIN
			-- yyyy-mm-dd format
            SET @CreateDate = Convert(varchar(12), cast (@CreateDate as datetime),23) ;
		 SET @where = @where + ' AND CONVERT(varchar(12),CreateDate,23) = ''' + @CreateDate + '''';
		END

        IF( @trxType != 0 )
        BEGIN
            SET @where = @where + ' AND TrxTypeId = ''' + CONVERT (VARCHAR, @trxType) + '''';
        END

        IF ( Len(@SiteId) > 0 )
        BEGIN
            SET @where = @where + ' AND SiteId IN (' + @SiteId + ')';
        END
      
        IF( Len(@PosId) > 0 )
        BEGIN
            SET @where = @where + ' AND TerminalId = ''' + @PosId + '''';
        END
      
       IF( Len(@Reference) > 0 )
        BEGIN
            SET @where = @where + ' AND Reference = ''' + @Reference + '''';
        END

      IF( Len(@TotalValueFrom) > 0 )
        BEGIN
            SET @where = @where + ' AND TotalValue>= ''' + @TotalValueFrom + '''';
        END

      IF( Len(@TotalValueTo) > 0 )
        BEGIN
            SET @where = @where + ' AND TotalValue<= ''' + @TotalValueTo + '''';
        END
      IF( Len(@ItemCode) > 0 )
        BEGIN
            SET @where = @where + ' AND ItemCode like ''' + @ItemCode + '''';
        END

      IF( Len(@AnalysisCode1) > 0 )
        BEGIN
            SET @where = @where + ' AND Anal1 like ''' + @AnalysisCode1 + '''';
        END

      IF( Len(@AnalysisCode2) > 0 )
        BEGIN
            SET @where = @where + ' AND Anal2 like ''' + @AnalysisCode2 + '''';
        END

      IF( Len(@AnalysisCode3) > 0 )
        BEGIN
            SET @where = @where + ' AND Anal3 like ''' + @AnalysisCode3 + '''';
        END

      IF( Len(@AnalysisCode4) > 0 )
        BEGIN
            SET @where = @where + ' AND Anal4 like ''' + @AnalysisCode4 + '''';
        END  
		
	IF LEN(@ApplicationNumber) > 0
	BEGIN
		SET @where = @where + ' AND ImportUniqueId like ''' + @ApplicationNumber + '''';
	END	  

	IF LEN(@BatchId) > 0
	BEGIN
		SET @where = @where + ' AND BatchId = ''' + @BatchId + '''';
	END	  

	IF LEN (@Source) > 0
	BEGIN
	SET @where = @where + ' AND ExtraInfo like ''' + @Source + '''';
	END
	IF LEN (@ClientId) > 0
	BEGIN
	SET @where = @where + ' AND ClientId =  ''' + CONVERT (VARCHAR(2), @ClientId) + '''';
	END
    Declare @ViewName nvarchar(50)='';
	IF( @PromotionId != 0 )
    BEGIN
	Set @ViewName = 'Transactions'
        SET @where = @where + ' AND PromotionId = ''' + CONVERT (VARCHAR, @PromotionId) + '''';
		set @PromotionSpecificFields = ',PromotionId,sum(StampCount) as Stamps,sum([Value]) as TotalValue'
		set @PromotionSpecificGroupBy = ' group by PromotionId,TrxId,[TrxStatusTypeId],[TrxDate],[DeviceId] ,[TerminalId],[OpId],[ClientId]
      ,[OperatorName],[Reference]  ,[HomeCurrencyCode],[TransactionType],[TotalPoints],[TotalValue],[TotalDiscount]
      ,[TotalBonus] ,[UserId] ,[SiteId] ,[Currency],[SiteName],[ImportUniqueId],[CreateDate],[TotalPromoValue],[TrxStatusName],[BatchId],EposTrxId,CreatedBy,TerminalDescription'
    END
	ELSE
	BEGIN
		set @PromotionSpecificFields = ',[TotalValue],Stamps'
		set @PromotionSpecificGroupBy = ''
		Set @ViewName = 'Transactions_Header'
	END
		--,dbo.RoundPoints([TotalPoints],''RoundPromotionPointsOnBasket'',TrxId) TotalPoints --VOY-727 Little Potato Promotion Value Roundin FROM SP [bws_GetTransactionSearch] 

        SET @sql='SELECT distinct top 500 [TrxId]
      ,[TrxStatusTypeId]
      ,[TrxDate]
      ,[DeviceId] 
      ,[TerminalId]
      ,[OpId]
      ,[ClientId]
      ,[OperatorName]
      ,[Reference]  
      ,[HomeCurrencyCode]
      ,[TransactionType]
      ,[TotalPoints]
      ,[TotalDiscount]
      ,[TotalBonus] 
      ,[UserId]
      ,[SiteId]      
      ,[Currency],[SiteName],[ImportUniqueId],[CreateDate],[TotalPromoValue],[TrxStatusName],[BatchId]
	  ,'''' as ApprovalStatus
	  ,'''' as ApproveRejectReason
      ,0 AS TotalMarketingFundAmount
      ,0 AS TotalSquares
      ,0 AS TotalRebateRate    
      ,0 AS TotalRewardDollarValue	  
	  ,0 AS ReceiptId
	  ,EposTrxId,CreatedBy,TerminalDescription
	  '+@PromotionSpecificFields+'
    from '+@ViewName+'                                               
			WHERE   TrxId<>-1 ' + @where + ' ' + @PromotionSpecificGroupBy;   
 

   EXEC (@sql)

      PRINT @sql
  END
