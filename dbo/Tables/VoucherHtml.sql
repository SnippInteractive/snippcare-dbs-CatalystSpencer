CREATE TABLE [dbo].[VoucherHtml] (
    [Id]          INT  IDENTITY (1, 1) NOT NULL,
    [Version]     INT  NOT NULL,
    [VoucherId]   INT  NOT NULL,
    [HtmlContent] TEXT NULL,
    [ClientId]    INT  NOT NULL,
    CONSTRAINT [PK_VoucherHtml] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_VoucherHtml_Client2] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Client] ([ClientId]),
    CONSTRAINT [FK_VoucherHtml_VoucherDeviceProfileTemplate] FOREIGN KEY ([VoucherId]) REFERENCES [dbo].[VoucherDeviceProfileTemplate] ([Id])
);

