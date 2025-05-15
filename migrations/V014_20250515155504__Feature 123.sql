SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Altering [dbo].[Clients]'
GO
ALTER TABLE [dbo].[Clients] ADD
[Status] [nvarchar] (20) NULL CONSTRAINT [DF__Clients__Status__65F62111] DEFAULT ('Active'),
[LastUpdated] [datetime] NULL
GO
PRINT N'Altering [dbo].[Payments]'
GO
ALTER TABLE [dbo].[Payments] ADD
[Currency] [nvarchar] (10) NULL CONSTRAINT [DF__Payments__Curren__66EA454A] DEFAULT ('USD'),
[TransactionReference] [nvarchar] (100) NULL
GO
PRINT N'Altering [dbo].[HR]'
GO
ALTER TABLE [dbo].[HR] ADD
[Department] [nvarchar] (100) NULL,
[Salary] [decimal] (12, 2) NULL
GO
PRINT N'Altering [dbo].[sp_InsertClient]'
GO
ALTER PROCEDURE [dbo].[sp_InsertClient]
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Clients (Name, Email, Phone)
        VALUES (@Name, @Email, @Phone);
        SELECT SCOPE_IDENTITY() AS NewClientID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
PRINT N'Altering [dbo].[sp_InsertEmployee]'
GO

-- Updated InsertEmployee
ALTER PROCEDURE [dbo].[sp_InsertEmployee]
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Position NVARCHAR(100),
    @HireDate DATE,
    @ClientID INT,
    @Department NVARCHAR(100),
    @Salary DECIMAL(12,2)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Clients WHERE ClientID = @ClientID)
    BEGIN
        RAISERROR('ClientID not found.', 16, 1);
        RETURN;
    END

    INSERT INTO HR (FirstName, LastName, Position, HireDate, ClientID, Department, Salary)
    VALUES (@FirstName, @LastName, @Position, @HireDate, @ClientID, @Department, @Salary);
END;
GO
PRINT N'Altering [dbo].[sp_InsertPayment]'
GO

-- Updated InsertPayment
ALTER PROCEDURE [dbo].[sp_InsertPayment]
    @ClientID INT,
    @Amount DECIMAL(10,2),
    @PaymentDate DATE,
    @Method NVARCHAR(50),
    @Currency NVARCHAR(10),
    @TransactionReference NVARCHAR(100)
AS
BEGIN
    IF @Amount <= 0
    BEGIN
        RAISERROR('Amount must be greater than zero.', 16, 1);
        RETURN;
    END

    INSERT INTO Payments (ClientID, Amount, PaymentDate, Method, Currency, TransactionReference)
    VALUES (@ClientID, @Amount, @PaymentDate, @Method, @Currency, @TransactionReference);
END;
GO
PRINT N'Refreshing [dbo].[vw_ClientOverview]'
GO
EXEC sp_refreshview N'[dbo].[vw_ClientOverview]'
GO
PRINT N'Creating [dbo].[vw_RecentClientActivity]'
GO

-- Created View RecentClientActivity
CREATE VIEW [dbo].[vw_RecentClientActivity] AS
SELECT 
    c.ClientID,
    c.Name AS ClientName,
    MAX(p.PaymentDate) AS LastPaymentDate,
    MAX(h.HireDate) AS MostRecentHireDate
FROM Clients c
LEFT JOIN Payments p ON c.ClientID = p.ClientID
LEFT JOIN HR h ON c.ClientID = h.ClientID
GROUP BY c.ClientID, c.Name;
GO

-- truncate
