SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping [dbo].[vw_RecentClientActivity]'
GO
DROP VIEW [dbo].[vw_RecentClientActivity]
GO
PRINT N'Altering [dbo].[Clients]'
GO
ALTER TABLE [dbo].[Clients] DROP
COLUMN [Notes]
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

