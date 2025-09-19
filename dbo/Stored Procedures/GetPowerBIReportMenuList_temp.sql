
CREATE PROCEDURE GetPowerBIReportMenuList_temp
(
	@ClientId		INT
)
AS
BEGIN
		DECLARE @ReportMenuItems TABLE
		(
			Menu			VARCHAR(100),
			ParentMenu		VARCHAR(100),
			MenuId			INT IDENTITY(1,1),
			ParentMenuId	INT,
			MenuLevel		INT,
			IsLastChild		BIT,
			ReportId		INT,
			DisplayName		VARCHAR(100),
			Description     VARCHAR(MAX),
			ReportIndex		INT
		)
		DECLARE @ReportMenuItemTemp TABLE
		(
			Menu			VARCHAR(100),
			ParentMenu		VARCHAR(100),
			MenuIndex		INT,
			MenuLevel		INT
		)
		DECLARE @splitTab TABLE
		(
			MenuIndex	INT,
			MenuName    VARCHAR(100),
			MenuLevel   INT
		)
		DECLARE @i INT,@path VARCHAR(MAX)='',@j INT

		SELECT @i = MIN(ReportId)
		FROM   Report
		WHERE  ReportType =2
		AND    ClientId = @ClientId

		WHILE @i IS NOT NULL
		BEGIN
			SELECT @path =ActualName FROM Report WHERE ReportId = @i
			INSERT @splitTab(MenuIndex,MenuName)
			SELECT ItemIndex,token FROM SplitString(@path,'/')

			UPDATE @SplitTab SET MenuLevel = (SELECT COUNT(token) FROM SplitString(@path,'/'))

			-- Inserting Parent Menu
			INSERT	@ReportMenuItemTemp(Menu,ParentMenu,MenuLevel)
			SELECT  MenuName,Null,MenuLevel
			FROM	@splitTab
			WHERE	MenuIndex =0

			SELECT	@j = MIN(MEnuIndex)
			FROM	@splitTab
			WHERE   MenuIndex <> 0

			WHILE @j IS NOT NULL
			BEGIN
				-- Inserting Sub Menus 
				INSERT @ReportMenuItemTemp(Menu,ParentMenu,MenuIndex,MenuLevel)
				VALUES
				(
					(SELECT  MenuName FROM	@splitTab WHERE MenuIndex =(@j)),
					(SELECT  MenuName FROM	@splitTab WHERE MenuIndex =(@j - 1)),
					@j,
					(SELECT  MenuLevel FROM	@splitTab WHERE MenuIndex =(@j))
				)
				SELECT	@j = MIN(MEnuIndex)
				FROM	@splitTab
				WHERE   MenuIndex <> 0
				AND     MenuIndex > @j		

			END

			DELETE @splitTab

			SELECT @i = MIN(ReportId)
			FROM   Report
			WHERE  ReportId > @i
			AND  ReportType =2
			AND    ClientId = @ClientId
		END

		INSERT @ReportMenuItems(Menu,ParentMenu,MenuLevel)
		SELECT DISTINCT Menu,ParentMenu,MenuLevel
		FROM   @ReportMenuItemTemp



		UPDATE		child
		SET			child.ParentMenuId = Parent.MenuId
		FROM		@ReportMenuItems child
		INNER JOIN	@ReportMenuItems Parent
		ON			ISNULL(child.ParentMenu,'')= ISNULL(parent.Menu,'')

		UPDATE		rm
		SET			rm.IsLastChild = 1,
					rm.ReportId = r.ReportId,
					rm.DisplayName = r.DisplayName,
					rm.ReportIndex = ISNULL(r.ReportIndex,rm.MenuId),
					rm.Description = r.Description
		FROM		@ReportMenuItems rm
		INNER JOIN	Report r
		ON			REVERSE(RIGHT(reverse(r.ActualName), LEN(r.ActualName) - CHARINDEX('/',REVERSE(r.ActualName),1)+ 1 )) + 
					ISNULL(rm.Menu collate SQL_Latin1_General_CP1_CI_AS,'') = r.ActualName
					--ISNULL( REVERSE(LEFT(REVERSE(r.ActualName), CHARINDEX('/', REVERSE(r.ActualName)) - 1)),'')collate SQL_Latin1_General_CP1_CI_AS

		SELECT		MenuId,Menu as Name,DisplayName,Description,ParentMenuId,'' as ReportId,IsLastChild,MenuLevel
		FROM		@ReportMenuItems 
		ORDER BY	ReportIndex

END

