CREATE PROCEDURE [dbo].[ExportUserTransactions_WIP] (      											                                               
                                            @SiteId        INT=NULL,                                                       
                                            @DeviceId      VARCHAR(max)=NULL,    
                                            @MaxResult INT=50000 ,   
											@IsAnonymous BIT = 0,
											@UserId INT=NULL  ,
											@ClientId INT
                                             )    
                                                  
                                                  
AS    
  BEGIN    
      
      -- SET NOCOUNT ON added to prevent extra result sets from    
      -- interfering with SELECT statements.    
      SET NOCOUNT ON;    
  
        
    DECLARE @sql VARCHAR(MAX);    
    DECLARE @where VARCHAR(MAX);   
	DECLARE @sqluser VARCHAR(MAX);         
    DECLARE @totalcount INt;    
    SET @where = '';                            
    SET @DeviceId = Replace(@DeviceId, '''', '''''');    
    SET @DeviceId = Replace(@DeviceId, ',', ''',''');             
           
	if(len(@UserId)>0)  
	BEGIN  
	SET @where = @where + ' AND UserId = ''' + CONVERT (VARCHAR, @UserId) + '''';    
	END  
  
	IF ( Len(@DeviceId) > 0 )  
   BEGIN    
    SET @where = @where + ' AND DeviceId IN (''' + @DeviceId + ''')';    
   END  
     
	IF ( @SiteId > 0 )    
	BEGIN    
		SET @where = @where + ' AND SiteId ='''+ CONVERT (VARCHAR, @SiteId) +'''';    
	END    
               
	--IF(@IsAnonymous = 0)
	--BEGIN
	--	SET @where = @where + ' AND IsAnonymous <> 1';
	--END          
 

DROP TABLE IF EXISTS #TrxData
DROP TABLE IF EXISTS #StampCardDistinctData
DROP TABLE IF EXISTS #StampCardData

 CREATE TABLE #TrxData            
 (            
	TrxId INT,  trxstatustypeid INT,trxdate datetime,deviceid nvarchar(25),terminalid nvarchar(25),opid nvarchar(100),clientid INT,operatorname nvarchar(10) ,reference nvarchar(50),transactiontype nvarchar(50),
	totalpoints float,totalvalue money,totaldiscount money,totalbonus float,userid INT,siteid INT,currency nchar(3),trxstatustype nvarchar(50),siteName nvarchar(250),
	NumberOfStamps int,
	RollingBalanceByTrxDateIncVoid float
 )

SET @sql='  
  INSERT INTO #TrxData  
  SELECT DISTINCT TOP 50000
	T.[trxid],[trxstatustypeid],[trxdate],[deviceid],[terminalid],[opid],T.[clientid],[operatorname],[reference],[transactiontype],
	[totalpoints],[totalvalue],[totaldiscount],[totalbonus],[userid],T.[siteid],[currency],TrxStatusName AS trxstatustype,companyName AS siteName,	 
	case  when [transactiontype] = ''ManualClaim'' and [totalvalue] < 0 then [totalvalue] else Stamps end as NumberOfStamps,
	
	Sum(totalpoints)
	  OVER (
		partition BY userid
		ORDER BY trxdate) AS RollingBalanceByTrxDateIncVoid   
  from Transactions T                                                 
  WHERE TrxId<>-1 AND CLIENTID = '+CONVERT (VARCHAR, @ClientId)+' ' + @where  + 
  ' GROUP  BY T.trxid,[trxstatustypeid],[trxdate],[deviceid],[terminalid],[opid],T.[clientid],[operatorname],
	[reference],[transactiontype],[totalpoints],[totalvalue],[totaldiscount],[totalbonus],[userid],T.[siteid],
	[currency],TrxStatusName, companyname,Stamps
	';       
     
    EXEC (@sql)  


	---------------------------------------------------------------------------------------------------------------------
	CREATE TABLE #StampCardDistinctData            
	(            
		PromoName NVARCHAR(250), TrxId INT
	)
	IF EXISTS (SELECT 1 FROM ClientConfig WHERE ClientId = @ClientId and [Key] = 'EnableStampManualClaim' AND [Value] = 'true')
	BEGIN
		INSERT INTO #StampCardDistinctData
		SELECT distinct  pd.[Name] as PromoName,td.TrxId TrxId
				FROM TrxDetail td with(nolock) 
				inner join TrxDetailStampCard tds with(nolock) on tds.TrxDetailId = td.trxDetailId
				LEFT JOIN Promotion pd with(nolock) on pd.Id = tds.PromotionId
				WHERE td.TrxId IN (SELECT trxid FROM   #TrxData)
				ORDER BY pd.[Name] 
	END
	
	
	---------------------------------------------------------------------------------------------------------------------

	CREATE TABLE #StampCardData            
	(            
		StampCardsInvolved NVARCHAR(max), TrxId INT
	)
	INSERT INTO #StampCardData 
	SELECT  STRING_AGG(detStamp.PromoName,', ') as StampCardsInvolved,detStamp.TrxId
	FROM	 #StampCardDistinctData as detStamp
	GROUP BY detStamp.TrxId

	---------------------------------------------------------------------------------------------------------------------

	SELECT trxD.TrxId, trxD.trxstatustypeid,trxD.trxdate,trxD.deviceid,trxD.terminalid,trxD.opid,trxD.clientid,trxD.operatorname,trxD.reference,trxD.transactiontype,
		trxD.totalpoints,trxD.totalvalue,trxD.totaldiscount,trxD.totalbonus,trxD.userid,trxD.siteid,trxD.currency,trxD.trxstatustype,trxD.siteName,
		trxD.NumberOfStamps,
		stampD.StampCardsInvolved,
		trxD.RollingBalanceByTrxDateIncVoid
	FROM #TrxData trxD 
		LEFT JOIN #StampCardData stampD ON trxD.TrxId = stampD.TrxId
	ORDER  BY trxD.trxdate
  
  END
