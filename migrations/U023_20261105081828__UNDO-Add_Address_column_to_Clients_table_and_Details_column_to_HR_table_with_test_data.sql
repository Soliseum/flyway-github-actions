SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Altering [dbo].[Clients]'
GO
ALTER TABLE [dbo].[Clients] DROP
COLUMN [Address]
GO
PRINT N'Altering [dbo].[HR]'
GO
ALTER TABLE [dbo].[HR] DROP
COLUMN [Details]
GO
PRINT N'Refreshing [dbo].[vw_ClientOverview]'
GO
EXEC sp_refreshview N'[dbo].[vw_ClientOverview]'
GO
PRINT N'Refreshing [dbo].[vw_ClientPayments]'
GO
EXEC sp_refreshview N'[dbo].[vw_ClientPayments]'
GO

SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON
GO
SET DATEFORMAT YMD
GO
SET XACT_ABORT ON
GO

PRINT(N'Delete 3 rows from [dbo].[Clients]')
DELETE FROM [dbo].[Clients] WHERE [ClientID] = 1
DELETE FROM [dbo].[Clients] WHERE [ClientID] = 2
DELETE FROM [dbo].[Clients] WHERE [ClientID] = 3

