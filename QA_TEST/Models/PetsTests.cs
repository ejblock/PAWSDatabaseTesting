using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using PAWS.WinForms.Models.Pet;

namespace QA_TEST.Models
{

    // FILENAME: PetsTests.cs
    //
    // WRITTEN BY: Max Yaw
    // DATE CREATED: February 5 2026
    //
    // PART OF PROJECT: PAWS.WinForms (QA Testing)
    //
    // FILE PURPOSE:
    // This file contains unit tests to ensure that the constructor correctly
    // assigns all properties and that data types are handled as expected.
    //
    // COMPILATION NOTES:
    // This file compiles normally under Microsoft Visual Studio using
    // the .NET Windows Forms framework. No special compiler options
    // or optimizations are required.
    //
    // LIBRARIES AND 3RD PARTY DEPENDENCIES:
    // Microsoft .NET
    // Microsoft.VisualStudio.TestTools.UnitTesting(MSTest)
    //
    // COMMAND LINE PARAMETER LIST (in Parameter Order):
    // (None)
    //
    // ENVIRONMENTAL RETURNS:
    // (Nothing)
    //
    // GLOBAL VARIABLE LIST (Alphabetically):
    // (None)
    //
    // MODIFICATION HISTORY:
    // WHO            WHEN            WHAT
    // ---            ----            ----------------------------------------

    [TestClass]
    public class PetsTests
    {
        // METHOD NAME: TestPetObject
        //
        // METHOD PURPOSE:
        // This unit test verifies the functionality of the Pet class constructor.
        // It creates a set of test data, instantiates a Pet object, and then
        // asserts that every public property of the object matches the original test data provided.
        //
        // PARAMETERS LIST (in Parameter Order):
        // (None)
        //
        // RETURNS:
        // (Void)
        //
        // LOCAL VARIABLE DICTIONARY:
        // pet                  - The Pet object instance being tested
        // testAdopted          - Boolean indicating adoption status
        // testAge              - Integer representing the pet's age
        // testAnimal           - String for the type of animal
        // testBreed            - String for the breed of the animal
        // testCharacteristics  - String describing the animal's traits
        // testCreatedBy        - Guid of the user who created the record
        // testCreatedOn        - DateOnly when the record was created
        // testCurrOwnerID      - Guid of the current owner
        // testIntake           - DateOnly of the intake date
        // testLastModified     - DateOnly of the last modification
        // testMicrochip        - String containing the microchip ID
        // testModifiedBy       - Guid of the user who modified the record
        // testName             - String for the pet's name
        // testNotes            - String for additional notes
        // testOrigin           - String for the origin of the pet
        // testPhotoLocation    - String path to the pet's photo
        // testPrevOwnerID      - Guid of the previous owner
        // testSex              - Boolean representing sex (True=Male)
        // testTuid             - Guid representing the unique ID (TUID)
        // testWeight           - Integer representing the pet's weight
        //
        // MODIFICATION HISTORY:
        // WHO            WHEN            WHAT
        // ---            ----            ----------------------------------------        //
        //
        //         [TestMethod]
        //         public void TestPetObject()
        //         {
        //
        //             // Create test data
        //             Guid testTuid = Guid.NewGuid();
        //             string testName = "Fetch";
        //             string testBreed = "Lab";
        //             int testAge = 5;
        //             DateOnly testIntake = new DateOnly(2026, 1, 15);
        //             string testAnimal = "Dog";
        //             bool testSex = true; // male
        //             string testOrigin = "Rescue";
        //             string testCharacteristics = "Friendly";
        //             int testWeight = 50;
        //             string testNotes = "Good with kids";
        //             string testMicrochip = "123456789012345";
        //             bool testAdopted = false;
        //             Guid testPrevOwnerID = Guid.NewGuid();
        //             Guid testCurrOwnerID = Guid.NewGuid();
        //             string testPhotoLocation = "path/to/photo";
        //             DateOnly testLastModified = new DateOnly(2026, 1, 15);
        //             Guid testModifiedBy = Guid.NewGuid();
        //             DateOnly testCreatedOn = new DateOnly(2026, 1, 15);
        //             Guid testCreatedBy = Guid.NewGuid();
        //
        //             // Instantiate Pet object to test
        //             Pet pet = new Pet(testTuid, testAnimal, testBreed, testName, testSex, testOrigin, testAge, 
        //                 testCharacteristics, testWeight, testIntake, testNotes, testMicrochip, testAdopted, testPrevOwnerID, 
        //                 testCurrOwnerID, testPhotoLocation, testLastModified, testModifiedBy, testCreatedOn, testCreatedBy);
        //
        //             // Verify all properties return the exact value assigned in the constructor
        //             Assert.AreEqual(testTuid, pet.TUID);
        //             Assert.AreEqual(testAnimal, pet.Animal);
        //             Assert.AreEqual(testBreed, pet.Breed);
        //             Assert.AreEqual(testName, pet.Name);
        //             Assert.AreEqual(testSex, pet.Sex);
        //             Assert.AreEqual(testOrigin, pet.Origin);
        //             Assert.AreEqual(testAge, pet.Age);
        //             Assert.AreEqual(testCharacteristics, pet.Characteristics);
        //             Assert.AreEqual(testWeight, pet.Weight);
        //             Assert.AreEqual(testIntake, pet.IntakeDate);
        //             Assert.AreEqual(testNotes, pet.Notes);
        //             Assert.AreEqual(testMicrochip, pet.Microchip);
        //             Assert.AreEqual(testAdopted, pet.Adopted);
        //             Assert.AreEqual(testPrevOwnerID, pet.PrevOwnerID);
        //             Assert.AreEqual(testCurrOwnerID, pet.CurrOwnerID);
        //             Assert.AreEqual(testPhotoLocation, pet.PhotoLocation);
        //             Assert.AreEqual(testLastModified, pet.LastModified);
        //             Assert.AreEqual(testModifiedBy, pet.ModifiedBy);
        //             Assert.AreEqual(testCreatedOn, pet.CreatedOn);
        //             Assert.AreEqual(testCreatedBy, pet.CreatedBy);
        //         }

