SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping foreign keys from [dbo].[HR]'
GO
ALTER TABLE [dbo].[HR] DROP CONSTRAINT [FK__HR__ClientID__53D770D6]
GO
PRINT N'Dropping foreign keys from [dbo].[Payments]'
GO
ALTER TABLE [dbo].[Payments] DROP CONSTRAINT [FK__Payments__Client__56B3DD81]
GO
PRINT N'Dropping constraints from [dbo].[Clients]'
GO
ALTER TABLE [dbo].[Clients] DROP CONSTRAINT [PK__Clients__E67E1A04441DC184]
GO
PRINT N'Dropping constraints from [dbo].[HR]'
GO
ALTER TABLE [dbo].[HR] DROP CONSTRAINT [PK__HR__7AD04FF1C7C12171]
GO
PRINT N'Dropping constraints from [dbo].[Payments]'
GO
ALTER TABLE [dbo].[Payments] DROP CONSTRAINT [PK__Payments__9B556A58E4DDC4B5]
GO
PRINT N'Dropping constraints from [dbo].[Clients]'
GO
ALTER TABLE [dbo].[Clients] DROP CONSTRAINT [DF__Clients__Created__50FB042B]
GO
PRINT N'Dropping [dbo].[sp_InsertPayment]'
GO
DROP PROCEDURE [dbo].[sp_InsertPayment]
GO
PRINT N'Dropping [dbo].[sp_InsertEmployee]'
GO
DROP PROCEDURE [dbo].[sp_InsertEmployee]
GO
PRINT N'Dropping [dbo].[sp_InsertClient]'
GO
DROP PROCEDURE [dbo].[sp_InsertClient]
GO
PRINT N'Dropping [dbo].[Payments]'
GO
DROP TABLE [dbo].[Payments]
GO
PRINT N'Dropping [dbo].[HR]'
GO
DROP TABLE [dbo].[HR]
GO
PRINT N'Dropping [dbo].[Clients]'
GO
DROP TABLE [dbo].[Clients]
GO

