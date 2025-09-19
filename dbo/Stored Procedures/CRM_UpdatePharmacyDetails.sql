CREATE PROCEDURE [dbo].[CRM_UpdatePharmacyDetails] (
	@SiteRef nvarchar(10),
	@CommunicationName nvarchar(50),
	@PharmacyName nvarchar(50),

	@Country nvarchar(50),
	@Street nvarchar(50),
	@Addressline1 nvarchar(50),
	@Zip nvarchar(10),
	@City nvarchar(50),

	@PhoneNumber nvarchar(10),
	@EmailAddress nvarchar(20)
)
AS
BEGIN
	SET NOCOUNT ON;

	declare @SiteId int, @AddressId int, @ContactDetailsId int;

	select  @SiteId = SiteId, 
			@AddressId = AddressId, 
			@ContactDetailsId = ContactDetailsId 
	from Site 
	where SiteRef = @SiteRef

	update ContactDetails set 
		Email = @EmailAddress,
		Phone = @PhoneNumber 
	where ContactDetailsId = @ContactDetailsId;
	
	update Address set 
		Street = @Street, 
		Addressline1 = @Addressline1, 
		Zip = @Zip,
		City = @City
	where AddressId = @AddressId;
	
	update Site set CommunicationName = @CommunicationName, 
			Name = @PharmacyName
	where SiteId = @SiteId;

END

