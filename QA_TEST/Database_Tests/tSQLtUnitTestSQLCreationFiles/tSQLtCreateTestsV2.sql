USE [MidlandPitStopDatabase]
GO
/**********************************************************************************************

 Filename: test_spCreateEntities.sql
 Part of Project: MidlandPitStopDatabase Unit Tests

 File Purpose:
 This file contains all unit tests for stored procedures that create entities
 in the MidlandPitStopDatabase.  It ensures that spCreateAdopterHome, spCreateFosterHome,
 spCreatePerson, spCreatePet, spCreatePrevention, spCreateRole, spCreateSurgery,
 spCreateUser, spCreateVaccine, and spCreateVetVisit function correctly and
 populate tables as expected.

 Author: Madison Koscielski

 Class Purpose:
 This file organizes tests into tSQLt schemas and executes each test procedure.  
 Each test validates that the target stored procedure correctly inserts or updates 
 relevant tables with expected values.
**********************************************************************************************/

-- Drop old test procedures
-- This ensures any previously existing test procedures matching 'test spCreate%' 
-- are removed so that we can recreate fresh test versions.
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql += 
    'IF OBJECT_ID(''' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ''', ''P'') IS NOT NULL
        DROP PROCEDURE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.procedures
WHERE name LIKE 'test spCreate%';
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

/**********************************************************************************************
Section 1: test spCreateEvent Stored Proceduer
**********************************************************************************************/
CREATE PROCEDURE EventTests.[test spCreateEvent inserts event with valid inputs]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',  @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC dbo.spCreateEvent
         @Name = 'Volunteer Orientation',
         @Description = 'Intro session for new volunteers',
         @Date = '2026-04-01',
         @StartTime = '10:00:00',
         @EndTime = '12:00:00',
         @Recurring = 0,
         @DayPeriod = 1,
         @LastModifiedOn = '2026-03-01',
         @LastModifiedBy = 2,
         @CreatedOn = '2026-03-01',
         @CreatedBy = 2;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[Event]
        WHERE [Name] = 'Volunteer Orientation'
          AND [Description] = 'Intro session for new volunteers'
          AND [Date] = '2026-04-01'
          AND StartTime = '10:00:00'
          AND EndTime = '12:00:00'
          AND Recurring = 0
          AND DayPeriod = 1
          AND LastModifiedOn = '2026-03-01'
          AND LastModifiedBy = 2
          AND CreatedOn = '2026-03-01'
          AND CreatedBy = 2
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected event row was not inserted correctly.';
    END
END;
GO

CREATE PROCEDURE EventTests.[test spCreateEvent applies default dates]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',  @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    DECLARE @Today DATE = CONVERT(date, GETDATE());

    EXEC dbo.spCreateEvent
         @Name = 'Default Date Event',
         @Description = 'Default date values test',
         @Date = '2026-06-01',
         @StartTime = '09:00:00',
         @EndTime = '10:00:00',
         @Recurring = 0,
         @DayPeriod = NULL,
         @LastModifiedOn = NULL,
         @LastModifiedBy = 1,
         @CreatedOn = NULL,
         @CreatedBy = 2;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[Event]
        WHERE [Name] = 'Default Date Event'
          AND LastModifiedOn = @Today
          AND LastModifiedBy = 1
          AND CreatedOn = @Today
          AND CreatedBy = 2
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected default date values were not applied.';
    END
END;
GO

CREATE PROCEDURE EventTests.[test spCreateEvent preserves provided audit values]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',  @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC dbo.spCreateEvent
         @Name = 'Provided Audit Event',
         @Description = 'Provided audit values test',
         @Date = '2026-06-15',
         @StartTime = '09:00:00',
         @EndTime = '10:00:00',
         @Recurring = 0,
         @DayPeriod = 2,
         @LastModifiedOn = '2026-02-20',
         @LastModifiedBy = 3,
         @CreatedOn = '2026-02-10',
         @CreatedBy = 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[Event]
        WHERE [Name] = 'Provided Audit Event'
          AND LastModifiedOn = '2026-02-20'
          AND LastModifiedBy = 3
          AND CreatedOn = '2026-02-10'
          AND CreatedBy = 1
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected provided audit values to be preserved.';
    END
END;
GO

CREATE PROCEDURE EventTests.[test spCreateEvent throws error when both times are null]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',  @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Invalid time range. Provide both StartTime and EndTime, and EndTime must be after StartTime.';

    EXEC dbo.spCreateEvent
         @Name = 'Bad Event Null Times',
         @Description = 'Both times null',
         @Date = '2026-07-10',
         @StartTime = NULL,
         @EndTime = NULL,
         @Recurring = 0,
         @DayPeriod = NULL,
         @LastModifiedBy = 1,
         @CreatedBy = 1;
END;
GO

CREATE PROCEDURE EventTests.[test spCreateEvent throws error when only start time is provided]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',  @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Invalid time range. Provide both StartTime and EndTime, and EndTime must be after StartTime.';

    EXEC dbo.spCreateEvent
         @Name = 'Bad Event Missing End',
         @Description = 'Missing end time',
         @Date = '2026-07-01',
         @StartTime = '10:00:00',
         @EndTime = NULL,
         @Recurring = 0,
         @DayPeriod = NULL,
         @LastModifiedBy = 1,
         @CreatedBy = 1;
END;
GO

CREATE PROCEDURE EventTests.[test spCreateEvent throws error when only end time is provided]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',  @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Invalid time range. Provide both StartTime and EndTime, and EndTime must be after StartTime.';

    EXEC dbo.spCreateEvent
         @Name = 'Bad Event Missing Start',
         @Description = 'Missing start time',
         @Date = '2026-07-02',
         @StartTime = NULL,
         @EndTime = '11:00:00',
         @Recurring = 0,
         @DayPeriod = NULL,
         @LastModifiedBy = 1,
         @CreatedBy = 1;
END;
GO

CREATE PROCEDURE EventTests.[test spCreateEvent throws error when start time is later than end time]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',  @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Invalid time range. Provide both StartTime and EndTime, and EndTime must be after StartTime.';

    EXEC dbo.spCreateEvent
         @Name = 'Bad Event Reversed Times',
         @Description = 'Start time later than end time',
         @Date = '2026-07-03',
         @StartTime = '12:00:00',
         @EndTime = '11:00:00',
         @Recurring = 0,
         @DayPeriod = NULL,
         @LastModifiedBy = 1,
         @CreatedBy = 1;
END;
GO

CREATE PROCEDURE EventTests.[test spCreateEvent throws error when start time equals end time]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',  @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Invalid time range. Provide both StartTime and EndTime, and EndTime must be after StartTime.';

    EXEC dbo.spCreateEvent
         @Name = 'Bad Event Equal Times',
         @Description = 'Equal times',
         @Date = '2026-07-04',
         @StartTime = '11:00:00',
         @EndTime = '11:00:00',
         @Recurring = 0,
         @DayPeriod = NULL,
         @LastModifiedBy = 1,
         @CreatedBy = 1;
END;
GO

CREATE PROCEDURE EventTests.[test spCreateEvent throws error when LastModifiedBy is null]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'LastModifiedBy and CreatedBy are required.';

    EXEC dbo.spCreateEvent
         @Name = 'Missing LastModifiedBy',
         @Description = 'Missing user id',
         @Date = '2026-07-05',
         @StartTime = '09:00:00',
         @EndTime = '10:00:00',
         @Recurring = 0,
         @DayPeriod = NULL,
         @LastModifiedBy = NULL,
         @CreatedBy = 1;
END;
GO

CREATE PROCEDURE EventTests.[test spCreateEvent throws error when CreatedBy is null]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'LastModifiedBy and CreatedBy are required.';

    EXEC dbo.spCreateEvent
         @Name = 'Missing CreatedBy',
         @Description = 'Missing user id',
         @Date = '2026-07-06',
         @StartTime = '09:00:00',
         @EndTime = '10:00:00',
         @Recurring = 0,
         @DayPeriod = NULL,
         @LastModifiedBy = 1,
         @CreatedBy = NULL;
END;
GO

CREATE PROCEDURE EventTests.[test spCreateEvent throws error when both user ids are null]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'LastModifiedBy and CreatedBy are required.';

    EXEC dbo.spCreateEvent
         @Name = 'Missing Both User IDs',
         @Description = 'Missing both user ids',
         @Date = '2026-07-07',
         @StartTime = '09:00:00',
         @EndTime = '10:00:00',
         @Recurring = 0,
         @DayPeriod = NULL,
         @LastModifiedBy = NULL,
         @CreatedBy = NULL;
END;
GO

CREATE PROCEDURE EventTests.[test spCreateEvent returns new event tuid]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',  @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    CREATE TABLE #Actual
    (
        NewEventTUID NUMERIC(38,0)
    );

    INSERT INTO #Actual (NewEventTUID)
    EXEC dbo.spCreateEvent
         @Name = 'Returned ID Event',
         @Description = 'Testing returned identity',
         @Date = '2026-08-01',
         @StartTime = '01:00:00',
         @EndTime = '02:00:00',
         @Recurring = 0,
         @DayPeriod = 1,
         @LastModifiedBy = 1,
         @CreatedBy = 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM #Actual
        WHERE NewEventTUID = 1
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected spCreateEvent to return NewEventTUID = 1.';
    END
END;
GO


/**********************************************************************************************
Section 2: test dpCreateExpense Stored Proceduer
**********************************************************************************************/

CREATE PROCEDURE FinanceTests.[test spCreateExpense inserts valid expense]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Expense', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',    @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    -- Act
    EXEC dbo.spCreateExpense
         @UserID = 1,
         @Date = '2026-03-01',
         @Category = 'Medical',
         @Description = 'Vet exam and medicine',
         @Amount = 125.50,
         @PayMethod = 'Credit Card',
         @Vendor = 'Happy Paws Vet';

    -- Assert
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Expense
        WHERE [Date] = '2026-03-01'
          AND Category = 'Medical'
          AND [Description] = 'Vet exam and medicine'
          AND Amount = 125.50
          AND PayMethod = 'Credit Card'
          AND Vendor = 'Happy Paws Vet'
          AND LastModifiedBy = 1
          AND CreatedBy = 1
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected valid expense row to be inserted.';
    END
END;
GO

CREATE PROCEDURE FinanceTests.[test spCreateExpense sets CreatedBy and LastModifiedBy from UserID]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Expense', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',    @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    -- Act
    EXEC dbo.spCreateExpense
         @UserID = 3,
         @Date = '2026-03-05',
         @Category = 'Supplies',
         @Description = 'Cleaning items',
         @Amount = 42.75,
         @PayMethod = 'Cash',
         @Vendor = 'Meijer';

    -- Assert
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Expense
        WHERE [Date] = '2026-03-05'
          AND CreatedBy = 3
          AND LastModifiedBy = 3
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected CreatedBy and LastModifiedBy to match @UserID.';
    END
END;
GO

CREATE PROCEDURE FinanceTests.[test spCreateExpense throws error when UserID does not exist]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Expense', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',    @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'User ID does not exist';

    -- Act
    EXEC dbo.spCreateExpense
         @UserID = 999,
         @Date = '2026-03-01',
         @Category = 'Medical',
         @Description = 'Vet exam',
         @Amount = 50.00,
         @PayMethod = 'Cash',
         @Vendor = 'Vet Office';
END;
GO

CREATE PROCEDURE FinanceTests.[test spCreateExpense throws error when Date is null]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Expense', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',    @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Date cannot be NULL';

    -- Act
    EXEC dbo.spCreateExpense
         @UserID = 1,
         @Date = NULL,
         @Category = 'Medical',
         @Description = 'Vet exam',
         @Amount = 50.00,
         @PayMethod = 'Cash',
         @Vendor = 'Vet Office';
END;
GO

CREATE PROCEDURE FinanceTests.[test spCreateExpense throws error when Amount is null]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Expense', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',    @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Amount cannot be NULL';

    -- Act
    EXEC dbo.spCreateExpense
         @UserID = 1,
         @Date = '2026-03-01',
         @Category = 'Medical',
         @Description = 'Vet exam',
         @Amount = NULL,
         @PayMethod = 'Cash',
         @Vendor = 'Vet Office';
END;
GO

CREATE PROCEDURE FinanceTests.[test spCreateExpense throws error when PayMethod is null]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Expense', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',    @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Payment Method cannot be NULL or empty';

    -- Act
    EXEC dbo.spCreateExpense
         @UserID = 1,
         @Date = '2026-03-01',
         @Category = 'Medical',
         @Description = 'Vet exam',
         @Amount = 50.00,
         @PayMethod = NULL,
         @Vendor = 'Vet Office';
END;
GO

CREATE PROCEDURE FinanceTests.[test spCreateExpense throws error when PayMethod is empty]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Expense', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',    @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Payment Method cannot be NULL or empty';

    -- Act
    EXEC dbo.spCreateExpense
         @UserID = 1,
         @Date = '2026-03-01',
         @Category = 'Medical',
         @Description = 'Vet exam',
         @Amount = 50.00,
         @PayMethod = '',
         @Vendor = 'Vet Office';
END;
GO

CREATE PROCEDURE FinanceTests.[test spCreateExpense stores category description and vendor correctly]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Expense', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',    @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    -- Act
    EXEC dbo.spCreateExpense
         @UserID = 2,
         @Date = '2026-03-10',
         @Category = 'Event',
         @Description = 'Adoption booth supplies',
         @Amount = 89.99,
         @PayMethod = 'Check',
         @Vendor = 'Target';

    -- Assert
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Expense
        WHERE Category = 'Event'
          AND [Description] = 'Adoption booth supplies'
          AND Vendor = 'Target'
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected Category, Description, and Vendor to be stored correctly.';
    END
END;
GO


/**********************************************************************************************
Section 3: test dpCreateFile Stored Proceduer
**********************************************************************************************/


CREATE PROCEDURE FolderAndFileTests.[test spCreateFile inserts valid file with pet and folder]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'File',   @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',   @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Pet',    @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.InsertTestPets;
    EXEC TestHelpers.InsertBaseFolders;

    EXEC dbo.spCreateFile
         @UserID = 1,
         @FileLocation = '/docs/buddy_medical.pdf',
         @FileName = 'buddy_medical.pdf',
         @IsReviewed = 1,
         @IsPolicyProcedure = 0,
         @PetID = 1,
         @FolderID = 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[File]
        WHERE FileLocation = '/docs/buddy_medical.pdf'
          AND [FileName] = 'buddy_medical.pdf'
          AND IsReviewed = 1
          AND IsPolicyProcedure = 0
          AND PetID = 1
          AND FolderID = 1
          AND LastModifiedBy = 1
          AND CreatedBy = 1
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected valid file row to be inserted.';
    END
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFile inserts valid file with null PetID]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'File',   @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',   @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.InsertBaseFolders;

    EXEC dbo.spCreateFile
         @UserID = 2,
         @FileLocation = '/docs/general_policy.pdf',
         @FileName = 'general_policy.pdf',
         @IsReviewed = 0,
         @IsPolicyProcedure = 1,
         @PetID = NULL,
         @FolderID = 2;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[File]
        WHERE FileLocation = '/docs/general_policy.pdf'
          AND [FileName] = 'general_policy.pdf'
          AND IsReviewed = 0
          AND IsPolicyProcedure = 1
          AND PetID IS NULL
          AND FolderID = 2
          AND CreatedBy = 2
          AND LastModifiedBy = 2
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected valid file row with NULL PetID to be inserted.';
    END
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFile inserts valid file with null FolderID]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Pet',  @identity = 1;

    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.InsertTestPets;

    EXEC dbo.spCreateFile
         @UserID = 3,
         @FileLocation = '/docs/taco_notes.pdf',
         @FileName = 'taco_notes.pdf',
         @IsReviewed = 1,
         @IsPolicyProcedure = 0,
         @PetID = 2,
         @FolderID = NULL;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[File]
        WHERE FileLocation = '/docs/taco_notes.pdf'
          AND [FileName] = 'taco_notes.pdf'
          AND IsReviewed = 1
          AND IsPolicyProcedure = 0
          AND PetID = 2
          AND FolderID IS NULL
          AND CreatedBy = 3
          AND LastModifiedBy = 3
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected valid file row with NULL FolderID to be inserted.';
    END
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFile throws error when UserID does not exist]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'File',   @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',   @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Pet',    @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;

    EXEC TestHelpers.InsertTestPets;
    EXEC TestHelpers.InsertBaseFolders;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'User ID does not exist';

    EXEC dbo.spCreateFile
         @UserID = 999,
         @FileLocation = '/docs/file.pdf',
         @FileName = 'file.pdf',
         @IsReviewed = 1,
         @IsPolicyProcedure = 0,
         @PetID = 1,
         @FolderID = 1;
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFile throws error when PetID does not exist]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'File',   @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',   @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Pet',    @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.InsertBaseFolders;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Pet ID does not exist';

    EXEC dbo.spCreateFile
         @UserID = 1,
         @FileLocation = '/docs/file.pdf',
         @FileName = 'file.pdf',
         @IsReviewed = 1,
         @IsPolicyProcedure = 0,
         @PetID = 999,
         @FolderID = 1;
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFile throws error when FolderID does not exist]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'File',   @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',   @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Pet',    @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.InsertTestPets;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Folder ID does not exist';

    EXEC dbo.spCreateFile
         @UserID = 1,
         @FileLocation = '/docs/file.pdf',
         @FileName = 'file.pdf',
         @IsReviewed = 1,
         @IsPolicyProcedure = 0,
         @PetID = 1,
         @FolderID = 999;
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFile throws error when FileLocation is null]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'File Location cannot be NULL or empty';

    EXEC dbo.spCreateFile
         @UserID = 1,
         @FileLocation = NULL,
         @FileName = 'file.pdf',
         @IsReviewed = 1,
         @IsPolicyProcedure = 0,
         @PetID = NULL,
         @FolderID = NULL;
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFile throws error when FileLocation is empty]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'File Location cannot be NULL or empty';

    EXEC dbo.spCreateFile
         @UserID = 1,
         @FileLocation = '',
         @FileName = 'file.pdf',
         @IsReviewed = 1,
         @IsPolicyProcedure = 0,
         @PetID = NULL,
         @FolderID = NULL;
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFile throws error when FileName is null]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'File Name cannot be NULL or empty';

    EXEC dbo.spCreateFile
         @UserID = 1,
         @FileLocation = '/docs/file.pdf',
         @FileName = NULL,
         @IsReviewed = 1,
         @IsPolicyProcedure = 0,
         @PetID = NULL,
         @FolderID = NULL;
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFile throws error when FileName is empty]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'File Name cannot be NULL or empty';

    EXEC dbo.spCreateFile
         @UserID = 1,
         @FileLocation = '/docs/file.pdf',
         @FileName = '',
         @IsReviewed = 1,
         @IsPolicyProcedure = 0,
         @PetID = NULL,
         @FolderID = NULL;
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFile throws error when IsReviewed is null]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'IsReviewed cannot be NULL';

    EXEC dbo.spCreateFile
         @UserID = 1,
         @FileLocation = '/docs/file.pdf',
         @FileName = 'file.pdf',
         @IsReviewed = NULL,
         @IsPolicyProcedure = 0,
         @PetID = NULL,
         @FolderID = NULL;
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFile throws error when IsPolicyProcedure is null]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'IsPolicyProcedure cannot be NULL';

    EXEC dbo.spCreateFile
         @UserID = 1,
         @FileLocation = '/docs/file.pdf',
         @FileName = 'file.pdf',
         @IsReviewed = 1,
         @IsPolicyProcedure = NULL,
         @PetID = NULL,
         @FolderID = NULL;
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFile sets CreatedBy and LastModifiedBy from UserID]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC dbo.spCreateFile
         @UserID = 3,
         @FileLocation = '/docs/audit_test.pdf',
         @FileName = 'audit_test.pdf',
         @IsReviewed = 0,
         @IsPolicyProcedure = 1,
         @PetID = NULL,
         @FolderID = NULL;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[File]
        WHERE FileLocation = '/docs/audit_test.pdf'
          AND CreatedBy = 3
          AND LastModifiedBy = 3
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected CreatedBy and LastModifiedBy to match @UserID.';
    END
END;
GO


/**********************************************************************************************
Section 4: test dpCreateFolder Stored Proceduere
**********************************************************************************************/

CREATE PROCEDURE FolderAndFileTests.[test spCreateFolder inserts valid folder]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',   @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    -- Act
    EXEC dbo.spCreateFolder
         @UserID = 1,
         @FolderName = '/Test Folder';

    -- Assert
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Folder
        WHERE FolderName = '/Test Folder'
          AND CreatedBy = 1
          AND LastModifiedBy = 1
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected valid folder to be inserted.';
    END
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFolder sets audit fields from UserID]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',   @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    -- Act
    EXEC dbo.spCreateFolder
         @UserID = 3,
         @FolderName = '/Audit Folder';

    -- Assert
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Folder
        WHERE FolderName = '/Audit Folder'
          AND CreatedBy = 3
          AND LastModifiedBy = 3
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected CreatedBy and LastModifiedBy to match @UserID.';
    END
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFolder throws error when UserID does not exist]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',   @identity = 1;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'User ID does not exist';

    -- Act
    EXEC dbo.spCreateFolder
         @UserID = 999,
         @FolderName = '/Invalid User Folder';
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFolder throws error when FolderName is null]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',   @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Folder Name cannot be NULL or empty';

    -- Act
    EXEC dbo.spCreateFolder
         @UserID = 1,
         @FolderName = NULL;
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFolder throws error when FolderName is empty]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',   @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Folder Name cannot be NULL or empty';

    -- Act
    EXEC dbo.spCreateFolder
         @UserID = 1,
         @FolderName = '';
END;
GO

CREATE PROCEDURE FolderAndFileTests.[test spCreateFolder does not insert on failure]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',   @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Folder Name cannot be NULL or empty';

    -- Act
    EXEC dbo.spCreateFolder
         @UserID = 1,
         @FolderName = NULL;

    -- Assert (this still runs after ExpectException)
    IF EXISTS (SELECT 1 FROM dbo.Folder)
    BEGIN
        EXEC tSQLt.Fail 'No rows should be inserted when validation fails.';
    END
END;
GO

/**********************************************************************************************
Section 5: test dpCreateHome Stored Proceduere
**********************************************************************************************/

CREATE PROCEDURE HomeTests.[test spCreateHome inserts valid home]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',  @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    -- Act
    EXEC dbo.spCreateHome
         @CreatedBy = 1,
         @HouseName = 'Test Home',
         @Address = '123 Main St',
         @City = 'Midland',
         @State = 'MI',
         @Zip = '48640',
         @PhoneNumber = '989-555-1111',
         @RedFlag = 0,
         @RedFlagReason = NULL,
         @CanFoster = 1,
         @NoFosterUntil = NULL,
         @CanAdopter = 1,
         @NoAdopterUntil = NULL,
         @Notes = 'Test notes',
         @IsIndividual = 1,
         @IsActive = 1,
         @HasFamily = 0,
         @HasKids = 0,
         @HasOtherPets = 1,
         @IsAdopter = 1,
         @IsFoster = 1;

    -- Assert
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.House
        WHERE HouseName = 'Test Home'
          AND Address = '123 Main St'
          AND City = 'Midland'
          AND State = 'MI'
          AND Zip = '48640'
          AND PhoneNumber = '989-555-1111'
          AND RedFlag = 0
          AND RedFlagReason IS NULL
          AND CanFoster = 1
          AND NoFosterUntil IS NULL
          AND CanAdopt = 1
          AND NoAdoptUntil IS NULL
          AND Notes = 'Test notes'
          AND IsIndividual = 1
          AND IsActive = 1
          AND HasFamily = 0
          AND HasKids = 0
          AND HasOtherPets = 1
          AND IsAdopter = 1
          AND IsFoster = 1
          AND CreatedBy = 1
          AND LastModifiedBy = 1
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected valid home row to be inserted.';
    END
END;
GO

/**********************************************************************************************
Section 6: test dpCreatPerson Stored Proceduere
**********************************************************************************************/

CREATE PROCEDURE PersonTests.[test spCreatePerson inserts valid person]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'House',  @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',   @identity = 1;

    EXEC TestHelpers.InsertTestUsers;
    EXEC TestHelpers.InsertTestHouses;

    -- Act
    EXEC dbo.spCreatePerson
         @FirstName = 'Alice',
         @LastName = 'Smith',
         @Email = 'alice@example.com',
         @PhoneNumber = '989-555-1111',
         @HouseID = 1,
         @IsVolunteer = 1,
         @Notes = 'Weekend volunteer',
         @User = 1;

    -- Assert
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Person
        WHERE FirstName = 'Alice'
          AND LastName = 'Smith'
          AND Email = 'alice@example.com'
          AND PhoneNumber = '989-555-1111'
          AND HouseID = 1
          AND IsVolunteer = 1
          AND Notes = 'Weekend volunteer'
          AND CreatedBy = 1
          AND LastModifiedBy = 1
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected valid person row to be inserted.';
    END
END;
GO

/**********************************************************************************************
Section 7: test dpCreatePet Stored Proceduere
**********************************************************************************************/

CREATE PROCEDURE PetTests.[test spCreatePet inserts valid pet]
AS
BEGIN
-- Arrange
EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;

EXEC TestHelpers.InsertTestUsers;
EXEC TestHelpers.InsertTestHouses;

-- Act
EXEC dbo.spCreatePet
@Animal = 'Dog',
@Breed = 'Beagle',
@Name = 'Charlie',
@Sex = 'Male',
@Origin = 'Shelter',
@DateOfBirth = '2024-01-15',
@IsDateOfBirthKnown = 1,
@Characterisitics = 'Friendly and playful',
@Weight = 25,
@IntakeDate = '2026-03-01',
@Notes = 'Healthy',
@Microchip = '123456789012345',
@Adopted = 0,
@PreviousHomeID = 1,
@CurrentHomeID = 2,
@PhotoLocation = '/photos/charlie.jpg',
@CreatedBy = 1,
@LastModifiedBy = 1;

-- Assert
IF NOT EXISTS
(
SELECT 1
FROM dbo.Pet
WHERE Animal = 'Dog'
AND Breed = 'Beagle'
AND [Name] = 'Charlie'
AND Sex = 'Male'
AND Origin = 'Shelter'
AND DateOfBirth = '2024-01-15'
AND IsDateOfBirthKnown = 1
AND Characteristics = 'Friendly and playful'
AND [Weight] = 25
AND IntakeDate = '2026-03-01'
AND Notes = 'Healthy'
AND Microchip = '123456789012345'
AND Adopted = 0
AND PreviousHomeID = 1
AND CurrentHomeID = 2
AND PhotoLocation = '/photos/charlie.jpg'
AND CreatedBy = 1
AND LastModifiedBy = 1
)
BEGIN
EXEC tSQLt.Fail 'Expected valid pet row to be inserted.';
END
END;
GO


/**********************************************************************************************
Section 8: test dpCreatePrevention Stored Proceduere
**********************************************************************************************/

CREATE PROCEDURE MedicalTests.[test spCreatePrevention inserts valid prevention]
AS
    BEGIN
    -- Arrange
        EXEC tSQLt.FakeTable 'dbo', 'Prevention', @identity = 1;
        EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;

        EXEC TestHelpers.InsertTestPets;

        -- Act
        EXEC dbo.spCreatePrevention
        @Type = 'Heartworm',
        @Notes = 'Monthly dose',
        @DateGiven = '2026-03-01',
        @DateDue = '2026-04-01',
        @PetID = 1;

        -- Assert
        IF NOT EXISTS
        (
        SELECT 1
        FROM dbo.Prevention
        WHERE [Type] = 'Heartworm'
        AND Notes = 'Monthly dose'
        AND DateGiven = '2026-03-01'
        AND DateDue = '2026-04-01'
        AND PetID = 1
        )
        BEGIN
        EXEC tSQLt.Fail 'Expected valid prevention row to be inserted.';
        END
    END;
GO

/**********************************************************************************************
Section 9: test dpCreateRevenue Stored Proceduere
**********************************************************************************************/

CREATE PROCEDURE FinanceTests.[test spCreateRevenue inserts valid revenue]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Revenue', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',    @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    -- Act
    EXEC dbo.spCreateRevenue
         @UserID = 1,
         @Date = '2026-03-01',
         @Category = 'Donation',
         @Description = 'General donation',
         @Amount = 250.00,
         @PayMethod = 'Venmo',
         @Person = 'Jane Doe';

    -- Assert
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Revenue
        WHERE [Date] = '2026-03-01'
          AND Category = 'Donation'
          AND [Description] = 'General donation'
          AND Amount = 250.00
          AND PayMethod = 'Venmo'
          AND Person = 'Jane Doe'
          AND CreatedBy = 1
          AND LastModifiedBy = 1
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected valid revenue row to be inserted.';
    END
END;
GO

CREATE PROCEDURE FinanceTests.[test spCreateRevenue throws error when UserID does not exist]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Revenue', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',    @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'User ID does not exist';

    -- Act
    EXEC dbo.spCreateRevenue
         @UserID = 999,
         @Date = '2026-03-01',
         @Category = 'Donation',
         @Description = 'Invalid user test',
         @Amount = 50.00,
         @PayMethod = 'Cash',
         @Person = 'Donor';
END;
GO

CREATE PROCEDURE FinanceTests.[test spCreateRevenue throws error when Date is null]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Revenue', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',    @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Date cannot be NULL';

    -- Act
    EXEC dbo.spCreateRevenue
         @UserID = 1,
         @Date = NULL,
         @Category = 'Donation',
         @Description = 'Missing date',
         @Amount = 75.00,
         @PayMethod = 'Cash',
         @Person = 'Donor';
END;
GO

CREATE PROCEDURE FinanceTests.[test spCreateRevenue throws error when Amount is null]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Revenue', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',    @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Amount cannot be NULL';

    -- Act
    EXEC dbo.spCreateRevenue
         @UserID = 1,
         @Date = '2026-03-01',
         @Category = 'Donation',
         @Description = 'Missing amount',
         @Amount = NULL,
         @PayMethod = 'Cash',
         @Person = 'Donor';
END;
GO

CREATE PROCEDURE FinanceTests.[test spCreateRevenue throws error when PayMethod is null]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Revenue', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',    @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Payment Method cannot be NULL or empty';

    -- Act
    EXEC dbo.spCreateRevenue
         @UserID = 1,
         @Date = '2026-03-01',
         @Category = 'Donation',
         @Description = 'Missing pay method',
         @Amount = 60.00,
         @PayMethod = NULL,
         @Person = 'Donor';
END;
GO

CREATE PROCEDURE FinanceTests.[test spCreateRevenue throws error when PayMethod is empty]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Revenue', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',    @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    EXEC tSQLt.ExpectException
        @ExpectedMessage = 'Payment Method cannot be NULL or empty';

    -- Act
    EXEC dbo.spCreateRevenue
         @UserID = 1,
         @Date = '2026-03-01',
         @Category = 'Donation',
         @Description = 'Empty pay method',
         @Amount = 60.00,
         @PayMethod = '',
         @Person = 'Donor';
END;
GO

CREATE PROCEDURE FinanceTests.[test spCreateRevenue inserts revenue with null Person]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Revenue', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User',    @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    -- Act
    EXEC dbo.spCreateRevenue
         @UserID = 2,
         @Date = '2026-03-15',
         @Category = 'Grant',
         @Description = 'Anonymous grant',
         @Amount = 500.00,
         @PayMethod = 'Check',
         @Person = NULL;

    -- Assert
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Revenue
        WHERE [Date] = '2026-03-15'
          AND Category = 'Grant'
          AND [Description] = 'Anonymous grant'
          AND Amount = 500.00
          AND PayMethod = 'Check'
          AND Person IS NULL
          AND CreatedBy = 2
          AND LastModifiedBy = 2
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected revenue row with NULL Person to be inserted.';
    END
END;
GO


/**********************************************************************************************
Section 10: test dpCreateRole Stored Proceduere
**********************************************************************************************/

CREATE PROCEDURE RoleTests.[test spCreateRole inserts valid role]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Role', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;

    EXEC TestHelpers.InsertTestUsers;

    -- Act
    EXEC dbo.spCreateRole
         @RoleName = 'Coordinator',
         @RoleColor = 'Green',
         @CreatedBy = 1,
         @LastModifiedBy = 1,
         @PetManagement = 'Edit',
         @AdopterManagement = 'View',
         @FosterAndVolunteerManagement = 'Edit',
         @ApplicationsAndVolunteerManagement = 'View',
         @FinancialManagement = 'No Access',
         @DocumentationAndMeetings = 'Edit';

    -- Assert
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.[Role]
        WHERE RoleName = 'Coordinator'
          AND RoleColor = 'Green'
          AND CreatedBy = 1
          AND LastModifiedBy = 1
          AND PetManagement = 'Edit'
          AND AdopterManagement = 'View'
          AND FosterAndVolunteerManagement = 'Edit'
          AND ApplicationsAndVolunteerManagement = 'View'
          AND FinancialManagement = 'No Access'
          AND DocumentationAndMeetings = 'Edit'
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected valid role row to be inserted.';
    END
END;
GO

/**********************************************************************************************
Section 11: test dpCreateSurgery Stored Proceduere
**********************************************************************************************/

CREATE PROCEDURE MedicalTests.[test spCreateSurgery inserts valid surgery]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Surgery', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Pet',     @identity = 1;

    EXEC TestHelpers.InsertTestPets;

    -- Act
    EXEC dbo.spCreateSurgery
         @Name = 'Spay',
         @Description = 'Routine spay procedure',
         @Date = '2026-03-01',
         @PetID = 1;

    -- Assert
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Surgery
        WHERE [Name] = 'Spay'
          AND [Description] = 'Routine spay procedure'
          AND [Date] = '2026-03-01'
          AND PetID = 1
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected valid surgery row to be inserted.';
    END
END;
GO


/**********************************************************************************************
Section 12: test dpCreateUser Stored Proceduere
**********************************************************************************************/

CREATE PROCEDURE UserTests.[test spCreateUser inserts valid user]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Role', @identity = 1;

    EXEC TestHelpers.InsertTestRoles;

    -- Act
    EXEC dbo.spCreateUser
    @RoleID = 1,
    @Username = 'newuser',
    @Password = 'password123',
    @Email = 'newuser@example.com',
    @Name = 'New User',
    @Notes = 'Created in unit test';

    -- Assert
    IF NOT EXISTS
    (
    SELECT 1
    FROM dbo.[User]
    WHERE RoleID = 1
    AND Username = 'newuser'
    AND [Password] = 'password123'
    AND Email = 'newuser@example.com'
    AND [Name] = 'New User'
    AND Notes = 'Created in unit test'
    )
    BEGIN
    EXEC tSQLt.Fail 'Expected valid user row to be inserted.';
    END
END;
GO

/**********************************************************************************************
Section 13: test dpCreateVaccine Stored Proceduere
**********************************************************************************************/

CREATE PROCEDURE MedicalTests.[test spCreateVaccine inserts valid vaccine]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'Vaccine', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;

    EXEC TestHelpers.InsertTestPets;

    -- Act
    EXEC dbo.spCreateVaccine
    @Type = 'Rabies',
    @Notes = 'Initial dose',
    @DateGiven = '2026-03-01',
    @DateDue = '2027-03-01',
    @PetID = 1;

    -- Assert
    IF NOT EXISTS
    (
    SELECT 1
    FROM dbo.Vaccine
    WHERE [Type] = 'Rabies'
    AND Notes = 'Initial dose'
    AND DateGiven = '2026-03-01'
    AND DateDue = '2027-03-01'
    AND PetID = 1
    )
    BEGIN
        EXEC tSQLt.Fail 'Expected valid vaccine row to be inserted.';
    END
END;
GO

/**********************************************************************************************
Section 14: test dpCreateVetVisit Stored Proceduere
**********************************************************************************************/

CREATE PROCEDURE MedicalTests.[test spCreateVetVisit inserts valid vet visit]
AS
BEGIN
    -- Arrange
    EXEC tSQLt.FakeTable 'dbo', 'VetVisit', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;

    EXEC TestHelpers.InsertTestPets;

    -- Act
    EXEC dbo.spCreateVetVisit
    @Name = 'Annual Checkup',
    @Description = 'Routine yearly exam',
    @Date = '2026-03-01',
    @PetID = 1;

    -- Assert
    IF NOT EXISTS
    (
    SELECT 1
    FROM dbo.VetVisit
    WHERE [Name] = 'Annual Checkup'
    AND [Description] = 'Routine yearly exam'
    AND [Date] = '2026-03-01'
    AND PetID = 1
    )
    BEGIN
    EXEC tSQLt.Fail 'Expected valid vet visit row to be inserted.';
    END
END;
GO



