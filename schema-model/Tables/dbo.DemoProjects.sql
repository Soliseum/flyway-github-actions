CREATE TABLE [dbo].[DemoProjects]
(
[ProjectID] [int] NOT NULL IDENTITY(1, 1),
[ProjectName] [nvarchar] (100) NOT NULL,
[ClientID] [int] NULL,
[StartDate] [date] NULL,
[EndDate] [date] NULL,
[Budget] [decimal] (18, 2) NULL,
[Status] [nvarchar] (20) NULL CONSTRAINT [DF__DemoProje__Statu__3429BB53] DEFAULT ('Pending'),
[CreatedAt] [datetime] NULL CONSTRAINT [DF__DemoProje__Creat__351DDF8C] DEFAULT (getdate())
)
GO
ALTER TABLE [dbo].[DemoProjects] ADD CONSTRAINT [PK__DemoProj__761ABED0A11715AD] PRIMARY KEY CLUSTERED ([ProjectID])
GO
ALTER TABLE [dbo].[DemoProjects] ADD CONSTRAINT [FK_DemoProjects_Clients] FOREIGN KEY ([ClientID]) REFERENCES [dbo].[Clients] ([ClientID])
GO
