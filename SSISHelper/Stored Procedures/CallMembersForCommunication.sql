Create Procedure SSISHelper.CallMembersForCommunication (@TemplateID nvarchar(200)) as
--exec SSISHelper.CallMembersForCommunication 'd-2ac2030f19484529a146b1ee6fbd75f0'
/*
Called from the MassCommunication Tool
Get all members for a TemplateID
Get the SOURCE (Email address in this case)
Get the PlaceHolders - parse them out
We return the Source as an Email address initially, can be switched for SMS etc as
well as a field for each of the placeholders
*/

Begin
--declare @Templateid nvarchar(200)='d-2ac2030f19484529a146b1ee6fbd75f0'

      Declare @fld nvarchar(100), @sql nvarchar(max) = 'select [source] as Email'
      drop table if exists #sel
      select id,[source],PlaceHolders, userid, extrainfo, SysUserId, contacttypeid into #sel
      from [SSISHelper].[Email_Queue]
      where datescheduled < GetDate()     and datesent is null
      and templateid = @TemplateID
      and contacttypeid=1 --these are just emails

      Update q set datesent = Getdate() from  [SSISHelper].[Email_Queue] q
      join #sel s on s.id=q.id

      INSERT INTO [dbo].[ContactHistory]
      ([Version],[UserId],[ContactTypeId],[ContactDate],[Comments])
      select 0,userid,contacttypeid,GetDate(),'Communication tool' from #sel
      where ExtraInfo not like '%Campaign%'

      declare @PlaceHolder  nvarchar(max)
      select top 1 @PlaceHolder = PlaceHolders from #sel
      
      Declare cur cursor for
      select [key] from openjson(@PlaceHolder)
      open cur
      FETCH NEXT FROM cur INTO @fld;
      WHILE @@FETCH_STATUS = 0
            BEGIN
            set @sql = @sql + ',JSON_VALUE(ph.value,''$.'+ @fld + ''') as [' + @fld + '] '
            FETCH NEXT FROM cur INTO @fld;
            END;
 
      -- close and deallocate cursor
      CLOSE cur;
      DEALLOCATE cur;
      set @sql = @sql + ' from #sel s CROSS APPLY OpenJson(PlaceHolders) ph'
      update #sel set placeholders = '[' + placeholders + ']' where LEFT(placeholders,1) !='['
      EXECUTE sp_executesql @sql
      drop table if exists #sel

END
