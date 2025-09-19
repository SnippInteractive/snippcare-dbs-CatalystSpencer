CREATE PROCEDURE [dbo].[GetDevicesForGeneratingBarcode]
(
	@ClientId						INT,
	@ProfileTemplateType			NVARCHAR(30)='',
	@ProfileId						INT = 0,
	@DeviceLotId					INT = 0
)
AS
BEGIN
		SET NOCOUNT ON;

		DECLARE		@DeviceProfileTemplateTypeId INT,
					@jsonData	NVARCHAR(MAX)

		SELECT		@DeviceProfileTemplateTypeId = Id 
		FROM		DeviceProfileTemplateType 
		WHERE		ClientId = @ClientId 
		AND			Name =	@ProfileTemplateType


		SET @jsonData =
		(
			SELECT		d.DeviceId AS [DeviceID],ISNULL(d.ImageUrl,'') AS [ImageUrl]
			FROM		Device d
			INNER JOIN  DeviceLot dl
			ON			dl.Id = d.DeviceLotId
			INNER JOIN  DeviceLotDeviceProfile dldp
			ON			dl.Id = dldp.DeviceLotId
			INNER JOIN  DeviceProfileTemplate dpt
			ON			dldp.DeviceProfileId = dpt.Id		
			WHERE		d.DeviceLotId = dldp.DeviceLotId	
			AND			(dpt.DeviceProfileTemplateTypeId = @DeviceProfileTemplateTypeId 
			OR			ISNULL(@DeviceProfileTemplateTypeId,0)=0)
			AND			(dpt.Id = @ProfileId OR ISNULL(@ProfileId,0)=0)
			AND			(dl.Id = @DeviceLotId OR ISNULL(@DeviceLotId,0)=0)
	
			FOR JSON AUTO
		)

		SELECT @jsonData AS Result
END
