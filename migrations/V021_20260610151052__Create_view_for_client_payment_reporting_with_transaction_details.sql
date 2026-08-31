SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Creating [dbo].[vw_ClientPayments]'
GO
-- Script 4: Create a view for payment reporting

CREATE   VIEW [dbo].[vw_ClientPayments]
AS
SELECT p.PaymentID,
       c.Name AS ClientName,
       p.Amount,
       p.PaymentDate,
       p.Method,
       p.Currency,
       p.TransactionReference,
       p.Status
FROM dbo.Payments p
    INNER JOIN dbo.Clients c
        ON p.ClientID = c.ClientID;

GO

