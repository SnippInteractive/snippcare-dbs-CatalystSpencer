
CREATE VIEW [dbo].[VW_MemberBasicInfo]
	AS SELECT     u.UserId AS MemberId, pd.Firstname AS MemberFirstName, pd.Lastname AS MemberLastName, us.Name AS MemberStatusName, ut.Name AS MemberTypeName, u.SiteId AS MemberSiteId, 
                      s.Name AS MemberSiteName, s.SiteRef AS MemberStoreRef,cd.Email,pd.DateOfBirth
FROM         dbo.[User] AS u INNER JOIN
                      dbo.PersonalDetails AS pd ON u.PersonalDetailsId = pd.PersonalDetailsId INNER JOIN
                      dbo.UserStatus AS us ON u.UserStatusId = us.UserStatusId INNER JOIN
                      dbo.UserSubType AS ut ON u.UserSubTypeId = ut.UserSubTypeId INNER JOIN
                      dbo.Site AS s ON s.SiteId = u.SiteId LEFT JOIN
					  dbo.UserContactDetails ucd ON ucd.UserId = u.UserId LEFT JOIN
					  dbo.ContactDetails cd on cd.ContactDetailsId = ucd.ContactDetailsId
