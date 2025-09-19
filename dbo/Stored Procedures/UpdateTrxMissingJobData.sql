CREATE PROCEDURE [dbo].[UpdateTrxMissingJobData](@clientId int,@filename nvarchar(200))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
--declare @filename nvarchar(200)=@file_name;
drop table if exists #tempTrx
drop table if exists #temptoupdate
select distinct host_trans_id into #tempTrx from [dbo].[TrxMissingJob] where host_trans_id is not null and is_processed is null and Convert(varchar(12), import_date,103)=Convert(varchar(12), getdate(),103) and file_name=@filename

select th.trxid,DeviceId,th.TrxStatusTypeId into #temptoupdate from TrxHeader th inner join #tempTrx t
on t.host_trans_id=th.TrxId where host_trans_id is not null

--set device for records with epos trx
UPDATE t1
  SET t1.deviceid=t2.DeviceId
  FROM TrxMissingJob AS t1
  INNER JOIN #temptoupdate AS t2
  ON t1.host_trans_id = t2.TrxId
  WHERE t1.host_trans_id = t2.TrxId
  --update is processed to 9 for completed epos trx
  UPDATE t1
  SET t1.is_processed=9
  FROM TrxMissingJob AS t1
  INNER JOIN #temptoupdate AS t2
  ON t1.host_trans_id = t2.TrxId
  WHERE t1.host_trans_id = t2.TrxId and t2.TrxStatusTypeId=2
  --update store ref
update TrxMissingJob set store_num = '0000'+store_num where len(store_num)=1 and is_processed is null and Convert(varchar(12), import_date,103)=Convert(varchar(12), getdate(),103) and file_name=@filename
update TrxMissingJob set store_num = '000'+store_num where len(store_num)=2 and is_processed is null and Convert(varchar(12), import_date,103)=Convert(varchar(12), getdate(),103) and file_name=@filename
update TrxMissingJob set store_num = '00'+store_num where len(store_num)=3 and is_processed is null and Convert(varchar(12), import_date,103)=Convert(varchar(12), getdate(),103) and file_name=@filename
update TrxMissingJob set store_num = '0'+store_num where len(store_num)=4 and is_processed is null and Convert(varchar(12), import_date,103)=Convert(varchar(12), getdate(),103) and file_name=@filename


drop table if exists #tempLineNo
select *,row_number() over (partition by [customer_number], [host_trans_id] order by [host_trans_id] ) as line into #tempLineNo from TrxMissingJob where ISNULL(host_trans_id,0) <> 0 and is_processed is null 
and Convert(varchar(12), import_date,103)=Convert(varchar(12), getdate(),103) and file_name=@filename
--select * from  #tempLineNo
UPDATE t1
  SET t1.linenumber=t2.line
  FROM TrxMissingJob AS t1
  INNER JOIN #tempLineNo AS t2
  ON t1.Id = t2.Id
  WHERE t1.Id = t2.Id

--  update reference for records with epos trxid & with out epos trxid seperately

UPDATE TrxMissingJOB SET reference = 
 LTRIM(STR(reg_num, 5, 0)) + store_num +LTRIM(STR(ISNULL(host_trans_id,0), 10, 0))  FROM TrxMissingJOB 
WHERE  is_processed is null and ISNULL(host_trans_id,0) <> 0  and Convert(varchar(12), import_date,103)=Convert(varchar(12), getdate(),103) and file_name=@filename
UPDATE TrxMissingJOB SET reference = 
 LTRIM(STR(reg_num, 5, 0)) + store_num +LTRIM(STR([pos trans_num], 5, 0))  FROM TrxMissingJOB 
WHERE  is_processed is null and ISNULL(host_trans_id,0)=0  and Convert(varchar(12), import_date,103)=Convert(varchar(12), getdate(),103) and file_name=@filename

--update devicied for records with out epos trxid and no userid

drop table if exists #tempDevice
select d.DeviceId,d.UserId,ExtraInfo,j.Id jobid into #tempDevice from DEvice d inner join 
[dbo].[TrxMissingJob] j on j.customer_number=d.ExtraInfo collate database_default 
where j.file_name=@filename and j.is_processed is null and j.deviceid is null and ISNULL(j.host_trans_id,0) =0
UPDATE t1
  SET t1.deviceid=t2.DeviceId
  FROM TrxMissingJob AS t1
  INNER JOIN #tempDevice AS t2
  ON t1.Id = t2.jobid
  WHERE t1.Id = t2.jobid and t1.deviceid is null and t1.file_name=@filename

  -- update deviceid for records with out epostrxid and with userid
