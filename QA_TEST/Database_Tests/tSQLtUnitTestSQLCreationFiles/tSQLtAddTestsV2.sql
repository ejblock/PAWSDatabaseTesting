/**********************************************************************************************
 Filename: test_spAddToHome.sql
 Part of Project: MidlandPitStopDatabase Unit Tests

 File Purpose:
 This file contains all unit tests for the stored procedures that add pets and people
 to homes in the MidlandPitStopDatabase.  It ensures that spAddPetToHome and 
 spAddResidentToHome function correctly and update tables as expected.

 Author: Madison Koscielski

 Class Purpose:
 This file organizes tests into tSQLt schemas and executes each test procedure.  
 Each test validates that the target stored procedure correctly updates relevant tables.
**********************************************************************************************/

-- Drop old test procedures.
-- This ensures any previously existing test procedures matching 'test spAdd%' 
-- are removed so that we can recreate fresh test versions.
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql += 
    'IF OBJECT_ID(''' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ''', ''P'') IS NOT NULL
        DROP PROCEDURE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.procedures
WHERE name LIKE 'test spAdd%';
EXEC sp_executesql @sql;
GO


-- Create test schemas if they do not exist.
-- Each schema corresponds to a tSQLt test class for organizing unit tests.
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

/***********************************************************************
Section 1: test spAddResidentToHome Stored Procedure
***********************************************************************/
CREATE PROCEDURE PersonTests.[test spAddResidentToHome assigns resident to valid house]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'House',  @identity = 1;

    EXEC TestHelpers.InsertTestHouses;
    EXEC TestHelpers.InsertTestPeople;

    DECLARE @PersonTUID INT = 1;
    DECLARE @HomeTUID   INT = 3;

    -- Act
    EXEC dbo.spAddResidentToHome
        @PersonTUID = @PersonTUID,
        @HomeTUID   = @HomeTUID;

    -- Assert
    DECLARE @ActualHouseID INT;

    SELECT @ActualHouseID = HouseID
    FROM dbo.Person
    WHERE TUID = @PersonTUID;

    EXEC tSQLt.AssertEquals
        @Expected = 3,
        @Actual   = @ActualHouseID;
END;
GO

CREATE PROCEDURE PersonTests.[test spAddResidentToHome sets HouseID to null when HomeTUID is minus one]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'House',  @identity = 1;

    EXEC TestHelpers.InsertTestHouses;
    EXEC TestHelpers.InsertTestPeople;

    DECLARE @PersonTUID INT = 2;

    -- Act
    EXEC dbo.spAddResidentToHome
        @PersonTUID = @PersonTUID,
        @HomeTUID   = -1;

    -- Assert
    IF EXISTS
    (
        SELECT 1
        FROM dbo.Person
        WHERE TUID = @PersonTUID
          AND HouseID IS NOT NULL
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected HouseID to be NULL when @HomeTUID = -1.';
    END
END;
GO

CREATE PROCEDURE PersonTests.[test spAddResidentToHome throws error for invalid person]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'House',  @identity = 1;

    EXEC TestHelpers.InsertTestHouses;
    EXEC TestHelpers.InsertTestPeople;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'The specified person does not exist.';

    -- Act
    EXEC dbo.spAddResidentToHome
        @PersonTUID = 999,
        @HomeTUID   = 1;
END;
GO

CREATE PROCEDURE PersonTests.[test spAddResidentToHome throws error for invalid house]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'House',  @identity = 1;

    EXEC TestHelpers.InsertTestHouses;
    EXEC TestHelpers.InsertTestPeople;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'The specified house does not exist.';

    -- Act
    EXEC dbo.spAddResidentToHome
        @PersonTUID = 1,
        @HomeTUID   = 999;
END;
GO

CREATE PROCEDURE PersonTests.[test spAddResidentToHome invalid person takes precedence over minus one]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'House',  @identity = 1;

    EXEC TestHelpers.InsertTestHouses;
    EXEC TestHelpers.InsertTestPeople;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'The specified person does not exist.';

    -- Act
    EXEC dbo.spAddResidentToHome
        @PersonTUID = 999,
        @HomeTUID   = -1;
END;
GO

/***********************************************************************
Section 2: test spAddResidentToHome Stored Procedure
***********************************************************************/
CREATE PROCEDURE PetTests.[test spAddPetToHome assigns pet to valid house]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Pet',   @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;

    EXEC TestHelpers.InsertTestHouses;
    EXEC TestHelpers.InsertTestPets;

    DECLARE @PetTUID  INT = 2; -- Taco starts with CurrentHomeID = NULL
    DECLARE @HomeTUID INT = 3; -- valid house

    -- Act
    EXEC dbo.spAddPetToHome
        @PetTUID  = @PetTUID,
        @HomeTUID = @HomeTUID;

    -- Assert
    DECLARE @ActualHomeID INT;

    SELECT @ActualHomeID = CurrentHomeID
    FROM dbo.Pet
    WHERE TUID = @PetTUID;

    EXEC tSQLt.AssertEquals
        @Expected = 3,
        @Actual   = @ActualHomeID;
END;
GO

CREATE PROCEDURE PetTests.[test spAddPetToHome sets CurrentHomeID to null when HomeTUID is minus one]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Pet',   @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;

    EXEC TestHelpers.InsertTestHouses;
    EXEC TestHelpers.InsertTestPets;

    DECLARE @PetTUID INT = 1; -- Buddy starts with CurrentHomeID = NULL in the helper data
    UPDATE dbo.Pet
    SET CurrentHomeID = 2
    WHERE TUID = @PetTUID;

    -- Act
    EXEC dbo.spAddPetToHome
        @PetTUID  = @PetTUID,
        @HomeTUID = -1;

    -- Assert
    IF EXISTS
    (
        SELECT 1
        FROM dbo.Pet
        WHERE TUID = @PetTUID
          AND CurrentHomeID IS NOT NULL
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected CurrentHomeID to be NULL when @HomeTUID = -1.';
    END
END;
GO

CREATE PROCEDURE PetTests.[test spAddPetToHome throws error for invalid pet]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Pet',   @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;

    EXEC TestHelpers.InsertTestHouses;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'The specified pet does not exist.';

    -- Act
    EXEC dbo.spAddPetToHome
        @PetTUID  = 999,
        @HomeTUID = 1;
END;
GO

CREATE PROCEDURE PetTests.[test spAddPetToHome throws error for invalid house]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Pet',   @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;

    EXEC TestHelpers.InsertTestHouses;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'The specified house does not exist.';

    -- Act
    EXEC dbo.spAddPetToHome
        @PetTUID  = 1,
        @HomeTUID = 999;
END;
GO

CREATE PROCEDURE PetTests.[test spAddPetToHome invalid pet takes precedence over minus one]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Pet',   @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;

    EXEC TestHelpers.InsertTestHouses;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'The specified pet does not exist.';

    -- Act
    EXEC dbo.spAddPetToHome
        @PetTUID  = 999,
        @HomeTUID = -1;
END;
GO