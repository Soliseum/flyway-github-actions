SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- === STORED PROCEDURES ===

-- Insert Client
CREATE PROCEDURE [dbo].[sp_InsertClient]
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(20)
AS
BEGIN
    INSERT INTO Clients (Name, Email, Phone)
    VALUES (@Name, @Email, @Phone);
END;
GO
