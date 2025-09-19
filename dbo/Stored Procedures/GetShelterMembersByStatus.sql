
CREATE PROCEDURE GetShelterMembersByStatus
(
	@ClientId		INT,
	@status			NVARCHAR(10)='',
	@Ein			NVARCHAR(100)='',
	@PageNumber		INT,
	@RowsOfPage		INT,
	@SortingCol		NVARCHAR(100)='',
	@SortType		NVARCHAR(100)='ASC'
	
)
AS
BEGIN
		DECLARE @userStatusId INT,
				@offset INT,
				@AddressTypeId INT,
				@DeliveryAddressTypeId INT,
				@AddressStatusId INT,
				@AddressValidStatusId INT,
				@AdditionalSearchCriteria NVARCHAR(MAX)=''

		IF LEN(@Ein)> 0
		BEGIN
			SET @AdditionalSearchCriteria = @AdditionalSearchCriteria + '
		AND uled.Ein = '''+CAST(@Ein AS VARCHAR(200))+''''
		END

		IF ISNULL(NULLIF(LTRIM(RTRIM(@status)), ''), '')<>''
		BEGIN
			SET @AdditionalSearchCriteria = @AdditionalSearchCriteria + '
		AND uled.Status = '''+@status+''''
		END


		SET @PageNumber = @PageNumber + 1
		SET @offset = (@PageNumber-1)*@RowsOfPage

		SELECT	@DeliveryAddressTypeId = AddressTypeId 
		FROM	AddressType 
		WHERE	ClientId = @ClientId
		AND		Name = 'Delivery'

		SELECT	@AddressTypeId = AddressTypeId 
		FROM	AddressType 
		WHERE	ClientId = @ClientId
		AND		Name = 'Main'

		SELECT	@AddressStatusId = AddressStatusId 
		FROM	AddressStatus 
		WHERE	ClientId = @ClientId 
		AND		Name = 'Current'

		SELECT	@AddressValidStatusId = AddressValidStatusId 
		FROM	AddressValidStatus
		WHERE	ClientId = @ClientId
		AND		Name = 'Valid'

		SELECT	@userStatusId = UserStatusId 
		FROM	UserStatus
		WHERE	ClientId = @ClientId
		AND		Name = CASE ISNULL(@status,'') WHEN '' THEN 'Active' ELSE @status END

		DECLARE  @sql NVARCHAR(MAX)=''

		SET @sql = @sql + '

		DECLARE @totalCount INT = 0

		SELECT		@totalCount = COUNT(ut.Userid) 
		FROM		[User] ut(nolock)
		INNER JOIN	UserSubType usrstype 
		ON			ut.UserSubTypeId = usrstype.UserSubTypeId
		INNER JOIN	UserLoyaltyExtensionData ued (nolock)
		ON			ued.UserLoyaltyDataId = ut.UserLoyaltyDataId 
		WHERE		clientId = '+CAST( @ClientId AS VARCHAR(10))+'
		AND			usrstype.Name = ''shelter''  
		AND			ued.PropertyName = ''Status'' 
		AND			ued.PropertyValue = '''+@status+''' 

		SELECT		u.CreateDate AS ApplicationDate,
					uled.Name AS ShelterName,
					CONCAT(pd.FirstName,pd.LastName)AS ContactName,
					cd.Email as ContactEmail,
					uled.Ein AS EIN,
					a.City,
					s.Name as State,
					u.UserId,
					CASE WHEN 
					(
						SELECT	COUNT(ID) 
						FROM	UserLoyaltyExtensionData
						WHERE	PropertyName = ''Ein''
						AND		PropertyValue = uled.Ein

					) > 1
					THEN 1
					ELSE 0 
					END AS EinShared,
					uled.Status,
					@totalCount AS TotalCount

			
		FROM		[User] u (nolock)
		INNER JOIN  UserSubType ust
		ON			u.UserSubTypeId = ust.UserSubTypeId
		INNER JOIN  PersonalDetails pd
		ON          u.PersonalDetailsId = pd.PersonalDetailsId
		INNER JOIN  UserLoyaltyData uld
		ON			u.UserLoyaltyDataId = uld.UserLoyaltyDataId

		INNER JOIN
		(
					SELECT * FROM
					(
						SELECT UserLoyaltyDataId,PropertyName,PropertyValue 
						FROM UserLoyaltyExtensionData 
						WHERE PropertyName IN (''Name'',''Ein'',''Status'')
					)Table1

					PIVOT
					(
						MIN(PropertyValue)
						FOR 
						PropertyName
						IN(Name,Ein,Status)
					)as p
					
		) uled
		ON			u.UserLoyaltyDataId = uled.UserLoyaltyDataId
		INNER JOIN  UserContactDetails ucd
		ON			u.Userid = ucd.Userid
		INNER JOIN  ContactDetails cd
		ON			ucd.ContactDetailsId = cd.ContactDetailsId
		INNER JOIN  UserAddresses ua
		ON			ua.Userid = u.Userid
		INNER JOIN  Address a
		ON          ua.AddressId = a.AddressId
		INNER JOIN  State s
		ON          a.StateId = s.StateId
		WHERE       ust.ClientId = '+CAST( @ClientId AS VARCHAR(10))+'
		AND			ust.Name = ''Shelter''
		AND			a.AddressTypeId = 
					CASE 
					WHEN 
					(
						SELECT		COUNT(addr.AddressId) 
						FROM		Address addr 
						INNER JOIN	UserAddresses uAddr 
						ON			addr.AddressId = uAddr.AddressId 
						WHERE		uAddr.UserId = u.Userid 
						AND			addr.AddressTypeId = '+CAST(@DeliveryAddressTypeId AS VARCHAR(100))+' 
					)>=1
					THEN '+CAST(@DeliveryAddressTypeId AS VARCHAR(10))+' 
					ELSE '+CAST(@AddressTypeId AS VARCHAR(10))+' 
					END
		AND			a.AddressStatusId = '+CAST(@AddressStatusId AS VARCHAR(10))+'
		AND			a.AddressValidStatusId = '+CAST(@AddressValidStatusId AS VARCHAR(10))+

		@AdditionalSearchCriteria +

		'
		GROUP BY	u.CreateDate,uled.Name,CONCAT(pd.FirstName,pd.LastName),cd.Email,uled.Ein,a.City,s.Name,u.UserId,uled.Status
		ORDER BY '+@SortingCol+' '+@SortType+'						
		OFFSET '+CAST(@offset AS VARCHAR(10))+' ROWS
		FETCH NEXT '+CAST(@RowsOfPage AS VARCHAR(10))+' ROWS ONLY
		'
		PRINT @sql
		EXEC(@sql)
END