drop table if exists #tempuserDevice
select d.DeviceId,d.UserId,ExtraInfo,j.Id jobid into #tempuserDevice from [user] u inner join
DEvice d on d.userid=u.userid inner join 
[dbo].[TrxMissingJob] j on j.customer_number=u.Username collate database_default 
where j.file_name=@filename and j.is_processed is null and j.deviceid is null and ISNULL(j.host_trans_id,0) = 0

UPDATE t1
  SET t1.deviceid=t2.DeviceId
  FROM TrxMissingJob AS t1
  INNER JOIN #tempuserDevice AS t2
  ON t1.Id = t2.jobid
  WHERE t1.Id = t2.jobid and t1.deviceid is null and t1.file_name=@filename

--TO DO -- Assign device to phone number not in username & extrainfo
DROP TABLE IF EXISTS #NEWDeviceID
SELECT DISTINCT customer_number INTO #NEWDeviceID FROM TrxMissingJOB WHERE DeviceId IS NULL AND is_processed IS NULL and file_name=@filename
IF EXISTS (select 1 from #NEWDeviceID)
BEGIN
DECLARE @customer_number NVARCHAR(30),@Userid INT,@DeviceId NVARCHAR(30),@DeviceIdentifier INT
DECLARE NEWDeviceCursor CURSOR LOCAL FORWARD_ONLY READ_ONLY FOR               
SELECT DISTINCT  customer_number FROM #NEWDeviceID                             
OPEN NEWDeviceCursor                                                  
    FETCH NEXT FROM NEWDeviceCursor           
    INTO @customer_number                                       
    WHILE @@FETCH_STATUS = 0 
    BEGIN 
        PRINT @customer_number
        SET @DeviceId = ''
        SET @Userid = 0
        SELECT TOP 1 @Userid = Userid  FROM [User] Where UserName = @customer_number AND UserStatusId = 2 AND UserTypeId = 3
        SELECT TOP 1 @DeviceId = DeviceId FROM Device Where ExtraInfo = @customer_number AND DeviceStatusId = 2
        IF ISNULL(@Userid,0) = 0 AND ISNULL(@DeviceId,'') = ''
        BEGIN
            PRINT @customer_number
            SELECT top 1 @DeviceId = d.deviceid, @DeviceIdentifier = d.Id
            from Device d With(nolock) 
            inner join DeviceProfile dp With(nolock) on d.id=dp.DeviceId 
            where d.DeviceStatusId=2 and dp.DeviceProfileId = 1  
            and isnull(d.Owner,'0')<>'-1' and d.UserId is null and d.ExtraInfo IS NULL
            ORDER BY NEWID()
            IF ISNULL(@DeviceId,'') <> ''
            BEGIN
                PRINT @DeviceId
                Update Device set Owner = '-1', ExtraInfo = @customer_number ,StartDate = Getdate() where DeviceId = @DeviceId
                EXEC Insert_Audit 'I', 1400012, 1, 'Device', 'ExtraInfo',@DeviceId, @customer_number
                UPDATE TrxMissingJOB SET DeviceId = @DeviceId Where customer_number = @customer_number and is_processed is null and file_name=@filename
            END

 

        END
        FETCH NEXT FROM NEWDeviceCursor     
        INTO @customer_number
    END     
	CLOSE NEWDeviceCursor;    
	DEALLOCATE NEWDeviceCursor;
END




  --update line number for records with out epostrxid
  drop table if exists #tempLineNoEpostrxid
select *,row_number() over (partition by [customer_number], [pos trans_num] order by [pos trans_num] ) as line into #tempLineNoEpostrxid from TrxMissingJob where ISNULL(host_trans_id ,0) = 0 and is_processed is null 
and Convert(varchar(12), import_date,103)=Convert(varchar(12), getdate(),103) and file_name=@filename

UPDATE t1
  SET t1.linenumber=t2.line
  FROM TrxMissingJob AS t1
  INNER JOIN #tempLineNoEpostrxid AS t2
  ON t1.Id = t2.Id
  WHERE t1.Id = t2.Id

END



