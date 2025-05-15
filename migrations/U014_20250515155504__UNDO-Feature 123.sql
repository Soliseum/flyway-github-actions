SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping constraints from [dbo].[Clients]'
GO
ALTER TABLE [dbo].[Clients] DROP CONSTRAINT [DF__Clients__Status__65F62111]
GO
PRINT N'Dropping constraints from [dbo].[Payments]'
GO
ALTER TABLE [dbo].[Payments] DROP CONSTRAINT [DF__Payments__Curren__66EA454A]
GO
PRINT N'Dropping [dbo].[vw_RecentClientActivity]'
GO
DROP VIEW [dbo].[vw_RecentClientActivity]
GO
PRINT N'Altering [dbo].[Clients]'
GO
ALTER TABLE [dbo].[Clients] DROP
COLUMN [Status],
COLUMN [LastUpdated]
GO
PRINT N'Altering [dbo].[HR]'
GO
ALTER TABLE [dbo].[HR] DROP
COLUMN [Department],
COLUMN [Salary]
GO
PRINT N'Altering [dbo].[Payments]'
GO
ALTER TABLE [dbo].[Payments] DROP
COLUMN [Currency],
COLUMN [TransactionReference]
GO
PRINT N'Altering [dbo].[sp_InsertClient]'
GO
-- === STORED PROCEDURES ===

-- Insert Client
ALTER PROCEDURE [dbo].[sp_InsertClient]
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20)
AS
BEGIN
    INSERT INTO Clients (Name, Email, Phone)
    VALUES (@Name, @Email, @Phone);
END;
GO
PRINT N'Altering [dbo].[sp_InsertEmployee]'
GO
-- Insert HR Employee
ALTER PROCEDURE [dbo].[sp_InsertEmployee]
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Position NVARCHAR(100),
    @HireDate DATE,
    @ClientID INT
AS
BEGIN
    INSERT INTO HR (FirstName, LastName, Position, HireDate, ClientID)
    VALUES (@FirstName, @LastName, @Position, @HireDate, @ClientID);
END;
GO
PRINT N'Altering [dbo].[sp_InsertPayment]'
GO
-- Insert Payment
ALTER PROCEDURE [dbo].[sp_InsertPayment]
    @ClientID INT,
    @Amount DECIMAL(10,2),
    @PaymentDate DATE,
    @Method NVARCHAR(50)
AS
BEGIN
    INSERT INTO Payments (ClientID, Amount, PaymentDate, Method)
    VALUES (@ClientID, @Amount, @PaymentDate, @Method);
END;
GO
PRINT N'Refreshing [dbo].[vw_ClientOverview]'
GO
EXEC sp_refreshview N'[dbo].[vw_ClientOverview]'
GO

