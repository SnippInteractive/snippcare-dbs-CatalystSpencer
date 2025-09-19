CREATE TABLE [dbo].[SegDetail] (
    [SegDetailId]      INT            IDENTITY (1, 1) NOT NULL,
    [SegmentId]        INT            NOT NULL,
    [Position]         TINYINT        NULL,
    [OpenBracket]      VARCHAR (20)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [CloseBracket]     VARCHAR (20)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [AndNext]          BIT            NULL,
    [DbFieldId]        SMALLINT       NULL,
    [ExpressionId]     SMALLINT       NULL,
    [Parameter]        VARCHAR (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [SurveyId]         INT            NULL,
    [SurveyQuestionId] INT            NULL,
    [ControlId]        VARCHAR (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [ReferenceId]      INT            NULL,
    CONSTRAINT [PK_SegDetail] PRIMARY KEY CLUSTERED ([SegDetailId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SegDetail_SegExpressions] FOREIGN KEY ([ExpressionId]) REFERENCES [dbo].[SegExpressions] ([ExpressionId]),
    CONSTRAINT [FK_SegDetail_SegHeader] FOREIGN KEY ([SegmentId]) REFERENCES [dbo].[SegHeader] ([SegmentId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This is an additional ReferenceId that can be used by more complex criteria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SegDetail', @level2type = N'COLUMN', @level2name = N'ReferenceId';

