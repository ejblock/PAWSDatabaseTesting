using Microsoft.Data.SqlClient;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Data;

namespace QA_TEST.Database_Tests
{
    [TestClass]
    public class TSQLTUnitTests : TestDatabaseSetup
    {
        [TestMethod]
        public void RunTSQLTTest()
        {
            using var connection = new SqlConnection(ConnectionString);
            connection.Open();

            string sql = @"
                SET ARITHABORT ON;
                EXEC tSQLt.RunAll;";

            using var command = new SqlCommand(sql, connection)
            {
                CommandTimeout = 600
            };

            using var reader = command.ExecuteReader();
            bool anyFailure = false;
            string failureMessage = "";

            do
            {
                while (reader.Read())
                {
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        string colName = reader.GetName(i);
                        object value = reader.GetValue(i);
                        Console.WriteLine($"{colName}: {value}");
                    }

                    if (reader.GetSchemaTable() != null && reader.GetSchemaTable().Columns.Contains("Result"))
                    {
                        var result = reader["Result"]?.ToString();
                        if (!string.IsNullOrEmpty(result) && result != "Success")
                        {
                            anyFailure = true;
                            failureMessage += $"{reader["TestClass"]}.{reader["TestName"]}: {reader["Message"]}\n";
                        }
                    }
                }
            } while (reader.NextResult());

            if (anyFailure)
                Assert.Fail($"tSQLt RunAll detected failures:\n{failureMessage}");
        }
        // EventTests
        /*[TestMethod] public void EventTests_spCreateEvent_updates_Event_table() => RunTSQLTTest("[EventTests].[test spCreateEvent updates Event table]");
        [TestMethod] public void EventTests_spGetEvent_returns_correct_events_from_Event_table() => RunTSQLTTest("[EventTests].[test spGetEvent returns correct events from the Event table]");
        [TestMethod] public void EventTests_spGetUpcomingEvent_returns_event_from_Event_table() => RunTSQLTTest("[EventTests].[test spGetUpcomingEvent returns event from Event table]");

        // HomeTests
        [TestMethod] public void HomeTests_spCreateAdopterHome_updates_House_table() => RunTSQLTTest("[HomeTests].[test spCreateAdopterHome updates House table]");
        [TestMethod] public void HomeTests_spCreateFosterHome_updates_House_table() => RunTSQLTTest("[HomeTests].[test spCreateFosterHome updates House table]");
        [TestMethod] public void HomeTests_spGetAdopterHome_returns_correct_adopter_home_from_House_table() => RunTSQLTTest("[HomeTests].[test spGetAdopterHome returns correct adopter home from House table]");
        [TestMethod] public void HomeTests_spGetAllAdopterHomes_returns_correct_rows_with_and_without_filters_from_House_table() => RunTSQLTTest("[HomeTests].[test spGetAllAdopterHomes returns correct rows with and without filters from House table]");
        [TestMethod] public void HomeTests_spGetAllFosterHomes_returns_correct_rows_from_House_table() => RunTSQLTTest("[HomeTests].[test spGetAllFosterHomes returns correct rows from House table]");
        [TestMethod] public void HomeTests_spGetFosterHome_returns_foster_home_and_person_information() => RunTSQLTTest("[HomeTests].[test spGetFosterHome returns foster home and person information]");

        // MedicalTests
        [TestMethod] public void MedicalTests_spCreatePrevention_updates_Prevention_table() => RunTSQLTTest("[MedicalTests].[test spCreatePrevention updates Prevention table]");
        [TestMethod] public void MedicalTests_spCreateSurgery_updates_Surgery_table() => RunTSQLTTest("[MedicalTests].[test spCreateSurgery updates Surgery table]");
        [TestMethod] public void MedicalTests_spCreateVaccine_updates_Vaccine_table() => RunTSQLTTest("[MedicalTests].[test spCreateVaccine updates Vaccine table]");
        [TestMethod] public void MedicalTests_spCreateVetVisit_updates_VetVisit_table() => RunTSQLTTest("[MedicalTests].[test spCreateVetVisit updates VetVisit table]");

        // PersonTests
        [TestMethod] public void PersonTests_spAddPersonToHome_updates_Person_table() => RunTSQLTTest("[PersonTests].[test spAddPersonToHome updates Person table]");
        [TestMethod] public void PersonTests_spCreatePerson_updates_Person_table() => RunTSQLTTest("[PersonTests].[test spCreatePerson updates Person table]");
        [TestMethod] public void PersonTests_spGetPeople_returns_people_from_the_Person_table() => RunTSQLTTest("[PersonTests].[test spGetPeople returns people from the Person table]");
        [TestMethod] public void PersonTests_spGetPerson_returns_person_from_People_table() => RunTSQLTTest("[PersonTests].[test spGetPerson returns person from People table]");

        // PetTests
        [TestMethod] public void PetTests_spCreatePet_updates_Pet_table() => RunTSQLTTest("[PetTests].[test spCreatePet updates Pet table]");
        [TestMethod] public void PetTests_spGetPetList_returns_all_pets_from_Pet() => RunTSQLTTest("[PetTests].[test spGetPetList returns all pets from Pet]");
        [TestMethod] public void PetTests_spGetPetsAssociatedToAHome_returns_a_person_linked_to_a_House() => RunTSQLTTest("[PetTests].[test spGetPetsAssociatedToAHome returns a person linked to a House]");
        [TestMethod] public void PetTests_spGetPetsAssociatedToAHome_returns_a_pet_linked_to_a_House() => RunTSQLTTest("[PetTests].[test spGetPetsAssociatedToAHome returns a pet linked to a House]");

        // RoleTests
        [TestMethod] public void RoleTests_spCreateRole_updates_Role_table() => RunTSQLTTest("[RoleTests].[test spCreateRole updates Role table]");
        [TestMethod] public void RoleTests_spGetAllRoles_returns_correct_roles_from_the_Role_table() => RunTSQLTTest("[RoleTests].[test spGetAllRoles returns correct roles from the Role table]");
        [TestMethod] public void RoleTests_spGetRole_returns_role_from_Role() => RunTSQLTTest("[RoleTests].[test spGetRole returns role from Role]");

        // UserTests
        [TestMethod] public void UserTests_spCreateUser_updates_User_table() => RunTSQLTTest("[UserTests].[test spCreateUser updates User table]");
        [TestMethod] public void UserTests_spGetAllUsers_returns_correct_users_from_the_User_table() => RunTSQLTTest("[UserTests].[test spGetAllUsers returns correct users from the User table]");
        [TestMethod] public void UserTests_spGetFilteredUser_returns_users_with_specified_role() => RunTSQLTTest("[UserTests].[test spGetFilteredUser returns users with specified role]");
        [TestMethod] public void UserTests_spGetSearchedFilteredUser_returns_users_with_role() => RunTSQLTTest("[UserTests].[test spGetSearchedFilteredUser returns users with role]");
        [TestMethod] public void UserTests_spGetSearchedUser_returns_user_from_User_table() => RunTSQLTTest("[UserTests].[test spGetSearchedUser returns user from User table]");
        [TestMethod] public void UserTests_spSearchedUser_returns_user_from_User_table() => RunTSQLTTest("[UserTests].[test spSearchedUser returns user from User table]");

        // PetTests continued
        [TestMethod] public void PetTests_spAddPetToHome_updates_Pet_table() => RunTSQLTTest("[PetTests].[test spAddPetToHome updates Pet table]");
        [TestMethod] public void PetTests_spGetPetProfile_returns_a_pet_from_Pet() => RunTSQLTTest("PetTests.[test spGetPetProfile returns a pet from Pet]");
        */
     }
}