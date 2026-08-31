SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Creating [dbo].[DemoProjects]'
GO
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
PRINT N'Creating primary key [PK__DemoProj__761ABED0A11715AD] on [dbo].[DemoProjects]'
GO
ALTER TABLE [dbo].[DemoProjects] ADD CONSTRAINT [PK__DemoProj__761ABED0A11715AD] PRIMARY KEY CLUSTERED ([ProjectID])
GO
PRINT N'Altering [dbo].[get_movies]'
GO

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
PRINT N'Adding foreign keys to [dbo].[DemoProjects]'
GO
ALTER TABLE [dbo].[DemoProjects] ADD CONSTRAINT [FK_DemoProjects_Clients] FOREIGN KEY ([ClientID]) REFERENCES [dbo].[Clients] ([ClientID])
GO

