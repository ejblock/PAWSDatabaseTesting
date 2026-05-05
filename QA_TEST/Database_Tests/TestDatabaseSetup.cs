using Microsoft.Data.SqlClient;

namespace QA_TEST;

[TestClass]
public abstract class TestDatabaseSetup
{
    public string[] expectedTables = new string[]
        {
            "Pet", "House", "Person", "Volunteer", "User", "Role", "Event",
            "RelationshipPersonEvent", "PetAdoption", "PetFoster", "Vaccine",
            "Prevention", "Surgery", "VetVisit", "Folder", "File", "Revenue",
            "Expense"
        };

    protected const string ConnectionString =
        "Server=localhost,1433;" +
            "Database=MidlandPitStopDatabase;" +
            "User Id=sa;" +
            "Password=SuaSenhaForte123!;" +
            "TrustServerCertificate=True;";

    protected SqlConnection CreateConnection()
    {
        return new SqlConnection(ConnectionString);
    }
}
