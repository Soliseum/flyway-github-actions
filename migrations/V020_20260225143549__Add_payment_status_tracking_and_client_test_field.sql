SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Altering [dbo].[Clients]'
GO
ALTER TABLE [dbo].[Clients] ADD
[Test3] [nchar] (10) NULL
GO
PRINT N'Altering [dbo].[Payments]'
GO
ALTER TABLE [dbo].[Payments] ADD
[Status] [nvarchar] (50) NULL CONSTRAINT [DF__Payments__Status__1F2E9E6D] DEFAULT ('Pending')
GO
PRINT N'Creating index [IX_Payments_ClientID_PaymentDate] on [dbo].[Payments]'
GO
CREATE NONCLUSTERED INDEX [IX_Payments_ClientID_PaymentDate] ON [dbo].[Payments] ([ClientID], [PaymentDate])
GO
PRINT N'Creating [dbo].[sp_UpdatePaymentStatus]'
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
PRINT N'Refreshing [dbo].[vw_ClientOverview]'
GO
EXEC sp_refreshview N'[dbo].[vw_ClientOverview]'
GO

