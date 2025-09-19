CREATE TABLE [dbo].[__TrxMissingJOB_1] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [store_num]        NVARCHAR (255) NULL,
    [reg_num]          FLOAT (53)     NULL,
    [pos trans_num]    FLOAT (53)     NULL,
    [host_trans_id]    FLOAT (53)     NULL,
    [trans_date]       DATETIME       NULL,
    [customer_number]  NVARCHAR (80)  NULL,
    [loyalty_number]   NVARCHAR (255) NULL,
    [item]             FLOAT (53)     NULL,
    [cnt]              FLOAT (53)     NULL,
    [value]            NVARCHAR (255) NULL,
    [linenumber]       INT            NULL,
    [deviceid]         NVARCHAR (30)  NULL,
    [import_date]      DATETIME       NULL,
    [processed_date]   DATETIME       NULL,
    [is_processed]     INT            NULL,
    [file_name]        NVARCHAR (50)  NULL,
    [reference]        FLOAT (53)     NULL,
    [item_description] NVARCHAR (500) NULL,
    [newtrxid]         INT            NULL
);

