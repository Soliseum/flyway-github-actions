CREATE TABLE [dbo].[Characters]
(
[CharacterID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (100) NOT NULL,
[Race] [nvarchar] (50) NULL,
[Home] [nvarchar] (100) NULL,
[Weapon] [nvarchar] (50) NULL,
[Age] [nchar] (10) NULL
)
GO
ALTER TABLE [dbo].[Characters] ADD CONSTRAINT [PK__Characte__757BCA401E18DCD0] PRIMARY KEY CLUSTERED ([CharacterID])
GO
