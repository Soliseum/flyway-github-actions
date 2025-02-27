SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Altering [dbo].[Characters]'

GO
ALTER TABLE [dbo].[Characters] ADD
[Age] [nchar] (10) NULL
GO

-- select * from tableA, tableB where tableA.field1 = tableB.field1
-- select * from table A inner join tableB on tableA.field1 = tableB.field1