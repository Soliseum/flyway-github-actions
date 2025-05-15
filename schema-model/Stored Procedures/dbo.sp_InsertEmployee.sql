SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Updated InsertEmployee
CREATE PROCEDURE [dbo].[sp_InsertEmployee]
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
