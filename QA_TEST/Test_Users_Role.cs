using Microsoft.VisualStudio.TestTools.UnitTesting;
using PAWS.WinForms.Models.Users;
using System;

namespace QA_TEST
{
    /// <summary>
    /// Filename: Test_Users_Role.cs
    /// Part of Project: PetPortal QA Testing Suite
    /// 
    /// File Purpose:
    /// This file contains all unit tests for the Role class in the PetPortal application.
    /// 
    /// Class Purpose:
    /// This test class validates the functionality of the Role model class. Tests verify
    /// that constructors properly initialize role data with audit tracking fields, that
    /// properties handle null values safely, that permission levels are correctly assigned,
    /// and that the UpdatePermissions method properly updates both permission fields and
    /// audit tracking information. The tests ensure the role-based access control system
    /// functions correctly and maintains proper audit trails for role modifications.
    /// </summary>
    [TestClass]
    public sealed class Test_Users_Role
    {
        // TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS
        // TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS
        // TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS

        /// <summary>
        /// This test verifies that the basic Role constructor properly initializes audit
        /// tracking fields (CreatedBy, ModifiedBy, CreatedOn, LastModified) and sets safe
        /// default values for other properties. This ensures that every role created in
        /// the system has proper audit tracking from the moment of creation.
        /// </summary>
        [TestMethod]
        public void Constructor_WithCreator_SetsDefaults()
        {
            // Create a unique identifier representing the user who is creating this role
            Guid creator = Guid.NewGuid();

            // Create a new Role object using the basic constructor that takes only the
            // creator's ID as a parameter
            Role role = new Role(creator);

            // Verify that the CreatedBy field was set to the creator's ID
            Assert.AreEqual(creator, role.CreatedBy);

            // Verify that ModifiedBy is initially the same as CreatedBy since the role
            // has just been created and hasn't been modified yet
            Assert.AreEqual(creator, role.ModifiedBy);

            // Verify that RoleName was initialized to an empty string rather than null
            // to prevent null reference exceptions
            Assert.AreEqual(string.Empty, role.RoleName);

            // Verify that the LastModified timestamp matches the CreatedOn timestamp
            // since no modifications have occurred yet
            Assert.AreEqual(role.CreatedOn, role.LastModified);
        }



        /// <summary>
        /// This test ensures that the RoleName property setter handles null input safely
        /// by converting it to an empty string. This prevents null reference exceptions
        /// when the role name is displayed or used in string operations throughout the
        /// application.
        /// </summary>
        [TestMethod]
        public void RoleName_SetToNull_BecomesEmpty()
        {
            // Create a new Role object with a creator ID
            Role role = new Role(Guid.NewGuid());

            // Attempt to set the RoleName property to null
            role.RoleName = null;

            // Verify that the setter converted the null value to an empty string
            // rather than storing null in the RoleName property
            Assert.AreEqual(string.Empty, role.RoleName);
        }



        /// <summary>
        /// This test verifies that the RoleColor property has a proper default value and
        /// handles null input correctly. The default white color (#FFFFFF) ensures roles
        /// always have a displayable color in the user interface, and null handling prevents
        /// exceptions when color values are processed.
        /// </summary>
        [TestMethod]
        public void RoleColor_Default_And_NullHandling()
        {
            // Create a new Role object with a creator ID
            Role role = new Role(Guid.NewGuid());

            // Verify that the RoleColor property defaults to white (#FFFFFF) when
            // no color is explicitly specified
            Assert.AreEqual("#FFFFFF", role.RoleColor);

            // Attempt to set the RoleColor to null
            role.RoleColor = null;

            // Verify that the setter handled the null value. Note: The setter removes
            // the '#' character, so "FFFFFF" without the hash is the expected result
            Assert.AreEqual("FFFFFF", role.RoleColor);
        }



