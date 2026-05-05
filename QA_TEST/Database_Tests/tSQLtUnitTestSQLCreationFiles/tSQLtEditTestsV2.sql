USE MidlandPitStopDatabase;
GO
-- MODIFICATION HISTORY
-- Alyssa Lilly 02/28/2026
-- Original spEdit stored procedure unit tests.

-- Madison Koscielski 03/22/2026
-- Standardized file header to match team test file format.
-- Removed file-level fake tables and shared seed data to ensure test isolation.
-- Replaced TestHelpers.FakeUser usage with explicit dbo.[User] table setup in each test.
-- Ensured dbo.[User] is faked and inserted first in all tests due to table dependencies.
-- Updated all tests to use consistent TUID values (replaced 0 with deterministic values like 1 or 2).
-- Removed spEditAdopterHome and spEditFosterHome tests to align with updated schema (replaced by spEditHome).
-- Updated spEditPerson test to match new procedure parameters and schema changes.
-- Updated spEditEvent test to match new procedure parameters and schema changes.
-- Corrected stored procedure parameter usage across all tests.
-- Expanded assertions to validate multiple updated fields where applicable.
-- Improved readability, consistency, and maintainability across all test cases.



-- Drop old test procedures
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql +=
'IF OBJECT_ID(''' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ''', ''P'') IS NOT NULL
DROP PROCEDURE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.procedures
WHERE name LIKE 'test spEdit%';
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

/****** Object: Test StoredProcedure PetTests.[test spEditPet updates row correctly] ******/
/****** Created by Alyssa Lilly ******/
/****** Modified by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE PetTests.[test spEditPet updates row correctly]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.Pet';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@gmail.com', NULL, NULL);

    DECLARE @UserID INT = 1;

    -- Insert pet row to edit
    INSERT INTO dbo.Pet
        (TUID, Animal, [Name], Sex, DateOfBirth, IsDateOfBirthKnown, [Weight],
         IntakeDate, Adopted, LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (2, 'Dog', 'Buddy', 'Male', '2020-01-01', 1, 30,
         '2020-02-01', 0, GETDATE(), GETDATE(), @UserID, @UserID);

    DECLARE @PetID INT = 2;

    -- Act
    EXEC dbo.spEditPet
        @TUID = @PetID,
        @Animal = 'Dog',
        @Breed = 'Labrador',
        @Name = 'Max',
        @Sex = 'Male',
        @Origin = 'Surrendered',
        @DateOfBirth = '2020-01-01',
        @IsDateOfBirthKnown = 1,
        @Characteristics = ' Friendly and energetic',
        @Weight = 35,
        @IntakeDate = '2020-02-01',
        @Notes = 'Updated notes',
        @Microchip = '123456789',
        @Adopted = 0,
        @PreviousHomeID = NULL,
        @CurrentHomeID = NULL,
        @PhotoLocation = 'C:\Photos\Max.jpg',
        @LastModifiedBy = @UserID;

    -- Assert
    DECLARE @NewName VARCHAR(100) =
        (SELECT [Name]
         FROM dbo.Pet
         WHERE TUID = @PetID);

    DECLARE @NewWeight INT =
        (SELECT [Weight]
         FROM dbo.Pet
         WHERE TUID = @PetID);

    DECLARE @Modifier INT =
        (SELECT LastModifiedBy
         FROM dbo.Pet
         WHERE TUID = @PetID);

    EXEC tSQLt.AssertEquals 'Max', @NewName;
    EXEC tSQLt.AssertEquals 35, @NewWeight;
    EXEC tSQLt.AssertEquals @UserID, @Modifier;
END;
GO

/****** Object: Test StoredProcedure MedicalTests.[test spEditPrevention updates row correctly] ******/
/****** Created by Alyssa Lilly ******/
/****** Modified by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE MedicalTests.[test spEditPrevention updates row correctly]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.Pet';
    EXEC tSQLt.FakeTable 'dbo.Prevention';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@gmail.com', NULL, NULL);

    DECLARE @UserID INT = 1;

    -- Insert required pet
    INSERT INTO dbo.Pet
        (TUID, Animal, [Name], Sex, DateOfBirth, IsDateOfBirthKnown, [Weight],
         IntakeDate, Adopted, LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (2, 'Dog', 'Buddy', 'Male', '2020-01-01', 1, 30,
         '2020-02-01', 0, GETDATE(), GETDATE(), @UserID, @UserID);

    DECLARE @PetID INT = 2;

    -- Insert prevention row to edit
    INSERT INTO dbo.Prevention
        (TUID, [Type], Notes, PetID)
    VALUES
        (1, 'Flea', 'Initial', @PetID);

    DECLARE @PreventionID INT = 1;

    -- Act
    EXEC dbo.spEditPrevention
        @TUID = @PreventionID,
        @Type = 'Tick',
        @Notes = 'Updated notes',
        @DateGiven = '2026-02-01',
        @DateDue = '2027-02-01';

    -- Assert
    DECLARE @NewType VARCHAR(100) =
        (SELECT [Type]
         FROM dbo.Prevention
         WHERE TUID = @PreventionID);

    DECLARE @NewNotes VARCHAR(255) =
        (SELECT Notes
         FROM dbo.Prevention
         WHERE TUID = @PreventionID);

    EXEC tSQLt.AssertEquals 'Tick', @NewType;
    EXEC tSQLt.AssertEquals 'Updated notes', @NewNotes;
END;
GO

/****** Object: Test StoredProcedure RoleTests.[test spEditRole updates row correctly] ******/
/****** Created by Alyssa Lilly ******/
/****** Modified by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE RoleTests.[test spEditRole updates row correctly]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.[Role]';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@gmail.com', NULL, NULL);

    DECLARE @UserID INT = 1;

    -- Insert role row to edit
    INSERT INTO dbo.[Role]
        (TUID, RoleName, RoleColor, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy,
         PetManagement, AdopterManagement, FosterAndVolunteerManagement,
         ApplicationsAndVolunteerManagement, FinancialManagement, DocumentationAndMeetings)
    VALUES
        (1, 'OldRole', 'Red', GETDATE(), @UserID, GETDATE(), @UserID,
         'edit', 'edit', 'edit', 'edit', 'edit', 'edit');

    DECLARE @RoleID INT = 1;

    -- Act
    EXEC dbo.spEditRole
        @TUID = @RoleID,
        @RoleName = 'NewRole',
        @RoleColor = 'Blue',
        @LastModifiedBy = @UserID,
        @PetManagement = 'view',
        @AdopterManagement = 'view',
        @FosterAndVolunteerManagement = 'view',
        @ApplicationsAndVolunteerManagement = 'view',
        @FinancialManagement = 'view',
        @DocumentationAndMeetings = 'view';

    -- Assert
    DECLARE @NewName VARCHAR(100) =
        (SELECT RoleName
         FROM dbo.[Role]
         WHERE TUID = @RoleID);

    DECLARE @Modifier INT =
        (SELECT LastModifiedBy
         FROM dbo.[Role]
         WHERE TUID = @RoleID);

    EXEC tSQLt.AssertEquals 'NewRole', @NewName;
    EXEC tSQLt.AssertEquals @UserID, @Modifier;
END;
GO

/****** Object: Test StoredProcedure MedicalTests.[test spEditSurgery updates row correctly] ******/
/****** Created by Alyssa Lilly ******/
/****** Modified by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE MedicalTests.[test spEditSurgery updates row correctly]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.Pet';
    EXEC tSQLt.FakeTable 'dbo.Surgery';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@gmail.com', NULL, NULL);

    DECLARE @UserID INT = 1;

    -- Insert required pet
    INSERT INTO dbo.Pet
        (TUID, Animal, [Name], Sex, DateOfBirth, IsDateOfBirthKnown, [Weight],
         IntakeDate, Adopted, LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (2, 'Dog', 'Buddy', 'Male', '2020-01-01', 1, 30,
         '2020-02-01', 0, GETDATE(), GETDATE(), @UserID, @UserID);

    DECLARE @PetID INT = 2;

    -- Insert surgery row to edit
    INSERT INTO dbo.Surgery
        (TUID, [Name], [Description], [Date], PetID)
    VALUES
        (1, 'Neuter', 'Initial surgery', '2026-01-01', @PetID);

    DECLARE @SurgeryID INT = 1;

    -- Act
    EXEC dbo.spEditSurgery
        @TUID = @SurgeryID,
        @Name = 'Spay',
        @Description = 'Updated description',
        @Date = '2026-02-01';

    -- Assert
    DECLARE @NewName VARCHAR(100) =
        (SELECT [Name]
         FROM dbo.Surgery
         WHERE TUID = @SurgeryID);

    DECLARE @NewDescription VARCHAR(255) =
        (SELECT [Description]
         FROM dbo.Surgery
         WHERE TUID = @SurgeryID);

    EXEC tSQLt.AssertEquals 'Spay', @NewName;
    EXEC tSQLt.AssertEquals 'Updated description', @NewDescription;
END;
GO

/****** Object: Test StoredProcedure UserTests.[test spEditUser updates row correctly] ******/
/****** Created by Alyssa Lilly ******/
/****** Modified by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE [UserTests].[test spEditUser updates row correctly]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[Role]';
    EXEC tSQLt.FakeTable 'dbo.[User]';

    -- Insert supporting role
    INSERT INTO dbo.[Role]
        (TUID, RoleName, RoleColor, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy,
         PetManagement, AdopterManagement, FosterAndVolunteerManagement,
         ApplicationsAndVolunteerManagement, FinancialManagement, DocumentationAndMeetings)
    VALUES
        (1, 'Test Role', 'Red', GETDATE(), NULL, GETDATE(), NULL,
         'edit', 'edit', 'edit', 'edit', 'edit', 'edit');

    DECLARE @RoleID INT = 1;

    -- Insert user row to edit
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Old Name', 'olduser', 'pass', 'old@mail.com', 'Some notes', @RoleID);

    DECLARE @UserTUID INT = 1;

    -- Act
    EXEC dbo.spEditUser
        @TUID = @UserTUID,
        @UserName = 'newuser',
        @Password = 'newpass',
        @Email = 'new@mail.com',
        @Name = 'New Name',
        @Notes = 'updated notes';

    -- Assert
    DECLARE @UpdatedName VARCHAR(100) =
        (SELECT [Name]
         FROM dbo.[User]
         WHERE TUID = @UserTUID);

    EXEC tSQLt.AssertEqualsString 'New Name', @UpdatedName;
END;
GO

/****** Object: Test StoredProcedure MedicalTests.[test spEditVaccine updates row correctly] ******/
/****** Created by Alyssa Lilly ******/
/****** Modified by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE MedicalTests.[test spEditVaccine updates row correctly]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.Pet';
    EXEC tSQLt.FakeTable 'dbo.Vaccine';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@gmail.com', NULL, NULL);

    DECLARE @UserID INT = 1;

    -- Insert required pet
    INSERT INTO dbo.Pet
        (TUID, Animal, [Name], Sex, DateOfBirth, IsDateOfBirthKnown, [Weight],
         IntakeDate, Adopted, LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (2, 'Dog', 'Buddy', 'Male', '2020-01-01', 1, 30,
         '2020-02-01', 0, GETDATE(), GETDATE(), @UserID, @UserID);

    DECLARE @PetID INT = 2;

    -- Insert vaccine row to edit
    INSERT INTO dbo.Vaccine
        (TUID, [Type], Notes, PetID)
    VALUES
        (1, 'Rabies', 'Initial', @PetID);

    DECLARE @VaccineID INT = 1;

    -- Act
    EXEC dbo.spEditVaccine
        @TUID = @VaccineID,
        @Type = 'Distemper',
        @Notes = 'Updated notes',
        @DateGiven = '2026-02-01',
        @DateDue = '2027-02-01';

    -- Assert
    DECLARE @NewType VARCHAR(100) =
        (SELECT [Type]
         FROM dbo.Vaccine
         WHERE TUID = @VaccineID);

    DECLARE @NewNotes VARCHAR(255) =
        (SELECT Notes
         FROM dbo.Vaccine
         WHERE TUID = @VaccineID);

    EXEC tSQLt.AssertEquals 'Distemper', @NewType;
    EXEC tSQLt.AssertEquals 'Updated notes', @NewNotes;
END;
GO

/****** Object: Test StoredProcedure MedicalTests.[test spEditVetVisit updates row correctly] ******/
/****** Created by Alyssa Lilly ******/
/****** Modified by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE MedicalTests.[test spEditVetVisit updates row correctly]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.Pet';
    EXEC tSQLt.FakeTable 'dbo.VetVisit';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@gmail.com', NULL, NULL);

    DECLARE @UserID INT = 1;

    -- Insert required pet
    INSERT INTO dbo.Pet
        (TUID, Animal, [Name], Sex, DateOfBirth, IsDateOfBirthKnown, [Weight],
         IntakeDate, Adopted, LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (2, 'Dog', 'Buddy', 'Male', '2020-01-01', 1, 30,
         '2020-02-01', 0, GETDATE(), GETDATE(), @UserID, @UserID);

    DECLARE @PetID INT = 2;

    -- Insert vet visit row to edit
    INSERT INTO dbo.VetVisit
        (TUID, [Name], [Description], [Date], PetID)
    VALUES
        (1, 'Dr. Vet', 'Initial visit', '2026-02-01', @PetID);

    DECLARE @VisitID INT = 1;

    -- Act
    EXEC dbo.spEditVetVisit
        @TUID = @VisitID,
        @Name = 'Dr. Smith',
        @Description = 'Follow-up visit',
        @Date = '2026-02-01';

    -- Assert
    DECLARE @NewName VARCHAR(100) =
        (SELECT [Name]
         FROM dbo.VetVisit
         WHERE TUID = @VisitID);

    DECLARE @NewDescription VARCHAR(255) =
        (SELECT [Description]
         FROM dbo.VetVisit
         WHERE TUID = @VisitID);

    EXEC tSQLt.AssertEquals 'Dr. Smith', @NewName;
    EXEC tSQLt.AssertEquals 'Follow-up visit', @NewDescription;
END;
GO

/****** Object: Test StoredProcedure PersonTests.[test spEditPerson updates row correctly] ******/
/****** Created by Alyssa Lilly ******/
/****** Modified by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE PersonTests.[test spEditPerson updates row correctly]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.House';
    EXEC tSQLt.FakeTable 'dbo.Person';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@gmail.com', NULL, NULL);

    DECLARE @UserID INT = 1;

    -- Insert required house
    INSERT INTO dbo.House
        (TUID, [Address], City, [State], ZIP, PhoneNumber,
         LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (1, '789 Home St', 'City', 'ST', '12345', '555-7890',
         GETDATE(), GETDATE(), @UserID, @UserID);

    DECLARE @HouseID INT = 1;

    -- Insert person row to edit
    INSERT INTO dbo.Person
        (TUID, FirstName, LastName, Email, PhoneNumber, HouseID, IsVolunteer, Notes,
         LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (2, 'John', 'Doe', 'john@test.com', '555-0000', @HouseID, 0, 'Old notes',
         GETDATE(), GETDATE(), @UserID, @UserID);

    DECLARE @PersonID INT = 2;

    -- Act
    EXEC dbo.spEditPerson
        @PersonTUID = @PersonID,
        @FirstName = 'Jane',
        @LastName = 'Smith',
        @Email = 'jsmith@mail.com',
        @PhoneNumber = '555-1111',
        @HouseID = @HouseID,
        @IsVolunteer = 1,
        @Notes = 'Updated notes',
        @User = @UserID;

    -- Assert
    DECLARE @NewFirstName VARCHAR(100) =
        (SELECT FirstName
         FROM dbo.Person
         WHERE TUID = @PersonID);

    DECLARE @NewIsVolunteer BIT =
        (SELECT IsVolunteer
         FROM dbo.Person
         WHERE TUID = @PersonID);

    DECLARE @NewNotes VARCHAR(1000) =
        (SELECT Notes
         FROM dbo.Person
         WHERE TUID = @PersonID);

    DECLARE @Modifier INT =
        (SELECT LastModifiedBy
         FROM dbo.Person
         WHERE TUID = @PersonID);

    EXEC tSQLt.AssertEquals 'Jane', @NewFirstName;
    EXEC tSQLt.AssertEquals 1, @NewIsVolunteer;
    EXEC tSQLt.AssertEquals 'Updated notes', @NewNotes;
    EXEC tSQLt.AssertEquals @UserID, @Modifier;
END;
GO

/****** Object: Test StoredProcedure EventTests.[test spEditEvent updates row correctly] ******/
/****** Created by Alyssa Lilly ******/
/****** Modified by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE EventTests.[test spEditEvent updates row correctly]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.[Event]';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@gmail.com', NULL, NULL);

    DECLARE @UserID INT = 1;

    -- Insert event row to edit
    INSERT INTO dbo.[Event]
        (TUID, [Name], [Description], [Date], StartTime, EndTime, Recurring, DayPeriod,
         LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (1, 'Event1', 'Initial description', '2026-01-01', '09:00:00', '10:00:00', 0, 1,
         GETDATE(), GETDATE(), @UserID, @UserID);

    DECLARE @EventID INT = 1;

    -- Act
    EXEC dbo.spEditEvent
        @TUID = @EventID,
        @Name = 'UpdatedEvent',
        @Description = 'Updated description',
        @Date = '2026-02-01',
        @StartTime = '11:00:00',
        @EndTime = '12:00:00',
        @Recurring = 1,
        @DayPeriod = 7,
        @LastModifiedBy = @UserID;

    -- Assert
    DECLARE @NewName VARCHAR(100) =
        (SELECT [Name]
         FROM dbo.[Event]
         WHERE TUID = @EventID);

    DECLARE @NewDescription VARCHAR(1000) =
        (SELECT [Description]
         FROM dbo.[Event]
         WHERE TUID = @EventID);

    DECLARE @NewRecurring BIT =
        (SELECT Recurring
         FROM dbo.[Event]
         WHERE TUID = @EventID);

    DECLARE @Modifier INT =
        (SELECT LastModifiedBy
         FROM dbo.[Event]
         WHERE TUID = @EventID);

    EXEC tSQLt.AssertEquals 'UpdatedEvent', @NewName;
    EXEC tSQLt.AssertEquals 'Updated description', @NewDescription;
    EXEC tSQLt.AssertEquals 1, @NewRecurring;
    EXEC tSQLt.AssertEquals @UserID, @Modifier;
END;
GO


/****** Object: Test StoredProcedure HomeTests.[test spEditHome updates row correctly] ******/
/****** Modified by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE HomeTests.[test spEditHome updates row correctly]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.House';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@gmail.com', NULL, NULL);

    DECLARE @UserID INT = 1;

    -- Insert house row to edit
    INSERT INTO dbo.House
        (TUID, HouseName, [Address], City, [State], ZIP, PhoneNumber,
         RedFlag, RedFlagReason, CanFoster, NoFosterUntil, CanAdopt, NoAdoptUntil,
         Notes, IsIndividual, IsActive, HasFamily, HasKids, HasOtherPets,
         IsAdopter, IsFoster, LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (1, 'Old House', '123 Main St', 'City', 'ST', '12345', '555-1234',
         0, NULL, 1, NULL, 1, NULL,
         'Old notes', 1, 1, 0, 0, 0,
         1, 1, GETDATE(), GETDATE(), @UserID, @UserID);

    DECLARE @HouseID INT = 1;

    -- Act
    EXEC dbo.spEditHome
        @TUID = @HouseID,
        @HouseName = 'New House Name',
        @LastModifiedBy = @UserID,
        @Address = '456 Oak Ave',
        @City = 'New City',
        @State = 'NS',
        @Zip = '54321',
        @PhoneNumber = '555-0000',
        @RedFlag = 1,
        @RedFlagReason = 'Test red flag reason',
        @CanFoster = 0,
        @NoFosterUntil = '2026-12-31',
        @CanAdopter = 0,
        @NoAdopterUntil = '2027-01-31',
        @Notes = 'Updated notes',
        @IsIndividual = 1,
        @IsActive = 1,
        @HasFamily = 1,
        @HasKids = 1,
        @HasOtherPets = 1,
        @IsAdopter = 0,
        @IsFoster = 1;

    -- Assert
    DECLARE @UpdatedHouseName VARCHAR(200) =
        (SELECT HouseName
         FROM dbo.House
         WHERE TUID = @HouseID);

    DECLARE @UpdatedCity VARCHAR(200) =
        (SELECT City
         FROM dbo.House
         WHERE TUID = @HouseID);

    DECLARE @UpdatedCanAdopt BIT =
        (SELECT CanAdopt
         FROM dbo.House
         WHERE TUID = @HouseID);

    DECLARE @UpdatedCanFoster BIT =
        (SELECT CanFoster
         FROM dbo.House
         WHERE TUID = @HouseID);

    DECLARE @UpdatedModifier INT =
        (SELECT LastModifiedBy
         FROM dbo.House
         WHERE TUID = @HouseID);

    EXEC tSQLt.AssertEquals 'New House Name', @UpdatedHouseName;
    EXEC tSQLt.AssertEquals 'New City', @UpdatedCity;
    EXEC tSQLt.AssertEquals 0, @UpdatedCanAdopt;
    EXEC tSQLt.AssertEquals 0, @UpdatedCanFoster;
    EXEC tSQLt.AssertEquals @UserID, @UpdatedModifier;
END;
GO

/****** Object: Test StoredProcedure FolderAndFileTests.[test spEditFolder updates row correctly] ******/
/****** Modified by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE FolderAndFileTests.[test spEditFolder updates row correctly]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.Folder';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@gmail.com', NULL, NULL);

    DECLARE @UserID INT = 1;

    -- Insert folder row to edit
    INSERT INTO dbo.Folder
        (TUID, FolderName, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy)
    VALUES
        (1, 'OldFolder', GETDATE(), @UserID, GETDATE(), @UserID);

    DECLARE @FolderID INT = 1;

    -- Act
    EXEC dbo.spEditFolder
        @UserID = @UserID,
        @FolderTUID = @FolderID,
        @FolderName = 'NewFolder';

    -- Assert
    DECLARE @UpdatedFolderName VARCHAR(200) =
        (SELECT FolderName
         FROM dbo.Folder
         WHERE TUID = @FolderID);

    DECLARE @UpdatedModifier INT =
        (SELECT LastModifiedBy
         FROM dbo.Folder
         WHERE TUID = @FolderID);

    EXEC tSQLt.AssertEquals 'NewFolder', @UpdatedFolderName;
    EXEC tSQLt.AssertEquals @UserID, @UpdatedModifier;
END;
GO

/****** Object: Test StoredProcedure FolderAndFileTests.[test spEditFile updates row correctly] ******/
/****** Modified by Madison Koscielski 03/22/2026 ******/
CREATE PROCEDURE FolderAndFileTests.[test spEditFile updates row correctly]
AS
BEGIN
    -- Fake required tables
    EXEC tSQLt.FakeTable 'dbo.[User]';
    EXEC tSQLt.FakeTable 'dbo.Pet';
    EXEC tSQLt.FakeTable 'dbo.Folder';
    EXEC tSQLt.FakeTable 'dbo.[File]';

    -- Insert required user first
    INSERT INTO dbo.[User]
        (TUID, [Name], UserName, [Password], Email, Notes, RoleID)
    VALUES
        (1, 'Test User', 'testuser', 'password123', 'test@gmail.com', NULL, NULL);

    DECLARE @UserID INT = 1;

    -- Insert supporting pet
    INSERT INTO dbo.Pet
        (TUID, Animal, [Name], Sex, DateOfBirth, IsDateOfBirthKnown, [Weight],
         IntakeDate, Adopted, LastModifiedOn, CreatedOn, LastModifiedBy, CreatedBy)
    VALUES
        (2, 'Dog', 'Buddy', 'Male', '2020-01-01', 1, 30,
         '2020-02-01', 0, GETDATE(), GETDATE(), @UserID, @UserID);

    DECLARE @PetID INT = 2;

    -- Insert supporting folder
    INSERT INTO dbo.Folder
        (TUID, FolderName, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy)
    VALUES
        (3, 'TestFolder', GETDATE(), @UserID, GETDATE(), @UserID);

    DECLARE @FolderID INT = 3;

    -- Insert file row to edit
    INSERT INTO dbo.[File]
        (TUID, FileLocation, [FileName], IsReviewed, IsPolicyProcedure, PetID, FolderID,
         LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy)
    VALUES
        (1, 'C:\OldFiles\old.pdf', 'old.pdf', 0, 0, @PetID, @FolderID,
         GETDATE(), @UserID, GETDATE(), @UserID);

    DECLARE @FileID INT = 1;

    -- Act
    EXEC dbo.spEditFile
        @UserID = @UserID,
        @FileTUID = @FileID,
        @FileLocation = 'C:\NewFiles\updated.pdf',
        @FileName = 'updated.pdf',
        @IsReviewed = 1,
        @IsPolicyProcedure = 1,
        @PetID = @PetID,
        @FolderID = @FolderID;

    -- Assert
    DECLARE @UpdatedFileName VARCHAR(500) =
        (SELECT [FileName]
         FROM dbo.[File]
         WHERE TUID = @FileID);

    DECLARE @UpdatedFileLocation VARCHAR(1000) =
        (SELECT FileLocation
         FROM dbo.[File]
         WHERE TUID = @FileID);

    DECLARE @UpdatedIsReviewed BIT =
        (SELECT IsReviewed
         FROM dbo.[File]
         WHERE TUID = @FileID);

    DECLARE @UpdatedModifier INT =
        (SELECT LastModifiedBy
         FROM dbo.[File]
         WHERE TUID = @FileID);

    EXEC tSQLt.AssertEquals 'updated.pdf', @UpdatedFileName;
    EXEC tSQLt.AssertEquals 'C:\NewFiles\updated.pdf', @UpdatedFileLocation;
    EXEC tSQLt.AssertEquals 1, @UpdatedIsReviewed;
    EXEC tSQLt.AssertEquals @UserID, @UpdatedModifier;
END;
GO







