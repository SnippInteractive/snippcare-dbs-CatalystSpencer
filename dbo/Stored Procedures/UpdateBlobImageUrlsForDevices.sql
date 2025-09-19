
CREATE Procedure UpdateBlobImageUrlsForDevices
(
	@ClientId				INT,
	@deviceListAsJson		NVARCHAR(MAX)
)
AS
BEGIN
		DECLARE @result INT = 0
		IF ISJSON(@deviceListAsJson)= 0 OR ISNULL(ISJSON(@deviceListAsJson),'')= ''
		BEGIN
			SET @result =0
			SELECT @result
			RETURN
		END
		BEGIN TRY
			DECLARE @tempdevice TABLE
			(
				DeviceId		NVARCHAR(100),
				ImageUrl		NVARCHAR(MAX)
			)

			INSERT @tempdevice(DeviceId,ImageUrl)
			SELECT		DeviceID,ImageUrl
			FROM		OPENJSON(@deviceListAsJson)
			WITH(DeviceID NVARCHAR(100),ImageUrl NVARCHAR(MAX))

			UPDATE			d
			SET				d.ImageUrl = tempd.ImageUrl
			FROM			Device d
			INNER JOIN		@tempdevice tempd
			ON				d.deviceId COLLATE SQL_Latin1_General_CP1_CI_AS = tempd.DeviceId COLLATE SQL_Latin1_General_CP1_CI_AS
			INNER JOIN		DeviceStatus ds
			ON				d.DeviceStatusId = ds.DeviceStatusId
			WHERE			ds.ClientId = @ClientId

			SET @result = 1
		END TRY

		BEGIN CATCH
			SET @result = 0
		END CATCH

		SELECT @result

END
