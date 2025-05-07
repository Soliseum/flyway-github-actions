SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping foreign keys from [dbo].[CharacterAlliances]'
GO
ALTER TABLE [dbo].[CharacterAlliances] DROP CONSTRAINT [FK__Character__Allia__251C81ED]
GO
ALTER TABLE [dbo].[CharacterAlliances] DROP CONSTRAINT [FK__Character__Chara__24285DB4]
GO
PRINT N'Dropping foreign keys from [dbo].[Battles]'
GO
ALTER TABLE [dbo].[Battles] DROP CONSTRAINT [FK__Battles__Locatio__1F63A897]
GO
PRINT N'Dropping constraints from [dbo].[Alliances]'
GO
ALTER TABLE [dbo].[Alliances] DROP CONSTRAINT [PK__Alliance__91F18798A4610C37]
GO
PRINT N'Dropping constraints from [dbo].[Battles]'
GO
ALTER TABLE [dbo].[Battles] DROP CONSTRAINT [PK__Battles__0E471DC9BAAF1053]
GO
PRINT N'Dropping constraints from [dbo].[CharacterAlliances]'
GO
ALTER TABLE [dbo].[CharacterAlliances] DROP CONSTRAINT [PK__Characte__EC64D239164FF19F]
GO
PRINT N'Dropping constraints from [dbo].[Characters]'
GO
ALTER TABLE [dbo].[Characters] DROP CONSTRAINT [PK__Characte__757BCA401E18DCD0]
GO
PRINT N'Dropping constraints from [dbo].[Locations]'
GO
ALTER TABLE [dbo].[Locations] DROP CONSTRAINT [PK__Location__E7FEA47774277248]
GO
PRINT N'Dropping [dbo].[Characters]'
GO
DROP TABLE [dbo].[Characters]
GO
PRINT N'Dropping [dbo].[CharacterAlliances]'
GO
DROP TABLE [dbo].[CharacterAlliances]
GO
PRINT N'Dropping [dbo].[Alliances]'
GO
DROP TABLE [dbo].[Alliances]
GO
PRINT N'Dropping [dbo].[Battles]'
GO
DROP TABLE [dbo].[Battles]
GO
PRINT N'Dropping [dbo].[Locations]'
GO
DROP TABLE [dbo].[Locations]
GO

