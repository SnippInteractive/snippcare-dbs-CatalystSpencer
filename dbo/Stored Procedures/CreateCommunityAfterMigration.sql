-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <Create Date,,>
-- Description:	<Creatse communties after migration>
-- Steps:  
			--1.	Ensure the data is inserted in right format into the MigratedUser table
			--2.	Community boss is distinguished by having an entry in the CommunityId filed
			--3.	Children relates to community boss by having the same OldIdentifier
			--4.	The first step is to get all bosses and their children 
			--5.	Loop through all the bosses and insert into community table (ensure the CommunityType = ‘Community’)
			--6.	Loop through all the children and insert into MemberLink table (community boss goes to MemberId1, relation member goes to MemberId2)
			--			a.	Transfer children points to community boss
			--			b.	Create 2 TrxHeaders
			--				i.	Parent
			--				ii.	Children
			--			c.	Updates accounts
			--				i.	Parent
			--				ii.	Children 
			--7.	Continue looping until no community bosses found

-- =============================================
CREATE PROCEDURE [dbo].[CreateCommunityAfterMigration] (
	@version varchar(20)
)

AS
BEGIN
	
	declare @outputTbl table (
		id int, 
		parentId int,
		parentOldDeviceId varchar(30), 
		parentDeviceId varchar(30), 
		childId int, 
		childCommunityId varchar(30), 
		childDeviceId varchar(30)
	)

	declare @communityBoss table (oldDeviceId varchar(30), id int, boss int, parentDeviceId varchar(30));
	declare @LinkType int;

	select @LinkType = MemberLinkTypeId from MemberLinkType where ClientId = 1 and Name = 'Community'

	insert into @outputTbl
	select ROW_NUMBER() over(order by mu.id), mu.id, mu.OldIdentifier, mu.deviceId, mu1.id, mu1.communityId, mu1.deviceId
	from MigratedUser mu
	join MigratedUser mu1 on mu1.communityId = mu.OldIdentifier
	where mu.version = @version;

	insert into @communityBoss
	select parentOldDeviceId, DENSE_RANK() over(order by parentOldDeviceId) , parentId, parentDeviceId
	from @outputTbl
	group by parentId, parentOldDeviceId, parentDeviceId


	Declare @i int = 1;

	WHILE @i <=  (select count(1) from @communityBoss)
		BEGIN
			declare @boss int;
			declare @oldDeviceId varchar(30)
			declare @newDeviceId varchar(30)
			declare @communityId int;
			
			declare @accountId int;
			declare @pointsBalance int;


			select @boss = boss, @oldDeviceId = oldDeviceId, @newDeviceId = parentDeviceId from @communityBoss where id = @i;

			select @accountId = AccountId from device where DeviceId = @newDeviceId;
			select @pointsBalance = PointsBalance from account where AccountId = @accountId;

			insert into Community (Name, Version, UserId, oldCommunityId)
			VALUES ('Family', 0, @boss, NULL)
			SELECT @communityId=SCOPE_IDENTITY();

			print convert(VARCHAR(MAX), @boss) + ' boss';

			declare @childId int = 0;
				WHILE(1 = 1)
					begin 
						DECLARE @childDeviceId VARCHAR(MAX);

						Declare @trxTypeId int;
						Declare @trxStatusTypeId int;
						Declare @trxId int;
						declare @childAccountId int;
						declare @childPointsBalance int;


						select @trxStatusTypeId = TrxStatusId from TrxStatus where Name = 'Completed';
						Select @trxTypeId = TrxTypeId from TrxType where ClientId = 1 and Name = 'PointsTransfer';

						SELECT @childId = MIN(childId)
						FROM @outputTbl 
						WHERE childId > @childId 
						and parentId = @boss;

						DECLARE @siteId INT
						select @childAccountId = AccountId, @childDeviceId = DeviceId from device where UserId = @childId;
						select @childPointsBalance = PointsBalance from account where AccountId = @childAccountId;

						SET @siteId=(SELECT Top 1 SITEID FROM [User] where UserId = @childId)
						set @pointsBalance = isnull(@childPointsBalance,0) + isnull(@pointsBalance,0);





						if @childId is not null
						begin 
							insert into MemberLink ( MemberId1, MemberId2, LinkType, ParentChild, CreatedBy, CreatedDate, Version, ConfidenceLevel, CommunityId)
							values (
								@boss, @childId, @LinkType, NULL, 1400006, GETDATE(), 0, NULL, @communityId)




								insert into TrxHeader (version, DeviceId, TrxTypeId, TrxDate, ClientId, SiteId, Reference, TrxStatusTypeId, CreateDate, CallContextId, AccountPointsBalance, LastUpdatedDate)
								values
								(0, @newDeviceId, @trxTypeId, GETDATE(), 1, @siteId, 'DB', @trxStatusTypeId, GETDATE(), NEWID(), @pointsBalance, GETDATE())
								SELECT @trxId=SCOPE_IDENTITY();

								insert into TrxDetail (Version, TrxID, LineNumber, ItemCode, Description, Quantity, Value, Points, ConvertedNetValue)
								VALUES
								(0, @trxId, 1, NULL,  'From accountId: ' + convert(VARCHAR(50),  @childAccountId ), 1, 0, 100, 0)





								insert into TrxHeader (version, DeviceId, TrxTypeId, TrxDate, ClientId, SiteId, Reference, TrxStatusTypeId, CreateDate, CallContextId, AccountPointsBalance, LastUpdatedDate)
								values
								(0, @childDeviceId, @trxTypeId, GETDATE(), 1, @siteId, 'DB', @trxStatusTypeId, GETDATE(), NEWID(), 0, GETDATE())
								SELECT @trxId=SCOPE_IDENTITY();

								insert into TrxDetail (Version, TrxID, LineNumber, ItemCode, Description, Quantity, Value, Points, ConvertedNetValue)
								VALUES
								(0, @trxId, 1, 'Transfer','To accountId: ' +convert(VARCHAR(50), @accountId ) , 1, 0, -(isnull(@childPointsBalance,0)), 0)


								update account set PointsBalance = @pointsBalance where AccountId = @accountId;
								update account set PointsBalance = 0 where AccountId = @childAccountId;


								print convert(VARCHAR(MAX), @childId) + ' child ' + @childDeviceId + ' balance ' + CONVERT(VARCHAR(MAX), isnull(@pointsBalance,0))
							
						end
						

						IF @childId IS NULL BREAK
					end

			
			SET @i = @i + 1

		end
END

