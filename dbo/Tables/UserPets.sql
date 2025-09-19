CREATE TABLE [dbo].[UserPets] (
    [UserPetId]       INT            IDENTITY (1, 1) NOT NULL,
    [UserId]          INT            NOT NULL,
    [IsPrimary]       BIT            NOT NULL,
    [DateOfBirth]     DATETIME       NULL,
    [BirthdayAwarded] DATETIME       NULL,
    [PetName]         NVARCHAR (250) NULL,
    [PetType]         NVARCHAR (50)  NULL,
    [ProfileUrl]      NVARCHAR (250) NULL,
    [Reference]       NVARCHAR (25)  NULL,
    [CreatedAt]       DATETIME       NULL,
    [ModifiedAt]      DATETIME       NULL,
    [Status]          NVARCHAR (25)  NOT NULL,
    CONSTRAINT [FK_UserPets] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserId])
);

