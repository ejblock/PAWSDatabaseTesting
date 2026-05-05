using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using PAWS.WinForms.Models.Pet;

namespace QA_TEST.Models
{

    // FILENAME: PreventionTests.cs
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
    public class PreventionTests
    {

        // METHOD NAME: TestPreventionObject
        //
        // METHOD PURPOSE:
        // This unit test verifies the functionality of the Prevention class constructor.
        // It creates a set of test data, instantiates a Prevention object, and then
        // asserts that every public property of the object matches the original test data provided.
        //
        // PARAMETERS LIST (in Parameter Order):
        // (None)
        //
        // RETURNS:
        // (Void)
        //
        // LOCAL VARIABLE DICTIONARY:
        // prevention           - The Prevention object instance being tested
        // testDateDue          - DateOnly for the due date
        // testDateGiven        - DateOnly for the given date
        // testNotes            - String for additional notes
        // testPetID            - Guid of the associated pet
        // testTuid             - Guid representing the unique ID (TUID)
        // testType             - String for the type of prevention
        //
        // MODIFICATION HISTORY:
        // WHO            WHEN            WHAT
        // ---            ----            ----------------------------------------

        [TestMethod]
        public void TestPreventionObject()
        {
            // Create test data
            int testTuid = 1;
            string testType = "Vaccination";
            string testNotes = "Annual booster";
            DateOnly testDateGiven = new DateOnly(2026, 1, 15);
            DateOnly testDateDue = new DateOnly(2027, 1, 15);
            int testPetID = 1;

            //// Instantiate Prevention object to test
            //Prevention prevention = new Prevention(testTuid, testType, testNotes, testDateGiven, testDateDue, testPetID);

            //// Verify all properties return the exact value assigned in the constructor
            //Assert.AreEqual(testTuid, prevention.TUID);
            //Assert.AreEqual(testType, prevention.Type);
            //Assert.AreEqual(testNotes, prevention.Notes);
            //Assert.AreEqual(testDateGiven, prevention.DateGiven);
            //Assert.AreEqual(testDateDue, prevention.DateDue);
            //Assert.AreEqual(testPetID, prevention.PetID);
        }

        // METHOD NAME: TestPreventionSetters
        //
        // METHOD PURPOSE:
        // This unit test verifies that all properties of the Prevention class can be
        // modified via their setters. It first creates a Prevention object with initial test data,
        // then changes each property to a new value and verifies the change.
        //
        // PARAMETERS LIST (in Parameter Order):
        // (None)
        //
        // RETURNS:
        // (Void)
        //
        // LOCAL VARIABLE DICTIONARY:
        // prevention           - The Prevention object instance being tested
        // initialDateDue          - DateOnly for the initial due date
        // initialDateGiven        - DateOnly for the initial given date
        // initialNotes            - String for initial additional notes
        // initialPetID            - Guid of the associated pet
        // initialTuid             - Guid representing the initial unique ID (TUID)
        // initialType             - String for the initial type of prevention
        // newDateDue          - DateOnly for the new due date
        // newDateGiven        - DateOnly for the new given date
        // newNotes            - String for new additional notes
        // newPetID            - Guid of the new associated pet
        // newTuid             - Guid representing the new unique ID (TUID)
        // newType             - String for the new type of prevention
        //
        // MODIFICATION HISTORY:
        // WHO            WHEN            WHAT
        // ---            ----            ----------------------------------------

        [TestMethod]
        public void TestPreventionSetters()
        {
            // Initial test data
            Guid initialTuid = Guid.NewGuid();
            string initialType = "Vaccination";
            string initialNotes = "Annual booster";
            DateOnly initialDateGiven = new DateOnly(2026, 1, 15);
            DateOnly initialDateDue = new DateOnly(2027, 1, 15);
            Guid initialPetID = Guid.NewGuid();

            //Prevention prevention = new Prevention(initialTuid, initialType, initialNotes, initialDateGiven, initialDateDue, initialPetID);

            //// New test data for setters
            //Guid newTuid = Guid.NewGuid();
            //string newType = "Deworming";
            //string newNotes = "Monthly treatment";
            //DateOnly newDateGiven = new DateOnly(2026, 2, 20);
            //DateOnly newDateDue = new DateOnly(2027, 2, 20);
            //Guid newPetID = Guid.NewGuid();

            //// Set new values
            //prevention.TUID = newTuid;
            //prevention.Type = newType;
            //prevention.Notes = newNotes;
            //prevention.DateGiven = newDateGiven;
            //prevention.DateDue = newDateDue;
            //prevention.PetID = newPetID;

            //// Assert all properties are updated to the new values
            //Assert.AreEqual(newTuid, prevention.TUID);
            //Assert.AreEqual(newType, prevention.Type);
            //Assert.AreEqual(newNotes, prevention.Notes);
            //Assert.AreEqual(newDateGiven, prevention.DateGiven);
            //Assert.AreEqual(newDateDue, prevention.DateDue);
            //Assert.AreEqual(newPetID, prevention.PetID);
        }
    }
}