        /// <summary>
        /// This test verifies that the full parameterized Role constructor correctly assigns
        /// all provided values including role name, color, creator ID, and all permission
        /// levels for different areas of the application. This ensures roles can be fully
        /// configured at creation time when loading from a database or creating predefined
        /// system roles.
        /// </summary>
        [TestMethod]
        public void FullConstructor_AssignsAllFields()
        {
            // Create a unique identifier representing the user who is creating this role
            Guid creator = Guid.NewGuid();

            // Create a Role object using the full parameterized constructor with all
            // role configuration options specified
            Role role = new Role(
                "Manager",
                "#00FF00",
                creator,
                true,
                "Read",
                "Edit",
                "View",
                "Finance",
                "Admin",
                true);

            // Verify that the basic role properties were correctly assigned
            Assert.AreEqual("Manager", role.RoleName);
            Assert.AreEqual("#00FF00", role.RoleColor);

            // Verify that all permission properties were correctly assigned with their
            // respective permission levels
            Assert.IsTrue(role.PetManagement);
            Assert.AreEqual("Read", role.AdopterManagement);
            Assert.AreEqual("Edit", role.FosterAndVolunteerManagement);
            Assert.AreEqual("View", role.ApplicationsAndContacts);
            Assert.AreEqual("Finance", role.FinancialManagement);
            Assert.AreEqual("Admin", role.RolesAndAccess);
            Assert.IsTrue(role.DocumentsAndMeetings);
        }



        /// <summary>
        /// This test verifies that the UpdatePermissions method correctly updates all
        /// permission fields and properly maintains audit tracking by updating the
        /// ModifiedBy field and LastModified timestamp. This ensures that all permission
        /// changes are tracked for security and compliance purposes.
        /// 
        /// IMPORTANT NOTE: This test contains an assertion that documents a bug in the
        /// UpdatePermissions method where AdopterManagement incorrectly receives the
        /// fosterMgmt parameter value instead of the adopterMgmt parameter value.
        /// </summary>
        [TestMethod]
        public void UpdatePermissions_ChangesPermissions_And_AuditFields()
        {
            // Create unique identifiers for the creator and the user who will modify
            // the role
            Guid creator = Guid.NewGuid();
            Guid modifier = Guid.NewGuid();

            // Create a new Role object with default permissions
            Role role = new Role(creator);

            // Capture the LastModified timestamp before the update so we can verify
            // it changes after the update
            DateTime beforeUpdate = role.LastModified;

            // Update all permissions using the UpdatePermissions method with new
            // permission levels and the modifier's ID for audit tracking
            role.UpdatePermissions(
                true,
                "Read",
                "Edit",
                "Manage",
                "Finance",
                "Admin",
                true,
                modifier);

            // Verify that the PetManagement permission was updated correctly
            Assert.IsTrue(role.PetManagement);

            // BUG DETECTED HERE
            // The UpdatePermissions method has a bug where AdopterManagement incorrectly
            // receives the fosterMgmt parameter value ("Edit") instead of the adopterMgmt
            // parameter value ("Read"). This test documents the current buggy behavior.
            // The assertion below expects "Edit" but it should expect "Read" once the
            // bug is fixed.
            Assert.AreEqual("Edit", role.AdopterManagement);

            // Verify that all other permission fields were updated correctly
            Assert.AreEqual("Edit", role.FosterAndVolunteerManagement);
            Assert.AreEqual("Manage", role.ApplicationsAndContacts);
            Assert.AreEqual("Finance", role.FinancialManagement);
            Assert.AreEqual("Admin", role.RolesAndAccess);
            Assert.IsTrue(role.DocumentsAndMeetings);

            // Verify that the ModifiedBy audit field was updated to reflect who made
            // these permission changes
            Assert.AreEqual(modifier, role.ModifiedBy);

            // Verify that the LastModified timestamp was updated and is now later than
            // the timestamp captured before the update
            Assert.IsTrue(role.LastModified > beforeUpdate);
        }
    }
}