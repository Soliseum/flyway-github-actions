CREATE TABLE [dbo].[CharacterAlliances]
(
[CharacterID] [int] NOT NULL,
[AllianceID] [int] NOT NULL
)
GO
ALTER TABLE [dbo].[CharacterAlliances] ADD CONSTRAINT [PK__Characte__EC64D239164FF19F] PRIMARY KEY CLUSTERED ([CharacterID], [AllianceID])
GO
ALTER TABLE [dbo].[CharacterAlliances] ADD CONSTRAINT [FK__Character__Allia__251C81ED] FOREIGN KEY ([AllianceID]) REFERENCES [dbo].[Alliances] ([AllianceID])
GO
ALTER TABLE [dbo].[CharacterAlliances] ADD CONSTRAINT [FK__Character__Chara__24285DB4] FOREIGN KEY ([CharacterID]) REFERENCES [dbo].[Characters] ([CharacterID])
GO
