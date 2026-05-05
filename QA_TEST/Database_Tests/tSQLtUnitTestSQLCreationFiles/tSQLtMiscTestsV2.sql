USE MidlandPitStopDatabase;
GO

-- MODIFICATION HISTORY
-- Alyssa Lilly 02/28/2026
-- Original misc stored procedure unit tests.

-- Madison Koscielski 03/22/2026
-- Standardized file header to match team format.
-- Removed file-level fake tables and shared seed data.
-- Replaced TestHelpers.FakeUser usage with TestHelpers.InsertTestData.
-- Ensured consistent TestHelpers usage across all tests.
-- Updated tests to be fully isolated and deterministic.
-- Converted spPetList test to assertion-based validation.
-- Added new Misc Tests for updated Schema 

-- Create schema
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'MiscTests')
    EXEC tSQLt.NewTestClass 'MiscTests';
GO

-- drop old test in MiscTests schema
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += 
    'IF OBJECT_ID(''' 
    + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) 
    + ''', ''P'') IS NOT NULL
        DROP PROCEDURE ' 
    + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) 
    + ';' + CHAR(13)
FROM sys.procedures
WHERE SCHEMA_NAME(schema_id) = 'MiscTests';

EXEC sp_executesql @sql;
GO


/****** Object: Test StoredProcedure MiscTests.[test spPetList returns all pets] ******/
/****** Created by Alyssa Lilly ******/
/****** Modified by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE MiscTests.[test spPetList returns all pets]
AS
BEGIN
    -- Arrange: fake only required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.Pet';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@gmail.com', NULL, NULL);

    DECLARE @UserID INT = 1;

    -- Insert only required pet rows
    INSERT INTO dbo.Pet
        (TUID, Animal, [Name], Sex, DateOfBirth, IsDateOfBirthKnown, [Weight],
         IntakeDate, Adopted, LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (2, 'Dog', 'Buddy', 'Male', '2020-01-01', 1, 30,
         '2020-02-01', 0, GETDATE(), GETDATE(), @UserID, @UserID),
        (3, 'Cat', 'Whiskers', 'Female', '2019-05-15', 1, 10,
         '2019-06-01', 0, GETDATE(), GETDATE(), @UserID, @UserID);

    -- Act
    DECLARE @Count INT = (SELECT COUNT(*) FROM dbo.Pet);

    -- Assert
    EXEC tSQLt.AssertEquals 2, @Count;
END;
GO

/*******************************************
 TEST: spUserLogin
 Created By: Alyssa Lilly 02/28/2026
 Modified by: Madison Koscielski 3/22/2026
*******************************************/
/****** Object: Test StoredProcedure MiscTests.[test spUserLogin authenticates valid user] ******/
/****** Modified by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE MiscTests.[test spUserLogin authenticates valid user]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC TestHelpers.InsertTestUsers;

    DECLARE @Result TABLE
    (
        TUID INT,
        [Name] VARCHAR(100),
        UserName VARCHAR(100),
        [Password] VARCHAR(255),
        Email VARCHAR(100),
        Notes VARCHAR(1000),
        RoleID INT
    );

    -- Act
    INSERT INTO @Result
    EXEC dbo.spUserLogin
        @UserName = 'admin',
        @Password = 'password123';

    -- Assert
    DECLARE @RowCount INT = (SELECT COUNT(*) FROM @Result);
    EXEC tSQLt.AssertEquals 1, @RowCount;
END;
GO

CREATE PROCEDURE MiscTests.[test spUserLogin rejects invalid password]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC TestHelpers.InsertTestUsers;

    DECLARE @Result INT;

    -- Act
    EXEC @Result = spUserLogin 
        @UserName = 'admin', 
        @Password = 'wrongpassword';

    -- Assert
    EXEC tSQLt.AssertEquals 0, @Result;
END;
GO


CREATE PROCEDURE MiscTests.[test spUserLogin rejects invalid username]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC TestHelpers.InsertTestUsers;

    DECLARE @Result INT;

    -- Act
    EXEC @Result = spUserLogin 
        @UserName = 'wronguser', 
        @Password = 'password123';

    -- Assert
    EXEC tSQLt.AssertEquals 0, @Result;
END;
GO


CREATE PROCEDURE MiscTests.[test spUserLogin rejects invalid credentials]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC TestHelpers.InsertTestUsers;

    DECLARE @Result INT;

    -- Act
    EXEC @Result = spUserLogin 
        @UserName = 'wronguser', 
        @Password = 'wrongpassword';

    -- Assert
    EXEC tSQLt.AssertEquals 0, @Result;
END;
GO

/****** Object: Test StoredProcedure MiscTests.[test spFindPersonTUID returns correct TUID] ******/
/****** Created by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE MiscTests.[test spFindPersonTUID returns correct TUID]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.House';
    EXEC tSQLt.FakeTable 'dbo.Person';

    -- Insert required user first
    EXEC TestHelpers.InsertTestUsers;

    DECLARE @UserID INT =
        (SELECT TOP 1 TUID
         FROM dbo.[User]
         WHERE UserName = 'testuser');

    -- Insert required house
    INSERT INTO dbo.House
        (TUID, [Address], City, [State], ZIP, PhoneNumber,
         LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (1, '123 Main St', 'Midland', 'MI', '48640', '9895551111',
         GETDATE(), GETDATE(), @UserID, @UserID);

    -- Insert person to find
    INSERT INTO dbo.Person
        (TUID, FirstName, LastName, Email, PhoneNumber, HouseID, IsVolunteer, Notes,
         LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (2, 'John', 'Doe', 'john@test.com', '9895552222', 1, 0, NULL,
         GETDATE(), GETDATE(), @UserID, @UserID);

    -- Expected result
    CREATE TABLE #Expected
    (
        TUID INT
    );

    INSERT INTO #Expected (TUID)
    VALUES (2);

    -- Actual result
    CREATE TABLE #Actual
    (
        TUID INT
    );

    INSERT INTO #Actual (TUID)
    EXEC dbo.spFindPersonTUID
        @Name = 'John Doe',
        @Phone = '9895552222';

    -- Assert
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

/****** Object: Test StoredProcedure MiscTests.[test spFindPersonTUID fails when phone formatting differs] ******/
/****** Created by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE MiscTests.[test spFindPersonTUID fails when phone formatting differs]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.House';
    EXEC tSQLt.FakeTable 'dbo.Person';

    -- Insert valid user data using TestHelpers
    EXEC TestHelpers.InsertTestUsers;

    DECLARE @UserID INT =
        (SELECT TOP 1 TUID
         FROM dbo.[User]
         WHERE UserName = 'testuser');

    -- Insert required house
    INSERT INTO dbo.House
        (TUID, [Address], City, [State], ZIP, PhoneNumber,
         LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (1, '123 Main St', 'Midland', 'MI', '48640', '9895551111',
         GETDATE(), GETDATE(), @UserID, @UserID);

    -- Insert person with unformatted stored phone number
    INSERT INTO dbo.Person
        (TUID, FirstName, LastName, Email, PhoneNumber, HouseID, IsVolunteer, Notes,
         LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (2, 'John', 'Doe', 'john@test.com', '9895552222', 1, 0, NULL,
         GETDATE(), GETDATE(), @UserID, @UserID);

    -- Expected: if the procedure used @CleanPhone correctly, it should find TUID 2
    CREATE TABLE #Expected
    (
        TUID INT
    );

    INSERT INTO #Expected (TUID)
    VALUES (2);

    -- Actual
    CREATE TABLE #Actual
    (
        TUID INT
    );

    INSERT INTO #Actual (TUID)
    EXEC dbo.spFindPersonTUID
        @Name = 'John Doe',
        @Phone = '(989) 555-2222';

    -- This assertion should FAIL with the current procedure,
    -- which exposes the bug.
    EXEC tSQLt.AssertEqualsTable '#Expected', '#Actual';
END;
GO

