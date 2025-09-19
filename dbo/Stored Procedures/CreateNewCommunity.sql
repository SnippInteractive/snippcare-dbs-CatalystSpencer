-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <06/10/2016>
-- Description:	<Create Community>
-- =============================================
CREATE PROCEDURE [dbo].[CreateNewCommunity] 
	(
		@MemberId1 int,
		@MemberId2 int,
		@OldCommunityId int,
		@ClientId int
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @communityId int;
	DECLARE @memberLinkId int;
	Declare @LinkType int;

	select @LinkType = MemberLinkTypeId from MemberLinkType where ClientId = @ClientId and Name = 'Community'


	select @communityId = CommunityId from Community where UserId = @MemberId1;
	print 'Checking community'
	print @communityId

	 if NULLIF(@communityId, '')  is null
		begin 
			print 'Creating new community'

			insert into Community (Name, Version, UserId, oldCommunityId)
			VALUES ('Family', 0, @MemberId1, @OldCommunityId)
			SELECT @communityId = Scope_Identity()

			print @communityId
		end 

	print 'Creating member link'
	insert into MemberLink ( MemberId1, MemberId2, LinkType, ParentChild, CreatedBy, CreatedDate, Version, ConfidenceLevel, CommunityId)
	values (
		@MemberId1, @MemberId2, @LinkType, NULL, 1400006, GETDATE(), 0, NULL, @communityId)
	
	SELECT @memberLinkId = SCOPE_IDENTITY()
	
	print 'Member link id'
	print @memberLinkId	
END

