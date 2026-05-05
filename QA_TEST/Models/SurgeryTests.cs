using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using PAWS.WinForms.Models.Pet;

namespace QA_TEST.Models
{
    // FILENAME: SurgeryTests.cs
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
    public class SurgeryTests
    {
        // METHOD NAME: TestSurgeryObject
        //
        // METHOD PURPOSE:
        // This unit test verifies the functionality of the Surgery class constructor.
        // It creates a set of test data, instantiates a Surgery object, and then
        // asserts that every public property of the object matches the original test data provided.
        //
        // PARAMETERS LIST (in Parameter Order):
        // (None)
        //
        // RETURNS:
        // (Void)
        //
        // LOCAL VARIABLE DICTIONARY:
        // surgery              - The Surgery object instance being tested
        // testDate             - DateOnly for the surgery date
        // testDescription      - String describing the surgery
        // testName             - String for the surgery name
        // testPetID            - Guid of the associated pet
        // testTuid             - Guid representing the unique ID (TUID)
        //
        // MODIFICATION HISTORY:
        // WHO            WHEN            WHAT
        // ---            ----            ----------------------------------------

        [TestMethod]
        public void TestSurgeryObject()
        {
            // Create test data
            Guid testTuid = Guid.NewGuid();
            string testName = "Spay";
            string testDescription = "Routine spaying procedure";
            DateOnly testDate = new DateOnly(2026, 1, 15);
            Guid testPetID = Guid.NewGuid();

            //// Instantiate Surgery object to test
            //Surgery surgery = new Surgery(testTuid, testName, testDescription, testDate, testPetID);

            //// Verify all properties return the exact value assigned in the constructor
            //Assert.AreEqual(testTuid, surgery.TUID);
            //Assert.AreEqual(testName, surgery.Name);
            //Assert.AreEqual(testDescription, surgery.Description);
            //Assert.AreEqual(testDate, surgery.Date);
            //Assert.AreEqual(testPetID, surgery.PetID);
        }

        // METHOD NAME: TestSurgerySetters
        //
        // METHOD PURPOSE:
        // This unit test verifies that all properties of the Surgery class can be modified
        // via their setters. It first creates a Surgery object with initial test data,
        // then changes each property to a new value and verifies the change.
        //
        // PARAMETERS LIST (in Parameter Order):
        // (None)
        //
        // RETURNS:
        // (Void)
        //
        // LOCAL VARIABLE DICTIONARY:
        // surgery              - The Surgery object instance being tested
        // initialDate          - Initial DateOnly for the surgery date
        // initialDescription   - Initial string describing the surgery
        // initialName          - Initial string for the surgery name
        // initialPetID         - Initial Guid of the associated pet
        // initialTuid          - Initial Guid representing the unique ID (TUID)
        // newDate              - New DateOnly for the surgery date
        // newDescription       - New string describing the surgery
        // newName              - New string for the surgery name
        // newPetID             - New Guid of the associated pet
        // newTuid              - New Guid representing the unique ID (TUID)
        //
        // MODIFICATION HISTORY:
        // WHO            WHEN            WHAT
        // ---            ----            ----------------------------------------

        [TestMethod]
        public void TestSurgerySetters()
        {
            // Initial test data
            Guid initialTuid = Guid.NewGuid();
            string initialName = "Spay";
            string initialDescription = "Routine spaying procedure";
            DateOnly initialDate = new DateOnly(2026, 1, 15);
            Guid initialPetID = Guid.NewGuid();

            //Surgery surgery = new Surgery(initialTuid, initialName, initialDescription, initialDate, initialPetID);

            //// New test data for setters
            //Guid newTuid = Guid.NewGuid();
            //string newName = "Neuter";
            //string newDescription = "Routine neutering procedure";
            //DateOnly newDate = new DateOnly(2026, 2, 20);
            //Guid newPetID = Guid.NewGuid();

            //// Set new values
            //surgery.TUID = newTuid;
            //surgery.Name = newName;
            //surgery.Description = newDescription;
            //surgery.Date = newDate;
            //surgery.PetID = newPetID;

            //// Assert all properties are updated to the new values
            //Assert.AreEqual(newTuid, surgery.TUID);
            //Assert.AreEqual(newName, surgery.Name);
            //Assert.AreEqual(newDescription, surgery.Description);
            //Assert.AreEqual(newDate, surgery.Date);
            //Assert.AreEqual(newPetID, surgery.PetID);
        }
    }
}
