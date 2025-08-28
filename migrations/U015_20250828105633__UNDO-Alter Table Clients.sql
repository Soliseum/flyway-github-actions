SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Altering [dbo].[Clients]'
GO
IF COL_LENGTH(N'[dbo].[Clients]', N'MMA') IS NOT NULL
ALTER TABLE [dbo].[Clients] DROP COLUMN [MMA]
GO
PRINT N'Refreshing [dbo].[vw_ClientOverview]'
GO
IF OBJECT_ID(N'[dbo].[vw_ClientOverview]', 'V') IS NOT NULL
EXEC sp_refreshview N'[dbo].[vw_ClientOverview]'
GO
PRINT N'Refreshing [dbo].[vw_RecentClientActivity]'
GO
IF OBJECT_ID(N'[dbo].[vw_RecentClientActivity]', 'V') IS NOT NULL
EXEC sp_refreshview N'[dbo].[vw_RecentClientActivity]'
GO

