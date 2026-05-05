using Microsoft.Data.SqlClient;

namespace QA_TEST.Database_Tests;


[TestClass]
public class DatabaseConnectionAndExistanceTests : TestDatabaseSetup
{

    /// <summary>
    /// Verifies that a connection to the database can be established 
    /// successfully.
    /// </summary>
    /// <remarks>This test ensures that the configured connection string allows
    /// the application to open a connection to the database. If the connection
    /// cannot be established, the test will fail, indicating a potential
    /// configuration or connectivity issue.</remarks>
    [TestMethod]
    public void CanConnectToDatabase()
    {
        using var connection = new SqlConnection(ConnectionString);
        connection.Open();

        Assert.AreEqual(System.Data.ConnectionState.Open, connection.State);
    }

    /// <summary>
    /// Verifies that the 'MidlandPitStopDatabase' database exists on the
    /// configured SQL Server instance.
    /// </summary>
    /// <remarks>This test asserts that a database named
    /// 'MidlandPitStopDatabase' is present and accessible using the provided
    /// connection string. If the database does not exist or is incorrectly
    /// named, the test will fail.</remarks>
    [TestMethod]
    public void MidlandPitStopDatabaseExists()
    {
        using var connection = new SqlConnection(ConnectionString);
        connection.Open();

        using var command = new SqlCommand("SELECT" +
            " DB_ID('MidlandPitStopDatabase')", connection);

        var databaseCount = command.ExecuteScalar();

        Assert.IsNotNull(databaseCount,  "Database is not correctly named");
    }

    /// <summary>
    /// Verifies that the WAIT_STATS_CAPTURE_MODE database scoped configuration
    /// is set to either ON or AUTO.
    /// </summary>
    /// <remarks>This test ensures that the WAIT_STATS_CAPTURE_MODE setting is
    /// enabled, which is required for capturing wait statistics in the
    /// database. The test will fail if the configuration is missing or set to
    /// an unexpected value.</remarks>
    [TestMethod]
    public void IsEnabledWaitStatsCaptureMode()
    {
        using var connection = CreateConnection();
        connection.Open();

        using var command = new SqlCommand(@"
            SELECT value
            FROM sys.database_scoped_configurations
            WHERE name = 'WAIT_STATS_CAPTURE_MODE';
        ", connection);

        var value = command.ExecuteScalar()?.ToString();

        Assert.IsNotNull(
            value,
            "WAIT_STATS_CAPTURE_MODE setting was not found.");

        Assert.IsTrue(
            value == "ON" || value == "AUTO",
            $"WAIT_STATS_CAPTURE_MODE is '{value}', expected ON or AUTO.");
    }

    /// <summary>
    /// Verifies that all expected database tables exist in the connected SQL
    /// Server instance.
    /// </summary>
    /// <remarks>This test checks for the presence of each table listed in the
    /// expected tables collection. The test fails if any expected table is
    /// missing from the database. Ensure that the connection string and
    /// expected table names are configured correctly before running this test.
    /// </remarks>
    [TestMethod]
    public void AllTablesExist()
    {
        using var connection = new SqlConnection(ConnectionString);
        connection.Open();

        foreach (string tableName in expectedTables)
        {
            using var command = new SqlCommand("SELECT COUNT(*) FROM " +
                "INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @TableName",
                connection);
            command.Parameters.AddWithValue("@TableName", tableName);
            int tableCount = (int)command.ExecuteScalar();
            Assert.AreEqual(1, tableCount, $"Table '{tableName}' does not" +
                $" exist.");
        }
    }

    /// <summary>
    /// Verifies that the database contains only the expected set of tables and
    /// no unexpected tables are present.
    /// </summary>
    /// <remarks>This test ensures that the database schema matches the
    /// predefined list of allowed tables. If any table exists in the database
    /// that is not in the expected set, the test fails. This helps maintain
    /// schema integrity and detect accidental or unauthorized schema changes.
    /// </remarks>
    [TestMethod]
    public void NoUnexpectedTables()
    {
        HashSet<string> expectedTables = new HashSet<string>
        {
            "Pet", "House", "Person", "Volunteer", "User", "Role", "Event",
            "RelationshipPersonEvent", "PetAdoption", "PetFoster", "Vaccine",
            "Prevention", "Surgery", "VetVisit", "Folder", "File", "Revenue",
            "Expense"
        };

        HashSet<string> actualTables = new HashSet<string>();

        using var connection = new SqlConnection(ConnectionString);
        connection.Open();

        using var command = new SqlCommand(@"SELECT TABLE_NAME FROM 
            INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';",
            connection);

        using var myReader = command.ExecuteReader();
        while (myReader.Read())
        {
            actualTables.Add(myReader.GetString(0));
        }

        foreach (var table in actualTables)
        {
            Assert.IsTrue(expectedTables.Contains(table), $"Unexpected " +
                $"table found in database: {table}");
        }
    }
}
