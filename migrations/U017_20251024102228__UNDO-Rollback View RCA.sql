SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
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

