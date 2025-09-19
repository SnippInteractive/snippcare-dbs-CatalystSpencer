CREATE PROCEDURE [dbo].[GetMemberExtensionDataByExtensionCategory]
	@MemberId INT,
	@ExtensionCategory NVARCHAR(50),
	@PropertyNamesOnly INT,
	@ClientId INT = 2
AS
BEGIN
	Declare @UserloyaltyDataId INT;
	SELECT  @UserloyaltyDataId = ISNULL(UserLoyaltyDataId ,0) FROM	[User] WHERE   UserId = @MemberId

	--@PropertyNamesOnly = 0 Get al extrainfo properties of a member start with @ExtensionCategory
	--@PropertyNamesOnly = 1 Get  property names to display in add new screen
	 
	IF @PropertyNamesOnly = 0
	BEGIN

		SELECT	ed.[GroupId] as 'Group'
				,ed.PropertyName
				,case when LOWER(ed.PropertyName) IN('petdob') then  dbo.ConvertDateStringFormat(ed.PropertyValue) else ed.PropertyValue end as PropertyValue
				,case when LOWER(ed.PropertyName) = 'pettype' then 'Dropdown' when LOWER(ed.PropertyName) = 'petgender' then 'Dropdown' when LOWER(ed.PropertyName) in('petname','childname') then 'Textbox' when LOWER(ed.PropertyName) = 'petsize' then 'Dropdown' when LOWER(ed.PropertyName) in('petdob','childbirthday') then 'Calender' when LOWER(ed.PropertyName) = 'petMedia_URL' then 'Image' else 'Label' end as ControlType
				,case when LOWER(ed.PropertyName) IN('petdob' ,'petname','childname','childbirthday') then 1 else 0 end as 'IsRequired'
				,Case when LOWER(ed.PropertyName) IN('petdob','childbirthday') then 'data-val-maxdate="Invalid Date" data-val-maxdate-year="0"  data-val-mindateyear="Invalid Date" data-val-mindateyear-year="25"' when LOWER(ed.PropertyName) = 'petMedia_URL' then 'width="50" height="50"'  else '' end as Attributes
				,Case LOWER(ed.PropertyName) when 'petsize' then 'hide-type-cat' else '' end as Classes
				,isnull(ed.DisplayOrder,0) as DisplayOrder
				,isnull(ed.Deleted,0) as Deleted
		FROM   [dbo].[UserLoyaltyExtensionData] ed 
		WHERE ed.UserloyaltyDataId = @UserloyaltyDataId AND LOWER(ed.PropertyName) like LOWER(@ExtensionCategory)+'%'
	END
	ELSE
	BEGIN
		
		SELECT [Name] as PropertyName 
				,'' as 'PropertyValue' 
				,1 as 'Group'
				,CASE  WHEN LOWER([Name]) in( 'petdob','childbirthday') THEN 'Calender' when LOWER([Name]) in('petCloroxCatID','petMedia_URL','petCreated_TimeStamp','petModified_TimeStamp','petBirthday_awarded_on_Timestamp','childname') then 'Textbox'   ELSE ControlType END as ControlType
				,case  when LOWER([Name]) in('petMedia_URL') then 0 else 1 end as 'IsRequired'
				,Case  when LOWER([Name]) in('petdob','childbirthday') then 'mindate="1900" data-val-maxdate="Invalid Date" data-val-maxdate-year="0"  data-val-mindateyear="Invalid Date" data-val-mindateyear-year="25"' else '' end  as Attributes
				,Case LOWER([Name]) when 'petsize' then 'hide-type-cat' when 'petCreated_TimeStamp' then ' hidefield' when 'petModified_TimeStamp' then ' hidefield' when 'petBirthday_awarded_on_Timestamp' then ' hidefield' else '' end as Classes	
				,isnull(DisplayOrder,0) as DisplayOrder
				,0 as Deleted					
		FROM [Widgit] 
		WHERE partialViewId = (select partialViewId from PartialView where [Name] = 'PortalExtraInformation' and clientid =@ClientId)
			AND LOWER([Name]) like LOWER(@ExtensionCategory)+'%'
		Order by DisplayOrder
			

	END
	
END
