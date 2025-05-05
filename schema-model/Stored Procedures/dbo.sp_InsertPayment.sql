SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Insert Payment
CREATE PROCEDURE [dbo].[sp_InsertPayment]
    @ClientID INT,
    @Amount DECIMAL(10,2),
    @PaymentDate DATE,
    @Method NVARCHAR(50)
AS
BEGIN
    INSERT INTO Payments (ClientID, Amount, PaymentDate, Method)
    VALUES (@ClientID, @Amount, @PaymentDate, @Method);
END;
GO
