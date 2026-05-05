using System;
using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using PAWS.WinForms.Helpers;
using PAWS.WinForms.Models.Pet;

namespace QA_TEST.Helpers
{
    /// <summary>
    /// FILENAME: MedicalHelpersTests.cs
    /// 
    /// WRITTEN BY: Rosh Mizoory
    /// DATE CREATED: March 18, 2026
    /// 
    /// PART OF PROJECT: QA_TEST
    /// 
    /// FILE PURPOSE:
    /// These tests focus on the validation logic inside SaveMedicalAsync.
    /// I used this helper because it is a central save point for staged medical data.
    /// The biggest thing I wanted to verify here was that bad input is rejected before
    /// any database work happens.
    /// 
    /// IMPORTANT TESTING NOTE:
    /// A lot of the remaining behavior in MedicalHelpers directly depends on stored procedures,
    /// database data, and private mapping methods. Those parts should also be covered manually.
    /// </summary>
    [TestClass]
    public class MedicalHelpersTests
    {
        [TestMethod]
        public async System.Threading.Tasks.Task SaveMedicalAsync_ThrowsWhenCurrentMedicalRecordIsNull()
        {
            // Arrange
            MedicalRecord? currentMedicalRecord = null;
            MedicalRecord medicalRecordToDelete = BuildEmptyMedicalRecord(1);

            // Act / Assert
            await Assert.ThrowsExceptionAsync<ArgumentNullException>(async () =>
            {
                await MedicalHelpers.SaveMedicalAsync(currentMedicalRecord!, medicalRecordToDelete);
            });
        }

        [TestMethod]
        public async System.Threading.Tasks.Task SaveMedicalAsync_ThrowsWhenMedicalRecordToDeleteIsNull()
        {
            // Arrange
            MedicalRecord currentMedicalRecord = BuildEmptyMedicalRecord(1);
            MedicalRecord? medicalRecordToDelete = null;

            // Act / Assert
            await Assert.ThrowsExceptionAsync<ArgumentNullException>(async () =>
            {
                await MedicalHelpers.SaveMedicalAsync(currentMedicalRecord, medicalRecordToDelete!);
            });
        }

        [TestMethod]
        public async System.Threading.Tasks.Task SaveMedicalAsync_ThrowsWhenPetIdIsInvalid()
        {
            // Arrange
            MedicalRecord currentMedicalRecord = BuildEmptyMedicalRecord(0);
            MedicalRecord medicalRecordToDelete = BuildEmptyMedicalRecord(1);

            // Act / Assert
            await Assert.ThrowsExceptionAsync<ArgumentException>(async () =>
            {
                await MedicalHelpers.SaveMedicalAsync(currentMedicalRecord, medicalRecordToDelete);
            });
        }

        [TestMethod]
        public async System.Threading.Tasks.Task SaveMedicalAsync_ClearsDeleteTrackingLists_WhenThereIsNothingToPersist()
        {
            // Arrange
            MedicalRecord currentMedicalRecord = BuildEmptyMedicalRecord(5);
            MedicalRecord medicalRecordToDelete = BuildDeleteTrackingRecordWithZeroIds(5);

            // Act
            await MedicalHelpers.SaveMedicalAsync(currentMedicalRecord, medicalRecordToDelete);

            // Assert
            Assert.AreEqual(0, medicalRecordToDelete.VaccineList.Count,
                "The vaccine delete-tracking list should be cleared after a successful save.");
            Assert.AreEqual(0, medicalRecordToDelete.PreventionList.Count,
                "The prevention delete-tracking list should be cleared after a successful save.");
            Assert.AreEqual(0, medicalRecordToDelete.SurgeryList.Count,
                "The surgery delete-tracking list should be cleared after a successful save.");
        }

        private static MedicalRecord BuildEmptyMedicalRecord(int petId)
        {
            return new MedicalRecord
            {
                PetID = petId,
                VaccineList = new List<Vaccine>(),
                PreventionList = new List<Prevention>(),
                SurgeryList = new List<Surgery>(),
                VetVisitList = new List<VetVisit>()
            };
        }

        private static MedicalRecord BuildDeleteTrackingRecordWithZeroIds(int petId)
        {
            return new MedicalRecord
            {
                PetID = petId,
                VaccineList = new List<Vaccine>
                {
                    new Vaccine { TUID = 0, PetID = petId, VaccineType = "Rabies", Notes = "Not persisted yet" }
                },
                PreventionList = new List<Prevention>
                {
                    new Prevention { TUID = 0, PetID = petId, PreventionType = "Flea", Notes = "Not persisted yet" }
                },
                SurgeryList = new List<Surgery>
                {
                    new Surgery { TUID = 0, PetID = petId, Name = "Check", Description = "Not persisted yet" }
                },
                VetVisitList = new List<VetVisit>()
            };
        }
    }
}