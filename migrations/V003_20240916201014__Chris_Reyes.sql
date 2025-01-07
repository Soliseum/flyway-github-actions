SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Creating [dbo].[Locations]'
GO
CREATE TABLE [dbo].[Locations]
(
[LocationID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (100) NOT NULL,
[Region] [nvarchar] (100) NULL,
[Description] [nvarchar] (max) NULL
)
GO
PRINT N'Creating primary key [PK__Location__E7FEA47774277248] on [dbo].[Locations]'
GO
ALTER TABLE [dbo].[Locations] ADD CONSTRAINT [PK__Location__E7FEA47774277248] PRIMARY KEY CLUSTERED ([LocationID])
GO
PRINT N'Creating [dbo].[Battles]'
GO
CREATE TABLE [dbo].[Battles]
(
[BattleID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (100) NOT NULL,
[Date] [date] NULL,
[LocationID] [int] NULL,
[Outcome] [nvarchar] (50) NULL
)
GO
PRINT N'Creating primary key [PK__Battles__0E471DC9BAAF1053] on [dbo].[Battles]'
GO
ALTER TABLE [dbo].[Battles] ADD CONSTRAINT [PK__Battles__0E471DC9BAAF1053] PRIMARY KEY CLUSTERED ([BattleID])
GO
PRINT N'Creating [dbo].[Alliances]'
GO
CREATE TABLE [dbo].[Alliances]
(
[AllianceID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (100) NOT NULL,
[Leader] [nvarchar] (100) NULL,
[Purpose] [nvarchar] (max) NULL
)
GO
PRINT N'Creating primary key [PK__Alliance__91F18798A4610C37] on [dbo].[Alliances]'
GO
ALTER TABLE [dbo].[Alliances] ADD CONSTRAINT [PK__Alliance__91F18798A4610C37] PRIMARY KEY CLUSTERED ([AllianceID])
GO
PRINT N'Creating [dbo].[CharacterAlliances]'
GO
CREATE TABLE [dbo].[CharacterAlliances]
(
[CharacterID] [int] NOT NULL,
[AllianceID] [int] NOT NULL
)
GO
PRINT N'Creating primary key [PK__Characte__EC64D239164FF19F] on [dbo].[CharacterAlliances]'
GO
ALTER TABLE [dbo].[CharacterAlliances] ADD CONSTRAINT [PK__Characte__EC64D239164FF19F] PRIMARY KEY CLUSTERED ([CharacterID], [AllianceID])
GO
PRINT N'Creating [dbo].[Characters]'
GO
CREATE TABLE [dbo].[Characters]
(
[CharacterID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (100) NOT NULL,
[Race] [nvarchar] (50) NULL,
[Home] [nvarchar] (100) NULL,
[Weapon] [nvarchar] (50) NULL
)
GO
PRINT N'Creating primary key [PK__Characte__757BCA401E18DCD0] on [dbo].[Characters]'
GO
ALTER TABLE [dbo].[Characters] ADD CONSTRAINT [PK__Characte__757BCA401E18DCD0] PRIMARY KEY CLUSTERED ([CharacterID])
GO
PRINT N'Adding foreign keys to [dbo].[CharacterAlliances]'
GO
ALTER TABLE [dbo].[CharacterAlliances] ADD CONSTRAINT [FK__Character__Allia__251C81ED] FOREIGN KEY ([AllianceID]) REFERENCES [dbo].[Alliances] ([AllianceID])
GO
ALTER TABLE [dbo].[CharacterAlliances] ADD CONSTRAINT [FK__Character__Chara__24285DB4] FOREIGN KEY ([CharacterID]) REFERENCES [dbo].[Characters] ([CharacterID])
GO
PRINT N'Adding foreign keys to [dbo].[Battles]'
GO
ALTER TABLE [dbo].[Battles] ADD CONSTRAINT [FK__Battles__Locatio__1F63A897] FOREIGN KEY ([LocationID]) REFERENCES [dbo].[Locations] ([LocationID])
GO

