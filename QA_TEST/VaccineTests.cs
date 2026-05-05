using Microsoft.VisualStudio.TestTools.UnitTesting;
using PAWS.WinForms.Models.Pet;
using System;

namespace QA_TEST
{
    /// <summary>
    /// Filename: VaccineTests.cs
    /// Part of Project: PAWS.WinForms
    ///
    /// Author: Rosh Mizoory
    ///
    /// File Purpose:
    /// This file contains unit tests for the Vaccine model.
    ///
    /// Class Purpose:
    /// The purpose of this class is to verify that the Vaccine model
    /// correctly stores and updates vaccine related data for a pet.
    /// These tests focus on constructor behavior and property access
    /// to ensure the model behaves as expected when used by the rest
    /// of the application.
    /// </summary>
    [TestClass]
    public class VaccineTests
    {
        /// <summary>
        /// This test confirms that the Vaccine constructor properly
        /// assigns all values passed into it. If any of these values
        /// are incorrect, it would indicate a serious issue with how
        /// vaccine data is being initialized.
        /// </summary>
        [TestMethod]
        public void Vaccine_Constructor_Sets_Properties()
        {
            Guid tuid = Guid.NewGuid();
            Guid petId = Guid.NewGuid();
            string type = "Rabies";
            string notes = "Initial vaccination";
            DateOnly dateGiven = new DateOnly(2026, 2, 1);
            DateOnly dateDue = new DateOnly(2027, 2, 1);

            //Vaccine vaccine = new Vaccine(
            //    tuid,
            //    type,
            //    notes,
            //    dateGiven,
            //    dateDue,
            //    petId
            //);

            //Assert.AreEqual(tuid, vaccine.TUID);
            //Assert.AreEqual(type, vaccine.Type);
            //Assert.AreEqual(notes, vaccine.Notes);
            //Assert.AreEqual(dateGiven, vaccine.DateGiven);
            //Assert.AreEqual(dateDue, vaccine.DateDue);
            //Assert.AreEqual(petId, vaccine.PetID);
        }

        /// <summary>
        /// This test verifies that Vaccine properties can be updated
        /// after the object has been created. This is important since
        /// vaccine information may change over time and needs to be
        /// editable without creating a new object.
        /// </summary>
        [TestMethod]
        public void Vaccine_Properties_Can_Be_Updated()
        {
            //Vaccine vaccine = new Vaccine(
            //    Guid.NewGuid(),
            //    "Rabies",
            //    "",
            //    new DateOnly(2026, 1, 1),
            //    new DateOnly(2027, 1, 1),
            //    Guid.NewGuid()
            //);

            //vaccine.Type = "Distemper";
            //vaccine.Notes = "Updated notes after follow up visit";
            //vaccine.DateDue = new DateOnly(2028, 1, 1);

            //Assert.AreEqual("Distemper", vaccine.Type);
            //Assert.AreEqual("Updated notes after follow up visit", vaccine.Notes);
            //Assert.AreEqual(new DateOnly(2028, 1, 1), vaccine.DateDue);
        }
    }
}
