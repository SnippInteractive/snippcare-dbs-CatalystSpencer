CREATE TABLE [dbo].[Loyalty_Data_Daily] (
    [Region]                   NVARCHAR (200) NULL,
    [District]                 NVARCHAR (200) NULL,
    [Store]                    NVARCHAR (200) NULL,
    [Store_Name]               NVARCHAR (200) NULL,
    [State_Name]               NVARCHAR (200) NULL,
    [Trans_Date]               DATE           NULL,
    [No_of_Trans]              INT            NULL,
    [No_of_Trans_Mem]          INT            NULL,
    [No_of_Trans_Guest]        INT            NULL,
    [No_of_QF_Mem]             INT            NULL,
    [No_of_QF_Guest]           INT            NULL,
    [No_of_TRFR_Punches_Mem]   INT            NULL,
    [No_of_TRFR_Punches_Guest] INT            NULL,
    [Total_Items]              INT            NULL,
    [Total_Reg_Phone]          INT            NULL,
    [Total_Member]             INT            NULL,
    [Total_Guest]              INT            NULL
);

