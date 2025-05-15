CREATE TABLE [dbo].[Payments]
(
[PaymentID] [int] NOT NULL IDENTITY(1, 1),
[ClientID] [int] NULL,
[Amount] [decimal] (10, 2) NULL,
[PaymentDate] [date] NULL,
[Method] [nvarchar] (50) NULL,
[Currency] [nvarchar] (10) NULL CONSTRAINT [DF__Payments__Curren__66EA454A] DEFAULT ('USD'),
[TransactionReference] [nvarchar] (100) NULL
)
GO
ALTER TABLE [dbo].[Payments] ADD CONSTRAINT [PK__Payments__9B556A58E4DDC4B5] PRIMARY KEY CLUSTERED ([PaymentID])
GO
ALTER TABLE [dbo].[Payments] ADD CONSTRAINT [FK__Payments__Client__56B3DD81] FOREIGN KEY ([ClientID]) REFERENCES [dbo].[Clients] ([ClientID])
GO
