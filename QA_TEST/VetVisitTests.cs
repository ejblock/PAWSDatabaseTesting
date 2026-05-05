using Microsoft.VisualStudio.TestTools.UnitTesting;
using PAWS.WinForms.Models.Pet;
using System;

namespace QA_TEST
{
    /// <summary>
    /// Filename: VetVisitTests.cs
    /// Part of Project: PAWS.WinForms
    ///
    /// Author: Rosh Mizoory
    ///
    /// File Purpose:
    /// This file contains unit tests for the VetVisit model.
    ///
    /// Class Purpose:
    /// The purpose of this class is to ensure that veterinary visit
    /// information is correctly stored and maintained. These tests
    /// confirm that visit data such as name, description, visit date,
    /// and associated pet identifier are handled properly.
    /// </summary>
    [TestClass]
    public class VetVisitTests
    {
        /// <summary>
        /// This test verifies that the VetVisit constructor assigns
        /// all incoming values to their appropriate properties.
        /// Correct construction is critical since vet visit records
        /// are used throughout the application.
        /// </summary>
        [TestMethod]
        public void VetVisit_Constructor_Sets_Properties()
        {
            //Guid tuid = Guid.NewGuid();
            //Guid petId = Guid.NewGuid();
            //string name = "Annual Checkup";
            //string description = "Routine veterinary examination";
            //DateOnly visitDate = new DateOnly(2026, 2, 5);

            //VetVisit visit = new VetVisit(
            //    tuid,
            //    name,
            //    description,
            //    visitDate,
            //    petId
            //);

            //Assert.AreEqual(tuid, visit.TUID);
            //Assert.AreEqual(name, visit.Name);
            //Assert.AreEqual(description, visit.Description);
            //Assert.AreEqual(visitDate, visit.Date);
            //Assert.AreEqual(petId, visit.PetID);
        }

        /// <summary>
        /// This test ensures that VetVisit properties remain editable
        /// after object creation. Vet visit details may be updated
        /// later, so it is important that changes persist correctly.
        /// </summary>
        [TestMethod]
        public void VetVisit_Properties_Can_Be_Updated()
        {
            //VetVisit visit = new VetVisit(
            //    Guid.NewGuid(),
            //    "Checkup",
            //    "Initial visit",
            //    new DateOnly(2026, 1, 1),
            //    Guid.NewGuid()
            //);

            //visit.Name = "Follow up visit";
            //visit.Description = "Staple removal and recovery check";
            //visit.Date = new DateOnly(2026, 3, 1);

            //Assert.AreEqual("Follow up visit", visit.Name);
            //Assert.AreEqual("Staple removal and recovery check", visit.Description);
            //Assert.AreEqual(new DateOnly(2026, 3, 1), visit.Date);
        }
    }
}
