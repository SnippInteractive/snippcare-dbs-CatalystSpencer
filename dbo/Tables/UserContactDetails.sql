CREATE TABLE [dbo].[UserContactDetails] (
    [UserContactDetailsId] INT IDENTITY (1, 1) NOT NULL,
    [UserId]               INT NOT NULL,
    [ContactDetailsId]     INT NOT NULL,
    CONSTRAINT [PK_UserContactDetails] PRIMARY KEY CLUSTERED ([UserContactDetailsId] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_UserContactDetails_ContactDetails] FOREIGN KEY ([ContactDetailsId]) REFERENCES [dbo].[ContactDetails] ([ContactDetailsId]),
    CONSTRAINT [FK_UserContactDetails_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId])
);


GO
CREATE NONCLUSTERED INDEX [UCD_UserId]
    ON [dbo].[UserContactDetails]([UserId] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [idx_UCD_CD_Userid]
    ON [dbo].[UserContactDetails]([ContactDetailsId] ASC)
    INCLUDE([UserId]);

