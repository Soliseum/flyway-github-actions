SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Creating [dbo].[vw_ClientOverview]'
GO
CREATE VIEW [dbo].[vw_ClientOverview] AS
SELECT 
    c.ClientID,
    c.Name AS ClientName,
    c.Email,
    c.Phone,
    c.CreatedAt,
    COUNT(DISTINCT h.EmployeeID) AS TotalEmployees,
    SUM(p.Amount) AS TotalPayments
FROM Clients c
LEFT JOIN HR h ON c.ClientID = h.ClientID
LEFT JOIN Payments p ON c.ClientID = p.ClientID
GROUP BY 
    c.ClientID, c.Name, c.Email, c.Phone, c.CreatedAt;
GO

