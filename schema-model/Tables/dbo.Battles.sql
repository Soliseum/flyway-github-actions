CREATE TABLE [dbo].[Battles]
(
[BattleID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (100) NOT NULL,
[Date] [date] NULL,
[LocationID] [int] NULL,
[Outcome] [nvarchar] (50) NULL
)
GO
ALTER TABLE [dbo].[Battles] ADD CONSTRAINT [PK__Battles__0E471DC9BAAF1053] PRIMARY KEY CLUSTERED ([BattleID])
GO
ALTER TABLE [dbo].[Battles] ADD CONSTRAINT [FK__Battles__Locatio__1F63A897] FOREIGN KEY ([LocationID]) REFERENCES [dbo].[Locations] ([LocationID])
GO
