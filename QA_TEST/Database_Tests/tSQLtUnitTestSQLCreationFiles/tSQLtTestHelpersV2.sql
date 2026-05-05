USE [MidlandPitStopDatabase];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'TestHelpers')
    EXEC tSQLt.NewTestClass 'TestHelpers';
GO

/**********************************************************************************************
 Helper: Fake all commonly used tables
 Purpose: Use only when a test genuinely needs the full fake schema.
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[FakeAllTestTables]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo', 'User', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Role', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'House', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Person', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Pet', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'PetFoster', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Vaccine', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Prevention', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Surgery', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'VetVisit', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Event', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'RelationshipPersonEvent', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Revenue', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Expense', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'Folder', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'File', @identity = 1;
    EXEC tSQLt.FakeTable 'dbo', 'PetAdoption', @identity = 1;
END;
GO

/**********************************************************************************************
 Helper: Insert Users
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestUsers]
AS
BEGIN
    INSERT INTO [dbo].[User] (Name, UserName, [Password], Email, Notes, RoleID)
    VALUES
        ('Gwen',  'admin',     'password123', 'admin@pets.org',     'Runs Midland Pit Stop', NULL),
        ('Cindy', 'treasurer', 'Ilovedogs',   'treasurer@pets.org', 'Handles financials',    NULL),
        ('Mark',  'secretary', '67',          'secretary@pets.org', 'Handles general inquiries', NULL);
END;
GO

/**********************************************************************************************
 Helper: Insert Roles
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestRoles]
AS
BEGIN
    INSERT INTO [dbo].[Role]
    (
        RoleName, RoleColor, LastModifiedOn, LastModifiedBy,
        CreatedOn, CreatedBy,
        PetManagement, AdopterManagement,
        FosterAndVolunteerManagement, ApplicationsAndVolunteerManagement,
        FinancialManagement, DocumentationAndMeetings
    )
    VALUES
        ('Administrator', 'Blue',
         GETDATE(), 1,
         GETDATE(), 1,
         'Edit', 'Edit',
         'Edit', 'Edit',
         'Edit', 'Edit'),

        ('Treasurer', 'Red',
         GETDATE(), 3,
         GETDATE(), 1,
         'No Access', 'No Access',
         'View', 'View',
         'Edit', 'View'),

        ('Secretary', 'Purple',
         GETDATE(), 1,
         GETDATE(), 2,
         'View', 'View',
         'View', 'View',
         'Edit', 'Edit');
END;
GO

/**********************************************************************************************
 Helper: Link Users to Roles
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[UpdateTestUserRoles]
AS
BEGIN
    UPDATE [dbo].[User]
    SET RoleID = 1
    WHERE TUID = 1;
END;
GO

/**********************************************************************************************
 Helper: Insert Houses
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestHouses]
AS
BEGIN
    INSERT INTO [dbo].[House]
    (
        [HouseName], [Address], City, [State], ZIP, PhoneNumber,
        RedFlag, CanFoster, CanAdopt,
        IsAdopter, IsFoster, IsActive,
        IsIndividual, HasFamily, HasKids, HasOtherPets,
        LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy
    )
    VALUES
        ('Downtown Midland house', '123 Main St', 'Midland', 'MI', '48640', '989-555-1234',
         0, 1, 0,
         1, 0, 0,
         1, 1, 1, 1,
         GETDATE(), 1, GETDATE(), 1),

        ('Downtown Brighton house', '800 Dunham Rd', 'Brighton', 'MI', '48114', '989-748-7832',
         0, 1, 1,
         1, 1, 1,
         1, 1, 0, 1,
         GETDATE(), 3, GETDATE(), 2),

        ('Downtown Saginaw house', '7778 Gratiot Rd', 'Saginaw', 'MI', '48609', '989-789-4567',
         0, 1, 1,
         1, 1, 1,
         1, 1, 0, 1,
         GETDATE(), 1, GETDATE(), 3);
END;
GO

/**********************************************************************************************
 Helper: Insert People
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestPeople]
AS
BEGIN
    INSERT INTO [dbo].[Person]
    (
        FirstName, LastName, Email, PhoneNumber,
        HouseID, IsVolunteer, Notes,
        LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy
    )
    VALUES
        ('Jane', 'Doe', 'janedoe@example.com', '989-555-9876',
         2, 0, 'Takes lots of cats',
         GETDATE(), 1, GETDATE(), 2),

        ('John', 'Doe', 'johndoe@example.com', '810-555-9876',
         1, 1, 'Very helpful, #1 guy',
         '2026-01-16', 2, '2026-01-01', 3),

        ('Mike', 'Bob', 'mikebob@example.com', '313-698-9646',
         3, 1, 'Weekend volunteer',
         '2026-01-16', 1, '2026-01-01', 3);
END;
GO

/**********************************************************************************************
 Helper: Insert Pets
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestPets]
AS
BEGIN
    INSERT INTO [dbo].[Pet]
    (
        Animal, Breed, Name, Sex, Origin, DateOfBirth,
        IsDateOfBirthKnown, Characteristics, Weight,
        IntakeDate, Notes, Microchip, Adopted, PhotoLocation,
        LastModifiedOn, CreatedOn,
        PreviousHomeID, CurrentHomeID,
        LastModifiedBy, CreatedBy
    )
    VALUES
        ('Dog', 'Labrador', 'Buddy', 'Male', 'Shelter', '2024-03-08', 1,
         'Friendly, Leash Trained', 80, '2026-01-04', 'Healthy',
         '965000000123456', 1, '/photos/buddy.jpg',
         GETDATE(), '2026-01-09',
         1, NULL,
         1, 1),

        ('Cat', 'Siamese', 'Taco', 'Female', 'Georgia St', '2026-01-01', 0,
         'Shy, Good with Kids', 5, '2026-01-29', 'Very shy',
         '931000000157893', 0, '/photos/taco.jpg',
         GETDATE(), GETDATE(),
         NULL, NULL,
         3, 3),

        ('Dog', 'Golden Retriever', 'Scooby', 'Male', 'Shelter', '2020-07-18', 1,
         'Friendly, Potty Trained, Dewormed', 67, '2025-12-15', 'Enjoys being outside',
         '901000000789456', 0, '/photos/scooby.jpg',
         GETDATE(), GETDATE(),
         NULL, NULL,
         1, 1);
END;
GO

/**********************************************************************************************
 Helper: Insert Pet Foster records
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestPetFosters]
AS
BEGIN
    INSERT INTO [dbo].[PetFoster]
    (
        PetID, FosterStartDate, [Status],
        LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy
    )
    VALUES
        (3, '2025-12-25', 1, GETDATE(), 1, '2025-12-25', 1),
        (1, '2025-08-09', 0, GETDATE(), 1, '2025-08-09', 1);
END;
GO

/**********************************************************************************************
 Helper: Insert Vaccines
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestVaccines]
AS
BEGIN
    INSERT INTO [dbo].[Vaccine] ([Type], Notes, DateGiven, DateDue, PetID)
    VALUES
        ('Rabies', 'Initial dose', NULL, '2026-08-03', 2),
        ('Hepatitis', 'Complete', GETDATE(), NULL, 3);
END;
GO

/**********************************************************************************************
 Helper: Insert Preventatives
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestPreventions]
AS
BEGIN
    INSERT INTO [dbo].[Prevention] ([Type], Notes, DateGiven, DateDue, PetID)
    VALUES
        ('Heartworm', 'Monthly', GETDATE(), DATEADD(MONTH, 1, GETDATE()), 2),
        ('Tick', 'Monthly', GETDATE(), DATEADD(MONTH, 1, GETDATE()), 3);
END;
GO

/**********************************************************************************************
 Helper: Insert Surgeries
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestSurgeries]
AS
BEGIN
    INSERT INTO [dbo].[Surgery] ([Name], [Description], [Date], PetID)
    VALUES
        ('Neutering', 'Routine neuter surgery', '2025-04-03', 1),
        ('Neutering', 'Routine neuter surgery', GETDATE(), 3);
END;
GO

/**********************************************************************************************
 Helper: Insert Vet Visits
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestVetVisits]
AS
BEGIN
    INSERT INTO [dbo].[VetVisit] ([Name], [Description], [Date], PetID)
    VALUES
        ('Annual Checkup', 'Routine exam', '2025-04-23', 1),
        ('Annual Checkup', 'Routine exam', '2026-08-02', 2),
        ('Stomach Problems', 'Bowel exam', GETDATE(), 3);
END;
GO

/**********************************************************************************************
 Helper: Insert Events
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestEvents]
AS
BEGIN
    INSERT INTO [dbo].[Event]
    (
        [Name], [Description], [Date],
        Recurring, DayPeriod,
        LastModifiedOn, CreatedOn,
        LastModifiedBy, CreatedBy
    )
    VALUES
        ('Adoption Fair', 'Local pet adoption event',
         '2026-01-14', 1, 30,
         GETDATE(), GETDATE(),
         1, 1),

        ('Meet and Greet', 'Meet your favorite paw friends',
         GETDATE(), 0, NULL,
         GETDATE(), GETDATE(),
         3, 3);
END;
GO

/**********************************************************************************************
 Helper: Insert Person/Event relationships
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestRelationshipPersonEvent]
AS
BEGIN
    INSERT INTO [dbo].[RelationshipPersonEvent] (PersonID, EventID)
    VALUES (1, 1), (3, 1), (2, 2);
END;
GO

/**********************************************************************************************
 Helper: Insert Revenue
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestRevenue]
AS
BEGIN
    INSERT INTO [dbo].[Revenue]
    (
        [Date], Category, Description, Amount,
        PayMethod, Person,
        LastModifiedOn, CreatedOn,
        LastModifiedBy, CreatedBy
    )
    VALUES
        (GETDATE(), 'Donation', 'General donation', 2000.00,
         'Cash', 'Joe Flacco',
         GETDATE(), GETDATE(),
         1, 3),

        ('2026-01-08', 'Adopted Pet Fee', 'Buddy', 4.00,
         'Venmo', 'Patrick Mahomes',
         GETDATE(), GETDATE(),
         1, 1);
END;
GO

/**********************************************************************************************
 Helper: Insert Expenses
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestExpenses]
AS
BEGIN
    INSERT INTO [dbo].[Expense]
    (
        [Date], Category, Description, Amount,
        PayMethod, Vendor,
        LastModifiedOn, CreatedOn,
        LastModifiedBy, CreatedBy
    )
    VALUES
        ('2025-08-19', 'Medical', 'Neutered', 120.50,
         'Credit Card', 'Happy Paws Vet',
         GETDATE(), GETDATE(),
         1, 3),

        (GETDATE(), 'Event', 'Meet and Greet', 906.67,
         'Check', 'Meijer',
         GETDATE(), GETDATE(),
         2, 2);
END;
GO

/**********************************************************************************************
 Helper: Insert top-level folders
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertBaseFolders]
AS
BEGIN
    INSERT INTO [dbo].[Folder]
    (
        FolderName,
        LastModifiedOn, LastModifiedBy,
        CreatedOn, CreatedBy
    )
    VALUES
        ('/Medical Records', GETDATE(), 1, '2025-04-30', 3),
        ('/Adoption Documents', GETDATE(), 2, '2025-04-01', 2),
        ('/Foster Agreements', GETDATE(), 1, '2025-07-01', 1);
END;
GO

/**********************************************************************************************
 Helper: Insert top-level files
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertBaseFiles]
AS
BEGIN
    INSERT INTO [dbo].[File]
    (
        FileLocation,
        [FileName],
        IsReviewed,
        IsPolicyProcedure,
        PetID,
        FolderID,
        LastModifiedOn, LastModifiedBy,
        CreatedOn, CreatedBy
    )
    VALUES
        ('medical/rabies.pdf', 'rabies.pdf', 1, 0, 1, 1, GETDATE(), 1, GETDATE(), 1),
        ('adoption/application.pdf', 'application.pdf', 0, 1, 2, 2, GETDATE(), 1, GETDATE(), 3),
        ('foster/contract.pdf', 'contract.pdf', 1, 0, 3, 3, GETDATE(), 2, GETDATE(), 1);
END;
GO

/**********************************************************************************************
 Helper: Insert Pet Adoptions
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestPetAdoptions]
AS
BEGIN
    INSERT INTO [dbo].[PetAdoption]
    (
        AdoptionStatus,
        PetID,
        AdoptionStartDate,
        AdoptionEndDate,
        LastModifiedOn,
        LastModifiedBy
    )
    VALUES
        (0, 1, '2024-02-01', GETDATE(), GETDATE(), 1),
        (0, 2, GETDATE(), NULL, GETDATE(), 3);
END;
GO

/**********************************************************************************************
 Helper: Insert nested folder structure
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertNestedFolders]
AS
BEGIN
    INSERT INTO [dbo].[Folder] (FolderName, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy)
    VALUES
        ('/Medical Records/Vaccinations', GETDATE(), 1, GETDATE(), 1), -- TUID 4
        ('/Medical Records/Surgery', GETDATE(), 2, GETDATE(), 2),      -- TUID 5
        ('/Medical Records/Vaccinations/2024', GETDATE(), 1, GETDATE(), 1), -- TUID 6
        ('/Adoption Documents/Pending', GETDATE(), 2, GETDATE(), 2),   -- TUID 7
        ('/Adoption Documents/Completed', GETDATE(), 1, GETDATE(), 1), -- TUID 8
        ('/Foster Agreements/2024', GETDATE(), 2, GETDATE(), 2);       -- TUID 9
END;
GO

/**********************************************************************************************
 Helper: Insert nested folder files
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertNestedFiles]
AS
BEGIN
    INSERT INTO [dbo].[File]
    (FileLocation, FileName, IsReviewed, IsPolicyProcedure, PetID, FolderID, LastModifiedOn, LastModifiedBy, CreatedOn, CreatedBy)
    VALUES
        ('/Medical Records/general_health.pdf', 'General Health Report', 1, 0, NULL, 1, GETDATE(), 1, GETDATE(), 1),
        ('/Medical Records/vet_notes.pdf', 'Vet Notes', 0, 0, NULL, 1, GETDATE(), 2, GETDATE(), 2),

        ('/Medical Records/Vaccinations/rabies.pdf', 'Rabies Vaccine', 1, 0, NULL, 4, GETDATE(), 1, GETDATE(), 1),
        ('/Medical Records/Vaccinations/distemper.pdf', 'Distemper Vaccine', 1, 0, NULL, 4, GETDATE(), 2, GETDATE(), 2),

        ('/Medical Records/Vaccinations/2024/annual_shots.pdf', 'Annual Shots 2024', 0, 0, NULL, 6, GETDATE(), 1, GETDATE(), 1),

        ('/Medical Records/Surgery/spay_neuter.pdf', 'Spay/Neuter Record', 1, 0, NULL, 5, GETDATE(), 2, GETDATE(), 2),

        ('/Adoption Documents/adoption_policy.pdf', 'Adoption Policy', 1, 1, NULL, 2, GETDATE(), 1, GETDATE(), 1),

        ('/Adoption Documents/Pending/application_john.pdf', 'John Doe Application', 0, 0, NULL, 7, GETDATE(), 2, GETDATE(), 2),
        ('/Adoption Documents/Pending/application_jane.pdf', 'Jane Smith Application', 0, 0, NULL, 7, GETDATE(), 1, GETDATE(), 1),

        ('/Adoption Documents/Completed/adopted_buddy.pdf', 'Buddy Adoption Contract', 1, 0, NULL, 8, GETDATE(), 2, GETDATE(), 2),

        ('/Foster Agreements/foster_policy.pdf', 'Foster Policy', 1, 1, NULL, 3, GETDATE(), 1, GETDATE(), 1),

        ('/Foster Agreements/2024/foster_agreement_smith.pdf', 'Smith Foster Agreement', 1, 0, NULL, 9, GETDATE(), 2, GETDATE(), 2),
        ('/Foster Agreements/2024/foster_agreement_jones.pdf', 'Jones Foster Agreement', 0, 0, NULL, 9, GETDATE(), 1, GETDATE(), 1);
END;
GO

/**********************************************************************************************
 Wrapper: Insert all test data
 Purpose: Keeps your old pattern available, but now it is built from smaller helpers.
**********************************************************************************************/
CREATE OR ALTER PROCEDURE [TestHelpers].[InsertTestData]
AS
BEGIN
    EXEC [TestHelpers].[FakeAllTestTables];

    EXEC [TestHelpers].[InsertTestUsers];
    EXEC [TestHelpers].[InsertTestRoles];
    EXEC [TestHelpers].[UpdateTestUserRoles];

    EXEC [TestHelpers].[InsertTestHouses];
    EXEC [TestHelpers].[InsertTestPeople];

    EXEC [TestHelpers].[InsertTestPets];
    EXEC [TestHelpers].[InsertTestPetFosters];
    EXEC [TestHelpers].[InsertTestVaccines];
    EXEC [TestHelpers].[InsertTestPreventions];
    EXEC [TestHelpers].[InsertTestSurgeries];
    EXEC [TestHelpers].[InsertTestVetVisits];

    EXEC [TestHelpers].[InsertTestEvents];
    EXEC [TestHelpers].[InsertTestRelationshipPersonEvent];

    EXEC [TestHelpers].[InsertTestRevenue];
    EXEC [TestHelpers].[InsertTestExpenses];

    EXEC [TestHelpers].[InsertBaseFolders];
    EXEC [TestHelpers].[InsertBaseFiles];
    EXEC [TestHelpers].[InsertTestPetAdoptions];
    EXEC [TestHelpers].[InsertNestedFolders];
    EXEC [TestHelpers].[InsertNestedFiles];
END;
GO