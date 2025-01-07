CREATE TABLE [dbo].[Movies]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Title] [nvarchar] (50) NOT NULL,
[Category] [nvarchar] (50) NOT NULL,
[IMDB] [decimal] (6, 2) NULL
)
GO