        // METHOD NAME: TestPetSetters
        //
        // METHOD PURPOSE:
        // This unit test verifies that all properties of the Pet class can be modified
        // via their setters. It creates a Pet object, then assigns new values to all
        // of its properties using the corresponding setter methods. Finally, it checks
        // that each property was updated correctly.
        //
        // PARAMETERS LIST (in Parameter Order):
        // (None)
        //
        // RETURNS:
        // (Void)
        //
        // LOCAL VARIABLE DICTIONARY:
        // pet                  - The Pet object instance being tested
        // initialAdopted       - Initial boolean indicating adoption status
        // initialAge           - Initial integer representing the pet's age
        // initialAnimal        - Initial string for the type of animal
        // initialBreed         - Initial string for the breed of the animal
        // initialCharacteristics - Initial string describing the animal's traits
        // initialCreatedBy     - Initial Guid of the user who created the record
        // initialCreatedOn     - Initial DateOnly when the record was created
        // initialCurrOwnerID   - Initial Guid of the current owner
        // initialIntake        - Initial DateOnly of the intake date
        // initialLastModified  - Initial DateOnly of the last modification
        // initialMicrochip     - Initial string containing the microchip ID
        // initialModifiedBy    - Initial Guid of the user who modified the record
        // initialName          - Initial string for the pet's name
        // initialNotes         - Initial string for additional notes
        // initialOrigin        - Initial string for the origin of the pet
        // initialPhotoLocation - Initial string path to the pet's photo
        // initialPrevOwnerID   - Initial Guid of the previous owner
        // initialSex           - Initial boolean representing sex (True=Male)
        // initialTuid          - Initial Guid representing the unique ID (TUID)
        // initialWeight        - Initial integer representing the pet's weight
        // newAdopted           - New boolean indicating adoption status
        // newAge               - New integer representing the pet's age
        // newAnimal            - New string for the type of animal
        // newBreed             - New string for the breed of the animal
        // newCharacteristics   - New string describing the animal's traits
        // newCreatedBy         - New Guid of the user who created the record
        // newCreatedOn         - New DateOnly when the record was created
        // newCurrOwnerID       - New Guid of the current owner
        // newIntake            - New DateOnly of the intake date
        // newLastModified      - New DateOnly of the last modification
        // newMicrochip         - New string containing the microchip ID
        // newModifiedBy        - New Guid of the user who modified the record
        // newName              - New string for the pet's name
        // newNotes             - New string for additional notes
        // newOrigin            - New string for the origin of the pet
        // newPhotoLocation     - New string path to the pet's photo
        // newPrevOwnerID       - New Guid of the previous owner
        // newSex               - New boolean representing sex (True=Male)
        // newTuid              - New Guid representing the unique ID (TUID)
        // newWeight            - New integer representing the pet's weight
        //
        // MODIFICATION HISTORY:
        // WHO            WHEN            WHAT
        // ---            ----            ----------------------------------------        //
        //
        //         [TestMethod]
        //         public void TestPetSetters()
        //         {
        //             // Initial test data
        //             Guid initialTuid = Guid.NewGuid();
        //             string initialName = "Fetch";
        //             string initialBreed = "Lab";
        //             int initialAge = 5;
        //             DateOnly initialIntake = new DateOnly(2026, 1, 15);
        //             string initialAnimal = "Dog";
        //             bool initialSex = true;
        //             string initialOrigin = "Rescue";
        //             string initialCharacteristics = "Friendly";
        //             int initialWeight = 50;
        //             string initialNotes = "Good with kids";
        //             string initialMicrochip = "123456789012345";
        //             bool initialAdopted = false;
        //             Guid initialPrevOwnerID = Guid.NewGuid();
        //             Guid initialCurrOwnerID = Guid.NewGuid();
        //             string initialPhotoLocation = "path/to/photo";
        //             DateOnly initialLastModified = new DateOnly(2026, 1, 15);
        //             Guid initialModifiedBy = Guid.NewGuid();
        //             DateOnly initialCreatedOn = new DateOnly(2026, 1, 15);
        //             Guid initialCreatedBy = Guid.NewGuid();
        //
        //             Pet pet = new Pet(initialTuid, initialAnimal, initialBreed, initialName, initialSex, initialOrigin, initialAge, 
        //                 initialCharacteristics, initialWeight, initialIntake, initialNotes, initialMicrochip, initialAdopted, initialPrevOwnerID, 
        //                 initialCurrOwnerID, initialPhotoLocation, initialLastModified, initialModifiedBy, initialCreatedOn, initialCreatedBy);
        //
        //             // New test data for setters
        //             Guid newTuid = Guid.NewGuid();
        //             string newName = "Buddy";
        //             string newBreed = "Golden Retriever";
        //             int newAge = 3;
        //             DateOnly newIntake = new DateOnly(2026, 2, 20);
        //             string newAnimal = "Dog";
        //             bool newSex = false;
        //             string newOrigin = "Breeder";
        //             string newCharacteristics = "Playful";
        //             int newWeight = 60;
        //             string newNotes = "Loves walks";
        //             string newMicrochip = "987654321098765";
        //             bool newAdopted = true;
        //             Guid newPrevOwnerID = Guid.NewGuid();
        //             Guid newCurrOwnerID = Guid.NewGuid();
        //             string newPhotoLocation = "new/path/to/photo";
        //             DateOnly newLastModified = new DateOnly(2026, 2, 20);
        //             Guid newModifiedBy = Guid.NewGuid();
        //             DateOnly newCreatedOn = new DateOnly(2026, 2, 20);
        //             Guid newCreatedBy = Guid.NewGuid();
        //
        //             // Set new values
        //             pet.TUID = newTuid;
        //             pet.Animal = newAnimal;
        //             pet.Breed = newBreed;
        //             pet.Name = newName;
        //             pet.Sex = newSex;
        //             pet.Origin = newOrigin;
        //             pet.Age = newAge;
        //             pet.Characteristics = newCharacteristics;
        //             pet.Weight = newWeight;
        //             pet.IntakeDate = newIntake;
        //             pet.Notes = newNotes;
        //             pet.Microchip = newMicrochip;
        //             pet.Adopted = newAdopted;
        //             pet.PrevOwnerID = newPrevOwnerID;
        //             pet.CurrOwnerID = newCurrOwnerID;
        //             pet.PhotoLocation = newPhotoLocation;
        //             pet.LastModified = newLastModified;
        //             pet.ModifiedBy = newModifiedBy;
        //             pet.CreatedOn = newCreatedOn;
        //             pet.CreatedBy = newCreatedBy;
        //
        //             // Assert all properties are updated to the new values
        //             Assert.AreEqual(newTuid, pet.TUID);
        //             Assert.AreEqual(newAnimal, pet.Animal);
        //             Assert.AreEqual(newBreed, pet.Breed);
        //             Assert.AreEqual(newName, pet.Name);
        //             Assert.AreEqual(newSex, pet.Sex);
        //             Assert.AreEqual(newOrigin, pet.Origin);
        //             Assert.AreEqual(newAge, pet.Age);
        //             Assert.AreEqual(newCharacteristics, pet.Characteristics);
        //             Assert.AreEqual(newWeight, pet.Weight);
        //             Assert.AreEqual(newIntake, pet.IntakeDate);
        //             Assert.AreEqual(newNotes, pet.Notes);
        //             Assert.AreEqual(newMicrochip, pet.Microchip);
        //             Assert.AreEqual(newAdopted, pet.Adopted);
        //             Assert.AreEqual(newPrevOwnerID, pet.PrevOwnerID);
        //             Assert.AreEqual(newCurrOwnerID, pet.CurrOwnerID);
        //             Assert.AreEqual(newPhotoLocation, pet.PhotoLocation);
        //             Assert.AreEqual(newLastModified, pet.LastModified);
        //             Assert.AreEqual(newModifiedBy, pet.ModifiedBy);
        //             Assert.AreEqual(newCreatedOn, pet.CreatedOn);
        //             Assert.AreEqual(newCreatedBy, pet.CreatedBy);
        //         }
    }
}
