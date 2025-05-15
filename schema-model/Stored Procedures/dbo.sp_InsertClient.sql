SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_InsertClient]
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
