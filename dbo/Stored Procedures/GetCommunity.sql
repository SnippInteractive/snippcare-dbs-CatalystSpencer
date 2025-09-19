CREATE PROCEDURE [dbo].[GetCommunity](@MemberId BIGINT, @ClientId INT)
AS
  BEGIN

          Declare @LinkTypeId int;
		  SELECT @LinkTypeId = MemberLinkTypeId FROM MemberLinkType WHERE [Name] = 'Community' AND ClientId = @ClientId
          
          SELECT TOP 1 c.CommunityId Id,c.UserId, c.[Name] 
		  FROM Community c
		      INNER JOIN Memberlink ml on c.CommunityId = ml.CommunityId
          WHERE c.UserId = @MemberId AND ml.MemberId1 = @MemberId AND  ml.LinkType = @LinkTypeId
   
  END
