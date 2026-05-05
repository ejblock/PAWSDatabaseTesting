using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Linq;

namespace QA_TEST.Database_Tests
{
    /// <summary>
    /// Filename: StoredProcedureInventoryTests.cs
    /// Part of Project: QA_TEST
    ///
    /// Author: Rosh Mizoory
    ///
    /// File Purpose:
    /// This file contains integration style database tests that verify the stored
    /// procedures required by the WinForms application are present and usable.
    ///
    /// Class Purpose:
    /// The purpose of this class is to confirm that the database layer matches what
    /// the application expects at runtime. Instead of testing the internal SQL logic
    /// for every stored procedure (which is handled elsewhere), these tests focus on:
    ///
    /// 1. Verifying all required stored procedures exist in the dbo schema.
    /// 2. Verifying the application critical reset routine can run successfully.
    /// 3. Verifying the reset routine actually leaves the database in a usable state.
    ///
    /// If any procedure is missing, renamed, or created in the wrong schema,
    /// the application can break even if the database mostly works.
    /// These tests catch that early and give an exact missing list to fix.
    /// </summary>
    [TestClass]
    public class StoredProcedureInventoryTests : TestDatabaseSetup
    {
        /// <summary>
        /// This list represents every stored procedure that the application expects
        /// to exist in the database. The goal here is simple: if the app calls a
        /// stored procedure and it is not present, the feature breaks immediately.
        ///
        /// This list is intentionally explicit so it is easy to review, easy to
        /// compare against the schema script, and easy to diagnose when something
        /// goes missing.
        /// </summary>
        private static readonly string[] RequiredProcedures = new[]
        {
            "spAddPetToHome",
            "spAddResidentToHome",
            "spCreateAdopterHome",
            "spCreateEvent",
            "spCreateFosterHome",
            "spCreatePerson",
            "spCreatePet",
            "spCreatePrevention",
            "spCreateRole",
            "spCreateSurgery",
            "spCreateTables",
            "spCreateUser",
            "spCreateVaccine",
            "spCreateVetVisit",
            "spDeleteEvent",
            "spDeletePerson",
            "spDeleteRole",
            "spDeleteTables",
            "spDeleteUser",
            "spEditAdopterHome",
            "spEditEvent",
            "spEditFosterHome",
            "spEditPerson",
            "spEditPet",
            "spEditPrevention",
            "spEditRole",
            "spEditSurgery",
            "spEditUser",
            "spEditVaccine",
            "spEditVetVisit",
            "spGetAdopterHome",
            "spGetAllAdopterHomes",
            "spGetAllFosterHomes",
            "spGetAllRoles",
            "spGetAllUsers",
            "spGetEvent",
            "spGetFilteredUser",
            "spGetFosterHome",
            "spGetPeople",
            "spGetPerson",
            "spGetPetList",
            "spGetPetProfile",
            "spGetPetsAssociatedToAHome",
            "spGetResidentsAssociatedToAHome",
            "spGetRole",
            "spGetSearchedFilteredUser",
            "spGetSearchedUser",
            "spGetUpcomingEvent",
            "spInsertTestData",
            "spPetList",
            "spResetDatabase",
            "spUserLogin",
            "spViewAllTables"
        };

        /// <summary>
        /// This test verifies that all required stored procedures exist in the dbo schema.
        ///
        /// Why this matters:
        /// The application depends on these procedure names being correct. If one is missing
        /// or placed in a different schema, the app will throw runtime errors when that
        /// screen or feature tries to load.
        ///
        /// How the test works:
        /// 1. It pulls the list of all stored procedures currently in dbo.
        /// 2. It compares that list against RequiredProcedures.
        /// 3. If anything is missing, it fails and prints the exact names.
        ///
        /// This gives a clean and simple pass or fail answer for:
        /// Are all app required stored procedures implemented correctly?
        /// </summary>
        [TestMethod]
        public void Required_StoredProcedures_Exist()
        {
            using var conn = new SqlConnection(ConnectionString);
            conn.Open();

            // HashSet is used so lookups are fast and case differences do not matter.
            // This protects us from small naming differences like spCreateUser vs SPCreateUser.
            var found = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            // Pull all stored procedures in dbo.
            // This approach is faster than checking one procedure at a time.
            using (var cmd = new SqlCommand(@"
                SELECT p.name
                FROM sys.procedures p
                INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
                WHERE s.name = 'dbo';", conn))
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                    found.Add(rdr.GetString(0));
            }

            // Find anything in our required list that was not found in dbo.
            var missing = RequiredProcedures.Where(r => !found.Contains(r)).ToList();

            // If anything is missing, fail with a readable list so it is easy to create a Git issue.
            if (missing.Count > 0)
            {
                Assert.Fail("Missing stored procedures:\n" + string.Join("\n", missing));
            }
        }

        /// <summary>
        /// This test verifies that dbo.spResetDatabase runs successfully and actually leaves
        /// the database in a usable state.
        ///
        /// Why this matters:
        /// From an application point of view, this is one of the most important procedures.
        /// It calls a chain of other procedures that delete tables, recreate them, and
        /// insert test data. If any stored procedure in that chain is broken, the reset
        /// will fail and the application becomes unusable for testing and development.
        ///
        /// What this test proves:
        /// 1. dbo.spResetDatabase exists and executes without throwing SQL errors.
        /// 2. The reset flow successfully seeds the database with data the app needs.
        ///
        /// Note:
        /// This is not meant to fully validate every table's contents. It is meant to confirm
        /// the reset routine works end to end, which is exactly what a real app workflow needs.
        /// </summary>
        [TestMethod]
        public void ResetDatabase_Procedure_Runs_And_Seeds_Data()
        {
            using var conn = new SqlConnection(ConnectionString);
            conn.Open();

            // Run the reset procedure.
            // The timeout is increased because this procedure drops and recreates many tables.
            using (var cmd = new SqlCommand("dbo.spResetDatabase", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.CommandTimeout = 120;
                cmd.ExecuteNonQuery();
            }

            // Basic sanity checks to prove the reset actually seeded data.
            // If these fail, it usually means spInsertTestData did not run or did not insert correctly.

            using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[User];", conn))
            {
                var userCount = Convert.ToInt32(cmd.ExecuteScalar());
                Assert.IsTrue(userCount > 0, "Expected dbo.[User] to have seeded rows after spResetDatabase.");
            }

            using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.[Role];", conn))
            {
                var roleCount = Convert.ToInt32(cmd.ExecuteScalar());
                Assert.IsTrue(roleCount > 0, "Expected dbo.[Role] to have seeded rows after spResetDatabase.");
            }

            // Adding one more domain check makes this feel more application focused.
            // It confirms the reset created and seeded tables beyond just security related tables.

            using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.House;", conn))
            {
                var houseCount = Convert.ToInt32(cmd.ExecuteScalar());
                Assert.IsTrue(houseCount > 0, "Expected dbo.House to have seeded rows after spResetDatabase.");
            }

            using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.Pet;", conn))
            {
                var petCount = Convert.ToInt32(cmd.ExecuteScalar());
                Assert.IsTrue(petCount > 0, "Expected dbo.Pet to have seeded rows after spResetDatabase.");
            }
        }
    }
}