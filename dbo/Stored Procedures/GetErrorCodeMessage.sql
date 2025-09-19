
CREATE PROCEDURE [dbo].[GetErrorCodeMessage] ( @ClientId int,@TranslationGroup nvarchar(50),@TranslationGroupKey nvarchar(150),@LanguageCode varchar(5), @Result nvarchar(200) output)  
                                                
                                                
AS  
  BEGIN  
    
      -- SET NOCOUNT ON added to prevent extra result sets from  
      -- interfering with SELECT statements.  
     SET NOCOUNT ON;
	 
     if isnull(@ClientId,0) = 0
	 BEGIN
		select top 1 @ClientId = clientid from client
	 END

     DECLare @Message varchar(200)
	 set @Message=(
      select top 1 isnull(value,'no translations found') as Result  from translations where clientid=@ClientId and TranslationGroup=@TranslationGroup and LanguageCode=@LanguageCode and TranslationGroupKey=@TranslationGroupKey
     )

	 select isnull(@Message,'no translations found') as Result
   
  END
