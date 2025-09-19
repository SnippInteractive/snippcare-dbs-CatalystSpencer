CREATE Procedure [SSISHelper].[ImportProducts] as 
Begin
/*
1. check if the field exists for the Import Status, if not add it
*/
IF NOT EXISTS(SELECT * FROM sys.columns  WHERE Name = N'ImportStatus'
      AND Object_ID = Object_ID(N'[SSISHelper].[ProductInfo_Import]'))
BEGIN
	alter table [SSISHelper].[ProductInfo_Import] add ImportStatus nvarchar(10) null
END
/* 
2. for the Import Status field
If there are NULL values, update to 'READY' as these are the new ones to import
*/
update [SSISHelper].[ProductInfo_Import] set ImportStatus = 'READY' where importstatus is null
/*
3. Select the ones that already exist in the PRODUCTINFO FILE
If exists, update them as well as the version 
*/
Update PIF set pif.importdate = pii.importdate, PIF.[Version] = PIF.[Version] +1
,PIF.[ProductDescription]=PII.[ProductDescription]
,PIF.[AnalysisCode1]=PII.[AnalysisCode1],PIF.[AnalysisCode2]=PII.[AnalysisCode2]
,PIF.[AnalysisCode3]=PII.[AnalysisCode3],PIF.[AnalysisCode4]=PII.[AnalysisCode4]
,PIF.[AnalysisCode5]=PII.[AnalysisCode5],PIF.[AnalysisCode6]=PII.[AnalysisCode6]
,PIF.[AnalysisCode7]=PII.[AnalysisCode7],PIF.[AnalysisCode8]=PII.[AnalysisCode8]
,PIF.[AnalysisCode9]=PII.[AnalysisCode9],PIF.[AnalysisCode10]=PII.[AnalysisCode10]
,PIF.[AnalysisCode11]=PII.[AnalysisCode11],PIF.[AnalysisCode12]=PII.[AnalysisCode12]
,PIF.[AnalysisCode13]=PII.[AnalysisCode13],PIF.[AnalysisCode14]=PII.[AnalysisCode14]
,PIF.[AnalysisCode15]=PII.[AnalysisCode15]
FROM [SSISHelper].[ProductInfo_Import] PII join [ProductInfo] PIF 
on PII.ProductID=PIF.PRODUCTID collate database_default
where ImportStatus = 'READY'
/*
4. Select the ones that already exist in the PRODUCTINFO FILE
If exists, update STATUS on the Import Table
*/
Update PII Set ImportStatus='Updated' 
FROM [SSISHelper].[ProductInfo_Import] PII join [ProductInfo] PIF 
on PII.ProductID=PIF.PRODUCTID collate database_default
where PII.ImportStatus = 'READY'
/*
4. Select the ones that DO NOT exist in the PRODUCTINFO FILE, These are marked still as READY
For these just append to the PRODUCTINFO table
*/
Insert into ProductInfo (
 [Version],[ClientID],[ProductID],[ProductDescription]
,[AnalysisCode1],[AnalysisCode2],[AnalysisCode3],[AnalysisCode4]
,[AnalysisCode5],[AnalysisCode6],[AnalysisCode7],[AnalysisCode8]
,[AnalysisCode9],[AnalysisCode10],[AnalysisCode11],[AnalysisCode12]
,[AnalysisCode13],[AnalysisCode14],[AnalysisCode15],[ImportDate]
)
SELECT PII.[Version],PII.[ClientID],PII.[ProductID],PII.[ProductDescription]
,PII.[AnalysisCode1],PII.[AnalysisCode2],PII.[AnalysisCode3],PII.[AnalysisCode4]
,PII.[AnalysisCode5],PII.[AnalysisCode6],PII.[AnalysisCode7],PII.[AnalysisCode8]
,PII.[AnalysisCode9],PII.[AnalysisCode10],PII.[AnalysisCode11]
,PII.[AnalysisCode12],PII.[AnalysisCode13],PII.[AnalysisCode14],PII.[AnalysisCode15]
,PII.[ImportDate]
FROM [SSISHelper].[ProductInfo_Import] PII 
where ImportStatus = 'READY'  

/*
5. Select the ones that DO NOT exist in the PRODUCTINFO FILE, These are marked still as READY
Update the status of them in the Import file
*/

Update PII Set ImportStatus='Inserted' 
FROM [SSISHelper].[ProductInfo_Import] PII 
where PII.ImportStatus = 'READY'
/*
If the AnalysisCode Field is empty (zero length string) replace it with the word 'NULL'
*/
update ProductInfo set AnalysisCode2 = 'NULL' where isnull(AnalysisCode2,'')=''
update ProductInfo set AnalysisCode4 = 'NULL' where isnull(AnalysisCode4,'')=''
update ProductInfo set AnalysisCode5 = 'NULL' where isnull(AnalysisCode5,'')=''
update ProductInfo set AnalysisCode6 = 'NULL' where isnull(AnalysisCode6,'')=''
--update ProductInfo set AnalysisCode7 = 'NULL' where isnull(AnalysisCode4,'')=''

update ProductInfo set AnalysisCode2 = ltrim(rtrim(Analysiscode2)) 
update ProductInfo set AnalysisCode4 = ltrim(rtrim(Analysiscode4)) 
--Modify Anlaysiscode4 with XX so that these two transfer skus will get punches
update productinfo set AnalysisCode4='MI901PRICEZEROXX' where productid='04237525'
update productinfo set AnalysisCode4='MI901PRICEZEROXX' where productid='04237517'
End