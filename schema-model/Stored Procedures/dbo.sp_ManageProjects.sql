SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_ManageProjects]
    @Action NVARCHAR(20),
    @ProjectID INT = NULL,
    @ProjectName NVARCHAR(100) = NULL,
    @ClientID INT = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @Budget DECIMAL(18,2) = NULL,
    @Status NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Add a new project
    IF @Action = 'Add'
    BEGIN
        INSERT INTO dbo.DemoProjects (ProjectName, ClientID, StartDate, EndDate, Budget, Status)
        VALUES (@ProjectName, @ClientID, @StartDate, @EndDate, @Budget, ISNULL(@Status, 'Pending'));
        
        SELECT SCOPE_IDENTITY() AS NewProjectID;
    END
    
    -- Update an existing project
    ELSE IF @Action = 'Update' AND @ProjectID IS NOT NULL
    BEGIN
        UPDATE dbo.DemoProjects
        SET ProjectName = ISNULL(@ProjectName, ProjectName),
            ClientID = ISNULL(@ClientID, ClientID),
            StartDate = ISNULL(@StartDate, StartDate),
            EndDate = ISNULL(@EndDate, EndDate),
            Budget = ISNULL(@Budget, Budget),
            Status = ISNULL(@Status, Status)
        WHERE ProjectID = @ProjectID;
        
        SELECT @ProjectID AS UpdatedProjectID;
    END
    
    -- Delete a project
    ELSE IF @Action = 'Delete' AND @ProjectID IS NOT NULL
    BEGIN
        DELETE FROM dbo.DemoProjects
        WHERE ProjectID = @ProjectID;
        
        SELECT @ProjectID AS DeletedProjectID;
    END
    
    -- Get all projects
    ELSE IF @Action = 'GetAll'
    BEGIN
        SELECT p.*, c.Name AS ClientName
        FROM dbo.DemoProjects p
        LEFT JOIN dbo.Clients c ON p.ClientID = c.ClientID;
    END
    
    -- Get project by ID
    ELSE IF @Action = 'GetById' AND @ProjectID IS NOT NULL
    BEGIN
        SELECT p.*, c.Name AS ClientName
        FROM dbo.DemoProjects p
        LEFT JOIN dbo.Clients c ON p.ClientID = c.ClientID
        WHERE p.ProjectID = @ProjectID;
    END
    
    -- Get projects by client
    ELSE IF @Action = 'GetByClient' AND @ClientID IS NOT NULL
    BEGIN
        SELECT p.*, c.Name AS ClientName
        FROM dbo.DemoProjects p
        INNER JOIN dbo.Clients c ON p.ClientID = c.ClientID
        WHERE p.ClientID = @ClientID;
    END
    
    ELSE
    BEGIN
        RAISERROR('Invalid action or missing required parameters', 16, 1);
    END
END;
GO
