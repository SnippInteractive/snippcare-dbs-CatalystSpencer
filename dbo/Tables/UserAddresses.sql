CREATE TABLE [dbo].[UserAddresses] (
    [UserAddressesId] INT IDENTITY (1, 1) NOT NULL,
    [Version]         INT CONSTRAINT [DF_UserAddresses_Version] DEFAULT ((0)) NOT NULL,
    [UserId]          INT NOT NULL,
    [AddressId]       INT NOT NULL,
    CONSTRAINT [PK_UserAddresses] PRIMARY KEY CLUSTERED ([UserAddressesId] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_UserAddresses_Address] FOREIGN KEY ([AddressId]) REFERENCES [dbo].[Address] ([AddressId]),
    CONSTRAINT [FK_UserAddresses_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId])
);


GO
CREATE NONCLUSTERED INDEX [User_Addresses]
    ON [dbo].[UserAddresses]([UserId] ASC)
    INCLUDE([AddressId]) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [UserAddresses_AddressId]
    ON [dbo].[UserAddresses]([AddressId] ASC)
    INCLUDE([UserId]) WITH (FILLFACTOR = 95);

