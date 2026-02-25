SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping constraints from [dbo].[Payments]'
GO
ALTER TABLE [dbo].[Payments] DROP CONSTRAINT [DF__Payments__Status__1F2E9E6D]
GO
PRINT N'Dropping index [IX_Payments_ClientID_PaymentDate] from [dbo].[Payments]'
GO
DROP INDEX [IX_Payments_ClientID_PaymentDate] ON [dbo].[Payments]
GO
PRINT N'Dropping [dbo].[sp_UpdatePaymentStatus]'
GO
DROP PROCEDURE [dbo].[sp_UpdatePaymentStatus]
GO
PRINT N'Altering [dbo].[Clients]'
GO
ALTER TABLE [dbo].[Clients] DROP
COLUMN [Test3]
GO
PRINT N'Altering [dbo].[Payments]'
GO
ALTER TABLE [dbo].[Payments] DROP
COLUMN [Status]
GO
PRINT N'Refreshing [dbo].[vw_ClientOverview]'
GO
EXEC sp_refreshview N'[dbo].[vw_ClientOverview]'
GO

