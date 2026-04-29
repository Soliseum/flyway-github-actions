SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Script 2: Create a stored procedure to update payment status

CREATE   PROCEDURE [dbo].[sp_UpdatePaymentStatus]
    @PaymentID INT,
    @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Payments
    SET Status = @Status,
        TransactionReference = CASE
                                   WHEN @Status = 'Completed'
                                        AND TransactionReference IS NULL THEN
                                       CONCAT('TRX-', CONVERT(NVARCHAR(20), GETDATE(), 112), '-', @PaymentID)
                                   ELSE
                                       TransactionReference
                               END
    WHERE PaymentID = @PaymentID;

    IF @@ROWCOUNT = 0
        THROW 50000, 'Payment ID not found', 1;

    RETURN 0;
END;

GO
