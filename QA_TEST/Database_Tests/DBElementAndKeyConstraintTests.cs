using Microsoft.Data.SqlClient;
using Microsoft.Identity.Client;

namespace QA_TEST.Database_Tests;

[TestClass]
public class DBElementAndKeyConstraintTests : TestDatabaseSetup
{
    /// <summary>
    /// Retrieves a list of foreign key relationships for the specified parent
    /// table from the database.
    /// </summary>
    /// <remarks>The returned list includes all foreign key relationships where
    /// the specified table is the parent. The method establishes a database
    /// connection and queries system tables to obtain the foreign key
    /// metadata.</remarks>
    /// <param name="parentTable">The name of the parent table for which to
    /// retrieve foreign key information. Cannot be null or empty.</param>
    /// <returns>A list of tuples, each containing the parent table name,
    /// parent column name, referenced table name, and referenced column name
    /// for each foreign key relationship associated with the specified parent
    /// table.</returns>
    private dynamic getForeignKeys(string parentTable)
    {
        int parentColumnIndex = 0;
        int refTableIndex = 1;
        int refColumnIndex = 2;

        var actualForeignKeys = new List<(string parentColumn, 
            string referencedTable, string referencedColumn)>();

        using (SqlConnection conn = CreateConnection())
        {
            conn.Open();

            string query = @"
            SELECT 
                pc.name AS ParentColumn,
                rt.name AS ReferencedTable,
                rc.name AS ReferencedColumn
            FROM sys.foreign_key_columns fkc
            JOIN sys.tables pt 
                ON fkc.parent_object_id = pt.object_id
            JOIN sys.columns pc 
                ON fkc.parent_object_id = pc.object_id 
                AND fkc.parent_column_id = pc.column_id
            JOIN sys.tables rt 
                ON fkc.referenced_object_id = rt.object_id
            JOIN sys.columns rc 
                ON fkc.referenced_object_id = rc.object_id 
                AND fkc.referenced_column_id = rc.column_id
            WHERE pt.name = @ParentTable";

            SqlCommand cmd = new SqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@ParentTable", parentTable);
            SqlDataReader reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                actualForeignKeys.Add((
                    reader.GetString(parentColumnIndex),
                    reader.GetString(refTableIndex),
                    reader.GetString(refColumnIndex)
                ));
            }
        }
        return actualForeignKeys;
    }

    /// <summary>
    /// Asserts that the specified database table contains exactly the expected
    /// set of columns.
    /// </summary>
    /// <remarks>This method throws an assertion failure if the table contains
    /// columns not listed in the expected set, or if any expected columns are
    /// missing. The comparison is case-sensitive and does not consider column
    /// order.</remarks>
    /// <param name="parentTable">The name of the table in the database to
    /// check for column attributes. Cannot be null or empty.</param>
    /// <param name="expectedColumns">A set of column names that are expected
    /// to be present in the specified table. Cannot be null.</param>
    public void TableHasCorrectAttributes(string parentTable, HashSet<string> expectedColumns)
    {
        var actualColumns = new HashSet<string>();

        using var connection = CreateConnection(); // Create a connection to
                                                   // the database

        connection.Open();
        using var command = new SqlCommand(@"
            SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = @TableName", connection);

        command.Parameters.AddWithValue("@TableName", parentTable);

        using var myReader = command.ExecuteReader();
        while (myReader.Read())
        {
            actualColumns.Add(myReader.GetString(0));
        }

        foreach (var attribute in actualColumns)
        {
            Assert.IsTrue(expectedColumns.Contains(attribute), $"Unexpected " +
                $"attribute found in table: {attribute}");
        }

        foreach (var attribute in expectedColumns)
        {
            Assert.IsTrue(actualColumns.Contains(attribute), $"Expected" +
                $" attribute not found in table: {attribute}");
        }
    }

    /// <summary>
    /// Verifies that the specified parent table has exactly the expected set
    /// of foreign key relationships.
    /// </summary>
    /// <remarks>This method asserts that all expected foreign keys exist on
    /// the parent table and that no unexpected foreign keys are present. An
    /// assertion failure is thrown if the actual foreign keys do not match the
    /// expected set.</remarks>
    /// <param name="parentTable">The name of the parent table whose foreign
    /// keys are to be checked. Cannot be null or empty.</param>
    /// <param name="expectedForeignKeys">A list of tuples representing the
    /// expected foreign keys. Each tuple specifies the parent column, the
    /// referenced table, and the referenced column. Cannot be null.</param>
    public void checkForeignKeys(string parentTable, List<(string parentColumn, 
        string referencedTable, string referencedColumn)> expectedForeignKeys)
    {
        List<(string parentColumn, string referencedTable, string
            referencedColumn)> actualForeignKeys = getForeignKeys(parentTable);
        foreach (var expectedFK in expectedForeignKeys)
        {
            Assert.IsTrue(
                actualForeignKeys.Contains(expectedFK),
                $"Expected foreign key not found: {expectedFK.parentColumn} " +
                $"-> {expectedFK.referencedTable}({expectedFK.referencedColumn})"
            );
        }
        foreach (var actualFK in actualForeignKeys)
        {
            Assert.IsTrue(
                expectedForeignKeys.Contains(actualFK),
                $"Unexpected foreign key found: {actualFK.parentColumn} " +
                $"-> {actualFK.referencedTable}({actualFK.referencedColumn})"
            );
        }
    }

    /// <summary>
    /// Verifies that all expected database tables have a primary key column
    /// named "TUID".
    /// </summary>
    /// <remarks>This test connects to the database and checks each table
    /// listed in the expected tables collection to ensure that a primary key
    /// exists and that its column name is "TUID". The test fails if any table
    /// is missing a primary key or if the primary key column is not named
    /// "TUID".</remarks>
    [TestMethod]
    public void AllTablesHavePrimaryKeyOnTUID()
    {


        using var connection = CreateConnection();
        connection.Open();

        foreach (var table in expectedTables)
        {
            using var command = new SqlCommand(@"
                SELECT k.COLUMN_NAME
                FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS t
                JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE k
                    ON t.CONSTRAINT_NAME = k.CONSTRAINT_NAME
                WHERE t.TABLE_NAME = @TableName
                  AND t.CONSTRAINT_TYPE = 'PRIMARY KEY';
            ", connection);

            command.Parameters.AddWithValue("@TableName", table);

            var result = command.ExecuteScalar();

            Assert.IsNotNull(result, $"Table '{table}' does not have a primary" +
                $" key.");
            Assert.AreEqual(
                "TUID",
                result.ToString(),
                $"Primary key for table '{table}' is not named TUID.");
        }
    }

    /// <summary>
    /// Verifies that the 'TUID' column is defined as an IDENTITY column in all expected
    /// database tables.
    /// </summary>
    /// <remarks>This test ensures schema consistency by asserting that each
    /// table in the set of expected tables has a 'TUID' column configured as
    /// an IDENTITY column. If any table does not meet this requirement, the
    /// test fails with a descriptive message.</remarks>
    [TestMethod]
    public void TUID_IsIdentityColumn_ForAllTables()
    {
        using var connection = CreateConnection();
        connection.Open();

        foreach (var table in expectedTables)
        {
            using var command = new SqlCommand(@"
                SELECT COLUMNPROPERTY(
                    OBJECT_ID(@TableName),
                    'TUID',
                    'IsIdentity'
                );
            ", connection);

            command.Parameters.AddWithValue("@TableName", table);

            var isIdentity = Convert.ToInt32(command.ExecuteScalar());

            Assert.AreEqual(
                1,
                isIdentity,
                $"TUID column in table '{table}' is not an IDENTITY column.");
        }
    }

    /// <summary>
    /// Verifies that each expected table has a primary key consisting of a
    /// single column.
    /// </summary>
    /// <remarks>This test asserts that none of the tables in the expected set
    /// use composite primary keys. If a table has a primary key spanning
    /// multiple columns, the test will fail and indicate the table name in the
    /// failure message.</remarks>
    [TestMethod]
    public void PrimaryKeysAreSingleColumn()
    {
        using var connection = CreateConnection();
        connection.Open();

        foreach (var table in expectedTables)
        {
            using var command = new SqlCommand(@"
                SELECT COUNT(*) 
                FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
                WHERE TABLE_NAME = @TableName
                  AND CONSTRAINT_NAME IN (
                      SELECT CONSTRAINT_NAME
                      FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
                      WHERE TABLE_NAME = @TableName
                        AND CONSTRAINT_TYPE = 'PRIMARY KEY'
                  );
            ", connection);

            command.Parameters.AddWithValue("@TableName", table);

            int columnCount = Convert.ToInt32(command.ExecuteScalar());

            Assert.AreEqual(
                1,
                columnCount,
                $"Table '{table}' has a composite primary key.");
        }
    }

    /// <summary>
    /// Verifies that the 'TUID' column in each expected table is of type int.
    /// </summary>
    /// <remarks>This test ensures schema consistency by asserting that all
    /// tables in the expected set define their 'TUID' column with the SQL
    /// Server 'int' data type. If any table does not meet this requirement,
    /// the test fails and identifies the offending table.</remarks>
    [TestMethod]
    public void TUIDIsIntForAllTables()
    {
        using var connection = CreateConnection();
        connection.Open();
        foreach (var table in expectedTables)
        {
            using var command = new SqlCommand(@"
                SELECT DATA_TYPE
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME = @TableName
                  AND COLUMN_NAME = 'TUID';
            ", connection);
            command.Parameters.AddWithValue("@TableName", table);
            var dataType = command.ExecuteScalar()?.ToString();
            Assert.AreEqual(
                "int",
                dataType,
                $"TUID column in table '{table}' is not of type int.");
        }
    }

    /// <summary>
    /// Verifies that the 'TUID' column is not nullable in all expected
    /// database tables.
    /// </summary>
    /// <remarks>This test ensures that each table in the set of expected
    /// tables defines the 'TUID' column as NOT NULL. If any table allows null
    /// values for the 'TUID' column, the test will fail, indicating a schema
    /// inconsistency.</remarks>
    [TestMethod]
    public void TUIDIsNotNullableForAllTables()
    {
        using var connection = CreateConnection();
        connection.Open();
        foreach (var table in expectedTables)
        {
            using var command = new SqlCommand(@"
                SELECT IS_NULLABLE
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME = @TableName
                  AND COLUMN_NAME = 'TUID';
            ", connection);
            command.Parameters.AddWithValue("@TableName", table);
            var isNullable = command.ExecuteScalar()?.ToString();
            Assert.AreEqual(
                "NO",
                isNullable,
                $"TUID column in table '{table}' is nullable.");
        }
    }

    /// <summary>
    /// Verifies that the 'Pet' table contains all expected attributes required
    /// for correct operation.
    /// </summary>
    /// <remarks>This test ensures that the 'Pet' table schema includes the
    /// necessary columns for application functionality. It should be updated
    /// if the table schema changes to maintain test accuracy.</remarks>
    [TestMethod]
    public void PetHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "Animal", "Breed", "Name", "Sex", "Origin", "DateOfBirth",
            "IsDateOfBirthKnown", "Characteristics", "Weight", "IntakeDate", 
            "Notes", "Microchip", "Adopted", "PreviousHomeID", "CurrentHomeID",
            "PhotoLocation", "LastModifiedOn", "LastModifiedBy", "CreatedOn", 
            "CreatedBy"
        };

        TableHasCorrectAttributes("Pet", expectedColumns);

    }

    /// <summary>
    /// Verifies that the 'Pet' table has the expected foreign key
    /// relationships.
    /// </summary>
    /// <remarks>This test ensures that the 'Pet' table contains the correct
    /// foreign keys as defined by the application's data model. It is intended
    /// to help maintain database schema integrity during development.</remarks>
    [TestMethod]
    public void PetHasCorrectForeignKeys()
    {
        string parentTable = "Pet"; // The table
                                    // containing the                                           
                                    // foreign keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
            ("PreviousHomeID", "House", "TUID")
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the 'House' table contains the expected set of
    /// attributes.
    /// </summary>
    /// <remarks>This test ensures that all required columns are present in the
    /// 'House' table schema. It is intended to catch schema changes that might
    /// affect application functionality or data integrity.</remarks>
    [TestMethod]
    public void HouseHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "Address", "City", "State", "Zip", "PhoneNumber",
            "RedFlag", "RedFlagReason", "CanFoster", "NoFosterUntil", "Notes",
            "isAdopter", "isFoster", "isActive", "IsIndividual", "HasFamily",
            "HasKids", "HasOtherPets", "CanAdopt", "NoAdoptUntil", 
            "LastModifiedOn", "LastModifiedBy", "CreatedOn", "CreatedBy"
        };

        TableHasCorrectAttributes("House", expectedColumns);

    }

    /// <summary>
    /// Verifies that the 'House' table contains the expected foreign key
    /// relationships.
    /// </summary>
    /// <remarks>This test ensures that the 'House' table's foreign key
    /// constraints match the expected schema definition. Use this test to
    /// detect unintended changes to the database schema that could affect data
    /// integrity.</remarks>
    [TestMethod]
    public void HouseHasCorrectForeignKeys()
    {
        string parentTable = "House"; // The table containing the foreign keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the 'Person' table contains the expected set of 
    /// attributes.
    /// </summary>
    /// <remarks>This test ensures that the 'Person' table schema includes all
    /// required columns. Use this test to detect unintended changes to the
    /// table's structure.</remarks>
    [TestMethod]
    public void PersonHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "FirstName", "LastName", "Email", "PhoneNumber", "HouseID",
            "VolunteerID", "LastModifiedOn", "LastModifiedBy", "CreatedOn", 
            "CreatedBy"
        };

        TableHasCorrectAttributes("Person", expectedColumns);

    }

    /// <summary>
    /// Verifies that the Person table contains the expected foreign key
    /// relationships to the House and Volunteer tables.
    /// </summary>
    /// <remarks>This test ensures that the Person table maintains correct
    /// referential integrity by checking for foreign keys to the House and
    /// Volunteer tables. It is intended to catch schema changes that might
    /// break expected relationships.</remarks>
    [TestMethod]
    public void PersonHasCorrectForeignKeys()
    {
        string parentTable = "Person"; // The table containing the foreign keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
            ("HouseID", "House", "TUID"),
            ("VolunteerID", "Volunteer", "TUID")
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the 'Volunteer' table contains the expected set of
    /// attributes.
    /// </summary>
    /// <remarks>This test ensures that the 'Volunteer' table schema includes
    /// all required columns and that their names match the expected values.
    /// Use this test to detect unintended changes to the table's structure.
    /// </remarks>
    [TestMethod]
    public void VolunteerHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "Notes", "LastModifiedBy", "LastModifiedOn", "CreatedOn", 
            "CreatedBY"
        };

        TableHasCorrectAttributes("Volunteer", expectedColumns);

    }

    /// <summary>
    /// Verifies that the Volunteer table has the expected foreign key
    /// relationships.
    /// </summary>
    /// <remarks>This test ensures that the Volunteer table's foreign keys
    /// match the defined expectations. Use this test to detect unintended
    /// changes to the database schema related to foreign key constraints.
    /// </remarks>
    [TestMethod]
    public void VolunteerHasCorrectForeignKeys()
    {
        string parentTable = "Volunteer"; // The table containing the foreign keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the 'User' table contains the expected set of attributes.
    /// </summary>
    /// <remarks>This test ensures that the 'User' table schema includes all
    /// required columns: TUID, RoleID, Name, UserName, Password, Email, and
    /// Notes. Use this test to detect unintended changes to the table's 
    /// structure.</remarks>
    [TestMethod]
    public void UserHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "RoleID", "Name", "UserName", "Password", "Email", "Notes"
        };

        TableHasCorrectAttributes("User", expectedColumns);

    }

    /// <summary>
    /// Verifies that the 'User' table contains the expected foreign key
    /// relationships.
    /// </summary>
    /// <remarks>This test ensures that the 'User' table has a foreign key from
    /// 'RoleID' to the 'TUID' column of the 'Role' table. Use this test to
    /// validate database schema integrity after changes to table
    /// relationships.</remarks>
    [TestMethod]
    public void UserHasCorrectForeignKeys()
    {
        string parentTable = "User"; // The table containing the foreign keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
            ("RoleID", "Role", "TUID")
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the 'Role' table contains the expected set of attributes.
    /// </summary>
    /// <remarks>This test ensures that all required columns are present in the
    /// 'Role' table schema. It is intended to catch schema changes that might
    /// affect application functionality or data integrity.</remarks>
    [TestMethod]
    public void RoleHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "RoleName", "RoleColor", "LastModifiedBy", 
            "LastModifiedOn", "CreatedOn", "CreatedBy", "PetManagement",
            "AdopterManagement", "FosterAndVolunteerManagement",
            "ApplicationsAndContacts", "FinancialManagement",
            "RolesAndContacts", "FinancialManagement", "RolesAndAccess",
            "DocumentsAndMeetings"
        };

        TableHasCorrectAttributes("Role", expectedColumns);

    }

    /// <summary>
    /// Verifies that the 'Role' table contains the expected foreign key
    /// relationships.
    /// </summary>
    /// <remarks>This test ensures that the foreign keys defined in the 'Role'
    /// table match the expected schema. Use this test to detect unintended
    /// changes to database relationships during development.</remarks>
    [TestMethod]
    public void RoleHasCorrectForeignKeys()
    {
        string parentTable = "Role"; // The table containing the foreign keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the "Event" table contains the expected set of
    /// attributes.
    /// </summary>
    /// <remarks>This test ensures that the "Event" table schema includes all
    /// required columns and that their names match the expected values. Use
    /// this test to detect unintended changes to the table's structure.
    /// </remarks>
    [TestMethod]
    public void EventHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "Name", "Description", "Date", "Recurring", "DayPeriod",
            "LastModifiedOn", "LastModifiedBy", "CreatedOn", "CreatedBy"
        };

        TableHasCorrectAttributes("Event", expectedColumns);
    }

    /// <summary>
    /// Verifies that the 'Event' table has the correct foreign key
    /// relationships defined.
    /// </summary>
    /// <remarks>This test ensures that the foreign keys in the 'Event' table
    /// match the expected configuration. Use this test to validate database
    /// schema integrity when making changes to related tables.</remarks>
    [TestMethod]
    public void EventHasCorrectForeignKeys()
    {
        string parentTable = "Event"; // The table containing the foreign keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the 'RelationshipPersonEvent' table in the database
    /// contains the expected columns.
    /// </summary>
    /// <remarks>This test ensures that the table schema includes only the
    /// 'TUID', 'PersonID', and 'EventID' columns. The test will fail if any
    /// expected column is missing or if any unexpected column is present.
    /// </remarks>
    [TestMethod]
    public void RelationshipPersonEventHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "PersonID", "EventID"
        }; 
           
        TableHasCorrectAttributes("RelationshipPersonEvent", expectedColumns);

    }

    /// <summary>
    /// Verifies that the 'RelationshipPersonEvent' table contains the correct
    /// foreign key relationships to the 'Person' and 'Event' tables.
    /// </summary>
    /// <remarks>This test ensures that the 'PersonID' and 'EventID' columns in
    /// the 'RelationshipPersonEvent' table are properly configured as foreign
    /// keys referencing the 'TUID' columns in the 'Person' and 'Event' tables,
    /// respectively. Use this test to detect schema changes that might break
    /// expected database relationships.</remarks>
    [TestMethod]
    public void RelationshipPersonEventHasCorrectForeignKeys()
    {
        string parentTable = "RelationshipPersonEvent"; // The table
                                                           // containing the 
                                                           // foreign keys

        var expectedForeignKeys = new List<(string parentColumn, 
            string referencedTable, string referencedColumn)>
        {
            ("PersonID", "Person", "TUID"),
            ("EventID", "Event", "TUID")
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the PetAdoption table contains the expected set of
    /// attributes.
    /// </summary>
    /// <remarks>This test ensures that the PetAdoption table schema includes
    /// all required columns and that their names match the expected values.
    /// Use this test to detect unintended changes to the table's structure
    /// during development.</remarks>
    [TestMethod]
    public void PetAdoptionHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "AdoptionStatus", "PetID", "AdoptionStartDate",
            "AdoptionEndDate", "LastModifiedOn", "LastModifiedBy", "HouseID"
        };

        TableHasCorrectAttributes("PetAdoption", expectedColumns);
    }

    /// <summary>
    /// Verifies that the PetAdoption table defines the correct foreign key
    /// relationships to the Pet and House tables.
    /// </summary>
    /// <remarks>This test ensures that the PetAdoption table includes foreign
    /// keys referencing the TUID columns of both the Pet and House tables. Use
    /// this test to validate database schema integrity after changes to
    /// table relationships.</remarks>
    [TestMethod]
    public void PetAdoptionHasCorrectForeignKeys()
    {
        string parentTable = "PetAdoption"; // The table
                                                        // containing the 
                                                        // foreign keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
            ("PetID", "Pet", "TUID"),
            ("HouseID", "House", "TUID")
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the PetFoster table contains the expected set of
    /// attributes.
    /// </summary>
    /// <remarks>This test ensures that the PetFoster table schema includes all
    /// required columns and that their names match the expected values. Use
    /// this test to detect unintended changes to the table's structure.
    /// </remarks>
    [TestMethod]
    public void PetFosterHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "PetID", "HouseID", "FosterStartDate", "FosterEndDate", 
            "Status", "LastModifiedBy", "LastModifiedOn", "CreatedBy",
            "CreatedOn"
        };

        TableHasCorrectAttributes("PetFoster", expectedColumns);
    }

    /// <summary>
    /// Verifies that the PetFoster table has the correct foreign key
    /// relationships to the Pet and House tables.
    /// </summary>
    /// <remarks>This test ensures that the PetFoster table maintains
    /// referential integrity by checking for the presence of expected foreign
    /// keys. It is intended to catch schema changes that might break
    /// relationships between PetFoster, Pet, and House tables.</remarks>
    [TestMethod]
    public void PetFosterHasCorrectForeignKeys()
    {
        string parentTable = "PetFoster"; // The table
                                            // containing the 
                                            // foreign keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
            ("PetID", "Pet", "TUID"),
            ("HouseID", "House", "TUID")
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the 'Vaccine' table contains the expected set of
    /// attributes.
    /// </summary>
    /// <remarks>This test ensures that the 'Vaccine' table includes the
    /// columns 'TUID', 'Type', 'Notes', 'DateGiven', 'DateDue', and 'PetID'.
    /// Use this test to validate schema consistency after database changes.
    /// </remarks>
    [TestMethod]
    public void VaccineHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "Type", "Notes", "DateGiven", "DateDue", "PetID"
        };

        TableHasCorrectAttributes("Vaccine", expectedColumns);
    }

    /// <summary>
    /// Verifies that the Vaccine table contains the expected foreign key
    /// relationships.
    /// </summary>
    /// <remarks>This test ensures that the Vaccine table has a foreign key
    /// from the PetID column to the TUID column of the Pet table. Use this
    /// test to detect schema changes that may affect data integrity or
    /// application logic.</remarks>
    [TestMethod]
    public void VaccineHasCorrectForeignKeys()
    {
        string parentTable = "Vaccine"; // The table
                                          // containing the 
                                          // foreign keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
            ("PetID", "Pet", "TUID")
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the "Prevention" table contains the expected set of
    /// attributes.
    /// </summary>
    /// <remarks>This test ensures that the "Prevention" table schema includes
    /// the required columns: "TUID", "Type", "Notes", "DateGiven", "DateDue",
    /// and "PetID". Use this test to detect unintended changes to the table's
    /// structure.</remarks>
    [TestMethod]
    public void PreventionHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "Type", "Notes", "DateGiven", "DateDue", "PetID"
        };

        TableHasCorrectAttributes("Prevention", expectedColumns);
    }

    /// <summary>
    /// Verifies that the 'Prevention' table has the correct foreign key
    /// relationships defined.
    /// </summary>
    /// <remarks>This test ensures that the 'Prevention' table includes all
    /// expected foreign keys, helping to maintain referential integrity in the
    /// database schema. Update this test if the foreign key structure of the
    /// 'Prevention' table changes.</remarks>
    [TestMethod]
    public void PreventionHasCorrectForeignKeys()
    {
        string parentTable = "Prevention"; // The table containing the foreign
                                           // keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
            ("PetID", "Pet", "TUID")
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the "Surgery" table has the expected set of attributes.
    /// </summary>
    /// <remarks>This test ensures that the "Surgery" table contains the
    /// required columns: "TUID", "Name", "Description", "Date", and "PetID".
    /// Use this test to validate schema consistency after changes to the data
    /// model.</remarks>
    [TestMethod]
    public void SurgeryHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "Name", "Description", "Date", "PetID"
        };

        TableHasCorrectAttributes("Surgery", expectedColumns);
    }

    /// <summary>
    /// Verifies that the Surgery table has the correct foreign key
    /// relationships defined.
    /// </summary>
    /// <remarks>This test ensures that the Surgery table includes all expected
    /// foreign keys and that they reference the correct tables and columns.
    /// Use this test to validate database schema integrity after changes to
    /// the Surgery table or its related entities.</remarks>
    [TestMethod]
    public void SurgeryHasCorrectForeignKeys()
    {
        string parentTable = "Surgery"; // The table containing the foreign
                                           // keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
            ("PetID", "Pet", "TUID")
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the 'VetVisit' table contains the expected set of
    /// attributes.
    /// </summary>
    /// <remarks>This test ensures that the 'VetVisit' table schema includes
    /// the required columns: 'TUID', 'Name', 'Description', 'Date', and
    /// 'PetID'. Use this test to validate that changes to the data model do
    /// not remove or rename these essential attributes.</remarks>
    [TestMethod]
    public void VetVisitHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "Name", "Description", "Date", "PetID"
        };

        TableHasCorrectAttributes("VetVisit", expectedColumns);
    }

    /// <summary>
    /// Verifies that the VetVisit table defines the expected foreign key
    /// relationships.
    /// </summary>
    /// <remarks>This test ensures that the VetVisit table contains a foreign
    /// key from the PetID column to the TUID column of the Pet table. Use this
    /// test to validate database schema integrity after changes to table
    /// relationships.</remarks>
    [TestMethod]
    public void VetVisitHasCorrectForeignKeys()
    {
        string parentTable = "VetVisit"; // The table containing the foreign
                                        // keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
            ("PetID", "Pet", "TUID")
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the 'VetVisit' folder contains the expected set of
    /// attributes.
    /// </summary>
    /// <remarks>This test checks that the 'VetVisit' table includes the
    /// required columns: 'TUID', 'FolderName', 'LastModifiedOn',
    /// 'LastModifiedBy', 'CreatedOn', and 'CreatedBy'. Use this test to ensure
    /// schema consistency after changes to the data model.</remarks>
    [TestMethod]
    public void FolderHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "FolderName", "LastModifiedOn", "LastModifiedBy", 
            "CreatedOn", "CreatedBy"
        };

        TableHasCorrectAttributes("Folder", expectedColumns);
    }

    /// <summary>
    /// Verifies that the Folder table contains the expected foreign key
    /// relationships.
    /// </summary>
    /// <remarks>This test ensures that the Folder table's foreign keys are
    /// correctly defined according to the expected schema. Use this test to
    /// detect unintended changes to database relationships during development.
    /// </remarks>
    [TestMethod]
    public void FolderHasCorrectForeignKeys()
    {
        string parentTable = "Folder"; // The table containing the foreign
                                         // keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
            
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the 'File' table contains the expected set of attributes.
    /// </summary>
    /// <remarks>This test ensures that the 'File' table schema includes all
    /// required columns. Use this test to detect unintended changes to the
    /// table's structure during development or refactoring.</remarks>
    [TestMethod]
    public void FileHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "FileLocation", "FileName", "IsReviewed",
            "IsPolicyProcedure", "PetID", "LastModifiedOn", "LastModifiedBy",
            "CreatedOn", "CreatedBy", "FolderID"
        };

        TableHasCorrectAttributes("File", expectedColumns);
    }

    /// <summary>
    /// Verifies that the 'File' table contains the expected foreign key
    /// relationships to the 'Pet' and 'Folder' tables.
    /// </summary>
    /// <remarks>This test ensures that the 'File' table maintains referential
    /// integrity by checking for foreign keys on 'PetID' and 'FolderID'
    /// columns. Use this test to validate database schema changes that may
    /// affect foreign key constraints.</remarks>
    [TestMethod]
    public void FileHasCorrectForeignKeys()
    {
        string parentTable = "File"; // The table containing the foreign keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
            ("PetID", "Pet", "TUID"),
            ("FolderID", "Folder", "TUID")
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the 'Revenue' table contains the expected set of
    /// attributes.
    /// </summary>
    /// <remarks>This test ensures that the 'Revenue' table schema includes all
    /// required columns and that their names match the expected values. Use
    /// this test to detect unintended changes to the table's structure during
    /// development or refactoring. Update this test if the schema of the
    /// 'Revenue' table changes to maintain test accuracy and relevance.
    /// </remarks>
    [TestMethod]
    public void RevenueHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "Date", "Category", "Description", "Amount", "PayMethod",
            "Person", "LastModifiedOn", "LastModifiedBy", "CreatedOn",
            "CreatedBy"
        };

        TableHasCorrectAttributes("Revenue", expectedColumns);
    }

    /// <summary>
    /// Verifies that the 'Revenue' table contains the expected foreign key
    /// relationships.
    /// </summary>
    /// <remarks>This test ensures that the 'Revenue' table's foreign keys are
    /// correctly defined according to the expected schema. Use this test to 
    /// detect unintended changes to database relationships during development
    /// or refactoring. Update this test if the foreign key structure of the 
    /// 'Revenue' table changes to maintain test accuracy and relevance.
    /// </remarks>
    [TestMethod]
    public void RevenueHasCorrectForeignKeys()
    {
        string parentTable = "Revenue"; // The table containing the foreign keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {
           
        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }

    /// <summary>
    /// Verifies that the 'Expense' table contains the expected set of
    /// attributes.
    /// </summary>
    /// <remarks>This test ensures that the 'Expense' table schema includes all
    /// required columns and that their names match the expected values. Use
    /// this test to detect unintended changes to the table's structure during 
    /// development or refactoring. Update this test if the schema of the 'Expense' 
    /// table changes to maintain test accuracy and relevance.</remarks>
    [TestMethod]
    public void ExpenseHasCorrectAttributes()
    {
        // To store column names for quick lookup
        var expectedColumns = new HashSet<string>
        {
            "TUID", "Date", "Category", "Vendor", "Description", "Amount",
            "PayMethod", "LastModifiedOn", "LastModifiedBy", "CreatedOn",
            "CreatedBy"
        };

        TableHasCorrectAttributes("Expense", expectedColumns);
    }

    /// <summary>
    /// Verifies that the 'Expense' table contains the expected foreign key 
    /// relationships.
    /// </summary>
    /// <remarks>This test ensures that the 'Expense' table's foreign keys are 
    /// correctly defined according to the expected schema. Use this test to
    /// detect unintended changes to database relationships during development
    /// or refactoring. Update this test if the foreign key structure of the
    /// 'Expense' table changes to maintain test accuracy and relevance
    /// .</remarks>
    [TestMethod]
    public void ExpenseHasCorrectForeignKeys()
    {
        string parentTable = "Expense"; // The table containing the foreign
                                        // keys

        var expectedForeignKeys = new List<(string parentColumn,
            string referencedTable, string referencedColumn)>
        {

        }; // The list of expected foreign keys in RelationshipPersonEvent

        checkForeignKeys(parentTable, expectedForeignKeys);
    }
}

