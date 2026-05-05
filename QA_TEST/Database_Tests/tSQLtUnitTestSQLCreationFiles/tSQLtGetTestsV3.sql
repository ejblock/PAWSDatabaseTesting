USE MidlandPitStopDatabase;
GO

-- Drop old test procedures
-- This ensures any previously existing test procedures matching 'test spCreate%' 
-- are removed so that we can recreate fresh test versions.
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql += 
    'IF OBJECT_ID(''' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ''', ''P'') IS NOT NULL
        DROP PROCEDURE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.procedures
WHERE name LIKE 'test spGet%';
EXEC sp_executesql @sql;
GO

-- Create test schemas if they do not exist
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'PetTests')
    EXEC tSQLt.NewTestClass 'PetTests';
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'HomeTests')
    EXEC tSQLt.NewTestClass 'HomeTests';
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'PersonTests')
    EXEC tSQLt.NewTestClass 'PersonTests';
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'EventTests')
    EXEC tSQLt.NewTestClass 'EventTests';
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'UserTests')
    EXEC tSQLt.NewTestClass 'UserTests';
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'RoleTests')
    EXEC tSQLt.NewTestClass 'RoleTests';
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'MedicalTests')
    EXEC tSQLt.NewTestClass 'MedicalTests';
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'SystemTests')
    EXEC tSQLt.NewTestClass 'SystemTests';
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'FolderAndFileTests')
    EXEC tSQLt.NewTestClass 'FolderAndFileTests';
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'FinanceTests')
    EXEC tSQLt.NewTestClass 'FinanceTests';
GO

/*************************************************************************
Section 1: spGetHome tests
Author: Madison Koscielski
Purpose: Test that the stored procedure spGetHome returns correct 
        information and handles invalid input
*************************************************************************/
CREATE OR ALTER PROCEDURE HomeTests.[test spGetHome returns correct house]
AS
BEGIN
    
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    DECLARE @TUID INT = 3;

    ------------------------------------------------------------------------------------------
    -- Expected
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Expected
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    INSERT INTO #Expected
    VALUES
    (
        3,
        'Downtown Saginaw house',
        '7778 Gratiot Rd',
        'Saginaw',
        'MI',
        '48609',
        '989-789-4567',
        0,
        NULL,
        1,
        NULL,
        NULL,
        1,
        1,
        1,
        1,
        0,
        1,
        1,
        1,
        NULL
    );

    ------------------------------------------------------------------------------------------
    -- Actual
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Actual
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    INSERT INTO #Actual
    EXEC dbo.spGetHome @TUID = @TUID;

    ------------------------------------------------------------------------------------------
    -- Order (safe even though single row)
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE HomeTests.[test spGetHome should fail when data is incorrect]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    DECLARE @TUID INT = 3;

    ------------------------------------------------------------------------------------------
    -- Expect a failure
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.ExpectException;

    ------------------------------------------------------------------------------------------
    -- Expected (INTENTIONALLY WRONG)
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Expected
    (
        TUID INT,
        HouseName NVARCHAR(200)
    );

    INSERT INTO #Expected
    VALUES
    (
        3,
        'WRONG NAME'
    );

    ------------------------------------------------------------------------------------------
    -- Actual
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Actual
    (
        TUID INT,
        HouseName NVARCHAR(200)
    );

    INSERT INTO #Actual
    EXEC dbo.spGetHome @TUID = @TUID;

    ------------------------------------------------------------------------------------------
    -- This WILL fail → which makes the test PASS
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE HomeTests.[test spGetHome returns no rows for invalid TUID]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    DECLARE @TUID INT = 999;

    ------------------------------------------------------------------------------------------
    -- Expected (empty)
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Expected
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    ------------------------------------------------------------------------------------------
    -- Actual
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Actual
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    INSERT INTO #Actual
    EXEC dbo.spGetHome @TUID = @TUID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE HomeTests.[test spGetHome returns no rows for NULL TUID]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    DECLARE @TUID INT = NULL;

    ------------------------------------------------------------------------------------------
    -- Expected (empty)
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Expected
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    ------------------------------------------------------------------------------------------
    -- Actual
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Actual
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    INSERT INTO #Actual
    EXEC dbo.spGetHome @TUID = @TUID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE HomeTests.[test spGetHome returns correct house for TUID 1]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    DECLARE @TUID INT = 1;

    ------------------------------------------------------------------------------------------
    -- Expected
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Expected
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    INSERT INTO #Expected
    VALUES
    (
        1,
        'Downtown Midland house',
        '123 Main St',
        'Midland',
        'MI',
        '48640',
        '989-555-1234',
        0,
        NULL,
        1,
        NULL,
        NULL,
        1,
        0,
        0,
        1,
        1,
        1,
        1,
        0,
        NULL
    );

    ------------------------------------------------------------------------------------------
    -- Actual
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Actual
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    INSERT INTO #Actual
    EXEC dbo.spGetHome @TUID = @TUID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

/*************************************************************************
Section 2: spGetAllFiles tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/
CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetAllFiles returns correct file data]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.InsertTestPets;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertBaseFiles;
    EXEC TestHelpers.InsertNestedFolders;
    EXEC TestHelpers.InsertNestedFiles;

    ------------------------------------------------------------------------------------------
    -- Expected (subset of known rows)
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Expected
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        [FileName] NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        PetName NVARCHAR(MAX),
        FolderID INT,
        FolderName NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    INSERT INTO #Expected
    SELECT TOP 1
        f.TUID,
        f.FileLocation,
        f.[FileName],
        f.IsReviewed,
        f.IsPolicyProcedure,
        f.PetID,
        p.[Name],
        f.FolderID,
        fo.FolderName,
        f.LastModifiedOn,
        f.CreatedOn,
        f.LastModifiedBy,
        u1.[Name],
        f.CreatedBy,
        u2.[Name]
    FROM [dbo].[File] f
    LEFT JOIN [dbo].[Folder] fo ON f.FolderID = fo.TUID
    LEFT JOIN [dbo].[Pet] p ON f.PetID = p.TUID
    LEFT JOIN [dbo].[User] u1 ON f.LastModifiedBy = u1.TUID
    LEFT JOIN [dbo].[User] u2 ON f.CreatedBy = u2.TUID
    WHERE f.[FileName] = 'rabies.pdf';

    ------------------------------------------------------------------------------------------
    -- Actual
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Actual
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        [FileName] NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        PetName NVARCHAR(MAX),
        FolderID INT,
        FolderName NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    INSERT INTO #Actual
    EXEC dbo.spGetAllFiles;

    ------------------------------------------------------------------------------------------
    -- Filter actual to same row
    ------------------------------------------------------------------------------------------
    DELETE FROM #Actual
    WHERE [FileName] <> 'rabies.pdf';

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY FolderName, [FileName];
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY FolderName, [FileName];

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetAllFiles handles NULL relationships]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.InsertTestPets;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertBaseFiles;
    EXEC TestHelpers.InsertNestedFolders;
    EXEC TestHelpers.InsertNestedFiles;

    INSERT INTO [dbo].[File]
    (
        FileLocation,
        [FileName],
        IsReviewed,
        IsPolicyProcedure,
        PetID,
        FolderID,
        LastModifiedBy,
        CreatedBy
    )
    VALUES
    (
        '/test/null.pdf',
        'null_test.pdf',
        0,
        0,
        NULL,
        NULL,
        NULL,
        NULL
    );

    ------------------------------------------------------------------------------------------
    -- Expected
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Expected
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        [FileName] NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        PetName NVARCHAR(MAX),
        FolderID INT,
        FolderName NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    INSERT INTO #Expected
    SELECT
        f.TUID,
        f.FileLocation,
        f.[FileName],
        f.IsReviewed,
        f.IsPolicyProcedure,
        f.PetID,
        NULL,
        f.FolderID,
        NULL,
        f.LastModifiedOn,
        f.CreatedOn,
        f.LastModifiedBy,
        NULL,
        f.CreatedBy,
        NULL
    FROM [dbo].[File] f
    WHERE f.[FileName] = 'null_test.pdf';

    ------------------------------------------------------------------------------------------
    -- Actual
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Actual
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        [FileName] NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        PetName NVARCHAR(MAX),
        FolderID INT,
        FolderName NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    INSERT INTO #Actual
    EXEC dbo.spGetAllFiles;

    DELETE FROM #Actual
    WHERE [FileName] <> 'null_test.pdf';

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetAllFiles returns ordered results]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.InsertTestPets;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertBaseFiles;
    EXEC TestHelpers.InsertNestedFolders;
    EXEC TestHelpers.InsertNestedFiles;

    ------------------------------------------------------------------------------------------
    -- Actual
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Actual
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        [FileName] NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        PetName NVARCHAR(MAX),
        FolderID INT,
        FolderName NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    INSERT INTO #Actual
    EXEC dbo.spGetAllFiles;

    ------------------------------------------------------------------------------------------
    -- Create correctly sorted version
    ------------------------------------------------------------------------------------------
    SELECT *
    INTO #Expected
    FROM #Actual
    ORDER BY FolderName, [FileName];

    ------------------------------------------------------------------------------------------
    -- Assert ordering
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetAllFiles returns all rows]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.InsertTestPets;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertBaseFiles;
    EXEC TestHelpers.InsertNestedFolders;
    EXEC TestHelpers.InsertNestedFiles;

    DECLARE @ExpectedCount INT = (SELECT COUNT(*) FROM [dbo].[File]);

    ------------------------------------------------------------------------------------------
    -- Actual
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Actual
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        [FileName] NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        PetName NVARCHAR(MAX),
        FolderID INT,
        FolderName NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    INSERT INTO #Actual
    EXEC dbo.spGetAllFiles;

    DECLARE @ActualCount INT = (SELECT COUNT(*) FROM #Actual);

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEquals @ExpectedCount, @ActualCount;
END;
GO
/*************************************************************************
Section 3: spGetAllHomes tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/
CREATE OR ALTER PROCEDURE HomeTests.[test spGetAllHomes returns all homes when no filters applied]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    ------------------------------------------------------------------------------------------
    -- Expected
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Expected
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    INSERT INTO #Expected
    VALUES
    (1,'Downtown Midland house','123 Main St','Midland','MI','48640','989-555-1234',0,NULL,1,NULL,NULL,1,0,0,1,1,1,1,0,NULL),
    (2,'Downtown Brighton house','800 Dunham Rd','Brighton','MI','48114','989-748-7832',0,NULL,1,NULL,NULL,1,1,1,1,0,1,1,1,NULL),
    (3,'Downtown Saginaw house','7778 Gratiot Rd','Saginaw','MI','48609','989-789-4567',0,NULL,1,NULL,NULL,1,1,1,1,0,1,1,1,NULL);

    ------------------------------------------------------------------------------------------
    -- Actual
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Actual
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    INSERT INTO #Actual
    EXEC dbo.spGetAllHomes;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE HomeTests.[test spGetAllHomes filters by IsActive]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    ------------------------------------------------------------------------------------------
    -- Expected
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Expected 
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    INSERT INTO #Expected
    VALUES
    (2,'Downtown Brighton house','800 Dunham Rd','Brighton','MI','48114','989-748-7832',0,NULL,1,NULL,NULL,1,1,1,1,0,1,1,1,NULL),
    (3,'Downtown Saginaw house','7778 Gratiot Rd','Saginaw','MI','48609','989-789-4567',0,NULL,1,NULL,NULL,1,1,1,1,0,1,1,1,NULL);

    ------------------------------------------------------------------------------------------
    -- Actual
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Actual 
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    INSERT INTO #Actual
    EXEC dbo.spGetAllHomes @IsActive = 1;

    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;

    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE HomeTests.[test spGetAllHomes filters by HasKids]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    CREATE TABLE #Expected 
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    INSERT INTO #Expected
    VALUES
    (1,'Downtown Midland house','123 Main St','Midland','MI','48640','989-555-1234',0,NULL,1,NULL,NULL,1,0,0,1,1,1,1,0,NULL);

    CREATE TABLE #Actual 
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    INSERT INTO #Actual
    EXEC dbo.spGetAllHomes @HasKids = 1;

    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;

    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE HomeTests.[test spGetAllHomes filters with multiple conditions]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    CREATE TABLE #Expected 
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    INSERT INTO #Expected
    VALUES
    (2,'Downtown Brighton house','800 Dunham Rd','Brighton','MI','48114','989-748-7832',0,NULL,1,NULL,NULL,1,1,1,1,0,1,1,1,NULL),
    (3,'Downtown Saginaw house','7778 Gratiot Rd','Saginaw','MI','48609','989-789-4567',0,NULL,1,NULL,NULL,1,1,1,1,0,1,1,1,NULL);

    CREATE TABLE #Actual 
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    INSERT INTO #Actual
    EXEC dbo.spGetAllHomes 
        @IsActive = 1,
        @HasKids = 0;

    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;

    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE HomeTests.[test spGetAllHomes returns no rows when filters exclude all]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    CREATE TABLE #Expected 
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    CREATE TABLE #Actual 
    (
        TUID INT,
        HouseName NVARCHAR(200),
        Address NVARCHAR(200),
        City NVARCHAR(100),
        State NVARCHAR(50),
        ZIP NVARCHAR(20),
        PhoneNumber NVARCHAR(20),
        RedFlag BIT,
        RedFlagReason NVARCHAR(MAX),
        CanFoster BIT,
        NoFosterUntil DATE,
        Notes NVARCHAR(MAX),
        IsAdopter BIT,
        IsFoster BIT,
        IsActive BIT,
        IsIndividual BIT,
        HasKids BIT,
        HasFamily BIT,
        HasOtherPets BIT,
        CanAdopt BIT,
        NoAdoptUntil DATE
    );

    INSERT INTO #Actual
    EXEC dbo.spGetAllHomes 
        @HasKids = 1,
        @IsActive = 1;

    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;

    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

/*************************************************************************
Section 4: spGetAllRoles tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/
CREATE OR ALTER PROCEDURE RoleTests.[test spGetAllRoles returns all roles]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'Role', @identity = 1;
    EXEC TestHelpers.InsertTestRoles;

    CREATE TABLE #Expected
    (
        TUID INT,
        RoleName NVARCHAR(MAX),
        RoleColor NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        PetManagement NVARCHAR(MAX),
        AdopterManagement NVARCHAR(MAX),
        FosterAndVolunteerManagement NVARCHAR(MAX),
        ApplicationsAndVolunteerManagement NVARCHAR(MAX),
        FinancialManagement NVARCHAR(MAX),
        DocumentationAndMeetings NVARCHAR(MAX)
    );

    INSERT INTO #Expected
    SELECT
        1,
        'Administrator',
        'Blue',
        LastModifiedOn,
        1,
        CreatedOn,
        1,
        'Edit',
        'Edit',
        'Edit',
        'Edit',
        'Edit',
        'Edit'
    FROM dbo.Role
    WHERE TUID = 1;

    INSERT INTO #Expected
    SELECT
        2,
        'Treasurer',
        'Red',
        LastModifiedOn,
        3,
        CreatedOn,
        1,
        'No Access',
        'No Access',
        'View',
        'View',
        'Edit',
        'View'
    FROM dbo.Role
    WHERE TUID = 2;

    INSERT INTO #Expected
    SELECT
        3,
        'Secretary',
        'Purple',
        LastModifiedOn,
        1,
        CreatedOn,
        2,
        'View',
        'View',
        'View',
        'View',
        'Edit',
        'Edit'
    FROM dbo.Role
    WHERE TUID = 3;

    ------------------------------------------------------------------------------------------
    -- Actual
    ------------------------------------------------------------------------------------------
    CREATE TABLE #Actual
    (
        TUID INT,
        RoleName NVARCHAR(MAX),
        RoleColor NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        PetManagement NVARCHAR(MAX),
        AdopterManagement NVARCHAR(MAX),
        FosterAndVolunteerManagement NVARCHAR(MAX),
        ApplicationsAndVolunteerManagement NVARCHAR(MAX),
        FinancialManagement NVARCHAR(MAX),
        DocumentationAndMeetings NVARCHAR(MAX)
    );

    INSERT INTO #Actual
    EXEC dbo.spGetAllRoles;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE RoleTests.[test spGetAllRoles returns no rows when Role table is empty]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'Role', @identity = 1;

    CREATE TABLE #Expected
    (
        TUID INT,
        RoleName NVARCHAR(MAX),
        RoleColor NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        PetManagement NVARCHAR(MAX),
        AdopterManagement NVARCHAR(MAX),
        FosterAndVolunteerManagement NVARCHAR(MAX),
        ApplicationsAndVolunteerManagement NVARCHAR(MAX),
        FinancialManagement NVARCHAR(MAX),
        DocumentationAndMeetings NVARCHAR(MAX)
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        RoleName NVARCHAR(MAX),
        RoleColor NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        PetManagement NVARCHAR(MAX),
        AdopterManagement NVARCHAR(MAX),
        FosterAndVolunteerManagement NVARCHAR(MAX),
        ApplicationsAndVolunteerManagement NVARCHAR(MAX),
        FinancialManagement NVARCHAR(MAX),
        DocumentationAndMeetings NVARCHAR(MAX)
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetAllRoles;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 5: spGetAllUsers tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/
CREATE OR ALTER PROCEDURE UserTests.[test spGetAllUsers returns all users]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.UpdateTestUserRoles;

    CREATE TABLE #Expected
    (
        TUID INT,
        RoleID INT,
        Username NVARCHAR(MAX),
        Password NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Name NVARCHAR(MAX),
        Notes NVARCHAR(MAX)
    );

    INSERT INTO #Expected
    VALUES
    (1, 1,    'admin',     'password123', 'admin@pets.org',     'Gwen',  'Runs Midland Pit Stop'),
    (3, NULL, 'secretary', '67',          'secretary@pets.org', 'Mark',  'Handles general inquiries'),
    (2, NULL, 'treasurer', 'Ilovedogs',   'treasurer@pets.org', 'Cindy', 'Handles financials');

    CREATE TABLE #Actual
    (
        TUID INT,
        RoleID INT,
        Username NVARCHAR(MAX),
        Password NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Name NVARCHAR(MAX),
        Notes NVARCHAR(MAX)
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetAllUsers;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY Username;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY Username;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE UserTests.[test spGetAllUsers returns no rows when User table is empty]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;

    CREATE TABLE #Expected
    (
        TUID INT,
        RoleID INT,
        Username NVARCHAR(MAX),
        Password NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Name NVARCHAR(MAX),
        Notes NVARCHAR(MAX)
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        RoleID INT,
        Username NVARCHAR(MAX),
        Password NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Name NVARCHAR(MAX),
        Notes NVARCHAR(MAX)
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetAllUsers;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 6: spGetEvent tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE EventTests.[test spGetEvent returns correct event for TUID 1]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC TestHelpers.InsertTestEvents;

    DECLARE @EventTUID INT = 1;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATE,
        Recurring BIT,
        DayPeriod INT,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        1,
        'Adoption Fair',
        'Local pet adoption event',
        '2026-01-14',
        1,
        30,
        LastModifiedOn,
        CreatedOn,
        1,
        1
    FROM dbo.[Event]
    WHERE TUID = 1;

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATE,
        Recurring BIT,
        DayPeriod INT,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetEvent @EventTUID = @EventTUID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE EventTests.[test spGetEvent returns no rows for NULL TUID]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC TestHelpers.InsertTestEvents;

    DECLARE @EventTUID INT = NULL;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATETIME,
        Recurring BIT,
        DayPeriod INT,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATETIME,
        Recurring BIT,
        DayPeriod INT,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetEvent @EventTUID = @EventTUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE EventTests.[test spGetEvent returns no rows for invalid TUID]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC TestHelpers.InsertTestEvents;

    DECLARE @EventTUID INT = 999;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATETIME,
        Recurring BIT,
        DayPeriod INT,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATETIME,
        Recurring BIT,
        DayPeriod INT,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetEvent @EventTUID = @EventTUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO


/*************************************************************************
Section 7: spGetExpense tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE FinanceTests.[test spGetExpense throws error for invalid month]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Expense', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.InsertTestExpenses;

    ------------------------------------------------------------------------------------------
    -- Expect
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.ExpectException @ExpectedMessage = 'Month must be between 1 and 12';

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    EXEC dbo.spGetExpense @Month = 13, @Year = 2025;
END;
GO

CREATE OR ALTER PROCEDURE FinanceTests.[test spGetExpense returns no rows when no expenses match]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Expense', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.InsertTestExpenses;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Date] DATETIME,
        Category NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        Amount DECIMAL(18,2),
        PayMethod NVARCHAR(MAX),
        Vendor NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        [Date] DATETIME,
        Category NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        Amount DECIMAL(18,2),
        PayMethod NVARCHAR(MAX),
        Vendor NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetExpense @Month = 12, @Year = 2030;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE FinanceTests.[test spGetExpense returns correct expenses for August 2025]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Expense', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.InsertTestExpenses;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Date] DATETIME,
        Category NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        Amount DECIMAL(18,2),
        PayMethod NVARCHAR(MAX),
        Vendor NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    INSERT INTO #Expected
    SELECT
        1,
        '2025-08-19',
        'Medical',
        'Neutered',
        120.50,
        'Credit Card',
        'Happy Paws Vet',
        LastModifiedOn,
        CreatedOn,
        1,
        'Gwen',
        3,
        'Mark'
    FROM dbo.Expense
    WHERE TUID = 1;

    CREATE TABLE #Actual
    (
        TUID INT,
        [Date] DATETIME,
        Category NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        Amount DECIMAL(18,2),
        PayMethod NVARCHAR(MAX),
        Vendor NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetExpense @Month = 8, @Year = 2025;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY [Date] DESC, TUID DESC;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY [Date] DESC, TUID DESC;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

/*************************************************************************
Section 8: spGetFilteredUser tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE UserTests.[test spGetFilteredUser returns all users when RoleID is NULL]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.UpdateTestUserRoles;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    INSERT INTO #Expected
    VALUES
        (1, 'Gwen',  'admin',     'password123', 'admin@pets.org',     'Runs Midland Pit Stop',     1),
        (3, 'Mark',  'secretary', '67',          'secretary@pets.org', 'Handles general inquiries', NULL),
        (2, 'Cindy', 'treasurer', 'Ilovedogs',   'treasurer@pets.org', 'Handles financials',        NULL);

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetFilteredUser @RoleID = NULL;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY UserName;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY UserName;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE UserTests.[test spGetFilteredUser returns only users for RoleID 1]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.UpdateTestUserRoles;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    INSERT INTO #Expected
    VALUES
        (1, 'Gwen', 'admin', 'password123', 'admin@pets.org', 'Runs Midland Pit Stop', 1);

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetFilteredUser @RoleID = 1;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY UserName;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY UserName;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

/*************************************************************************
Section 9: spGetFolderByPath tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetFolderByPath returns correct root folder]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    DECLARE @FolderName NVARCHAR(255) = '/Medical Records';

    CREATE TABLE #Expected
    (
        TUID INT,
        FolderName NVARCHAR(255),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        1,
        '/Medical Records',
        LastModifiedOn,
        1,
        '2025-04-30',
        3
    FROM dbo.Folder
    WHERE TUID = 1;

    CREATE TABLE #Actual
    (
        TUID INT,
        FolderName NVARCHAR(255),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetFolderByPath @FolderName = @FolderName;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetFolderByPath returns correct nested folder]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    DECLARE @FolderName NVARCHAR(255) = '/Medical Records/Vaccinations/2024';

    CREATE TABLE #Expected
    (
        TUID INT,
        FolderName NVARCHAR(255),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        6,
        '/Medical Records/Vaccinations/2024',
        LastModifiedOn,
        1,
        CreatedOn,
        1
    FROM dbo.Folder
    WHERE TUID = 6;

    CREATE TABLE #Actual
    (
        TUID INT,
        FolderName NVARCHAR(255),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetFolderByPath @FolderName = @FolderName;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetFolderByPath returns no rows for invalid folder]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    DECLARE @FolderName NVARCHAR(255) = '/Does Not Exist';

    CREATE TABLE #Expected
    (
        TUID INT,
        FolderName NVARCHAR(255),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FolderName NVARCHAR(255),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetFolderByPath @FolderName = @FolderName;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetFolderByPath returns no rows for NULL folder]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    DECLARE @FolderName NVARCHAR(255) = NULL;

    CREATE TABLE #Expected
    (
        TUID INT,
        FolderName NVARCHAR(255),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FolderName NVARCHAR(255),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetFolderByPath @FolderName = @FolderName;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO


/*************************************************************************
Section 10: spGetMedicalRecords tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE MedicalTests.[test spGetMedicalRecords returns correct vaccine records for pet 2]
AS
BEGIN
   ------------------------------------------------------------------------------------------
-- Arrange
------------------------------------------------------------------------------------------
EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
EXEC TestHelpers.InsertTestUsers;

EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
EXEC TestHelpers.InsertTestPets;

EXEC tSQLt.FakeTable 'dbo', 'Vaccine', @identity = 1;
EXEC tSQLt.FakeTable 'dbo', 'Prevention', @identity = 1;
EXEC tSQLt.FakeTable 'dbo', 'Surgery', @identity = 1;

EXEC TestHelpers.InsertTestVaccines;
EXEC TestHelpers.InsertTestPreventions;
EXEC TestHelpers.InsertTestSurgeries;


    CREATE TABLE #Expected
    (
        TUID INT,
        [Type] NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        DateGiven DATETIME,
        DateDue DATETIME,
        PetID INT
    );

    INSERT INTO #Expected
    VALUES
    (
        1,
        'Rabies',
        'Initial dose',
        NULL,
        '2026-08-03',
        2
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        [Type] NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        DateGiven DATETIME,
        DateDue DATETIME,
        PetID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC tSQLt.ResultSetFilter
        1,
        'EXEC dbo.spGetMedicalRecords @PetID = 2';

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE MedicalTests.[test spGetMedicalRecords returns correct prevention records for pet 2]
AS
BEGIN
    ------------------------------------------------------------------------------------------
-- Arrange
------------------------------------------------------------------------------------------
EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
EXEC TestHelpers.InsertTestUsers;

EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
EXEC TestHelpers.InsertTestPets;

EXEC tSQLt.FakeTable 'dbo', 'Vaccine', @identity = 1;
EXEC tSQLt.FakeTable 'dbo', 'Prevention', @identity = 1;
EXEC tSQLt.FakeTable 'dbo', 'Surgery', @identity = 1;

EXEC TestHelpers.InsertTestVaccines;
EXEC TestHelpers.InsertTestPreventions;
EXEC TestHelpers.InsertTestSurgeries;


    CREATE TABLE #Expected
    (
        TUID INT,
        [Type] NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        DateGiven DATETIME,
        DateDue DATETIME,
        PetID INT
    );

    INSERT INTO #Expected
    SELECT
        1,
        'Heartworm',
        'Monthly',
        DateGiven,
        DateDue,
        2
    FROM dbo.Prevention
    WHERE TUID = 1;

    CREATE TABLE #Actual
    (
        TUID INT,
        [Type] NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        DateGiven DATETIME,
        DateDue DATETIME,
        PetID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC tSQLt.ResultSetFilter
        2,
        'EXEC dbo.spGetMedicalRecords @PetID = 2';

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE MedicalTests.[test spGetMedicalRecords returns correct surgery records for pet 1]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
EXEC TestHelpers.InsertTestUsers;
    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Vaccine', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Prevention', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Surgery', @identity = 1;

    EXEC TestHelpers.InsertTestPets;
    EXEC TestHelpers.InsertTestVaccines;
    EXEC TestHelpers.InsertTestPreventions;
    EXEC TestHelpers.InsertTestSurgeries;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATETIME,
        PetID INT
    );

    INSERT INTO #Expected
    VALUES
    (
        1,
        'Neutering',
        'Routine neuter surgery',
        '2025-04-03',
        1
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATETIME,
        PetID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC tSQLt.ResultSetFilter
        3,
        'EXEC dbo.spGetMedicalRecords @PetID = 1';

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE MedicalTests.[test spGetMedicalRecords returns no vaccine records for invalid pet]
AS
BEGIN
    ------------------------------------------------------------------------------------------
-- Arrange
------------------------------------------------------------------------------------------
EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
EXEC TestHelpers.InsertTestUsers;

EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
EXEC TestHelpers.InsertTestPets;

EXEC tSQLt.FakeTable 'dbo', 'Vaccine', @identity = 1;
EXEC tSQLt.FakeTable 'dbo', 'Prevention', @identity = 1;
EXEC tSQLt.FakeTable 'dbo', 'Surgery', @identity = 1;

EXEC TestHelpers.InsertTestVaccines;
EXEC TestHelpers.InsertTestPreventions;
EXEC TestHelpers.InsertTestSurgeries;


    CREATE TABLE #Expected
    (
        TUID INT,
        [Type] NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        DateGiven DATETIME,
        DateDue DATETIME,
        PetID INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        [Type] NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        DateGiven DATETIME,
        DateDue DATETIME,
        PetID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC tSQLt.ResultSetFilter
        1,
        'EXEC dbo.spGetMedicalRecords @PetID = 999';

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE MedicalTests.[test spGetMedicalRecords returns no prevention records for invalid pet]
AS
BEGIN
    ------------------------------------------------------------------------------------------
-- Arrange
------------------------------------------------------------------------------------------
EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
EXEC TestHelpers.InsertTestUsers;

EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
EXEC TestHelpers.InsertTestPets;

EXEC tSQLt.FakeTable 'dbo', 'Vaccine', @identity = 1;
EXEC tSQLt.FakeTable 'dbo', 'Prevention', @identity = 1;
EXEC tSQLt.FakeTable 'dbo', 'Surgery', @identity = 1;

EXEC TestHelpers.InsertTestVaccines;
EXEC TestHelpers.InsertTestPreventions;
EXEC TestHelpers.InsertTestSurgeries;


    CREATE TABLE #Expected
    (
        TUID INT,
        [Type] NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        DateGiven DATETIME,
        DateDue DATETIME,
        PetID INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        [Type] NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        DateGiven DATETIME,
        DateDue DATETIME,
        PetID INT
    );

    INSERT INTO #Actual
    EXEC tSQLt.ResultSetFilter
        2,
        'EXEC dbo.spGetMedicalRecords @PetID = 999';

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE MedicalTests.[test spGetMedicalRecords returns no surgery records for invalid pet]
AS
BEGIN
    ------------------------------------------------------------------------------------------
-- Arrange
------------------------------------------------------------------------------------------
EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
EXEC TestHelpers.InsertTestUsers;

EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
EXEC TestHelpers.InsertTestPets;

EXEC tSQLt.FakeTable 'dbo', 'Vaccine', @identity = 1;
EXEC tSQLt.FakeTable 'dbo', 'Prevention', @identity = 1;
EXEC tSQLt.FakeTable 'dbo', 'Surgery', @identity = 1;

EXEC TestHelpers.InsertTestVaccines;
EXEC TestHelpers.InsertTestPreventions;
EXEC TestHelpers.InsertTestSurgeries;


    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATETIME,
        PetID INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATETIME,
        PetID INT
    );

    INSERT INTO #Actual
    EXEC tSQLt.ResultSetFilter
        3,
        'EXEC dbo.spGetMedicalRecords @PetID = 999';

    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 11: spGetNextLayerFiles tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetNextLayerFiles returns correct files for folder 7]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC TestHelpers.InsertBaseFiles;
    EXEC TestHelpers.InsertNestedFiles;

    DECLARE @FolderID INT = 7;

    CREATE TABLE #Expected
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        TUID,
        '/Adoption Documents/Pending/application_john.pdf',
        'John Doe Application',
        0,
        0,
        NULL,
        7,
        LastModifiedOn,
        2,
        CreatedOn,
        2
    FROM dbo.[File]
    WHERE FileLocation = '/Adoption Documents/Pending/application_john.pdf';

    INSERT INTO #Expected
    SELECT
        TUID,
        '/Adoption Documents/Pending/application_jane.pdf',
        'Jane Smith Application',
        0,
        0,
        NULL,
        7,
        LastModifiedOn,
        1,
        CreatedOn,
        1
    FROM dbo.[File]
    WHERE FileLocation = '/Adoption Documents/Pending/application_jane.pdf';

    CREATE TABLE #Actual
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNextLayerFiles @FolderID = @FolderID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetNextLayerFiles returns correct single file for folder 8]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC TestHelpers.InsertBaseFiles;
    EXEC TestHelpers.InsertNestedFiles;

    DECLARE @FolderID INT = 8;

    CREATE TABLE #Expected
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        TUID,
        '/Adoption Documents/Completed/adopted_buddy.pdf',
        'Buddy Adoption Contract',
        1,
        0,
        NULL,
        8,
        LastModifiedOn,
        2,
        CreatedOn,
        2
    FROM dbo.[File]
    WHERE FileLocation = '/Adoption Documents/Completed/adopted_buddy.pdf';

    CREATE TABLE #Actual
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNextLayerFiles @FolderID = @FolderID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetNextLayerFiles returns no rows for invalid folder]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC TestHelpers.InsertBaseFiles;
    EXEC TestHelpers.InsertNestedFiles;

    DECLARE @FolderID INT = 999;

    CREATE TABLE #Expected
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNextLayerFiles @FolderID = @FolderID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetNextLayerFiles returns no rows for NULL folder]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC TestHelpers.InsertBaseFiles;
    EXEC TestHelpers.InsertNestedFiles;

    DECLARE @FolderID INT = NULL;

    CREATE TABLE #Expected
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNextLayerFiles @FolderID = @FolderID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 12: spGetNextLayerFolders tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE PROCEDURE FolderAndFileTests.[test spGetNextLayerFolders returns immediate child folders for Medical Records]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC TestHelpers.InsertTestData;

    DECLARE @FolderID INT = 1;

    CREATE TABLE #Expected
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        4,
        '/Medical Records/Vaccinations',
        LastModifiedOn,
        1,
        CreatedOn,
        1
    FROM dbo.Folder
    WHERE TUID = 4;

    INSERT INTO #Expected
    SELECT
        5,
        '/Medical Records/Surgery',
        LastModifiedOn,
        2,
        CreatedOn,
        2
    FROM dbo.Folder
    WHERE TUID = 5;

    CREATE TABLE #Actual
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNextLayerFolders @FolderID = @FolderID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spGetNextLayerFolders returns immediate child folder for Vaccinations]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC TestHelpers.InsertTestData;

    DECLARE @FolderID INT = 4;

    CREATE TABLE #Expected
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        6,
        '/Medical Records/Vaccinations/2024',
        LastModifiedOn,
        1,
        CreatedOn,
        1
    FROM dbo.Folder
    WHERE TUID = 6;

    CREATE TABLE #Actual
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNextLayerFolders @FolderID = @FolderID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spGetNextLayerFolders returns no rows when folder has no children]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC TestHelpers.InsertTestData;

    DECLARE @FolderID INT = 6;

    CREATE TABLE #Expected
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNextLayerFolders @FolderID = @FolderID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spGetNextLayerFolders returns no rows for invalid folder]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC TestHelpers.InsertTestData;

    DECLARE @FolderID INT = 999;

    CREATE TABLE #Expected
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNextLayerFolders @FolderID = @FolderID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spGetNextLayerFolders returns no rows for NULL folder]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC TestHelpers.InsertTestData;

    DECLARE @FolderID INT = NULL;

    CREATE TABLE #Expected
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNextLayerFolders @FolderID = @FolderID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 11: spGetNextLayerFiles tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetNextLayerFiles returns correct files for folder 7]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC TestHelpers.InsertBaseFiles;
    EXEC TestHelpers.InsertNestedFiles;

    DECLARE @FolderID INT = 7;

    CREATE TABLE #Expected
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        TUID,
        '/Adoption Documents/Pending/application_john.pdf',
        'John Doe Application',
        0,
        0,
        NULL,
        7,
        LastModifiedOn,
        2,
        CreatedOn,
        2
    FROM dbo.[File]
    WHERE FileLocation = '/Adoption Documents/Pending/application_john.pdf';

    INSERT INTO #Expected
    SELECT
        TUID,
        '/Adoption Documents/Pending/application_jane.pdf',
        'Jane Smith Application',
        0,
        0,
        NULL,
        7,
        LastModifiedOn,
        1,
        CreatedOn,
        1
    FROM dbo.[File]
    WHERE FileLocation = '/Adoption Documents/Pending/application_jane.pdf';

    CREATE TABLE #Actual
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNextLayerFiles @FolderID = @FolderID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetNextLayerFiles returns correct single file for folder 8]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC TestHelpers.InsertBaseFiles;
    EXEC TestHelpers.InsertNestedFiles;

    DECLARE @FolderID INT = 8;

    CREATE TABLE #Expected
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        TUID,
        '/Adoption Documents/Completed/adopted_buddy.pdf',
        'Buddy Adoption Contract',
        1,
        0,
        NULL,
        8,
        LastModifiedOn,
        2,
        CreatedOn,
        2
    FROM dbo.[File]
    WHERE FileLocation = '/Adoption Documents/Completed/adopted_buddy.pdf';

    CREATE TABLE #Actual
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNextLayerFiles @FolderID = @FolderID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetNextLayerFiles returns no rows for invalid folder]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC TestHelpers.InsertBaseFiles;
    EXEC TestHelpers.InsertNestedFiles;

    DECLARE @FolderID INT = 999;

    CREATE TABLE #Expected
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNextLayerFiles @FolderID = @FolderID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetNextLayerFiles returns no rows for NULL folder]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC TestHelpers.InsertBaseFiles;
    EXEC TestHelpers.InsertNestedFiles;

    DECLARE @FolderID INT = NULL;

    CREATE TABLE #Expected
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNextLayerFiles @FolderID = @FolderID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 13: spGetNonRecurringEvents tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE EventTests.[test spGetNonRecurringEvents returns correct non recurring events]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC TestHelpers.InsertTestEvents;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATETIME,
        StartTime TIME NULL,
        EndTime TIME NULL,
        Recurring BIT,
        DayPeriod INT NULL,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        2,
        'Meet and Greet',
        'Meet your favorite paw friends',
        [Date],
        StartTime,
        EndTime,
        0,
        NULL,
        LastModifiedOn,
        3,
        CreatedOn,
        3
    FROM dbo.[Event]
    WHERE TUID = 2;

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATETIME,
        StartTime TIME NULL,
        EndTime TIME NULL,
        Recurring BIT,
        DayPeriod INT NULL,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNonRecurringEvents;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY [Date], StartTime;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY [Date], StartTime;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE EventTests.[test spGetNonRecurringEvents returns no rows when all events are recurring]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC TestHelpers.InsertTestEvents;

    UPDATE dbo.[Event]
    SET Recurring = 1;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATETIME,
        StartTime TIME NULL,
        EndTime TIME NULL,
        Recurring BIT,
        DayPeriod INT NULL,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATETIME,
        StartTime TIME NULL,
        EndTime TIME NULL,
        Recurring BIT,
        DayPeriod INT NULL,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNonRecurringEvents;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE EventTests.[test spGetNonRecurringEvents returns rows ordered by date and start time]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC TestHelpers.InsertTestEvents;

    INSERT INTO dbo.[Event]
    (
        [Name],
        [Description],
        [Date],
        StartTime,
        EndTime,
        Recurring,
        DayPeriod,
        LastModifiedOn,
        CreatedOn,
        LastModifiedBy,
        CreatedBy
    )
    VALUES
    (
        'Volunteer Breakfast',
        'Morning meetup before event',
        '2026-01-01',
        '08:00:00',
        '09:00:00',
        0,
        NULL,
        GETDATE(),
        GETDATE(),
        1,
        1
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATETIME,
        StartTime TIME NULL,
        EndTime TIME NULL,
        Recurring BIT,
        DayPeriod INT NULL,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetNonRecurringEvents;

    ------------------------------------------------------------------------------------------
    -- Expected = same rows in sorted order
    ------------------------------------------------------------------------------------------
    SELECT *
    INTO #Expected
    FROM #Actual
    ORDER BY [Date], StartTime;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 14: spGetPeople tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE PersonTests.[test spGetPeople returns all people when no filters are applied]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC TestHelpers.InsertTestPeople;

    CREATE TABLE #Expected
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        1,
        'Jane',
        'Doe',
        'janedoe@example.com',
        '989-555-9876',
        2,
        0,
        'Takes lots of cats',
        LastModifiedOn,
        1,
        CreatedOn,
        2
    FROM dbo.Person
    WHERE TUID = 1;

    INSERT INTO #Expected
    VALUES
    (
        2,
        'John',
        'Doe',
        'johndoe@example.com',
        '810-555-9876',
        1,
        1,
        'Very helpful, #1 guy',
        '2026-01-16',
        2,
        '2026-01-01',
        3
    );

    INSERT INTO #Expected
    VALUES
    (
        3,
        'Mike',
        'Bob',
        'mikebob@example.com',
        '313-698-9646',
        3,
        1,
        'Weekend volunteer',
        '2026-01-16',
        1,
        '2026-01-01',
        3
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPeople;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY CreatedOn DESC, TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY CreatedOn DESC, TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE PersonTests.[test spGetPeople filters by search string]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC TestHelpers.InsertTestPeople;

    CREATE TABLE #Expected
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        1,
        'Jane',
        'Doe',
        'janedoe@example.com',
        '989-555-9876',
        2,
        0,
        'Takes lots of cats',
        LastModifiedOn,
        1,
        CreatedOn,
        2
    FROM dbo.Person
    WHERE TUID = 1;

    INSERT INTO #Expected
    VALUES
    (
        2,
        'John',
        'Doe',
        'johndoe@example.com',
        '810-555-9876',
        1,
        1,
        'Very helpful, #1 guy',
        '2026-01-16',
        2,
        '2026-01-01',
        3
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPeople @SearchString = 'Doe';

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY CreatedOn DESC, TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY CreatedOn DESC, TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE PersonTests.[test spGetPeople filters by volunteer status]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC TestHelpers.InsertTestPeople;

    CREATE TABLE #Expected
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    VALUES
    (
        2,
        'John',
        'Doe',
        'johndoe@example.com',
        '810-555-9876',
        1,
        1,
        'Very helpful, #1 guy',
        '2026-01-16',
        2,
        '2026-01-01',
        3
    ),
    (
        3,
        'Mike',
        'Bob',
        'mikebob@example.com',
        '313-698-9646',
        3,
        1,
        'Weekend volunteer',
        '2026-01-16',
        1,
        '2026-01-01',
        3
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPeople @IsVolunteer = 1;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY CreatedOn DESC, TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY CreatedOn DESC, TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE PersonTests.[test spGetPeople filters by has house]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC TestHelpers.InsertTestPeople;

    CREATE TABLE #Expected
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        1,
        'Jane',
        'Doe',
        'janedoe@example.com',
        '989-555-9876',
        2,
        0,
        'Takes lots of cats',
        LastModifiedOn,
        1,
        CreatedOn,
        2
    FROM dbo.Person
    WHERE TUID = 1;

    INSERT INTO #Expected
    VALUES
    (
        2,
        'John',
        'Doe',
        'johndoe@example.com',
        '810-555-9876',
        1,
        1,
        'Very helpful, #1 guy',
        '2026-01-16',
        2,
        '2026-01-01',
        3
    ),
    (
        3,
        'Mike',
        'Bob',
        'mikebob@example.com',
        '313-698-9646',
        3,
        1,
        'Weekend volunteer',
        '2026-01-16',
        1,
        '2026-01-01',
        3
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPeople @HasHouse = 1;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY CreatedOn DESC, TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY CreatedOn DESC, TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE PersonTests.[test spGetPeople returns no rows for has house equals 0]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC TestHelpers.InsertTestPeople;

    CREATE TABLE #Expected
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPeople @HasHouse = 0;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE PersonTests.[test spGetPeople combines search and volunteer filters]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC TestHelpers.InsertTestPeople;

    CREATE TABLE #Expected
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    VALUES
    (
        2,
        'John',
        'Doe',
        'johndoe@example.com',
        '810-555-9876',
        1,
        1,
        'Very helpful, #1 guy',
        '2026-01-16',
        2,
        '2026-01-01',
        3
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPeople
        @SearchString = 'Doe',
        @IsVolunteer = 1;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY CreatedOn DESC, TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY CreatedOn DESC, TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

/*************************************************************************
Section 15: spGetPerson tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE PersonTests.[test spGetPerson returns correct person for TUID 1]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC TestHelpers.InsertTestPeople;

    DECLARE @PersonTUID INT = 1;

    CREATE TABLE #Expected
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        1,
        'Jane',
        'Doe',
        'janedoe@example.com',
        '989-555-9876',
        2,
        0,
        'Takes lots of cats',
        LastModifiedOn,
        1,
        CreatedOn,
        2
    FROM dbo.Person
    WHERE TUID = 1;

    CREATE TABLE #Actual
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPerson @PersonTUID = @PersonTUID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE PersonTests.[test spGetPerson returns correct person for TUID 2]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC TestHelpers.InsertTestPeople;

    DECLARE @PersonTUID INT = 2;

    CREATE TABLE #Expected
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    VALUES
    (
        2,
        'John',
        'Doe',
        'johndoe@example.com',
        '810-555-9876',
        1,
        1,
        'Very helpful, #1 guy',
        '2026-01-16',
        2,
        '2026-01-01',
        3
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPerson @PersonTUID = @PersonTUID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE PersonTests.[test spGetPerson returns no rows for invalid TUID]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC TestHelpers.InsertTestPeople;

    DECLARE @PersonTUID INT = 999;

    CREATE TABLE #Expected
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPerson @PersonTUID = @PersonTUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE PersonTests.[test spGetPerson returns no rows for NULL TUID]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC TestHelpers.InsertTestPeople;

    DECLARE @PersonTUID INT = NULL;

    CREATE TABLE #Expected
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPerson @PersonTUID = @PersonTUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO


/*************************************************************************
Section 16: spGetPetList tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE PetTests.[test spGetPetList returns all pets]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    CREATE TABLE #Expected
    (
        TUID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DateOfBirth DATE,
        IsDateOfBirthKnown BIT,
        Characteristics NVARCHAR(MAX),
        Weight INT,
        IntakeDate DATE,
        Notes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        PreviousHomeID INT,
        CurrentHomeID INT NULL,
        LastModifiedBy INT,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        1,
        'Dog',
        'Labrador',
        'Buddy',
        'Male',
        'Shelter',
        '2024-03-08',
        1,
        'Friendly, Leash Trained',
        80,
        '2026-01-04',
        'Healthy',
        '965000000123456',
        1,
        '/photos/buddy.jpg',
        LastModifiedOn,
        '2026-01-09',
        1,
        NULL,
        1,
        1
    FROM dbo.Pet
    WHERE TUID = 1;

    INSERT INTO #Expected
    SELECT
        2,
        'Cat',
        'Siamese',
        'Taco',
        'Female',
        'Georgia St',
        '2026-01-01',
        0,
        'Shy, Good with Kids',
        5,
        '2026-01-29',
        'Very shy',
        '931000000157893',
        0,
        '/photos/taco.jpg',
        LastModifiedOn,
        CreatedOn,
        NULL,
        NULL,
        3,
        3
    FROM dbo.Pet
    WHERE TUID = 2;

    INSERT INTO #Expected
    SELECT
        3,
        'Dog',
        'Golden Retriever',
        'Scooby',
        'Male',
        'Shelter',
        '2020-07-18',
        1,
        'Friendly, Potty Trained, Dewormed',
        67,
        '2025-12-15',
        'Enjoys being outside',
        '901000000789456',
        0,
        '/photos/scooby.jpg',
        LastModifiedOn,
        CreatedOn,
        NULL,
        NULL,
        1,
        1
    FROM dbo.Pet
    WHERE TUID = 3;

    CREATE TABLE #Actual
    (
        TUID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DateOfBirth DATE,
        IsDateOfBirthKnown BIT,
        Characteristics NVARCHAR(MAX),
        Weight INT,
        IntakeDate DATE,
        Notes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        PreviousHomeID INT,
        CurrentHomeID INT NULL,
        LastModifiedBy INT,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPetList;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE PetTests.[test spGetPetList returns no rows when Pet table is empty]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;

    CREATE TABLE #Expected
    (
        TUID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DateOfBirth DATE,
        IsDateOfBirthKnown BIT,
        Characteristics NVARCHAR(MAX),
        Weight INT,
        IntakeDate DATE,
        Notes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        PreviousHomeID INT,
        CurrentHomeID INT NULL,
        LastModifiedBy INT,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DateOfBirth DATE,
        IsDateOfBirthKnown BIT,
        Characteristics NVARCHAR(MAX),
        Weight INT,
        IntakeDate DATE,
        Notes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        PreviousHomeID INT,
        CurrentHomeID INT NULL,
        LastModifiedBy INT,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPetList;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 17: spGetPetProfile tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE PetTests.[test spGetPetProfile returns Buddy profile for PetID 1]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;

    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC TestHelpers.InsertBaseFiles;

    EXEC tSQLt.FakeTable 'dbo', 'Vaccine', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Prevention', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Surgery', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'VetVisit', @identity = 1;

    EXEC TestHelpers.InsertTestVaccines;
    EXEC TestHelpers.InsertTestPreventions;
    EXEC TestHelpers.InsertTestSurgeries;
    EXEC TestHelpers.InsertTestVetVisits;

    CREATE TABLE #Expected
    (
        PetID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DOB DATE,
        DOBKnown BIT,
        Characterisitics NVARCHAR(MAX),
        [Weight] INT,
        IntakeDate DATE,
        PetNotes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PreviousHomeID INT NULL,
        CurrentHomeID INT NULL,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        CurrentHomeID_Joined INT NULL,
        CurrentHomeAddress NVARCHAR(MAX),
        CurrentHomeCity NVARCHAR(MAX),
        CurrentHomeState NVARCHAR(MAX),
        CurrentHomeZip NVARCHAR(MAX),
        CurrentHomePhoneNumber NVARCHAR(MAX),
        PreviousHomeID_Joined INT NULL,
        PreviousHomeAddress NVARCHAR(MAX),
        PreviousHomeCity NVARCHAR(MAX),
        PreviousHomeState NVARCHAR(MAX),
        PreviousHomeZip NVARCHAR(MAX),
        PreviousHomePhoneNumber NVARCHAR(MAX),
        FileID INT NULL,
        FileLocation NVARCHAR(MAX),
        VaccineType NVARCHAR(MAX),
        VaccineNotes NVARCHAR(MAX),
        VaccineDateGiven DATETIME,
        VaccineDateDue DATETIME,
        PreventionType NVARCHAR(MAX),
        PreventionNotes NVARCHAR(MAX),
        PreventionDateGiven DATETIME,
        PreventionDateDue DATETIME,
        SurgeryName NVARCHAR(MAX),
        SurgeryDescription NVARCHAR(MAX),
        SurgeryDate DATETIME,
        VetVisitName NVARCHAR(MAX),
        VetVisitDescription NVARCHAR(MAX),
        VetVisitDate DATETIME
    );

    INSERT INTO #Expected
    SELECT
        1,
        'Dog',
        'Labrador',
        'Buddy',
        'Male',
        'Shelter',
        '2024-03-08',
        1,
        'Friendly, Leash Trained',
        80,
        '2026-01-04',
        'Healthy',
        '965000000123456',
        1,
        1,
        NULL,
        '/photos/buddy.jpg',
        p.LastModifiedOn,
        1,
        '2026-01-09',
        1,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        1,
        '123 Main St',
        'Midland',
        'MI',
        '48640',
        '989-555-1234',
        1,
        'medical/rabies.pdf',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        'Neutering',
        'Routine neuter surgery',
        '2025-04-03',
        'Annual Checkup',
        'Routine exam',
        '2025-04-23'
    FROM dbo.Pet p
    WHERE p.TUID = 1;

    CREATE TABLE #Actual
    (
        PetID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DOB DATE,
        DOBKnown BIT,
        Characterisitics NVARCHAR(MAX),
        [Weight] INT,
        IntakeDate DATE,
        PetNotes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PreviousHomeID INT NULL,
        CurrentHomeID INT NULL,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        CurrentHomeID_Joined INT NULL,
        CurrentHomeAddress NVARCHAR(MAX),
        CurrentHomeCity NVARCHAR(MAX),
        CurrentHomeState NVARCHAR(MAX),
        CurrentHomeZip NVARCHAR(MAX),
        CurrentHomePhoneNumber NVARCHAR(MAX),
        PreviousHomeID_Joined INT NULL,
        PreviousHomeAddress NVARCHAR(MAX),
        PreviousHomeCity NVARCHAR(MAX),
        PreviousHomeState NVARCHAR(MAX),
        PreviousHomeZip NVARCHAR(MAX),
        PreviousHomePhoneNumber NVARCHAR(MAX),
        FileID INT NULL,
        FileLocation NVARCHAR(MAX),
        VaccineType NVARCHAR(MAX),
        VaccineNotes NVARCHAR(MAX),
        VaccineDateGiven DATETIME,
        VaccineDateDue DATETIME,
        PreventionType NVARCHAR(MAX),
        PreventionNotes NVARCHAR(MAX),
        PreventionDateGiven DATETIME,
        PreventionDateDue DATETIME,
        SurgeryName NVARCHAR(MAX),
        SurgeryDescription NVARCHAR(MAX),
        SurgeryDate DATETIME,
        VetVisitName NVARCHAR(MAX),
        VetVisitDescription NVARCHAR(MAX),
        VetVisitDate DATETIME
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPetProfile @PetID = 1;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE PetTests.[test spGetPetProfile returns no rows for invalid PetID]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;

    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC TestHelpers.InsertBaseFiles;

    EXEC tSQLt.FakeTable 'dbo', 'Vaccine', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Prevention', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Surgery', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'VetVisit', @identity = 1;

    EXEC TestHelpers.InsertTestVaccines;
    EXEC TestHelpers.InsertTestPreventions;
    EXEC TestHelpers.InsertTestSurgeries;
    EXEC TestHelpers.InsertTestVetVisits;

    CREATE TABLE #Expected
    (
        PetID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DOB DATE,
        DOBKnown BIT,
        Characterisitics NVARCHAR(MAX),
        [Weight] INT,
        IntakeDate DATE,
        PetNotes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PreviousHomeID INT NULL,
        CurrentHomeID INT NULL,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        CurrentHomeID_Joined INT NULL,
        CurrentHomeAddress NVARCHAR(MAX),
        CurrentHomeCity NVARCHAR(MAX),
        CurrentHomeState NVARCHAR(MAX),
        CurrentHomeZip NVARCHAR(MAX),
        CurrentHomePhoneNumber NVARCHAR(MAX),
        PreviousHomeID_Joined INT NULL,
        PreviousHomeAddress NVARCHAR(MAX),
        PreviousHomeCity NVARCHAR(MAX),
        PreviousHomeState NVARCHAR(MAX),
        PreviousHomeZip NVARCHAR(MAX),
        PreviousHomePhoneNumber NVARCHAR(MAX),
        FileID INT NULL,
        FileLocation NVARCHAR(MAX),
        VaccineType NVARCHAR(MAX),
        VaccineNotes NVARCHAR(MAX),
        VaccineDateGiven DATETIME,
        VaccineDateDue DATETIME,
        PreventionType NVARCHAR(MAX),
        PreventionNotes NVARCHAR(MAX),
        PreventionDateGiven DATETIME,
        PreventionDateDue DATETIME,
        SurgeryName NVARCHAR(MAX),
        SurgeryDescription NVARCHAR(MAX),
        SurgeryDate DATETIME,
        VetVisitName NVARCHAR(MAX),
        VetVisitDescription NVARCHAR(MAX),
        VetVisitDate DATETIME
    );

    CREATE TABLE #Actual
    (
        PetID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DOB DATE,
        DOBKnown BIT,
        Characterisitics NVARCHAR(MAX),
        [Weight] INT,
        IntakeDate DATE,
        PetNotes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PreviousHomeID INT NULL,
        CurrentHomeID INT NULL,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        CurrentHomeID_Joined INT NULL,
        CurrentHomeAddress NVARCHAR(MAX),
        CurrentHomeCity NVARCHAR(MAX),
        CurrentHomeState NVARCHAR(MAX),
        CurrentHomeZip NVARCHAR(MAX),
        CurrentHomePhoneNumber NVARCHAR(MAX),
        PreviousHomeID_Joined INT NULL,
        PreviousHomeAddress NVARCHAR(MAX),
        PreviousHomeCity NVARCHAR(MAX),
        PreviousHomeState NVARCHAR(MAX),
        PreviousHomeZip NVARCHAR(MAX),
        PreviousHomePhoneNumber NVARCHAR(MAX),
        FileID INT NULL,
        FileLocation NVARCHAR(MAX),
        VaccineType NVARCHAR(MAX),
        VaccineNotes NVARCHAR(MAX),
        VaccineDateGiven DATETIME,
        VaccineDateDue DATETIME,
        PreventionType NVARCHAR(MAX),
        PreventionNotes NVARCHAR(MAX),
        PreventionDateGiven DATETIME,
        PreventionDateDue DATETIME,
        SurgeryName NVARCHAR(MAX),
        SurgeryDescription NVARCHAR(MAX),
        SurgeryDate DATETIME,
        VetVisitName NVARCHAR(MAX),
        VetVisitDescription NVARCHAR(MAX),
        VetVisitDate DATETIME
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPetProfile @PetID = 999;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE PetTests.[test spGetPetProfile returns only requested pet]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;

    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC TestHelpers.InsertBaseFiles;

    EXEC tSQLt.FakeTable 'dbo', 'Vaccine', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Prevention', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Surgery', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'VetVisit', @identity = 1;

    EXEC TestHelpers.InsertTestVaccines;
    EXEC TestHelpers.InsertTestPreventions;
    EXEC TestHelpers.InsertTestSurgeries;
    EXEC TestHelpers.InsertTestVetVisits;

    INSERT INTO dbo.Pet
    (
        Animal, Breed, [Name], Sex, Origin, DateOfBirth,
        IsDateOfBirthKnown, Characteristics, Weight,
        IntakeDate, Notes, Microchip, Adopted, PhotoLocation,
        LastModifiedOn, CreatedOn,
        PreviousHomeID, CurrentHomeID,
        LastModifiedBy, CreatedBy
    )
    VALUES
    (
        'Dog', 'Beagle', 'Patch', 'Male', 'Rescue', '2023-05-01',
        1, 'Playful', 25,
        '2026-02-01', 'Patch notes', '999000000000001', 0, '/photos/patch.jpg',
        GETDATE(), GETDATE(),
        1, 2,
        1, 1
    ),
    (
        'Cat', 'Tabby', 'Mittens', 'Female', 'Owner Surrender', '2022-04-01',
        1, 'Calm', 10,
        '2026-02-02', 'Mittens notes', '999000000000002', 0, '/photos/mittens.jpg',
        GETDATE(), GETDATE(),
        2, 3,
        1, 1
    );

    DECLARE @PatchID INT = IDENT_CURRENT('dbo.Pet') - 1;
    DECLARE @MittensID INT = IDENT_CURRENT('dbo.Pet');

    INSERT INTO dbo.[File]
    (
        FileLocation, FileName, IsReviewed, IsPolicyProcedure, PetID, FolderID,
        LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy
    )
    VALUES
    ('/test/patch.pdf', 'patch.pdf', 1, 0, @PatchID, 1, GETDATE(), 1, GETDATE(), 1),
    ('/test/mittens.pdf', 'mittens.pdf', 1, 0, @MittensID, 1, GETDATE(), 1, GETDATE(), 1);

    INSERT INTO dbo.Vaccine ([Type], Notes, DateGiven, DateDue, PetID)
    VALUES
    ('Rabies', 'Patch vaccine', '2026-02-02', '2027-02-02', @PatchID),
    ('Rabies', 'Mittens vaccine', '2026-02-02', '2027-02-02', @MittensID);

    INSERT INTO dbo.Prevention ([Type], Notes, DateGiven, DateDue, PetID)
    VALUES
    ('Heartworm', 'Patch prevention', '2026-02-02', '2026-03-02', @PatchID),
    ('Flea', 'Mittens prevention', '2026-02-02', '2026-03-02', @MittensID);

    INSERT INTO dbo.Surgery ([Name], [Description], [Date], PetID)
    VALUES
    ('Neuter', 'Routine', '2026-02-03', @PatchID),
    ('Spay', 'Routine', '2026-02-03', @MittensID);

    INSERT INTO dbo.VetVisit ([Name], [Description], [Date], PetID)
    VALUES
    ('Intake Exam', 'Routine intake', '2026-02-04', @PatchID),
    ('Intake Exam', 'Routine intake', '2026-02-04', @MittensID);

    CREATE TABLE #Expected
    (
        PetID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DOB DATE,
        DOBKnown BIT,
        Characterisitics NVARCHAR(MAX),
        [Weight] INT,
        IntakeDate DATE,
        PetNotes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PreviousHomeID INT NULL,
        CurrentHomeID INT NULL,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        CurrentHomeID_Joined INT NULL,
        CurrentHomeAddress NVARCHAR(MAX),
        CurrentHomeCity NVARCHAR(MAX),
        CurrentHomeState NVARCHAR(MAX),
        CurrentHomeZip NVARCHAR(MAX),
        CurrentHomePhoneNumber NVARCHAR(MAX),
        PreviousHomeID_Joined INT NULL,
        PreviousHomeAddress NVARCHAR(MAX),
        PreviousHomeCity NVARCHAR(MAX),
        PreviousHomeState NVARCHAR(MAX),
        PreviousHomeZip NVARCHAR(MAX),
        PreviousHomePhoneNumber NVARCHAR(MAX),
        FileID INT NULL,
        FileLocation NVARCHAR(MAX),
        VaccineType NVARCHAR(MAX),
        VaccineNotes NVARCHAR(MAX),
        VaccineDateGiven DATETIME,
        VaccineDateDue DATETIME,
        PreventionType NVARCHAR(MAX),
        PreventionNotes NVARCHAR(MAX),
        PreventionDateGiven DATETIME,
        PreventionDateDue DATETIME,
        SurgeryName NVARCHAR(MAX),
        SurgeryDescription NVARCHAR(MAX),
        SurgeryDate DATETIME,
        VetVisitName NVARCHAR(MAX),
        VetVisitDescription NVARCHAR(MAX),
        VetVisitDate DATETIME
    );

    INSERT INTO #Expected
    SELECT
        p.TUID,
        p.Animal,
        p.Breed,
        p.[Name],
        p.Sex,
        p.Origin,
        p.DateOfBirth,
        p.IsDateOfBirthKnown,
        p.Characteristics,
        p.[Weight],
        p.IntakeDate,
        p.Notes,
        p.Microchip,
        p.Adopted,
        p.PreviousHomeID,
        p.CurrentHomeID,
        p.PhotoLocation,
        p.LastModifiedOn,
        p.LastModifiedBy,
        p.CreatedOn,
        p.CreatedBy,
        2,
        '800 Dunham Rd',
        'Brighton',
        'MI',
        '48114',
        '989-748-7832',
        1,
        '123 Main St',
        'Midland',
        'MI',
        '48640',
        '989-555-1234',
        f.TUID,
        f.FileLocation,
        v.[Type],
        v.Notes,
        v.DateGiven,
        v.DateDue,
        pr.[Type],
        pr.Notes,
        pr.DateGiven,
        pr.DateDue,
        s.[Name],
        s.[Description],
        s.[Date],
        vt.[Name],
        vt.[Description],
        vt.[Date]
    FROM dbo.Pet p
    JOIN dbo.[File] f ON f.PetID = p.TUID
    JOIN dbo.Vaccine v ON v.PetID = p.TUID
    JOIN dbo.Prevention pr ON pr.PetID = p.TUID
    JOIN dbo.Surgery s ON s.PetID = p.TUID
    JOIN dbo.VetVisit vt ON vt.PetID = p.TUID
    WHERE p.TUID = @PatchID;

    CREATE TABLE #Actual
    (
        PetID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DOB DATE,
        DOBKnown BIT,
        Characterisitics NVARCHAR(MAX),
        [Weight] INT,
        IntakeDate DATE,
        PetNotes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PreviousHomeID INT NULL,
        CurrentHomeID INT NULL,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        CurrentHomeID_Joined INT NULL,
        CurrentHomeAddress NVARCHAR(MAX),
        CurrentHomeCity NVARCHAR(MAX),
        CurrentHomeState NVARCHAR(MAX),
        CurrentHomeZip NVARCHAR(MAX),
        CurrentHomePhoneNumber NVARCHAR(MAX),
        PreviousHomeID_Joined INT NULL,
        PreviousHomeAddress NVARCHAR(MAX),
        PreviousHomeCity NVARCHAR(MAX),
        PreviousHomeState NVARCHAR(MAX),
        PreviousHomeZip NVARCHAR(MAX),
        PreviousHomePhoneNumber NVARCHAR(MAX),
        FileID INT NULL,
        FileLocation NVARCHAR(MAX),
        VaccineType NVARCHAR(MAX),
        VaccineNotes NVARCHAR(MAX),
        VaccineDateGiven DATETIME,
        VaccineDateDue DATETIME,
        PreventionType NVARCHAR(MAX),
        PreventionNotes NVARCHAR(MAX),
        PreventionDateGiven DATETIME,
        PreventionDateDue DATETIME,
        SurgeryName NVARCHAR(MAX),
        SurgeryDescription NVARCHAR(MAX),
        SurgeryDate DATETIME,
        VetVisitName NVARCHAR(MAX),
        VetVisitDescription NVARCHAR(MAX),
        VetVisitDate DATETIME
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPetProfile @PetID = @PatchID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 18: spGetPetsAssociatedToAHome tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE PetTests.[test spGetPetsAssociatedToAHome returns pets for valid home]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    UPDATE dbo.Pet
    SET CurrentHomeID = 2
    WHERE TUID IN (2, 3);

    CREATE TABLE #Expected
    (
        TUID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DateOfBirth DATE,
        IsDateOfBirthKnown BIT,
        Characteristics NVARCHAR(MAX),
        Weight INT,
        IntakeDate DATE,
        Notes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PreviousHomeID INT NULL,
        CurrentHomeID INT NULL,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedBy INT,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        2,
        'Cat',
        'Siamese',
        'Taco',
        'Female',
        'Georgia St',
        '2026-01-01',
        0,
        'Shy, Good with Kids',
        5,
        '2026-01-29',
        'Very shy',
        '931000000157893',
        0,
        NULL,
        2,
        '/photos/taco.jpg',
        3,
        LastModifiedOn,
        CreatedOn,
        3
    FROM dbo.Pet
    WHERE TUID = 2;

    INSERT INTO #Expected
    SELECT
        3,
        'Dog',
        'Golden Retriever',
        'Scooby',
        'Male',
        'Shelter',
        '2020-07-18',
        1,
        'Friendly, Potty Trained, Dewormed',
        67,
        '2025-12-15',
        'Enjoys being outside',
        '901000000789456',
        0,
        NULL,
        2,
        '/photos/scooby.jpg',
        1,
        LastModifiedOn,
        CreatedOn,
        1
    FROM dbo.Pet
    WHERE TUID = 3;

    CREATE TABLE #Actual
    (
        TUID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DateOfBirth DATE,
        IsDateOfBirthKnown BIT,
        Characteristics NVARCHAR(MAX),
        Weight INT,
        IntakeDate DATE,
        Notes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PreviousHomeID INT NULL,
        CurrentHomeID INT NULL,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedBy INT,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPetsAssociatedToAHome @HomeTUID = 2;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE PetTests.[test spGetPetsAssociatedToAHome returns no rows when home has no pets]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    CREATE TABLE #Expected
    (
        TUID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DateOfBirth DATE,
        IsDateOfBirthKnown BIT,
        Characteristics NVARCHAR(MAX),
        Weight INT,
        IntakeDate DATE,
        Notes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PreviousHomeID INT NULL,
        CurrentHomeID INT NULL,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedBy INT,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DateOfBirth DATE,
        IsDateOfBirthKnown BIT,
        Characteristics NVARCHAR(MAX),
        Weight INT,
        IntakeDate DATE,
        Notes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PreviousHomeID INT NULL,
        CurrentHomeID INT NULL,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedBy INT,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPetsAssociatedToAHome @HomeTUID = 1;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE PetTests.[test spGetPetsAssociatedToAHome returns no rows for NULL home]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    DECLARE @HomeTUID INT = NULL;

    CREATE TABLE #Expected
    (
        TUID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DateOfBirth DATE,
        IsDateOfBirthKnown BIT,
        Characteristics NVARCHAR(MAX),
        Weight INT,
        IntakeDate DATE,
        Notes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PreviousHomeID INT NULL,
        CurrentHomeID INT NULL,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedBy INT,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        Animal NVARCHAR(MAX),
        Breed NVARCHAR(MAX),
        [Name] NVARCHAR(MAX),
        Sex NVARCHAR(MAX),
        Origin NVARCHAR(MAX),
        DateOfBirth DATE,
        IsDateOfBirthKnown BIT,
        Characteristics NVARCHAR(MAX),
        Weight INT,
        IntakeDate DATE,
        Notes NVARCHAR(MAX),
        Microchip NVARCHAR(MAX),
        Adopted BIT,
        PreviousHomeID INT NULL,
        CurrentHomeID INT NULL,
        PhotoLocation NVARCHAR(MAX),
        LastModifiedBy INT,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetPetsAssociatedToAHome @HomeTUID = @HomeTUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 19: spGetRecentFiles tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetRecentFiles returns all files when under 30]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC TestHelpers.InsertBaseFiles;
    EXEC TestHelpers.InsertNestedFiles;

    CREATE TABLE #Expected
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT *
    FROM dbo.[File];

    CREATE TABLE #Actual
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRecentFiles;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY LastModifiedOn DESC;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY LastModifiedOn DESC;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetRecentFiles returns only top 30 files]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC TestHelpers.InsertBaseFiles;
    EXEC TestHelpers.InsertNestedFiles;

    DECLARE @i INT = 1;

    WHILE @i <= 40
    BEGIN
        INSERT INTO dbo.[File]
        (
            FileLocation, FileName, IsReviewed, IsPolicyProcedure,
            PetID, FolderID,
            LastModifiedOn, LastModifiedBy,
            CreatedOn, CreatedBy
        )
        VALUES
        (
            '/test/file' + CAST(@i AS NVARCHAR(MAX)),
            'file' + CAST(@i AS NVARCHAR(MAX)),
            1, 0,
            NULL, 1,
            DATEADD(MINUTE, @i, GETDATE()),
            1,
            GETDATE(),
            1
        );

        SET @i += 1;
    END;

    CREATE TABLE #Actual
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRecentFiles;

    ------------------------------------------------------------------------------------------
    -- Assert count = 30
    ------------------------------------------------------------------------------------------
    DECLARE @Count INT = (SELECT COUNT(*) FROM #Actual);

    EXEC tSQLt.AssertEquals 30, @Count;
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetRecentFiles returns files ordered by LastModifiedOn desc]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC TestHelpers.InsertBaseFiles;
    EXEC TestHelpers.InsertNestedFiles;

    -- Force known ordering
    UPDATE dbo.[File] SET LastModifiedOn = '2026-01-01' WHERE TUID = 1;
    UPDATE dbo.[File] SET LastModifiedOn = '2026-02-01' WHERE TUID = 2;
    UPDATE dbo.[File] SET LastModifiedOn = '2026-03-01' WHERE TUID = 3;

    CREATE TABLE #Actual
    (
        TUID INT,
        FileLocation NVARCHAR(MAX),
        FileName NVARCHAR(MAX),
        IsReviewed BIT,
        IsPolicyProcedure BIT,
        PetID INT,
        FolderID INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRecentFiles;

    ------------------------------------------------------------------------------------------
    -- Expected = same rows sorted properly
    ------------------------------------------------------------------------------------------
    SELECT *
    INTO #Expected
    FROM #Actual
    ORDER BY LastModifiedOn DESC;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 20: spGetRecurringEventsInRange tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE EventTests.[test spGetRecurringEventsInRange throws error for invalid date range]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC TestHelpers.InsertTestEvents;

    EXEC tSQLt.ExpectException @ExpectedMessage = 'Invalid date range.';

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    EXEC dbo.spGetRecurringEventsInRange
        @StartDate = '2026-02-01',
        @EndDate   = '2026-01-01';
END;
GO

CREATE OR ALTER PROCEDURE EventTests.[test spGetRecurringEventsInRange returns occurrences for seeded recurring event]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC TestHelpers.InsertTestEvents;

    CREATE TABLE #Expected
    (
        BaseEventTUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        BaseEventDate DATE,
        OccurrenceDate DATETIME,
        StartTime TIME NULL,
        EndTime TIME NULL,
        Recurring BIT,
        DayPeriod INT,
        IntervalDays INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        1,
        'Adoption Fair',
        'Local pet adoption event',
        '2026-01-14',
        '2026-01-14',
        StartTime,
        EndTime,
        1,
        30,
        30,
        LastModifiedOn,
        1,
        CreatedOn,
        1
    FROM dbo.[Event]
    WHERE TUID = 1;

    INSERT INTO #Expected
    SELECT
        1,
        'Adoption Fair',
        'Local pet adoption event',
        '2026-01-14',
        '2026-02-13',
        StartTime,
        EndTime,
        1,
        30,
        30,
        LastModifiedOn,
        1,
        CreatedOn,
        1
    FROM dbo.[Event]
    WHERE TUID = 1;

    INSERT INTO #Expected
    SELECT
        1,
        'Adoption Fair',
        'Local pet adoption event',
        '2026-01-14',
        '2026-03-15',
        StartTime,
        EndTime,
        1,
        30,
        30,
        LastModifiedOn,
        1,
        CreatedOn,
        1
    FROM dbo.[Event]
    WHERE TUID = 1;

    CREATE TABLE #Actual
    (
        BaseEventTUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        BaseEventDate DATE,
        OccurrenceDate DATETIME,
        StartTime TIME NULL,
        EndTime TIME NULL,
        Recurring BIT,
        DayPeriod INT,
        IntervalDays INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRecurringEventsInRange
        @StartDate = '2026-01-01',
        @EndDate   = '2026-03-31';

    ------------------------------------------------------------------------------------------
    -- Keep only the seeded recurring event
    ------------------------------------------------------------------------------------------
    DELETE FROM #Actual
    WHERE BaseEventTUID <> 1;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY OccurrenceDate, StartTime;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY OccurrenceDate, StartTime;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE EventTests.[test spGetRecurringEventsInRange treats NULL DayPeriod as 1]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC TestHelpers.InsertTestEvents;

    INSERT INTO dbo.[Event]
    (
        [Name],
        [Description],
        [Date],
        StartTime,
        EndTime,
        Recurring,
        DayPeriod,
        LastModifiedOn,
        CreatedOn,
        LastModifiedBy,
        CreatedBy
    )
    VALUES
    (
        'Daily Walk',
        'Recurring event with null interval',
        '2026-01-10',
        '09:00:00',
        '10:00:00',
        1,
        NULL,
        GETDATE(),
        GETDATE(),
        1,
        1
    );

    DECLARE @EventID INT = SCOPE_IDENTITY();

    CREATE TABLE #Expected
    (
        BaseEventTUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        BaseEventDate DATE,
        OccurrenceDate DATETIME,
        StartTime TIME NULL,
        EndTime TIME NULL,
        Recurring BIT,
        DayPeriod INT NULL,
        IntervalDays INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT @EventID, 'Daily Walk', 'Recurring event with null interval', '2026-01-10', '2026-01-10',
           '09:00:00', '10:00:00', 1, NULL, 1, LastModifiedOn, 1, CreatedOn, 1
    FROM dbo.[Event] WHERE TUID = @EventID;

    INSERT INTO #Expected
    SELECT @EventID, 'Daily Walk', 'Recurring event with null interval', '2026-01-10', '2026-01-11',
           '09:00:00', '10:00:00', 1, NULL, 1, LastModifiedOn, 1, CreatedOn, 1
    FROM dbo.[Event] WHERE TUID = @EventID;

    INSERT INTO #Expected
    SELECT @EventID, 'Daily Walk', 'Recurring event with null interval', '2026-01-10', '2026-01-12',
           '09:00:00', '10:00:00', 1, NULL, 1, LastModifiedOn, 1, CreatedOn, 1
    FROM dbo.[Event] WHERE TUID = @EventID;

    CREATE TABLE #Actual
    (
        BaseEventTUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        BaseEventDate DATE,
        OccurrenceDate DATETIME,
        StartTime TIME NULL,
        EndTime TIME NULL,
        Recurring BIT,
        DayPeriod INT NULL,
        IntervalDays INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRecurringEventsInRange
        @StartDate = '2026-01-10',
        @EndDate   = '2026-01-12';

    DELETE FROM #Actual
    WHERE BaseEventTUID <> @EventID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY OccurrenceDate, StartTime;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY OccurrenceDate, StartTime;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE EventTests.[test spGetRecurringEventsInRange treats zero DayPeriod as 1]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC TestHelpers.InsertTestEvents;

    INSERT INTO dbo.[Event]
    (
        [Name],
        [Description],
        [Date],
        StartTime,
        EndTime,
        Recurring,
        DayPeriod,
        LastModifiedOn,
        CreatedOn,
        LastModifiedBy,
        CreatedBy
    )
    VALUES
    (
        'Zero Interval Event',
        'Recurring event with zero interval',
        '2026-01-20',
        '13:00:00',
        '14:00:00',
        1,
        0,
        GETDATE(),
        GETDATE(),
        1,
        1
    );

    DECLARE @EventID INT = SCOPE_IDENTITY();

    CREATE TABLE #Expected
    (
        BaseEventTUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        BaseEventDate DATE,
        OccurrenceDate DATETIME,
        StartTime TIME NULL,
        EndTime TIME NULL,
        Recurring BIT,
        DayPeriod INT,
        IntervalDays INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT @EventID, 'Zero Interval Event', 'Recurring event with zero interval', '2026-01-20', '2026-01-20',
           '13:00:00', '14:00:00', 1, 0, 1, LastModifiedOn, 1, CreatedOn, 1
    FROM dbo.[Event] WHERE TUID = @EventID;

    INSERT INTO #Expected
    SELECT @EventID, 'Zero Interval Event', 'Recurring event with zero interval', '2026-01-20', '2026-01-21',
           '13:00:00', '14:00:00', 1, 0, 1, LastModifiedOn, 1, CreatedOn, 1
    FROM dbo.[Event] WHERE TUID = @EventID;

    INSERT INTO #Expected
    SELECT @EventID, 'Zero Interval Event', 'Recurring event with zero interval', '2026-01-20', '2026-01-22',
           '13:00:00', '14:00:00', 1, 0, 1, LastModifiedOn, 1, CreatedOn, 1
    FROM dbo.[Event] WHERE TUID = @EventID;

    CREATE TABLE #Actual
    (
        BaseEventTUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        BaseEventDate DATE,
        OccurrenceDate DATETIME,
        StartTime TIME NULL,
        EndTime TIME NULL,
        Recurring BIT,
        DayPeriod INT,
        IntervalDays INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRecurringEventsInRange
        @StartDate = '2026-01-20',
        @EndDate   = '2026-01-22';

    DELETE FROM #Actual
    WHERE BaseEventTUID <> @EventID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY OccurrenceDate, StartTime;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY OccurrenceDate, StartTime;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE EventTests.[test spGetRecurringEventsInRange returns no rows when range has no occurrences]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC TestHelpers.InsertTestEvents;

    CREATE TABLE #Expected
    (
        BaseEventTUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        BaseEventDate DATE,
        OccurrenceDate DATETIME,
        StartTime TIME NULL,
        EndTime TIME NULL,
        Recurring BIT,
        DayPeriod INT,
        IntervalDays INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        BaseEventTUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        BaseEventDate DATE,
        OccurrenceDate DATETIME,
        StartTime TIME NULL,
        EndTime TIME NULL,
        Recurring BIT,
        DayPeriod INT,
        IntervalDays INT,
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRecurringEventsInRange
        @StartDate = '2025-01-01',
        @EndDate   = '2025-12-31';

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 21: spGetResidentsAssociatedToAHome tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE HomeTests.[test spGetResidentsAssociatedToAHome returns correct resident for home 1]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC TestHelpers.InsertTestPeople;

    DECLARE @HomeTUID INT = 1;

    CREATE TABLE #Expected
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    VALUES
    (
        2,
        'John',
        'Doe',
        'johndoe@example.com',
        '810-555-9876',
        1,
        1,
        'Very helpful, #1 guy',
        '2026-01-16',
        2,
        '2026-01-01',
        3
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetResidentsAssociatedToAHome @HomeTUID = @HomeTUID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE HomeTests.[test spGetResidentsAssociatedToAHome returns correct resident for home 2]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC TestHelpers.InsertTestPeople;

    DECLARE @HomeTUID INT = 2;

    CREATE TABLE #Expected
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        1,
        'Jane',
        'Doe',
        'janedoe@example.com',
        '989-555-9876',
        2,
        0,
        'Takes lots of cats',
        LastModifiedOn,
        1,
        CreatedOn,
        2
    FROM dbo.Person
    WHERE TUID = 1;

    CREATE TABLE #Actual
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetResidentsAssociatedToAHome @HomeTUID = @HomeTUID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE HomeTests.[test spGetResidentsAssociatedToAHome returns no rows for invalid home]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC TestHelpers.InsertTestHouses;

    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC TestHelpers.InsertTestPeople;

    DECLARE @HomeTUID INT = 999;

    CREATE TABLE #Expected
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FirstName NVARCHAR(MAX),
        LastName NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        PhoneNumber NVARCHAR(MAX),
        HouseID INT,
        IsVolunteer BIT,
        Notes NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetResidentsAssociatedToAHome @HomeTUID = @HomeTUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 22: spGetRevenue tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE FinanceTests.[test spGetRevenue returns correct revenue for January 2026]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Revenue', @identity = 1;
    EXEC TestHelpers.InsertTestRevenue;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Date] DATETIME,
        Category NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        Amount DECIMAL(18,2),
        PayMethod NVARCHAR(MAX),
        Person NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    INSERT INTO #Expected
    SELECT
        2,
        '2026-01-08',
        'Adopted Pet Fee',
        'Buddy',
        4.00,
        'Venmo',
        'Patrick Mahomes',
        LastModifiedOn,
        CreatedOn,
        1,
        'Gwen',
        1,
        'Gwen'
    FROM dbo.Revenue
    WHERE TUID = 2;

    CREATE TABLE #Actual
    (
        TUID INT,
        [Date] DATETIME,
        Category NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        Amount DECIMAL(18,2),
        PayMethod NVARCHAR(MAX),
        Person NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRevenue @Month = 1, @Year = 2026;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY [Date] DESC, TUID DESC;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY [Date] DESC, TUID DESC;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE FinanceTests.[test spGetRevenue returns no rows when no revenue matches]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Revenue', @identity = 1;
    EXEC TestHelpers.InsertTestRevenue;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Date] DATETIME,
        Category NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        Amount DECIMAL(18,2),
        PayMethod NVARCHAR(MAX),
        Person NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        [Date] DATETIME,
        Category NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        Amount DECIMAL(18,2),
        PayMethod NVARCHAR(MAX),
        Person NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRevenue @Month = 12, @Year = 2030;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE FinanceTests.[test spGetRevenue throws error for invalid month]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Revenue', @identity = 1;
    EXEC TestHelpers.InsertTestRevenue;

    EXEC tSQLt.ExpectException @ExpectedMessage = 'Month must be between 1 and 12';

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    EXEC dbo.spGetRevenue @Month = 13, @Year = 2026;
END;
GO

CREATE OR ALTER PROCEDURE FinanceTests.[test spGetRevenue uses current year when year is NULL]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Revenue', @identity = 1;
    EXEC TestHelpers.InsertTestRevenue;

    DECLARE @CurrentYear INT = YEAR(GETDATE());
    DECLARE @CurrentMonth INT = MONTH(GETDATE());

    INSERT INTO dbo.Revenue
    (
        [Date],
        Category,
        [Description],
        Amount,
        PayMethod,
        Person,
        LastModifiedOn,
        CreatedOn,
        LastModifiedBy,
        CreatedBy
    )
    VALUES
    (
        DATEFROMPARTS(@CurrentYear, @CurrentMonth, 15),
        'Donation',
        'Current Year Test Revenue',
        25.00,
        'Cash',
        'Test Person',
        GETDATE(),
        GETDATE(),
        1,
        2
    );

    CREATE TABLE #Expected
    (
        TUID INT,
        [Date] DATETIME,
        Category NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        Amount DECIMAL(18,2),
        PayMethod NVARCHAR(MAX),
        Person NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    INSERT INTO #Expected
    SELECT
        r.TUID,
        r.[Date],
        'Donation',
        'Current Year Test Revenue',
        25.00,
        'Cash',
        'Test Person',
        r.LastModifiedOn,
        r.CreatedOn,
        1,
        'Gwen',
        2,
        'Cindy'
    FROM dbo.Revenue r
    WHERE r.[Description] = 'Current Year Test Revenue';

    CREATE TABLE #Actual
    (
        TUID INT,
        [Date] DATETIME,
        Category NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        Amount DECIMAL(18,2),
        PayMethod NVARCHAR(MAX),
        Person NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        LastModifiedByName NVARCHAR(MAX),
        CreatedBy INT,
        CreatedByName NVARCHAR(MAX)
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRevenue @Month = @CurrentMonth, @Year = NULL;

    DELETE FROM #Actual
    WHERE [Description] <> 'Current Year Test Revenue';

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY [Date] DESC, TUID DESC;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY [Date] DESC, TUID DESC;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

/*************************************************************************
Section 23: spGetRole tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE RoleTests.[test spGetRole returns correct role for TUID 1]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Role', @identity = 1;
    EXEC TestHelpers.InsertTestRoles;

    DECLARE @TUID INT = 1;

    CREATE TABLE #Expected
    (
        TUID INT,
        RoleName NVARCHAR(MAX),
        RoleColor NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        PetManagement NVARCHAR(MAX),
        AdopterManagement NVARCHAR(MAX),
        FosterAndVolunteerManagement NVARCHAR(MAX),
        ApplicationsAndVolunteerManagement NVARCHAR(MAX),
        FinancialManagement NVARCHAR(MAX),
        DocumentationAndMeetings NVARCHAR(MAX)
    );

    INSERT INTO #Expected
    SELECT
        1,
        'Administrator',
        'Blue',
        LastModifiedOn,
        1,
        CreatedOn,
        1,
        'Edit',
        'Edit',
        'Edit',
        'Edit',
        'Edit',
        'Edit'
    FROM dbo.[Role]
    WHERE TUID = 1;

    CREATE TABLE #Actual
    (
        TUID INT,
        RoleName NVARCHAR(MAX),
        RoleColor NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        PetManagement NVARCHAR(MAX),
        AdopterManagement NVARCHAR(MAX),
        FosterAndVolunteerManagement NVARCHAR(MAX),
        ApplicationsAndVolunteerManagement NVARCHAR(MAX),
        FinancialManagement NVARCHAR(MAX),
        DocumentationAndMeetings NVARCHAR(MAX)
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRole @TUID = @TUID;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE RoleTests.[test spGetRole returns no rows for invalid TUID]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Role', @identity = 1;
    EXEC TestHelpers.InsertTestRoles;

    DECLARE @TUID INT = 999;

    CREATE TABLE #Expected
    (
        TUID INT,
        RoleName NVARCHAR(MAX),
        RoleColor NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        PetManagement NVARCHAR(MAX),
        AdopterManagement NVARCHAR(MAX),
        FosterAndVolunteerManagement NVARCHAR(MAX),
        ApplicationsAndVolunteerManagement NVARCHAR(MAX),
        FinancialManagement NVARCHAR(MAX),
        DocumentationAndMeetings NVARCHAR(MAX)
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        RoleName NVARCHAR(MAX),
        RoleColor NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        PetManagement NVARCHAR(MAX),
        AdopterManagement NVARCHAR(MAX),
        FosterAndVolunteerManagement NVARCHAR(MAX),
        ApplicationsAndVolunteerManagement NVARCHAR(MAX),
        FinancialManagement NVARCHAR(MAX),
        DocumentationAndMeetings NVARCHAR(MAX)
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRole @TUID = @TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE RoleTests.[test spGetRole returns no rows for NULL TUID]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Role', @identity = 1;
    EXEC TestHelpers.InsertTestRoles;

    DECLARE @TUID INT = NULL;

    CREATE TABLE #Expected
    (
        TUID INT,
        RoleName NVARCHAR(MAX),
        RoleColor NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        PetManagement NVARCHAR(MAX),
        AdopterManagement NVARCHAR(MAX),
        FosterAndVolunteerManagement NVARCHAR(MAX),
        ApplicationsAndVolunteerManagement NVARCHAR(MAX),
        FinancialManagement NVARCHAR(MAX),
        DocumentationAndMeetings NVARCHAR(MAX)
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        RoleName NVARCHAR(MAX),
        RoleColor NVARCHAR(MAX),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT,
        PetManagement NVARCHAR(MAX),
        AdopterManagement NVARCHAR(MAX),
        FosterAndVolunteerManagement NVARCHAR(MAX),
        ApplicationsAndVolunteerManagement NVARCHAR(MAX),
        FinancialManagement NVARCHAR(MAX),
        DocumentationAndMeetings NVARCHAR(MAX)
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRole @TUID = @TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 24: spGetRootFolders tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetRootFolders returns all root folders]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    CREATE TABLE #Expected
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        1,
        '/Medical Records',
        LastModifiedOn,
        1,
        CreatedOn,
        3
    FROM dbo.Folder
    WHERE TUID = 1;

    INSERT INTO #Expected
    SELECT
        2,
        '/Adoption Documents',
        LastModifiedOn,
        2,
        CreatedOn,
        2
    FROM dbo.Folder
    WHERE TUID = 2;

    INSERT INTO #Expected
    SELECT
        3,
        '/Foster Agreements',
        LastModifiedOn,
        1,
        CreatedOn,
        1
    FROM dbo.Folder
    WHERE TUID = 3;

    CREATE TABLE #Actual
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRootFolders;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetRootFolders does not return nested folders]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC TestHelpers.InsertBaseFolders;
    EXEC TestHelpers.InsertNestedFolders;

    CREATE TABLE #Expected
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    -- Only root folders
    INSERT INTO #Expected
    SELECT *
    FROM dbo.Folder
    WHERE TUID IN (1,2,3);

    CREATE TABLE #Actual
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRootFolders;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY TUID;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY TUID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE FolderAndFileTests.[test spGetRootFolders returns no rows when no root folders exist]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;

    -- Only nested folders (no roots)
    INSERT INTO dbo.Folder
    (
        FolderName,
        LastModifiedOn,
        LastModifiedBy,
        CreatedOn,
        CreatedBy
    )
    VALUES
    ('/Medical Records/Vaccinations', GETDATE(), 1, GETDATE(), 1),
    ('/Medical Records/Surgery', GETDATE(), 1, GETDATE(), 1),
    ('/Adoption Documents/Pending', GETDATE(), 1, GETDATE(), 1);

    CREATE TABLE #Expected
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        FolderName NVARCHAR(500),
        LastModifiedOn DATETIME,
        LastModifiedBy INT,
        CreatedOn DATETIME,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetRootFolders;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 25: spGetSearchedFilteredUser tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE UserTests.[test spGetSearchedFilteredUser returns all users when no filters are applied]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.UpdateTestUserRoles;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    INSERT INTO #Expected
    VALUES
        (1, 'Gwen',  'admin',     'password123', 'admin@pets.org',     'Runs Midland Pit Stop',     1),
        (3, 'Mark',  'secretary', '67',          'secretary@pets.org', 'Handles general inquiries', NULL),
        (2, 'Cindy', 'treasurer', 'Ilovedogs',   'treasurer@pets.org', 'Handles financials',        NULL);

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetSearchedFilteredUser
        @SearchString = '',
        @RoleID = NULL;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY UserName;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY UserName;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE UserTests.[test spGetSearchedFilteredUser searches by username]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.UpdateTestUserRoles;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    INSERT INTO #Expected
    VALUES
        (1, 'Gwen', 'admin', 'password123', 'admin@pets.org', 'Runs Midland Pit Stop', 1);

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetSearchedFilteredUser
        @SearchString = 'admin',
        @RoleID = NULL;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY UserName;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY UserName;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE UserTests.[test spGetSearchedFilteredUser searches by name]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.UpdateTestUserRoles;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    INSERT INTO #Expected
    VALUES
        (2, 'Cindy', 'treasurer', 'Ilovedogs', 'treasurer@pets.org', 'Handles financials', NULL);

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetSearchedFilteredUser
        @SearchString = 'Cindy',
        @RoleID = NULL;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY UserName;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY UserName;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE UserTests.[test spGetSearchedFilteredUser filters by RoleID]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.UpdateTestUserRoles;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    INSERT INTO #Expected
    VALUES
        (1, 'Gwen', 'admin', 'password123', 'admin@pets.org', 'Runs Midland Pit Stop', 1);

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetSearchedFilteredUser
        @SearchString = '',
        @RoleID = 1;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY UserName;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY UserName;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE UserTests.[test spGetSearchedFilteredUser combines search and role filter]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.UpdateTestUserRoles;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    INSERT INTO #Expected
    VALUES
        (1, 'Gwen', 'admin', 'password123', 'admin@pets.org', 'Runs Midland Pit Stop', 1);

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetSearchedFilteredUser
        @SearchString = 'Gwen',
        @RoleID = 1;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY UserName;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY UserName;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE UserTests.[test spGetSearchedFilteredUser returns no rows when search does not match]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.UpdateTestUserRoles;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetSearchedFilteredUser
        @SearchString = 'zzz_not_found',
        @RoleID = NULL;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 26: spGetSearchedUser tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/
CREATE OR ALTER PROCEDURE UserTests.[test spGetSearchedUser returns all users when search is empty]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.UpdateTestUserRoles;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    INSERT INTO #Expected
    VALUES
        (1, 'Gwen',  'admin',     'password123', 'admin@pets.org',     'Runs Midland Pit Stop',     1),
        (3, 'Mark',  'secretary', '67',          'secretary@pets.org', 'Handles general inquiries', NULL),
        (2, 'Cindy', 'treasurer', 'Ilovedogs',   'treasurer@pets.org', 'Handles financials',        NULL);

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetSearchedUser @SearchString = '';

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY UserName;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY UserName;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE UserTests.[test spGetSearchedUser returns all users when search is NULL]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.UpdateTestUserRoles;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    INSERT INTO #Expected
    SELECT *
    FROM dbo.[User];

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetSearchedUser @SearchString = NULL;

    ------------------------------------------------------------------------------------------
    -- Order
    ------------------------------------------------------------------------------------------
    SELECT * INTO #ExpectedOrdered FROM #Expected ORDER BY UserName;
    SELECT * INTO #ActualOrdered FROM #Actual ORDER BY UserName;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#ExpectedOrdered', '#ActualOrdered';
END;
GO

CREATE OR ALTER PROCEDURE UserTests.[test spGetSearchedUser searches by username]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.UpdateTestUserRoles;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    INSERT INTO #Expected
    VALUES
        (1, 'Gwen', 'admin', 'password123', 'admin@pets.org', 'Runs Midland Pit Stop', 1);

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetSearchedUser @SearchString = 'admin';

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE UserTests.[test spGetSearchedUser searches by name]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.UpdateTestUserRoles;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    INSERT INTO #Expected
    VALUES
        (2, 'Cindy', 'treasurer', 'Ilovedogs', 'treasurer@pets.org', 'Handles financials', NULL);

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetSearchedUser @SearchString = 'Cindy';

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE UserTests.[test spGetSearchedUser returns no rows when no match]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.UpdateTestUserRoles;

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        UserName NVARCHAR(MAX),
        [Password] NVARCHAR(MAX),
        Email NVARCHAR(MAX),
        Notes NVARCHAR(MAX),
        RoleID INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetSearchedUser @SearchString = 'notfound';

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/*************************************************************************
Section 27: spGetUpcomingEvent tests
Author: Madison Koscielski
Purpose: Test that the stored procedure returns correct 
        information and handles invalid input
*************************************************************************/

CREATE OR ALTER PROCEDURE EventTests.[test spGetUpcomingEvent returns events for today]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;

    DECLARE @Today DATE = CAST(GETDATE() AS DATE);

    INSERT INTO dbo.Event
    (
        [Name],
        [Description],
        [Date],
        Recurring,
        DayPeriod,
        LastModifiedOn,
        CreatedOn,
        LastModifiedBy,
        CreatedBy
    )
    VALUES
    (
        'Today Event',
        'Test event happening today',
        @Today,
        0,
        NULL,
        GETDATE(),
        GETDATE(),
        1,
        1
    );

    DECLARE @EventID INT = SCOPE_IDENTITY();

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATE,
        Recurring BIT,
        DayPeriod INT NULL,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        CreatedBy INT
    );

    INSERT INTO #Expected
    SELECT
        TUID,
        'Today Event',
        'Test event happening today',
        @Today,
        0,
        NULL,
        LastModifiedOn,
        CreatedOn,
        1,
        1
    FROM dbo.Event
    WHERE TUID = @EventID;

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATE,
        Recurring BIT,
        DayPeriod INT NULL,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetUpcomingEvent;

    ------------------------------------------------------------------------------------------
    -- Filter only our inserted event
    ------------------------------------------------------------------------------------------
    DELETE FROM #Actual
    WHERE TUID <> @EventID;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE EventTests.[test spGetUpcomingEvent does not return events from other dates]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;

    INSERT INTO dbo.Event
    (
        [Name],
        [Description],
        [Date],
        Recurring,
        DayPeriod,
        LastModifiedOn,
        CreatedOn,
        LastModifiedBy,
        CreatedBy
    )
    VALUES
    (
        'Future Event',
        'Should not be returned',
        DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
        0,
        NULL,
        GETDATE(),
        GETDATE(),
        1,
        1
    );

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATE,
        Recurring BIT,
        DayPeriod INT NULL,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATE,
        Recurring BIT,
        DayPeriod INT NULL,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetUpcomingEvent;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

CREATE OR ALTER PROCEDURE EventTests.[test spGetUpcomingEvent returns no rows when no events today]
AS
BEGIN
    ------------------------------------------------------------------------------------------
    -- Arrange
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;

    INSERT INTO dbo.Event
    (
        [Name],
        [Description],
        [Date],
        Recurring,
        DayPeriod,
        LastModifiedOn,
        CreatedOn,
        LastModifiedBy,
        CreatedBy
    )
    VALUES
    (
        'Old Event',
        'Not today',
        '2020-01-01',
        0,
        NULL,
        GETDATE(),
        GETDATE(),
        1,
        1
    );

    CREATE TABLE #Expected
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATE,
        Recurring BIT,
        DayPeriod INT NULL,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        CreatedBy INT
    );

    CREATE TABLE #Actual
    (
        TUID INT,
        [Name] NVARCHAR(MAX),
        [Description] NVARCHAR(MAX),
        [Date] DATE,
        Recurring BIT,
        DayPeriod INT NULL,
        LastModifiedOn DATETIME,
        CreatedOn DATETIME,
        LastModifiedBy INT,
        CreatedBy INT
    );

    ------------------------------------------------------------------------------------------
    -- Act
    ------------------------------------------------------------------------------------------
    INSERT INTO #Actual
    EXEC dbo.spGetUpcomingEvent;

    ------------------------------------------------------------------------------------------
    -- Assert
    ------------------------------------------------------------------------------------------
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO


