CREATE TABLE [dbo].[HR]
(
[EmployeeID] [int] NOT NULL IDENTITY(1, 1),
[FirstName] [nvarchar] (50) NULL,
[LastName] [nvarchar] (50) NULL,
[Position] [nvarchar] (100) NULL,
[HireDate] [date] NULL,
[ClientID] [int] NULL
)
GO
ALTER TABLE [dbo].[HR] ADD CONSTRAINT [PK__HR__7AD04FF1C7C12171] PRIMARY KEY CLUSTERED ([EmployeeID])
GO
ALTER TABLE [dbo].[HR] ADD CONSTRAINT [FK__HR__ClientID__53D770D6] FOREIGN KEY ([ClientID]) REFERENCES [dbo].[Clients] ([ClientID])
GO
