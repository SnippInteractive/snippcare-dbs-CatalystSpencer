CREATE PROCEDURE [DBHelper].[CreateReferenceData]
@ClientName NVARCHAR (100)
AS
BEGIN

DECLARE @ClientID INT
SELECT @ClientID = ClientId from Client where Name = @ClientName
PRINT @Clientid

DECLARE @TypeName nvarchar(100)
DECLARE @TypeValues string_list2  --  (value, value2, display)  where Value is used for TranslationGroupKey and following "DeCamelCasing" also for Value

 
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- USER RELATEDpoints
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

BEGIN TRANSACTION 
DELETE FROM UserSubType where ClientId = @ClientID
DELETE FROM UserType where ClientId = @ClientID
DELETE FROM UserStatus where ClientId = @ClientID
DELETE FROM Translations where TranslationGroup in ('UserType','UserSubType','UserStatus') AND ClientId = @ClientID
COMMIT TRANSACTION

BEGIN TRANSACTION
-- USER TYPE  

SELECT @TypeName = 'UserType'
INSERT @TypeValues (value, value2, display) values ('Admin','Admin',1), ('Helpdesk','Helpdesk',1), ('LoyaltyMember','LoyaltyMember',1), ('GiftCardService', 'GiftCardService', 0), ('EposService', 'EposService', 0), ('SystemUser', 'SystemUser', 0), ('UnAuthSysuser','UnAuthSysuser',0), ('MembersService', 'MembersService', 0),('Prospect', 'Prospect', 0)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId

EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
-- German translation
--INSERT @TypeValues (value, value2, display) values ('Unauthorisierter Sysuser','UnAuthSysuser',1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues 


-- USER SUB TYPE
SELECT @TypeName = 'UserSubType'
INSERT @TypeValues (value, value2, display) values ('Normal','Normal',1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
-- No German translation required
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues


-- USER STATUS
SELECT @TypeName = 'UserStatus'
INSERT @TypeValues (value, value2, display) values ('InActive','InActive',1) , ('Active','Active',1), ('Merged','Merged', 0), ('InProgress','InProgress', 1), ('Dormant','Dormant', 0),('Prospect','Prospect', 0),('Potential','Potential', 0)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues
-- German translation
INSERT @TypeValues (value, value2, display) values ('Inaktiv','InActive',1) , ('Aktiv','Active',1), ('Merged','Merged',  0), ('InBearbeitung','InProgress',  1), ('Schlafend','Dormant',  0),('Prospect','Prospect', 0),('Potential','Potential', 0)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues

COMMIT TRANSACTION

PRINT 'USER DONE'
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- PERSONAL DETAILS RELATED
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

BEGIN TRANSACTION
DELETE FROM SalutationType where ClientId = @ClientID
DELETE FROM TitleType where ClientId = @ClientID
DELETE FROM GenderType where ClientId = @ClientID 
DELETE FROM Translations where TranslationGroup in ('SalutationType','TitleType','GenderType')  AND ClientId = @ClientID
COMMIT TRANSACTION

BEGIN TRANSACTION
-- SALUTATION TYPE

SELECT @TypeName = 'SalutationType'
INSERT @TypeValues (value, value2, display) values ('Mr','Mr',1) , ('Mrs','Mrs',1),('Ms','Ms',1),('Company','Company',1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues
-- German translation
INSERT @TypeValues (value, value2, display) values ('Herr','Mr',1) , ('Frau','Mrs',1),('Fräulein','Ms',1),('Firma','Company',1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues
print 'SalutationType done'
-- TITLE TYPE
SELECT @TypeName = 'TitleType'
INSERT @TypeValues (value, value2, display) values ('empty/none','NULL',1) ,('Dr.','Dr',1) , ('Dr. med.','Dr med',1), ('Prof.','Prof',1)

EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues
-- German translation
INSERT @TypeValues (value, value2, display) values ('leer','NULL',1) ,('Dr.','Dr',1) , ('Dr. med.','Dr med',1), ('Prof.','Prof',1)

EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues 
print 'TitleType done'

-- GENDER TYPE
SELECT @TypeName = 'GenderType'
INSERT @TypeValues (value, value2, display) values ('Male','Male',1) ,('Female','Female', 1),('Club','Club', 1),('Association','Association', 1),('Society','Society', 1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues
-- German translation
INSERT @TypeValues (value, value2, display) values ('Männlich','Male',1) ,('Weiblich','Female',  1),('Verein','Club', 1),('Verband','Association', 1),('Gesellschaft','Society', 1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues

COMMIT TRANSACTION

PRINT 'PERSONAL DETAILS DONE'
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
 --  VOUCHER RELATED
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION
DELETE FROM VoucherSubType where ClientId = @ClientID
--DELETE FROM VoucherType where ClientId = @ClientID
DELETE FROM Translations where TranslationGroup in ('VoucherType','VoucherSubType')  AND ClientId = @ClientID
COMMIT TRANSACTION

BEGIN TRANSACTION
/* VoucherType table missing in Humanic dev db
-- VOUCHER TYPE
SELECT @TypeName = 'VoucherType'
INSERT @TypeValues (value, value2, display) values ('Points','Points',1) ,('Discount','Discount',  1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues 
-- German translation
INSERT @TypeValues (value, value2, display) values ('Bonus','Points',1) ,('Rabatt','Discount',  1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues 
*/

-- VOUCHER SUB TYPE
SELECT @TypeName = 'VoucherSubType'
INSERT @TypeValues (value, value2, display) values ('PointsFixed','PointsFixed',0) ,('PointsMultiplier', 'PointsMultiplier', 0) ,('DiscountPercentage', 'DiscountPercentage', 1) ,('DiscountFixed', 'DiscountFixed', 1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation
INSERT @TypeValues (value, value2, display) values ('BonusFix','PointsFixed',0) ,('BonusMultiplikator', 'PointsMultiplier', 0) ,('Rabatt %','DiscountPercentage',  1) ,('Rabatt Betrag', 'DiscountFixed', 1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  

COMMIT TRANSACTION

PRINT 'VOUCHER DONE'

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

 

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
 --  TRANSACTION RELATED
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

BEGIN TRANSACTION
DELETE FROM [TrxType] where ClientId = @ClientID
DELETE FROM [TrxStatus] where ClientId = @ClientID
DELETE FROM [TenderType] where ClientId = @ClientID
DELETE FROM Translations where TranslationGroup in ('TrxType','TrxStatus','TenderType') AND ClientId = @ClientID
COMMIT TRANSACTION

BEGIN TRANSACTION
-- TRX TYPE

SELECT @TypeName = 'TrxType'
INSERT @TypeValues (value, value2, display) 
values 
('Purchase','Purchase',1),
('Return', 'Return', 1),
('PointsTransfer', 'PointsTransfer', 1),
('PointsAdjustment', 'PointsAdjustment', 1),
('MoneyTransferFrom','MoneyTransferFrom',1),
('Redemption', 'Redemption', 1),
('Qualification', 'Qualification', 1),
('ManualClaim','ManualClaim', 1),
('PartnerTrx','PartnerTrx',1) ,
('Refund', 'Refund',1) ,
('Reload', 'Reload',1),
('ReserveAmount', 'ReserveAmount',1), 
('Adjustment','Adjustment',1) ,
('CancelReserve','CancelReserve', 1) ,
('CommitReserve','CommitReserve', 1) ,
('Fee','Fee', 1),
('PosTransaction','PosTransaction',1),
('Activation', 'Activation', 1) ,
('MoneyTransferTo','MoneyTransferTo', 1) ,
('InitialCashBalanceSet','InitialCashBalanceSet', 1),
('InitialPointsBalanceSet','InitialPointsBalanceSet',1) ,
('Void','Void',1) ,
('RedeemPoints','RedeemPoints',1),
('CompetitionEntry','CompetitionEntry',1) ,
('ReservePoints','ReservePoints',1) ,
('CommitReservePoints','CommitReservePoints',1) ,
('CancelReservePoints','CancelReservePoints',1),
('MoneyExpiry','MoneyExpiry',1) ,
('PointsConversionToVoucher','PointsConversionToVoucher',1) ,
('Reservation','Reservation',1) 

EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues   
-- German translation
INSERT @TypeValues (value, value2, display) 
VALUES
('Einkauf','Purchase',1),
('Retoure', 'Return', 1),
('Bonus-Transfer', 'PointsTransfer', 1),
('Bonus - Anpassung', 'PointsAdjustment', 1),
('Geld-Transfer von','MoneyTransferFrom',1),
('Einlösung', 'Redemption', 1),
('Qualifizierung', 'Qualification', 1),
('Manuelle Korrektur','ManualClaim', 1),
('Partner-TRX','PartnerTrx',1) ,
('Barauszahlung', 'Refund',1) ,
('Wiederaufladung', 'Reload',1),
('Reservation', 'ReserveAmount',1), 
('Anpassung','Adjustment',1) ,
('Reservation stornieren','CancelReserve', 1) ,
('Reservation verbuchen','CommitReserve', 1) ,
('Gebühr','Fee', 1),
('POS TRX','PosTransaction',1),
('Aktivierung', 'Activation', 1) ,
('Geld-Transfer nach','MoneyTransferTo', 1) ,
('Initial gesetzter Betrag','InitialCashBalanceSet', 1),
('Initial gesetzter Bonus','InitialPointsBalanceSet',1) ,
('Void','Void',1) ,
('RedeemPoints','RedeemPoints',1),
('CompetitionEntry','CompetitionEntry',1) ,
('ReservePoints','ReservePoints',1) ,
('Bonus-Reservation verbuchen','CommitReservePoints',1) ,
('Bonus-Reservation stornieren','CancelReservePoints',1),
('MoneyExpiry','MoneyExpiry',1) ,
('PointsConversionToVoucher','PointsConversionToVoucher',1) ,
('Reservation','Reservation',1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues 

-- TRX STATUS
SELECT @TypeName = 'TrxStatus'
INSERT @TypeValues (value, value2, display) values ('Started','Started',1) ,('Completed', 'Completed', 1) ,('Cancelled', 'Cancelled', 1) ,('Void', 'Void', 1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation
INSERT @TypeValues (value, value2, display) values ('Gestartet','Started',1) ,('OK','Completed',  1) ,('Storniert','Cancelled',  1) ,('Ungültig','Void',  1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  


-- TENDER TYPE
SELECT @TypeName = 'TenderType'
INSERT @TypeValues (value, value2, display) values ('Cash','Cash',1) ,('EFT', 'EFT', 1) ,('GiftCard', 'GiftCard', 1) ,('PaymentCard', 'PaymentCard', 1),('LoyaltyPoints', 'LoyaltyPoints', 1) ,('Voucher', 'Voucher', 1) ,('DirectPayment', 'DirectPayment', 1),('Undefined', 'Undefined', 1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation 
INSERT @TypeValues (value, value2, display) values ('Cash','Cash',1) ,('EFT','EFT',  1) ,('GiftCard', 'GiftCard', 1) ,('Zahlkarte','PaymentCard',  1),('LoyaltyBonus','LoyaltyPoints',  1) ,('Voucher','Voucher',  1) ,('EinzahlungPOS','DirectPayment',  1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  

-- PG  SPECIFIC TenderTYPES for Leder Und Schuh which can't be entered via normal process for reference data due to mismatch on name/key/translation
INSERT INTO TenderType (name , ClientId, Display)
VALUES ('01ZZ', @ClientID, 0) , ('BKZZ', @ClientID, 0), ('G1ZZ', @ClientID, 0), ('G2ZZ', @ClientID, 0),('G4ZZ', @ClientID, 0), ('ZZ01', @ClientID, 0),('ZZ11', @ClientID, 0),
('ZZBC', @ClientID, 0) , ('ZZBK', @ClientID, 0), ('ZZCA', @ClientID, 0), ('G2ZZ', @ClientID, 0),('ZZCD', @ClientID, 0), ('ZZCV', @ClientID, 0),('ZZG1', @ClientID, 0),
('ZZG2', @ClientID, 0) ,('ZZG3', @ClientID, 0),('ZZG4', @ClientID, 0),('ZZGU', @ClientID, 0),('ZZMW', @ClientID, 0)


Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'en', 'TenderType', '01ZZ', 'Bar domestic', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'en', 'TenderType', 'BKZZ', 'ATM', @ClientID)
Insert into Translations ( LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'en', 'TenderType', 'G1ZZ', 'coupon', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('en', 'TenderType', 'G2ZZ', 'Reklamat.gutschein', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'en', 'TenderType', 'G4ZZ', 'customer credit', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('en', 'TenderType', 'ZZ01', 'Bar domestic', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('en', 'TenderType', 'ZZ11', 'Bar EURO', @ClientID)

 Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'en', 'TenderType', 'ZZBC', 'B(S +)-K Credit Card', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'en', 'TenderType', 'ZZBK', 'ATM', @ClientID)
Insert into Translations ( LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'en', 'TenderType', 'ZZCA', 'CC American Express', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('en', 'TenderType', 'ZZCD', 'CC Diners', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'en', 'TenderType', 'ZZCV', 'VISA CC', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('en', 'TenderType', 'ZZG1', 'Reklamat.gutschein',@ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('en', 'TenderType', 'ZZG2', 'Bar EURO', @ClientID)

Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'en', 'TenderType', 'ZZG3', 'stranger coupon', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('en', 'TenderType', 'ZZG4', 'customer credit',@ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('en', 'TenderType', 'ZZGU', 'vouchers old', @ClientID)


Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'de', 'TenderType', '01ZZ', 'Bar Inland', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'de', 'TenderType', 'BKZZ', 'Bankomat', @ClientID)
Insert into Translations ( LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'de', 'TenderType', 'G1ZZ', 'Gutschein', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('de', 'TenderType', 'G2ZZ', 'Reklamat.gutschein', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'de', 'TenderType', 'G4ZZ', 'Kundengutschrift', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('de', 'TenderType', 'ZZ01', 'Bar Inland',@ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('de', 'TenderType', 'ZZ11', 'Bar EURO', @ClientID)

 Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'de', 'TenderType', 'ZZBC', 'B(+S)-K Kreditkarte', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'de', 'TenderType', 'ZZBK', 'Bankomat', @ClientID)
Insert into Translations ( LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'de', 'TenderType', 'ZZCA', 'CC American Express', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('de', 'TenderType', 'ZZCD', 'CC Diners', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'de', 'TenderType', 'ZZCV', 'VISA CC', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('de', 'TenderType', 'ZZG1', 'Gutschein',@ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('de', 'TenderType', 'ZZG2', 'Reklamat.gutschein', @ClientID)

Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ( 'de', 'TenderType', 'ZZG3', 'Fremder Gutschein', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('de', 'TenderType', 'ZZG4', 'Kundengutschrift',@ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('de', 'TenderType', 'ZZGU', 'Gutscheine alt', @ClientID)
Insert into Translations (LanguageCode, TranslationGroup, TranslationGroupKey , Value, ClientId)
values ('de', 'TenderType', 'ZZMW', 'MWSt-Rückvergütung', @ClientID)

COMMIT TRANSACTION

PRINT 'TRX DONE'

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
 --  SITE RELATED
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION
DELETE FROM [SiteType] where ClientId = @ClientID
DELETE FROM [SiteStatus] where ClientId = @ClientID 
DELETE FROM Translations where TranslationGroup in ('SiteType','SiteStatus') AND ClientId = @ClientID
COMMIT TRANSACTION

BEGIN TRANSACTION

-- SITE TYPE
SELECT @TypeName = 'SiteType'
INSERT @TypeValues (value, value2, display) values ('Store','Store',1) ,('AreaGroup', 'AreaGroup', 1) ,('HeadOffice', 'HeadOffice', 1) ,('OnlineSite','OnlineSite', 1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation 
INSERT @TypeValues (value, value2, display) values ('Filiale','Store',1) ,('Region','AreaGroup',  1) ,('Zentrale','HeadOffice',  1) ,('Online','OnlineSite',  1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  

-- SITE STATUS
SELECT @TypeName = 'SiteStatus'
INSERT @TypeValues (value, value2, display) values ('Active','Active',1) ,('Inactive', 'Inactive', 1)  
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation   
INSERT @TypeValues (value, value2, display) values ('Aktiv','Active',1) ,('Inaktiv', 'Inactive', 1)  
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  

COMMIT TRANSACTION

PRINT 'SITE DONE'
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
 --  PROMOTION / OFFER RELATED
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

BEGIN TRANSACTION
DELETE FROM [PromotionOfferType] where ClientId = @ClientID
DELETE FROM [PromotionItemType] where ClientId = @ClientID 
DELETE FROM [PromotionValidationType] where ClientId = @ClientID 
DELETE FROM [PromotionThresholdType] where ClientId = @ClientID
DELETE FROM Translations where TranslationGroup in ('PromotionOfferType','PromotionItemType','PromotionValidationType','PromotionThresholdType')  and ClientId = @ClientID
COMMIT TRANSACTION

BEGIN TRANSACTION

-- PROMOTION OFFER TYPE
SELECT @TypeName = 'PromotionOfferType'
INSERT @TypeValues (value, value2, display) values ('DiscountPercentage','DiscountPercentage',1) ,('DiscountAmount', 'DiscountAmount', 1) ,('Points', 'Points', 0) ,('PointsMultiplier', 'PointsMultiplier', 0)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues    
-- German translation   
INSERT @TypeValues (value, value2, display) values ('Rabatt %','DiscountPercentage',1) ,('Rabatt Betrag', 'DiscountAmount', 1) ,('Bonus','Points',  0) ,('BonusMultiplikator','PointsMultiplier',  0)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues   

-- PROMOTION ITEM TYPE
SELECT @TypeName = 'PromotionItemType'
INSERT @TypeValues (value, value2, display) values ('AnalysisCode1','AnalysisCode1',1) ,('AnalysisCode2', 'AnalysisCode2', 1) ,('AnalysisCode3', 'AnalysisCode3', 1) ,('AnalysisCode4', 'AnalysisCode4', 1),('AnalysisCode5', 'AnalysisCode5', 1),('AnalysisCode6', 'AnalysisCode6', 1),('AnalysisCode7', 'AnalysisCode7', 1),('AnalysisCode8', 'AnalysisCode8', 1),('AnalysisCode9', 'AnalysisCode9', 1),('AnalysisCode10', 'AnalysisCode10', 1),('ItemCode', 'ItemCode', 1) ,('All', 'All', 1), ('Basket', 'Basket', 1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues     
-- German translation 
INSERT @TypeValues (value, value2, display) values ('AnalysisCode1','AnalysisCode1',1) ,('AnalysisCode2','AnalysisCode2',  1) ,('AnalysisCode3', 'AnalysisCode3', 1) ,('AnalysisCode4','AnalysisCode4',  1),('AnalysisCode5', 'AnalysisCode5', 1),('AnalysisCode6', 'AnalysisCode6', 1),('AnalysisCode7', 'AnalysisCode7', 1),('AnalysisCode8', 'AnalysisCode8', 1),('AnalysisCode9', 'AnalysisCode9', 1),('AnalysisCode10', 'AnalysisCode10', 1),('Artikel-Nr.', 'ItemCode', 1) ,('All', 'All', 1), ('Warenkorb','Basket',  1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  

-- PROMOTION VALIDATION TYPE
SELECT @TypeName = 'PromotionValidationType'
INSERT @TypeValues (value, value2, display) values ('UsagesPerWeek','UsagesPerWeek',1) ,('NumberUsagesPerMonth', 'NumberUsagesPerMonth', 1) ,('MaxNumberUsages', 'MaxNumberUsages', 1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues    
-- No German translation Required
INSERT @TypeValues (value, value2, display) values ('UsagesPerWeek','UsagesPerWeek',1) ,('NumberUsagesPerMonth', 'NumberUsagesPerMonth', 1) ,('MaxNumberUsages','MaxNumberUsages',  1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues 

-- PROMOTION THRESHOLD TYPE
SELECT @TypeName = 'PromotionThresholdType'
INSERT @TypeValues (value, value2, display) values ('Counter','Counter',1) ,('MinimumValueToSpendOnBasket', 'MinimumValueToSpendOnBasket',1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- No German translation Required
INSERT @TypeValues (value, value2, display) values ('Counter','Counter',1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  

COMMIT TRANSACTION

PRINT 'PROMOTION OFFER DONE'

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
 --  MESSAGE RELATED
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

BEGIN TRANSACTION
DELETE FROM [MessagePurpose] where ClientId = @ClientID
DELETE FROM [MessageType] where ClientId = @ClientID 
DELETE FROM [MessagePlatform] where ClientId = @ClientID 
DELETE FROM Translations where TranslationGroup in ('MessagePurpose','MessageType','MessagePlatform') AND ClientId = @ClientID
COMMIT TRANSACTION

BEGIN TRANSACTION

-- MESSAGE PURPOSE
SELECT @TypeName = 'MessagePurpose'
INSERT @TypeValues (value, value2, display) values ('Display','Display',1) ,('Print', 'Print', 1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues
-- German translation
INSERT @TypeValues (value, value2, display) values ('Anzeigen','Display',1) ,('Drucken', 'Print', 1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues

-- MESSAGE PLATFORM
SELECT @TypeName = 'MessagePlatform'
INSERT @TypeValues (value, value2, display) values ('EPOS','EPOS',1) ,('MobileApp', 'MobileApp', 1) ,('AllPlatforms', 'AllPlatforms', 1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation
INSERT @TypeValues (value, value2, display) values ('ePOS','EPOS',1) ,('MobileApp', 'MobileApp', 1) ,('AllePlattformen','AllPlatforms',  1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues

COMMIT TRANSACTION

PRINT 'MESSAGE DONE'

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- DEVICE RELATED
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

BEGIN TRANSACTION
DELETE FROM [DeviceType] where ClientId = @ClientID
DELETE FROM [DeviceStatusTransitionType] where ClientId = @ClientID 
DELETE FROM [DeviceStatus] where ClientId = @ClientID 
DELETE FROM [DeviceCategory] where ClientId = @ClientID 
DELETE FROM [DeviceProfileStatus] where ClientId = @ClientID 
DELETE FROM [DeviceProfileTemplateType] where ClientId = @ClientID 
DELETE FROM [DeviceProfileTemplateStatus] where ClientId = @ClientID 
DELETE FROM [DeviceProfileChargeFeeType] where ClientId = @ClientID 
DELETE FROM [DeviceExpirationPolicyType] where ClientId = @ClientID 
DELETE FROM [DeviceNumberGeneratorTemplateStatus] where ClientId = @ClientID 
DELETE FROM [DeviceNumberStatus] where ClientId = @ClientID 
DELETE FROM [DeviceLotStatus] where ClientId = @ClientID 
DELETE FROM [DeviceAction] where ClientId = @ClientID
DELETE FROM [BulkGiftCardActivationsStatus] where ClientId = @ClientID
DELETE FROM [CheckSumAlgorithm] where ClientId = @ClientID
DELETE FROM [DeviceProfileExpirationType] where ClientId = @ClientID
DELETE FROM Translations where TranslationGroup in 
('DeviceType','DeviceStatusTransitionType','DeviceStatus',
'DeviceCategory','DeviceProfileStatus','DeviceProfileTemplateType',
'DeviceProfileTemplateStatus','DeviceProfileChargeFeeType','DeviceExpirationPolicyType',
'DeviceNumberGeneratorTemplateStatus','DeviceNumberStatus','DeviceLotStatus', 'DeviceAction','BulkGiftCardActivationsStatus','CheckSumAlgorithm','DeviceProfileExpirationType') AND ClientId = @ClientID
COMMIT TRANSACTION

BEGIN TRANSACTION

-- DEVICE ACTION
SELECT @TypeName = 'DeviceAction'
INSERT @TypeValues (value, value2, display) values 
('Redeem','Redeem',1),
('SetPin','SetPin',1) ,
('Activation','Activation',1) ,
('Refund','Refund',1) ,
('Adjustment','Adjustment',1) ,
('ReserveAmount','ReserveAmount',1) ,
('Fee','Fee',1) ,
('BlockDevice','BlockDevice',1) ,
('UndoBlock','UndoBlock',1), 
('UnBlockDeviceProfile','UnBlockDeviceProfile',1)  ,
('BlockDeviceProfile','BlockDeviceProfile',1) ,
('UndoExpire','UndoExpire',1) ,
('void','void',1) ,
('Deactivate','Deactivate',1) ,
('CancelReserve','CancelReserve',1) ,
('CommitReserve','CommitReserve',1) ,
('TransferBalance','TransferBalance',1) 
,('UpdateExpireDate','UpdateExpireDate',1), 
('AssignDeviceToUser','AssignDeviceToUser',1),
('ExpireDevice','ExpireDevice',1),
('Reload','Reload',1),
('PointsRedeem','PointsRedeem',1),
('ReservePoints','ReservePoints',1)
,('CancelReservePoints','CancelReservePoints',1),
('CommitReservePoints','CommitReservePoints',1) ,
('ReplaceDeviceForUser','ReplaceDeviceForUser',1),
('UnAssignDeviceFromUser','UnAssignDeviceFromUser',1),
('ValidatePin','ValidatePin',1),
('MergeFromUser','MergeFromUser',1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues
-- German translation
--INSERT @TypeValues (value, value2, display) values 
--('Einlösen','Redeem',1),
--('PIN setzen','SetPin',1) ,
--('Aktivierung','Activation',1) ,
--('Auszahlen','Refund',1) ,
--('Korrekturbuchung','Adjustment',1) ,
--('Betrag reservieren','ReserveAmount',1) ,
--('Gebühr','Fee',1) ,
--('Device sperren','BlockDevice',1) ,
--('Entsperren','UndoBlock',1), 
--('UnBlockDeviceProfile','UnBlockDeviceProfile',1)  ,
--('Profil sperren','BlockDeviceProfile',1) ,
--('Verfall aufheben','UndoExpire',1) ,
--('annulieren','void',1) ,
--('Deaktivieren','Deactivate',1) ,
--('Reservation stornieren','CancelReserve',1) ,
--('Reservation überweisen','CommitReserve',1) ,
--('Saldo transferieren','TransferBalance',1) 
--,('Verfalldatum aktualisieren','UpdateExpireDate',1), 
--('AssignDeviceToUser','AssignDeviceToUser',1),
--('ExpireDevice','ExpireDevice',1),
--('Reload','Reload',1),
--('PointsRedeem','PointsRedeem',1),
--('ReservePoints','ReservePoints',1)
--,('Reservation stornieren','CancelReservePoints',1),
--('Reservation überweisen','CommitReservePoints',1) ,
--('ReplaceDeviceForUser','ReplaceDeviceForUser',1),
--('UnAssignDeviceFromUser','UnAssignDeviceFromUser',1),
--('ValidatePin','ValidatePin',1),
--('MergeFromUser','MergeFromUser',1)
--EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
--DELETE FROM @TypeValues
---- Bulgarian translation
--INSERT @TypeValues (value, value2, display) values 
--('Einlösen','Redeem',1),
--(N'Поставене PIN','SetPin',1) ,
--('Aktivierung','Activation',1) ,
--(N'Изплащане','Refund',1) ,
--(N'Вписване на корекция','Adjustment',1) ,
--(N'Сумата резервирана','ReserveAmount',1) ,
--('Gebühr','Fee',1) ,
--(N'Блокиране на устройството','BlockDevice',1) ,
--(N'Деблокирам','UndoBlock',1), 
--(N'Деблокиране профила на устройството','UnBlockDeviceProfile',1)  ,
--(N'Блокиране на профила','BlockDeviceProfile',1) ,
--(N'Отмяна на датата на падежа','UndoExpire',1) ,
--(N'Анулирам','void',1) ,
--(N'Деактивиране','Deactivate',1) ,
--('Reservation stornieren','CancelReserve',1) ,
--(N'Паричен превод по резервацията','CommitReserve',1) ,
--(N'Превеждане на салдото в чужда валута','TransferBalance',1),
--(N'Актуализиране датата на падежа','UpdateExpireDate',1), 
--(N'Устройство-определяне на членовете','AssignDeviceToUser',1),
--(N'Устройство обявяване на датата на изтичане за невалидна','ExpireDevice',1),
--(N'Ново изтегляне','Reload',1),
--(N'Осребряване на бонуса','PointsRedeem',1),
--(N'Резервиране на бонус','ReservePoints',1),
--('Reservation stornieren','CancelReservePoints',1),
--('Reservation überweisen','CommitReservePoints',1) ,
--(N'Подмяна на устройството','ReplaceDeviceForUser',1),
--('UnAssignDeviceFromUser','UnAssignDeviceFromUser',1),
--('ValidatePin','ValidatePin',1),
--('MergeFromUser','MergeFromUser',1)
--EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'bg'
--DELETE FROM @TypeValues

print 'DeviceAction done'
-- DEVICE TYPE
SELECT @TypeName = 'DeviceType'
INSERT @TypeValues (value, value2, display) values ('Card','Card',1)  
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation
SELECT @TypeName = 'DeviceType'
INSERT @TypeValues (value, value2, display) values ('Karte','Card',1)  
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  


-- DEVICE STATUS TRANSITION TYPE
SELECT @TypeName = 'DeviceStatusTransitionType'
INSERT @TypeValues (value, value2, display) values ('Manual','Manual',1) ,('Automatic', 'Automatic',1),('EIDeviceOperation','EIDeviceOperation', 1)  
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation
INSERT @TypeValues (value, value2, display) values ('Manuell','Manual',1) ,('Automatisch','Automatic', 1),('Spez. Operation','EIDeviceOperation', 1)  
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  


-- DEVICE STATUS
SELECT @TypeName = 'DeviceStatus'
INSERT @TypeValues (value, value2, display) values ('Inactive','Inactive',1) ,('Active','Active', 1),('Blocked','Blocked', 1),('Expired','Expired', 1),('Created','Created', 1),('Ready','Ready', 1) ,('Reserved','Reserved', 1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues 
  
-- German translation
INSERT @TypeValues (value, value2, display) values ('Inaktiv','Inactive',1) ,('Aktiv','Active', 1),('Gesperrt','Blocked', 1),('Verfallen','Expired',  1),('Erstellt','Created', 1),('Bereit','Ready', 1) , ('Reserviert','Reserved', 1)  
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  

 ----add the BulkGiftCardActivationsStatus
SELECT @TypeName = 'BulkGiftCardActivationsStatus'
INSERT @TypeValues (value, value2, display) values ('Created','Created', 1),('Started','Started', 1),('Error','Error', 1),('Completed','Completed', 1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientID
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientID, 'en'
DELETE FROM @TypeValues 

-- German translation
INSERT @TypeValues (value, value2, display) values ('Erstellt','Created', 1),('Gestartet','Started', 1) ,('Fehler','Error', 1),('Komplett','Completed', 1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues 
print 'DeviceStatus done'
-- DEVICE CATEGORY
SELECT @TypeName = 'DeviceCategory'
INSERT @TypeValues (value, value2, display) values ('MainCard','MainCard',1) ,('AdditionalCard', 'AdditionalCard',1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation 
INSERT @TypeValues (value, value2, display) values ('Haupt-Device','MainCard',1) ,('ZusätzlichesDevice','AdditionalCard', 1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  
print 'DeviceCategory done'
-- DEVICE PROFILE STATUS 
SELECT @TypeName = 'DeviceProfileStatus'
INSERT @TypeValues (value, value2, display) values ('Created','Created',1) ,('Active','Active', 1),('Blocked', 'Blocked',1),('Inactive','Inactive',  1),('Undefined','Undefined', 1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues 
-- German translation
SELECT @TypeName = 'DeviceProfileStatus'
INSERT @TypeValues (value, value2, display) values ('Angelegt','Created',1) ,('Aktiv','Active', 1),('Gesperrt','Blocked', 1),('Inaktiv', 'Inactive', 1),('Undefiniert','Undefined', 1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues 

-- DEVICE PROFILE TEMPLATE TYPE
SELECT @TypeName = 'DeviceProfileTemplateType'
INSERT @TypeValues (value, value2, display) values ('Loyalty','Loyalty',1) ,('Financial','Financial', 1),('Voucher','Voucher', 1),('EShop','EShop',  1),('FinancialVoucher', 'FinancialVoucher',1) ,('EShopLoyalty', 'EShopLoyalty',1)  
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation
INSERT @TypeValues (value, value2, display) values ('Loyalty','Loyalty',1) ,('Wert', 'Financial',1),('Voucher','Voucher', 1),('e-Shop','EShop',  1),('Wertgutschein','FinancialVoucher', 1)  ,('EShopLoyalty', 'EShopLoyalty',1)  
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  


-- DEVICE PROFILE TEMPLATE STATUS
SELECT @TypeName = 'DeviceProfileTemplateStatus'
INSERT @TypeValues (value, value2, display) values ('Active','Active',1) ,('Inactive','Inactive', 1),('Created', 'Created', 1),('Disabled', 'Disabled', 1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues 
-- German translation
INSERT @TypeValues (value, value2, display) values ('Aktiv','Active',1) ,('Inaktiv', 'Inactive',1),('Angelegt', 'Created', 1),('Deaktiviert', 'Disabled', 1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues 


-- DEVICE PROFILE CHARGE FEE TYPE
SELECT @TypeName = 'DeviceProfileChargeFeeType'
INSERT @TypeValues (value, value2, display) values ('FixedChargedFee','FixedChargedFee',1) ,('BasedOnLastTransactionType', 'BasedOnLastTransactionType',1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation
INSERT @TypeValues (value, value2, display) values ('Fixe Gebühr','FixedChargedFee',1) ,('Basierend auf Letzten TRX-Typ','BasedOnLastTransactionType', 1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues 

-- DEVICE EXPIRATION POLICY
SELECT @TypeName = 'DeviceExpirationPolicyType'
INSERT @TypeValues (value, value2, display) values ('Fixed','Fixed',1) ,('SlidingWindow', 'SlidingWindow',1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues   
-- German translation
INSERT @TypeValues (value, value2, display) values ('Fix','Fixed',1) ,('Gleitend','SlidingWindow', 1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues   
print 'DeviceExpirationPolicyType done'
-- DEVICE NUMBER STATUS 
SELECT @TypeName = 'DeviceNumberStatus'
INSERT @TypeValues (value, value2, display) values ('Created','Created',1) ,('Used','Used',  1),('Invalid', 'Invalid', 1),('AssignedToLot', 'AssignedToLot',1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation
INSERT @TypeValues (value, value2, display) values ('Angelegt','Created',1) ,('Benutzt','Used',  1),('Ungültig','Invalid',  1),('DemLosZugeordnet', 'AssignedToLot',1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  


-- DEVICE NUMBER GENERATOR STATUS
SELECT @TypeName = 'DeviceNumberGeneratorTemplateStatus'
INSERT @TypeValues (value, value2, display) values ('Active','Active',1) ,('Disabled', 'Disabled', 1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues   
-- German translation
INSERT @TypeValues (value, value2, display) values ('Aktiv','Active',1) ,('Deaktiviert', 'Disabled', 1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues 

-- DEVICE NUMBER GENERATOR Checksum algorithm
SELECT @TypeName = 'CheckSumAlgorithm'
INSERT @TypeValues (value, value2, display) values ('Modulo10','Modulo10',1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues   
-- German translation
--INSERT @TypeValues (value, value2, display) values ('Modulo10','Modulo10',1)  
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues 


-- DEVICE LOT STATUS
SELECT @TypeName = 'DeviceLotStatus'
INSERT @TypeValues (value, value2, display) values ('Ready','Ready',1) ,('Created','Created',  1) ,('Inactive', 'Inactive',1) ,('Locked','Locked', 1) ,('NumbersAssigned','NumbersAssigned', 1) ,('Activating','Activating', 1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues    
-- German translation
INSERT @TypeValues (value, value2, display) values ('Bereit','Ready',1) ,('Angelegt','Created',  1) ,('Inaktiv','Inactive', 1) ,('Gesperrt', 'Locked',1) ,('NummernZugeordnet','NumbersAssigned', 1) ,('InAktivierung', 'Activating',1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues    

SELECT @TypeName = 'DeviceProfileExpirationType'
INSERT @TypeValues (value, value2, display) values ('DaysToExpire','DaysToExpire',1) ,('EuropeanStandard','EuropeanStandard',1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues   
-- German translation
INSERT @TypeValues (value, value2, display) values ('DaysToExpire','DaysToExpire',1) ,('EuropeanStandard','EuropeanStandard',1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues 

COMMIT TRANSACTION

PRINT 'DEVICE DONE'

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- TICKET RELATED
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

BEGIN TRANSACTION
DELETE FROM [TicketTopic] where ClientId = @ClientID
DELETE FROM [TicketStatus] where ClientId = @ClientID 
DELETE FROM [TicketPriority] where ClientId = @ClientID  
DELETE FROM Translations where TranslationGroup in ('TicketTopic','TicketStatus','TicketPriority') AND ClientId = @ClientID
COMMIT TRANSACTION



BEGIN TRANSACTION

-- TICKET TOPIC
SELECT @TypeName = 'TicketTopic'
INSERT @TypeValues (value, value2, display) values ('Support','Support',1) ,('Invoice', 'Invoice',1) ,('NewClient', 'NewClient',1) ,('LoyaltyPoints', 'LoyaltyPoints',1) ,('Other', 'Other',1) ,('Payment', 'Payment',1) ,('Loyalty', 'Loyalty',1) ,('Complaint', 'Complaint', 1) ,('eShop', 'eShop', 1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues     
-- German translation
INSERT @TypeValues (value, value2, display) values ('Support','Support',1) ,('Rechnung','Invoice', 1) ,('NeuerKunde','NewClient', 1) ,('Loyalty Bonus','LoyaltyPoints', 1) ,('Anderes', 'Other',1) ,('Zahlung', 'Payment',1) ,('Loyalty','Loyalty', 1) ,('Reklamation', 'Complaint', 1) ,('eShop','eShop',  1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  

-- TICKET STATUS
SELECT @TypeName = 'TicketStatus'
INSERT @TypeValues (value, value2, display) values ('Unassigned','Unassigned',1) ,('Assigned','Assigned', 1) ,('Resolved', 'Resolved', 1) ,('Closed','Closed', 1) ,('Reopened','Reopened', 1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation
INSERT @TypeValues (value, value2, display) values ('NichtZugeordnet','Unassigned',1) ,('Zugeordnet', 'Assigned',1) ,('Gelöst','Resolved',  1) ,('Geschlossen', 'Closed',1) ,('Reopened-de','Reopened', 1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  


-- TICKET PRIORITY
SELECT @TypeName = 'TicketPriority'
INSERT @TypeValues (value, value2, display) values ('LOW','LOW',1) ,('MEDIUM', 'MEDIUM', 1) ,('HIGH', 'HIGH',1)  
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation
INSERT @TypeValues (value, value2, display) values ('Niedrig','LOW',1) ,('Medium', 'MEDIUM', 1) ,('Hoch', 'HIGH',1)  
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  

COMMIT TRANSACTION

PRINT 'TICKET DONE'
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
-- ADDRESS / CONTACT DETAILS RELATED 
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION
DELETE FROM [AddressValidStatus] where ClientId = @ClientID
DELETE FROM [AddressType] where ClientId = @ClientID 
DELETE FROM [AddressStatus] where ClientId = @ClientID 
DELETE FROM [ContactType] where ClientId = @ClientID 
DELETE FROM [ContactDetailsType] where ClientId = @ClientID  
DELETE FROM [EmailStatus] where ClientId = @ClientID  
DELETE FROM Translations where TranslationGroup in ('AddressValidStatus','AddressType','AddressStatus','ContactType','ContactDetailsType','EmailStatus') AND ClientId = @ClientID
COMMIT TRANSACTION

BEGIN TRANSACTION

-- ADDRESS VALID STATUS
SELECT @TypeName = 'AddressValidStatus'
INSERT @TypeValues (value, value2, display) values ('Invalid','Invalid',1) ,('Valid', 'Valid',1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation 
INSERT @TypeValues (value, value2, display) values ('Ungültig','Invalid',1) ,('Gültig','Valid', 1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  
---- Bulgarian Translation
--INSERT @TypeValues (value, value2, display) values (N'Невалиден','Invalid',1) ,(N'Валиден','Valid', 1) 
--EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
--DELETE FROM @TypeValues  

-- ADDRESS TYPE
SELECT @TypeName = 'AddressType'
INSERT @TypeValues (value, value2, display) values ('Main','Main',1) ,('Delivery','Delivery',1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation 
INSERT @TypeValues (value, value2, display) values ('Haupt','Main',1) ,('Delivery','Delivery',1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  
-- Bulgarian translation
--INSERT @TypeValues (value, value2, display) values (N'Основен','Main',1) ,(N'Доставчик','Delivery',1) 
--EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
--DELETE FROM @TypeValues  

-- ADDRESS STATUS
SELECT @TypeName = 'AddressStatus'
INSERT @TypeValues (value, value2, display) values ('Current','Current',1) ,('Replaced', 'Replaced',1)  ,('Future','Future',  1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation  
INSERT @TypeValues (value, value2, display) values ('Aktuell','Current',1) ,('Ersetzt','Replaced', 1)  ,('Zukünftig','Future',  1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  
--Bulgarian translation
--INSERT @TypeValues (value, value2, display) values (N'Актуален','Current',1) ,(N'Сменен', 'Replaced',1)  ,(N'в бъдеще','Future',  1) 
--EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'bg'
--DELETE FROM @TypeValues  

-- CONTENT TYPE
SELECT @TypeName = 'ContactType'
INSERT @TypeValues (value, value2, display) values ('Email','Email',1) ,('SMS','SMS',  1)  ,('Mail','Mail', 1) ,('Telephone','Telephone', 1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues   
-- German translation
INSERT @TypeValues (value, value2, display) values ('eMail','Email',1) ,('SMS','SMS',  1)  ,('DirectMail','Mail', 1) ,('Telefon','Telephone', 1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  


-- CONTACT DETAILS TYPE
SELECT @TypeName = 'ContactDetailsType'
INSERT @TypeValues (value, value2, display) values ('Main','Main',1) ,('Billing', 'Billing',1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation
INSERT @TypeValues (value, value2, display) values ('Hauptinformationen','Main',1) ,('Billing','Billing', 1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues 


-- Email Status
SELECT @TypeName = 'EmailStatus'
INSERT @TypeValues (value, value2, display) values ('Valid','Valid',1) ,('Soft Bounce', 'Soft Bounce',1),('Hard Bounce', 'Hard Bounce',1)
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation
INSERT @TypeValues (value, value2, display) values ('Valid','Valid',1) ,('weichen Bounce', 'Soft Bounce',1),('Fest Bounce', 'Hard Bounce',1)
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues 

COMMIT TRANSACTION

PRINT 'ADDRESS AND CONTACT DETAILS DONE'
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
-- MISC
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION
DELETE FROM [MemberLinkType] where ClientId = @ClientID
DELETE FROM [ManualClaimType] where ClientId = @ClientID 
DELETE FROM [AccountStatus] where ClientId = @ClientID  
DELETE FROM Translations where TranslationGroup in ('MemberLinkType','ManualClaimType','AccountStatus') AND ClientId = @ClientID
COMMIT TRANSACTION

BEGIN TRANSACTION
-- MEMBER LINK TYPE

SELECT @TypeName = 'MemberLinkType'
INSERT @TypeValues (value, value2, display) values ('House','House',1) ,('Family','Family', 1) , ('Merger','Merger',1) ,('Potential','Potential',1),('Community','Community',1)   
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues   
-- German translation
INSERT @TypeValues (value, value2, display) values ('Hierarchie','House',1) ,('Haushalt', 'Family',1) , ('Merge','Merger',1) ,('Potential','Potential',1) ,('Community','Community',1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  

-- MANUAL CLAIM TYPE
SELECT @TypeName = 'ManualClaimType'
INSERT @TypeValues (value, value2, display) values ('Complaint','Complaint',1) ,('Goodwill', 'Goodwill',1)   
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues 
-- German translation
INSERT @TypeValues (value, value2, display) values ('Reklamation','Complaint',1) ,('Kulanz','Goodwill', 1)   
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues 

-- ACCOUNT STATUS
SELECT @TypeName = 'AccountStatus'
INSERT @TypeValues (value, value2, display) values ('Disable','Disable',1) ,('Enable','Enable', 1)   
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation
INSERT @TypeValues (value, value2, display) values ('Aus','Disable',1) ,('Ein ','Enable', 1)   
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  

PRINT 'MISC DONE'

COMMIT TRANSACTION

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
 
 -- Loyalty Profile
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION
DELETE FROM [PointsCalculationRuleType] where ClientId = @ClientID  
DELETE FROM Translations where TranslationGroup in ('PointsCalculationRuleType') AND ClientId = @ClientID
COMMIT TRANSACTION

BEGIN TRANSACTION

-- ACCOUNT STATUS
SELECT @TypeName = 'PointsCalculationRuleType'
INSERT @TypeValues (value, value2, display) values ('TruncatePointsOnLineItem','TruncatePointsOnLineItem',1) ,('TruncatePointsOnBasket','TruncatePointsOnBasket', 1) ,('RoundPointsOnLineItem', 'RoundPointsOnLineItem',1) ,('RoundPointsOnBasket','RoundPointsOnBasket', 1)  ,('NoAction','NoAction', 1)   
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation
INSERT @TypeValues (value, value2, display) values ('Bonus auf Ebene Artikel Dezimalstellen streichen','TruncatePointsOnLineItem',1) ,('Bonus auf Ebene Warenkorb Dezimalstellen streichen', 'TruncatePointsOnBasket',1) ,('Bonus auf Ebene Artikel runden','RoundPointsOnLineItem', 1) ,('Bonus auf Ebene Warenkorb runden','RoundPointsOnBasket', 1)   ,('KeineAktion','NoAction', 1)   
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  

PRINT 'Loyalty Profile DONE'

COMMIT TRANSACTION

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
 
 -- Member Document Types
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION
DELETE FROM [MemberDocumentType] where ClientId = @ClientID  
DELETE FROM Translations where TranslationGroup in ('MemberDocumentType') AND ClientId = @ClientID
COMMIT TRANSACTION

BEGIN TRANSACTION

-- ACCOUNT STATUS
SELECT @TypeName = 'MemberDocumentType'
INSERT @TypeValues (value, value2, display) values ('MailMerge','MailMerge',1) ,('TicketDocument','TicketDocument', 1) 
EXEC [DBHelper].[Create_ReferenceType2] @TypeName , @TypeValues , @ClientId
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues  
-- German translation
INSERT @TypeValues (value, value2, display) values ('MailMerge','MailMerge',1) ,('Ticket Dokument','TicketDocument', 1) 
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  

PRINT 'MemberDocumentType DONE'

COMMIT TRANSACTION
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
 
 -- MailMergePlaceholder
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
BEGIN TRANSACTION
DELETE FROM [MailMergePlaceholder] where ClientId = @ClientID  
DELETE FROM Translations where TranslationGroup in ('MailMergePlaceholder') AND ClientId = @ClientID
COMMIT TRANSACTION

BEGIN TRANSACTION

-- MailMergePlaceholder
SELECT @TypeName = 'MailMergePlaceholder'
INSERT @TypeValues (value, value2, display) values ('Gender','@@gender@@' ,1),('Salutation','@@salutation@@' ,1),('Title','@@title@@' ,1),('Firstname','@@firstname@@' ,1),('Surname','@@surname@@' ,1),('Street','@@street@@' ,1),('SouseNr','@@houseNr@@' ,1),('Adressline 1','@@adressline1@@' ,1),('Adressline 2','@@adressline2@@' ,1),('Postbox','@@postbox@@' ,1),('ZIP','@@zip@@' ,1),('City','@@city@@' ,1),('DeviceID','@@deviceId@@' ,1),('DeviceID of bonus giftcard','@@deviceIdofBonusGiftcard@@' ,1),('eMail address','@@email@@' ,1),('Phone','@@phone@@' ,1),('Mobile phone','@@mobilePhone@@' ,1),('Date of Birth','@@dateOfBirth@@' ,1),('Home store','@@homeStore@@' ,1),('Language','@@language@@' ,1),('Letter Salutation','@@letterSalutation@@' ,1)  
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'en'
DELETE FROM @TypeValues 

-- German translation
INSERT @TypeValues (value, value2, display) values ('Gender-DE','@@gender@@',1),('Anrede','@@salutation@@',1),('Titel','@@title@@',1),('Vorname','@@firstname@@',1),('Name','@@surname@@',1),('Strasse','@@street@@',1),('Hnr.','@@houseNr@@',1),('Adresszeile 1','@@adressline1@@',1),('Adresszeile 2','@@adressline2@@',1),('Postfach','@@postbox@@',1),('PLZ','@@zip@@',1),('Ort','@@city@@',1),('KartenNr.','@@deviceId@@',1),('BonusGiftcard-Nr.','@@deviceIdofBonusGiftcard@@',1),('eMail','@@email@@',1),('Telefon','@@phone@@',1),('Mobil','@@mobilePhone@@',1),('Geburtsdatum','@@dateOfBirth@@',1),('Heimfiliale','@@homeStore@@',1),('Sprache','@@language@@',1) ,('Letter Salutation','@@letterSalutation@@' ,1)  
EXEC [DBHelper].[Create_ReferenceTypeTranslations] @TypeName, @TypeValues, @ClientId, 'de'
DELETE FROM @TypeValues  

COMMIT TRANSACTION
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
 
PRINT 'ALL REFERENCE TYPES POPULATED SUCCESSFULLY' 
end
