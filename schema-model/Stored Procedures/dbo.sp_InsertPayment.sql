SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Update stored procedure: sp_InsertPayment
CREATE PROCEDURE [dbo].[sp_InsertPayment]
    @ClientID INT,
    @Amount DECIMAL(10,2),
    @PaymentDate DATE,
    @Method NVARCHAR(50),
    @Currency NVARCHAR(10),
    @TransactionReference NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate input
    IF @Amount <= 0
    BEGIN
        RAISERROR('Amount must be greater than zero.', 16, 1);
        RETURN;
    END

    -- Insert payment record
    INSERT INTO [dbo].[Payments] (
        ClientID,
        Amount,
        PaymentDate,
        Method,
        Currency,
        TransactionReference
    )
    VALUES (
        @ClientID,
        @Amount,
        @PaymentDate,
        @Method,
        @Currency,
        @TransactionReference
    );
END;
GO
