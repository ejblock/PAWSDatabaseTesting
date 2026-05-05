USE MidlandPitStopDatabase;
GO

-- MODIFICATION HISTORY
-- Alyssa Lilly 02/28/2026
-- Original delete procedure unit tests.
-- Madison Koscielski 03/22/2026
-- Replaced file header with standardized team test-file header.
-- Removed file-level fake table and seed data setup so each test is isolated.
-- Updated tests to use TestHelpers schema setup pattern.
-- Ensured dbo.[User] is faked and inserted first where dependent tables require it.
-- Corrected delete assertions to verify zero remaining rows after deletion.
-- removed spDeleteTable tests -> this should be a manual test

-- Drop old test procedures
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql += 
    'IF OBJECT_ID(''' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ''', ''P'') IS NOT NULL
        DROP PROCEDURE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.procedures
WHERE name LIKE 'test spDelete%';
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


/****** Object: Test StoredProcedure EventTests.[test spDeleteEvent deletes correct record] ******/
/****** Originally created by Alyssa Lilly ******/
CREATE PROCEDURE EventTests.[test spDeleteEvent deletes correct record]
AS
BEGIN
    -- Fake dependent tables first
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.[Event]';

    -- Insert required user first
    INSERT INTO dbo.[User] (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES (1, 'Test User', 'testuser', 'password123', 'test@gmail.com', NULL, NULL);

    -- Insert test event
    INSERT INTO dbo.[Event]
        (TUID, [Name], [Date], LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (1, 'Event1', '2026-01-01', GETDATE(), GETDATE(), 1, 1);

    -- Act
    EXEC dbo.spDeleteEvent @EventTUID = 1;

    -- Assert
    DECLARE @Remaining INT =
        (SELECT COUNT(*) FROM dbo.[Event] WHERE TUID = 1);

    EXEC tSQLt.AssertEquals 0, @Remaining;
END;
GO


/****** Object: Test StoredProcedure PersonTests.[test spDeletePerson deletes correct record] ******/
/****** Originally created by Alyssa Lilly ******/
CREATE PROCEDURE PersonTests.[test spDeletePerson deletes correct record]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.House';
    EXEC tSQLt.FakeTable 'dbo.Person';

    -- Insert required user first
    INSERT INTO dbo.[User] (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES (1, 'Test User', 'testuser', 'password123', 'test@gmail.com', NULL, NULL);

    -- Insert required house
    INSERT INTO dbo.House
        (TUID, [Address], City, [State], ZIP, PhoneNumber, LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (1, '789 Home St', 'City', 'ST', '12345', '555-7890', GETDATE(), GETDATE(), 1, 1);

    -- Insert test person
    INSERT INTO dbo.Person
        (TUID, FirstName, LastName, Email, PhoneNumber, HouseID, LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (2, 'John', 'Doe', 'john@test.com', '555-0000', 1, GETDATE(), GETDATE(), 1, 1);

    -- Act
    EXEC dbo.spDeletePerson @PersonTUID = 2;

    -- Assert
    DECLARE @Remaining INT =
        (SELECT COUNT(*) FROM dbo.Person WHERE TUID = 2);

    EXEC tSQLt.AssertEquals 0, @Remaining;
END;
GO


/****** Object: Test StoredProcedure RoleTests.[test spDeleteRole deletes correct record] ******/
/****** Originally created by Alyssa Lilly ******/
CREATE PROCEDURE RoleTests.[test spDeleteRole deletes correct record]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.[Role]';

    -- Insert required user first
    INSERT INTO dbo.[User] (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES (1, 'Test User', 'testuser', 'password123', 'test@gmail.com', NULL, NULL);

    -- Insert test role
    INSERT INTO dbo.[Role]
        (TUID, RoleName, RoleColor, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy,
         PetManagement, AdopterManagement, FosterAndVolunteerManagement,
         ApplicationsAndVolunteerManagement, FinancialManagement, DocumentationAndMeetings)
    VALUES
        (1, 'OldRole', 'Red', GETDATE(), 1, GETDATE(), 1,
         'edit', 'edit', 'edit', 'edit', 'edit', 'edit');

    -- Act
    EXEC dbo.spDeleteRole @TUID = 1;

    -- Assert
    DECLARE @Remaining INT =
        (SELECT COUNT(*) FROM dbo.[Role] WHERE TUID = 1);

    EXEC tSQLt.AssertEquals 0, @Remaining;
END;
GO


/****** Object: Test StoredProcedure UserTests.[test spDeleteUser deletes correct record] ******/
/****** Originally created by Alyssa Lilly ******/
CREATE PROCEDURE UserTests.[test spDeleteUser deletes correct record]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo.[Role]';
    EXEC tSQLt.FakeTable 'dbo.[User]';

    -- Insert supporting role first
    INSERT INTO dbo.[Role]
        (TUID, RoleName, RoleColor, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy,
         PetManagement, AdopterManagement, FosterAndVolunteerManagement,
         ApplicationsAndVolunteerManagement, FinancialManagement, DocumentationAndMeetings)
    VALUES
        (1, 'Test Role', 'Red', GETDATE(), NULL, GETDATE(), NULL,
         'edit', 'edit', 'edit', 'edit', 'edit', 'edit');

    -- Insert user to delete
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (2, 'Old Name', 'olduser', 'pass', 'old@mail.com', 'Some notes', 1);

    -- Act
    EXEC dbo.spDeleteUser @TUID = 2;

    -- Assert
    DECLARE @Remaining INT =
        (SELECT COUNT(*) FROM dbo.[User] WHERE TUID = 2);

    EXEC tSQLt.AssertEquals 0, @Remaining;
END;
GO



/****** Object: Test StoredProcedure PersonTests.[test spDeletePerson deletes person and related event rows] ******/
/****** Originally created by Madison Koscielski ******/
CREATE PROCEDURE PersonTests.[test spDeletePerson deletes person and related event rows]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.House';
    EXEC tSQLt.FakeTable 'dbo.Person';
    EXEC tSQLt.FakeTable 'dbo.RelationshipPersonEvent';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@test.com', NULL, NULL);

    -- Insert required house for person dependency
    INSERT INTO dbo.House
        (TUID, [Address], City, [State], ZIP, PhoneNumber,
         LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (1, '123 Main St', 'Midland', 'MI', '48640', '9895551111',
         GETDATE(), GETDATE(), 1, 1);

    -- Insert person to be deleted
    INSERT INTO dbo.Person
        (TUID, FirstName, LastName, Email, PhoneNumber, HouseID,
         LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (1, 'John', 'Doe', 'john@test.com', '9895552222', 1,
         GETDATE(), GETDATE(), 1, 1);

    -- Insert related relationship row that should also be deleted
    INSERT INTO dbo.RelationshipPersonEvent
        (PersonID, EventID)
    VALUES
        (1, 99);

    -- Act
    EXEC dbo.spDeletePerson @PersonTUID = 1;

    -- Assert relationship row was deleted
    DECLARE @RelationshipCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.RelationshipPersonEvent
        WHERE PersonID = 1
    );

    EXEC tSQLt.AssertEquals 0, @RelationshipCount;

    -- Assert person row was deleted
    DECLARE @PersonCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.Person
        WHERE TUID = 1
    );

    EXEC tSQLt.AssertEquals 0, @PersonCount;
END;
GO

/****** Object: Test StoredProcedureFolderAndFileTests.[test spDeleteFolder deletes folder subfolders and associated files] ******/
/****** Originally created by Madison Koscielski ******/
CREATE PROCEDURE FolderAndFileTests.[test spDeleteFolder deletes folder subfolders and associated files]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.Folder';
    EXEC tSQLt.FakeTable 'dbo.[File]';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@test.com', NULL, NULL);

    -- Insert parent folder
    INSERT INTO dbo.Folder
        (TUID, FolderName, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy)
    VALUES
        (1, 'Docs', GETDATE(), 1, GETDATE(), 1);

    -- Insert subfolders that should also be deleted
    INSERT INTO dbo.Folder
        (TUID, FolderName, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy)
    VALUES
        (2, 'Docs/Sub1', GETDATE(), 1, GETDATE(), 1),
        (3, 'Docs\Sub2', GETDATE(), 1, GETDATE(), 1);

    -- Insert unrelated folder that should remain
    INSERT INTO dbo.Folder
        (TUID, FolderName, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy)
    VALUES
        (4, 'OtherFolder', GETDATE(), 1, GETDATE(), 1);

    -- Insert files in parent and subfolders that should be deleted
    INSERT INTO dbo.[File]
        (TUID, FileName, FolderID, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy)
    VALUES
        (1, 'parentfile.txt', 1, GETDATE(), 1, GETDATE(), 1),
        (2, 'subfile1.txt', 2, GETDATE(), 1, GETDATE(), 1),
        (3, 'subfile2.txt', 3, GETDATE(), 1, GETDATE(), 1);

    -- Insert unrelated file that should remain
    INSERT INTO dbo.[File]
        (TUID, FileName, FolderID, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy)
    VALUES
        (4, 'keepme.txt', 4, GETDATE(), 1, GETDATE(), 1);

    -- Act
    EXEC dbo.spDeleteFolder @FolderTUID = 1;

    -- Assert folders were deleted
    DECLARE @DeletedFolderCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.Folder
        WHERE TUID IN (1, 2, 3)
    );

    EXEC tSQLt.AssertEquals 0, @DeletedFolderCount;

    -- Assert associated files were deleted
    DECLARE @DeletedFileCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.[File]
        WHERE TUID IN (1, 2, 3)
    );

    EXEC tSQLt.AssertEquals 0, @DeletedFileCount;

    -- Assert unrelated folder remains
    DECLARE @RemainingFolderCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.Folder
        WHERE TUID = 4
    );

    EXEC tSQLt.AssertEquals 1, @RemainingFolderCount;

    -- Assert unrelated file remains
    DECLARE @RemainingFileCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.[File]
        WHERE TUID = 4
    );

    EXEC tSQLt.AssertEquals 1, @RemainingFileCount;
END;
GO

/****** Object: Test StoredProcedure FolderAndFileTests.[test spDeleteFile deletes correct record] ******/
/****** Originally created by Madison Koscielski ******/
CREATE PROCEDURE FolderAndFileTests.[test spDeleteFile deletes correct record]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.Folder';
    EXEC tSQLt.FakeTable 'dbo.[File]';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@test.com', NULL, NULL);

    -- Insert required folder
    INSERT INTO dbo.Folder
        (TUID, FolderName, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy)
    VALUES
        (1, 'TestFolder', GETDATE(), 1, GETDATE(), 1);

    -- Insert file to delete
    INSERT INTO dbo.[File]
        (TUID, FileName, FolderID, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy)
    VALUES
        (1, 'delete_me.txt', 1, GETDATE(), 1, GETDATE(), 1);

    -- Insert unrelated file that should remain
    INSERT INTO dbo.[File]
        (TUID, FileName, FolderID, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy)
    VALUES
        (2, 'keep_me.txt', 1, GETDATE(), 1, GETDATE(), 1);

    -- Act
    EXEC dbo.spDeleteFile @FileTUID = 1;

    -- Assert deleted file is gone
    DECLARE @DeletedFileCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.[File]
        WHERE TUID = 1
    );

    EXEC tSQLt.AssertEquals 0, @DeletedFileCount;

    -- Assert unrelated file remains
    DECLARE @RemainingFileCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.[File]
        WHERE TUID = 2
    );

    EXEC tSQLt.AssertEquals 1, @RemainingFileCount;
END;
GO

/****** Object: Test StoredProcedure PetTests.[test spDeleteAllPetInfo deletes pet and all related records] ******/
/****** Originally created by Madison Koscielski ******/
CREATE PROCEDURE PetTests.[test spDeleteAllPetInfo deletes pet and all related records]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.Pet';
    EXEC tSQLt.FakeTable 'dbo.Vaccine';
    EXEC tSQLt.FakeTable 'dbo.Surgery';
    EXEC tSQLt.FakeTable 'dbo.Prevention';
    EXEC tSQLt.FakeTable 'dbo.VetVisit';
    EXEC tSQLt.FakeTable 'dbo.[File]';
    EXEC tSQLt.FakeTable 'dbo.PetAdoption';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@test.com', NULL, NULL);

    -- Insert pet to delete
    INSERT INTO dbo.Pet
        (TUID, [Name], LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (1, 'Buddy', GETDATE(), GETDATE(), 1, 1);

    -- Insert unrelated pet that should remain
    INSERT INTO dbo.Pet
        (TUID, [Name], LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (2, 'Max', GETDATE(), GETDATE(), 1, 1);

    -- Insert related records for pet 1
    INSERT INTO dbo.Vaccine
        (TUID, PetID)
    VALUES
        (1, 1);

    INSERT INTO dbo.Surgery
        (TUID, PetID)
    VALUES
        (1, 1);

    INSERT INTO dbo.Prevention
        (TUID, PetID)
    VALUES
        (1, 1);

    INSERT INTO dbo.VetVisit
        (TUID, PetID)
    VALUES
        (1, 1);

    INSERT INTO dbo.[File]
        (TUID, PetID)
    VALUES
        (1, 1);

    INSERT INTO dbo.PetAdoption
        (TUID, PetID)
    VALUES
        (1, 1);

    -- Insert unrelated records for pet 2 that should remain
    INSERT INTO dbo.Vaccine
        (TUID, PetID)
    VALUES
        (2, 2);

    INSERT INTO dbo.Surgery
        (TUID, PetID)
    VALUES
        (2, 2);

    INSERT INTO dbo.Prevention
        (TUID, PetID)
    VALUES
        (2, 2);

    INSERT INTO dbo.VetVisit
        (TUID, PetID)
    VALUES
        (2, 2);

    INSERT INTO dbo.[File]
        (TUID, PetID)
    VALUES
        (2, 2);

    INSERT INTO dbo.PetAdoption
        (TUID, PetID)
    VALUES
        (2, 2);

    -- Act
    EXEC dbo.spDeleteAllPetInfo @TUID = 1;

    -- Assert pet 1 was deleted
    DECLARE @PetCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.Pet
        WHERE TUID = 1
    );
    EXEC tSQLt.AssertEquals 0, @PetCount;

    -- Assert related records for pet 1 were deleted
    DECLARE @VaccineCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.Vaccine
        WHERE PetID = 1
    );
    EXEC tSQLt.AssertEquals 0, @VaccineCount;

    DECLARE @SurgeryCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.Surgery
        WHERE PetID = 1
    );
    EXEC tSQLt.AssertEquals 0, @SurgeryCount;

    DECLARE @PreventionCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.Prevention
        WHERE PetID = 1
    );
    EXEC tSQLt.AssertEquals 0, @PreventionCount;

    DECLARE @VetVisitCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.VetVisit
        WHERE PetID = 1
    );
    EXEC tSQLt.AssertEquals 0, @VetVisitCount;

    DECLARE @FileCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.[File]
        WHERE PetID = 1
    );
    EXEC tSQLt.AssertEquals 0, @FileCount;

    DECLARE @PetAdoptionCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.PetAdoption
        WHERE PetID = 1
    );
    EXEC tSQLt.AssertEquals 0, @PetAdoptionCount;

    -- Assert unrelated pet 2 still exists
    DECLARE @RemainingPetCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.Pet
        WHERE TUID = 2
    );
    EXEC tSQLt.AssertEquals 1, @RemainingPetCount;

    -- Assert unrelated records for pet 2 still exist
    DECLARE @RemainingVaccineCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.Vaccine
        WHERE PetID = 2
    );
    EXEC tSQLt.AssertEquals 1, @RemainingVaccineCount;

    DECLARE @RemainingSurgeryCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.Surgery
        WHERE PetID = 2
    );
    EXEC tSQLt.AssertEquals 1, @RemainingSurgeryCount;

    DECLARE @RemainingPreventionCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.Prevention
        WHERE PetID = 2
    );
    EXEC tSQLt.AssertEquals 1, @RemainingPreventionCount;

    DECLARE @RemainingVetVisitCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.VetVisit
        WHERE PetID = 2
    );
    EXEC tSQLt.AssertEquals 1, @RemainingVetVisitCount;

    DECLARE @RemainingFileCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.[File]
        WHERE PetID = 2
    );
    EXEC tSQLt.AssertEquals 1, @RemainingFileCount;

    DECLARE @RemainingPetAdoptionCount INT =
    (
        SELECT COUNT(*)
        FROM dbo.PetAdoption
        WHERE PetID = 2
    );
    EXEC tSQLt.AssertEquals 1, @RemainingPetAdoptionCount;
END;
GO







