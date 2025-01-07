CREATE TABLE [dbo].[Locations]
(
[LocationID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (100) NOT NULL,
[Region] [nvarchar] (100) NULL,
[Description] [nvarchar] (max) NULL
)
GO
ALTER TABLE [dbo].[Locations] ADD CONSTRAINT [PK__Location__E7FEA47774277248] PRIMARY KEY CLUSTERED ([LocationID])
GO
