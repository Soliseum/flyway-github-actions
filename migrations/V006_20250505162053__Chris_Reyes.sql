SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Creating [dbo].[Clients]'
GO
CREATE TABLE [dbo].[Clients]
(
[ClientID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (100) NULL,
[Email] [nvarchar] (100) NULL,
[Phone] [nvarchar] (20) NULL,
[CreatedAt] [datetime] NULL CONSTRAINT [DF__Clients__Created__50FB042B] DEFAULT (getdate())
)
GO
PRINT N'Creating primary key [PK__Clients__E67E1A04441DC184] on [dbo].[Clients]'
GO
ALTER TABLE [dbo].[Clients] ADD CONSTRAINT [PK__Clients__E67E1A04441DC184] PRIMARY KEY CLUSTERED ([ClientID])
GO
PRINT N'Creating [dbo].[HR]'
GO
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
PRINT N'Creating primary key [PK__HR__7AD04FF1C7C12171] on [dbo].[HR]'
GO
ALTER TABLE [dbo].[HR] ADD CONSTRAINT [PK__HR__7AD04FF1C7C12171] PRIMARY KEY CLUSTERED ([EmployeeID])
GO
PRINT N'Creating [dbo].[Payments]'
GO
CREATE TABLE [dbo].[Payments]
(
[PaymentID] [int] NOT NULL IDENTITY(1, 1),
[ClientID] [int] NULL,
[Amount] [decimal] (10, 2) NULL,
[PaymentDate] [date] NULL,
[Method] [nvarchar] (50) NULL
)
GO
PRINT N'Creating primary key [PK__Payments__9B556A58E4DDC4B5] on [dbo].[Payments]'
GO
ALTER TABLE [dbo].[Payments] ADD CONSTRAINT [PK__Payments__9B556A58E4DDC4B5] PRIMARY KEY CLUSTERED ([PaymentID])
GO
PRINT N'Creating [dbo].[sp_InsertClient]'
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
PRINT N'Creating [dbo].[sp_InsertEmployee]'
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
PRINT N'Creating [dbo].[sp_InsertPayment]'
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
PRINT N'Adding foreign keys to [dbo].[HR]'
GO
ALTER TABLE [dbo].[HR] ADD CONSTRAINT [FK__HR__ClientID__53D770D6] FOREIGN KEY ([ClientID]) REFERENCES [dbo].[Clients] ([ClientID])
GO
PRINT N'Adding foreign keys to [dbo].[Payments]'
GO
ALTER TABLE [dbo].[Payments] ADD CONSTRAINT [FK__Payments__Client__56B3DD81] FOREIGN KEY ([ClientID]) REFERENCES [dbo].[Clients] ([ClientID])
GO

