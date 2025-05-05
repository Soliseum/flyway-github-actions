SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Altering [dbo].[Characters]'

GO
ALTER TABLE [dbo].[Characters] ADD
[Age] [nchar] (10) NULL
GO

-- create procedure GetiSizes
-- as 
-- select customer name, * from dbo.SizeTest INNER JOIN customer ON sizetest.a = customer.b
-- return
-- go
-- *