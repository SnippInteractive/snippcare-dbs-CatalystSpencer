-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <01/06/2017>
-- Description:	<Merge member A - B>
-- =============================================
CREATE PROCEDURE [dbo].[MemberMerge](
	@TblName varchar(126)
)
AS
BEGIN

	declare @UsersTable table (id int, MemberA int, MemberB int)
	declare @i int = 0;

	insert into @UsersTable execute ('select row_number() over(ORDER BY memberA), convert(int, MemberA) , convert(int, MemberB) from ' + @TblName)
		
	while @i < (select count(1) from @UsersTable)
	begin
		declare @toUpdate varchar(max);
		declare @toUpdate2 varchar(max);
		
		declare @MemberA varchar(max);
		declare @MemberB varchar(max);
		declare @MemberBPointsBalance float;	
		declare @MemberAPointsBalance float;	
		
				
		select @MemberA = MemberA, @MemberB = MemberB from @UsersTable where id = @i + 1;
		
		
		INSERT INTO	 MemberMergeHistory
		SELECT  @MemberA, @MemberB,d.DeviceId, 'User Merge', getdate() from dbo.Device d 
		WHERE d.UserId = @MemberB

		PRINT @MemberA
		PRINT @MemberB

		insert into audit ([Version],[UserId],[FieldName],[NewValue],[OldValue],[ChangeDate],[ChangeBy],[Reason],[ReferenceType],[OperatorId],[SiteId]) 
		values (1, 
			@MemberB, 'UserStatusChanged',
			'Merged', 
			(SELECT us.Name FROM dbo.[User] u JOIN dbo.UserStatus us ON u.UserStatusId = us.UserStatusId WHERE u.UserId = @MemberB),
			getdate(), 1400006, 'Member Merge', null, null , NULL
		)

		Update Account SET UserId = @MemberA
		WHERE AccountId IN (
			select d.AccountId
			from DeviceProfile dp
			join DeviceProfileTemplate dpt on dp.DeviceProfileId = dpt.id
			join DeviceProfileTemplateType dptt on dpt.DeviceProfileTemplateTypeId = dptt.Id
			join Device d on dp.DeviceId = d.Id
			join DeviceStatus ds on d.DeviceStatusId = ds.DeviceStatusId
			where dptt.Name <> 'Loyalty'
			AND d.UserId = @MemberB
		)
		select @MemberBPointsBalance = PointsBalance from Account where UserId = @MemberB ;
		SELECT @MemberAPointsBalance = PointsBalance from Account where UserId = @MemberA ;
	
		PRINT @MemberAPointsBalance
		PRINT @MemberBPointsBalance

		UPDATE Device Set UserId = @MemberA  where userid =  @MemberB;
		Update Account set PointsBalance = (@MemberAPointsBalance + @MemberBPointsBalance)  from Account 
		where UserId = @MemberA AND PointsBalance IS NOT null;
		
		insert into audit ([Version],[UserId],[FieldName],[NewValue],[OldValue],[ChangeDate],[ChangeBy],[Reason],[ReferenceType],[OperatorId],[SiteId])  values (1, 
			@MemberA, 'PointsUpdate',
			convert(varchar(max),(@MemberBPointsBalance +  @MemberAPointsBalance)),@MemberAPointsBalance, 
			getdate(), 1400006, 'Member Merge', null, null , NULL
		)


		insert into audit ([Version],[UserId],[FieldName],[NewValue],[OldValue],[ChangeDate],[ChangeBy],[Reason],[ReferenceType],[OperatorId],[SiteId]) values (1, 
			@MemberA, 'MemberMerge',
			null, 
			null,
			getdate(), 1400006, 
			'Member Merge from ' + convert(varchar(max), @MemberB) + ' to ' + convert(varchar(max), @MemberA)
			, null, null , NULL
		)

		PRINT '1';
		-- disable account

		Update Account set Account.AccountStatusTypeId = 1, Account.PointsBalance = 0 where UserId = @MemberB ;

		--update user status to merged
		Update [User] set UserStatusId = 3,[User].LastUpdatedDate = getdate() where UserId =  @MemberB ;

		-- update community or member link if B is a community member A should replace it
		UPDATE dbo.MemberLink SET MemberId2 = @MemberA WHERE MemberId2 = @MemberB;

		-- update community if B is a community boss member, A should replace it
		UPDATE dbo.Community SET dbo.Community.UserId = @MemberA WHERE UserId = @MemberB;
		UPDATE dbo.MemberLink SET MemberId1 = @MemberA WHERE MemberId1 = @MemberB;



		-- insert new link
		insert into MemberLink values (@MemberA, @MemberB, 3,0, 1400006, getdate(), 1, 0, NULL);


		print @i;

		set @i = @i + 1;
	end

END
