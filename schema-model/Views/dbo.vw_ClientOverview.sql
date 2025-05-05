SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
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
