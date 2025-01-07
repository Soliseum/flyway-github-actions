CREATE TABLE [dbo].[Alliances]
(
[AllianceID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (100) NOT NULL,
[Leader] [nvarchar] (100) NULL,
[Purpose] [nvarchar] (max) NULL
)
GO
ALTER TABLE [dbo].[Alliances] ADD CONSTRAINT [PK__Alliance__91F18798A4610C37] PRIMARY KEY CLUSTERED ([AllianceID])
GO
