SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
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
