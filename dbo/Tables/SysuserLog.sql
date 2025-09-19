CREATE TABLE [dbo].[SysuserLog] (
    [SysuserLogId] BIGINT       IDENTITY (1, 1) NOT NULL,
    [Sysuserid]    INT          NULL,
    [Action]       VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Datetime]     DATETIME     NULL,
    [Entity]       VARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [Entity_Id]    BIGINT       NULL,
    CONSTRAINT [PK_SysuserLog] PRIMARY KEY CLUSTERED ([SysuserLogId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SysuserLog_Sysuserid] FOREIGN KEY ([Sysuserid]) REFERENCES [dbo].[User] ([UserId])
);


GO
CREATE NONCLUSTERED INDEX [Entity_DateTime]
    ON [dbo].[SysuserLog]([Datetime] ASC, [Entity] ASC)
    INCLUDE([Entity_Id]) WITH (FILLFACTOR = 100);

