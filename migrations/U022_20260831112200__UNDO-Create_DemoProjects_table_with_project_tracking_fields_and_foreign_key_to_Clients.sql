SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping foreign keys from [dbo].[DemoProjects]'
GO
ALTER TABLE [dbo].[DemoProjects] DROP CONSTRAINT [FK_DemoProjects_Clients]
GO
PRINT N'Dropping constraints from [dbo].[DemoProjects]'
GO
ALTER TABLE [dbo].[DemoProjects] DROP CONSTRAINT [PK__DemoProj__761ABED0A11715AD]
GO
PRINT N'Dropping constraints from [dbo].[DemoProjects]'
GO
ALTER TABLE [dbo].[DemoProjects] DROP CONSTRAINT [DF__DemoProje__Statu__3429BB53]
GO
PRINT N'Dropping constraints from [dbo].[DemoProjects]'
GO
ALTER TABLE [dbo].[DemoProjects] DROP CONSTRAINT [DF__DemoProje__Creat__351DDF8C]
GO
PRINT N'Dropping [dbo].[DemoProjects]'
GO
DROP TABLE [dbo].[DemoProjects]
GO
PRINT N'Altering [dbo].[get_movies]'
GO
--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
ALTER PROCEDURE [dbo].[get_movies] @parameter_name AS INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
    BEGIN
        SELECT
            ID,
            Title,
            Category,
            IMDB
        FROM
            dbo.Movies;
    END;
GO

