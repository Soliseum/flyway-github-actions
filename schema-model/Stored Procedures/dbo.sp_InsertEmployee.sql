SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Insert HR Employee
CREATE PROCEDURE [dbo].[sp_InsertEmployee]
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
