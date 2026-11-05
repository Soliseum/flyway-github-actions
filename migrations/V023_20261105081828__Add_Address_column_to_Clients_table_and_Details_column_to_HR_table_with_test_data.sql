SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Altering [dbo].[Clients]'
GO
ALTER TABLE [dbo].[Clients] ADD
[Address] [nvarchar] (200) NULL
GO
PRINT N'Altering [dbo].[HR]'
GO
ALTER TABLE [dbo].[HR] ADD
[Details] [nchar] (100) NULL
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
-- lookup table data for testing
PRINT(N'Add 3 rows to [dbo].[Clients]')
SET IDENTITY_INSERT [dbo].[Clients] ON
INSERT INTO [dbo].[Clients] ([ClientID], [Address], [Name], [Email], [Phone], [CreatedAt], [Status], [LastUpdated], [Test], [Test2], [Test3]) VALUES (1, N'123 Business St, New York, NY', N'Acme Corporation', N'contact@acme.com', N'555-0101', '2026-11-05 07:59:47.690', N'Active', '2026-11-05 07:59:47.690', NULL, NULL, NULL)
INSERT INTO [dbo].[Clients] ([ClientID], [Address], [Name], [Email], [Phone], [CreatedAt], [Status], [LastUpdated], [Test], [Test2], [Test3]) VALUES (2, N'456 Innovation Ave, San Francisco, CA', N'Tech Solutions Inc', N'info@techsolutions.com', N'555-0102', '2026-11-05 07:59:47.690', N'Active', '2026-11-05 07:59:47.690', NULL, NULL, NULL)
INSERT INTO [dbo].[Clients] ([ClientID], [Address], [Name], [Email], [Phone], [CreatedAt], [Status], [LastUpdated], [Test], [Test2], [Test3]) VALUES (3, N'789 Commerce Blvd, Chicago, IL', N'Global Enterprises', N'support@globalent.com', N'555-0103', '2026-11-05 07:59:47.690', N'Active', '2026-11-05 07:59:47.690', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Clients] OFF

