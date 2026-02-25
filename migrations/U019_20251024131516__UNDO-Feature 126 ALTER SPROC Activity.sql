SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Altering [dbo].[Clients]'
GO
ALTER TABLE [dbo].[Clients] ADD
[Notes] [nvarchar] (500) NULL
GO
PRINT N'Altering [dbo].[sp_InsertPayment]'
GO
-- Update stored procedure: sp_InsertPayment
ALTER PROCEDURE [dbo].[sp_InsertPayment]
    @ClientID INT,
    @Amount DECIMAL(10,2),
    @PaymentDate DATE,
    @Method NVARCHAR(50),
    @Currency NVARCHAR(10),
    @TransactionReference NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate input
    IF @Amount <= 0
    BEGIN
        RAISERROR('Amount must be greater than zero.', 16, 1);
        RETURN;
    END

    -- Insert payment record
    INSERT INTO [dbo].[Payments] (
        ClientID,
        Amount,
        PaymentDate,
        Method,
        Currency,
        TransactionReference
    )
    VALUES (
        @ClientID,
        @Amount,
        @PaymentDate,
        @Method,
        @Currency,
        @TransactionReference
    );
END;
GO
PRINT N'Refreshing [dbo].[vw_ClientOverview]'
GO
EXEC sp_refreshview N'[dbo].[vw_ClientOverview]'
GO
PRINT N'Creating [dbo].[vw_RecentClientActivity]'
GO
-- truncate drop table

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

