-- =============================================
-- Author:		<Kamil Wozniak>
-- Create date: <28/11/2016>
-- Description:	<Checks user profile extra info>
-- =============================================
CREATE PROCEDURE [dbo].[CheckUserProfileExtraInfo]
	(
		@UserId int,
		@SocialSecurityHash nvarchar(50)= '',
		@SocialSecurityNo nvarchar(50)= '',
		@CoverCard nvarchar (20) = '',
		@MpiId nvarchar (20) = '',
		@retVal nvarchar(max) output
	)
	
AS
BEGIN

	select  top 1  @retVal= ''
		--case when (SocialSecurity =  @SocialSecurityHash or SocialSecurity = @SocialSecurityNo) and UserId <> @UserId   then 'Supplied social security number is already stored in the database. Please verify and try again, or check if this member already exists.'
		--when Covercard = @CoverCard and UserId <> @UserId then 'Supplied covercard is already stored in the database. Please verify and try again, or check if this member already exists.' 
		--when MpiId = @MpiId and UserId <> @UserId then 'Supplied MPI ID is already stored in the database. Please verify and try again, or check if this member already exists.'
		--else '' end
	from UserProfileExtraInfo
	where (SocialSecurity =  @SocialSecurityHash or SocialSecurity = @SocialSecurityNo) 
	or MpiId = @MpiId
	or Covercard = @CoverCard
	and UserId <> @UserId;

	select @retVal;
END

