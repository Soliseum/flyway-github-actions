CREATE TABLE [dbo].[Clients]
(
[ClientID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (100) NULL,
[Email] [nvarchar] (100) NULL,
[Phone] [nvarchar] (20) NULL,
[CreatedAt] [datetime] NULL CONSTRAINT [DF__Clients__Created__50FB042B] DEFAULT (getdate()),
[Notes] [nchar] (100) NULL
)
GO
ALTER TABLE [dbo].[Clients] ADD CONSTRAINT [PK__Clients__E67E1A04441DC184] PRIMARY KEY CLUSTERED ([ClientID])
GO
