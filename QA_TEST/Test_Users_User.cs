using Microsoft.VisualStudio.TestTools.UnitTesting;
using PAWS.WinForms.Models.Users;
using System;

namespace QA_TEST
{
    /// <summary>
    /// Filename: Test_Users_User.cs
    /// Part of Project: PetPortal QA Testing Suite
    /// 
    /// File Purpose:
    /// This file contains all unit tests for the User class in the PetPortal application.
    /// 
    /// Class Purpose:
    /// This test class validates the functionality of the User model class. Tests verify
    /// that both constructors properly initialize user data, that property setters handle
    /// null values safely by converting them to empty strings, and that all mutation methods
    /// (ChangeEmail, ChangePassword, ChangeRole) correctly update their respective fields.
    /// The tests ensure data integrity and prevent null reference exceptions in the User model.
    /// </summary>
    [TestClass]
    public sealed class Test_Users_User
    {
        // TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS
        // TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS
        // TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS -- TESTS

        /// <summary>
        /// This test verifies that the default (parameterless) User constructor properly
        /// initializes all string properties to empty strings rather than null values.
        /// This is critical for preventing null reference exceptions throughout the 
        /// application when User objects are created without initial data.
        /// </summary>
        [TestMethod]
        public void DefaultConstructor_InitializesEmptyStrings()
        {
            // Create a new User object using the default constructor with no parameters
            User user = new User();

            // Verify that all string properties have been initialized to empty strings
            // rather than null values, which prevents null reference exceptions
            Assert.AreEqual(string.Empty, user.Name);
            Assert.AreEqual(string.Empty, user.Username);
            Assert.AreEqual(string.Empty, user.Password);
            Assert.AreEqual(string.Empty, user.Email);
            Assert.AreEqual(string.Empty, user.Notes);
        }



        /// <summary>
        /// This test verifies that the parameterized User constructor correctly assigns
        /// all provided values to their corresponding properties. This ensures that when
        /// a User is created with full information (such as when loading from a database),
        /// all fields are properly populated.
        /// </summary>
        [TestMethod]
        public void Constructor_WithParameters_AssignsFields()
        {
            // Create a new unique identifier to represent the user's role in the system
            Guid roleId = Guid.NewGuid();

            // Create a User object using the full parameterized constructor with all
            // required user information
            User user = new User(
                "Katie Messana",
                "kmessana",
                "SecurePass123",
                "katie@email.com",
                "Shelter manager",
                roleId);

            // Verify that each parameter was correctly assigned to its corresponding
            // property in the User object
            Assert.AreEqual("Katie Messana", user.Name);
            Assert.AreEqual("kmessana", user.Username);
            Assert.AreEqual("SecurePass123", user.Password);
            Assert.AreEqual("katie@email.com", user.Email);
            Assert.AreEqual("Shelter manager", user.Notes);
            Assert.AreEqual(roleId, user.RoleID);
        }



        /// <summary>
        /// This test ensures that the ChangeEmail method handles null input safely by
        /// converting it to an empty string rather than storing null. This is important
        /// for preventing null reference exceptions when the email property is accessed
        /// or displayed in the user interface.
        /// </summary>
        [TestMethod]
        public void ChangeEmail_ToNull_BecomesEmptyString()
        {
            // Create a new User object with default values
            User user = new User();

            // Attempt to set the email to null using the ChangeEmail method
            user.ChangeEmail(null);

            // Verify that the method converted the null value to an empty string
            // rather than storing null in the Email property
            Assert.AreEqual(string.Empty, user.Email);
        }



        /// <summary>
        /// This test ensures that the ChangePassword method handles null input safely by
        /// converting it to an empty string rather than storing null. This prevents null
        /// reference exceptions when password validation or authentication operations are
        /// performed.
        /// </summary>
        [TestMethod]
        public void ChangePassword_ToNull_BecomesEmptyString()
        {
            // Create a new User object with default values
            User user = new User();

            // Attempt to set the password to null using the ChangePassword method
            user.ChangePassword(null);

            // Verify that the method converted the null value to an empty string
            // rather than storing null in the Password property
            Assert.AreEqual(string.Empty, user.Password);
        }



        /// <summary>
        /// This test verifies that the ChangeEmail method correctly updates the Email
        /// property when provided with a valid email string. This ensures the method
        /// works properly for normal use cases where valid email addresses are provided.
        /// </summary>
        [TestMethod]
        public void ChangeEmail_UpdatesValue()
        {
            // Create a new User object with default values
            User user = new User();

            // Update the email address using the ChangeEmail method
            user.ChangeEmail("new@email.com");

            // Verify that the Email property was successfully updated with the new
            // email address
            Assert.AreEqual("new@email.com", user.Email);
        }



        /// <summary>
        /// This test verifies that the ChangePassword method correctly updates the Password
        /// property when provided with a valid password string. This ensures the method
        /// functions properly when users change their passwords or when passwords are
        /// updated administratively.
        /// </summary>
        [TestMethod]
        public void ChangePassword_UpdatesValue()
        {
            // Create a new User object with default values
            User user = new User();

            // Update the password using the ChangePassword method
            user.ChangePassword("NewPassword!");

            // Verify that the Password property was successfully updated with the new
            // password value
            Assert.AreEqual("NewPassword!", user.Password);
        }



        /// <summary>
        /// This test verifies that the ChangeRole method correctly updates the RoleID
        /// property when a user's role is changed. This is important for the application's
        /// role-based access control system, ensuring users can be reassigned to different
        /// roles with different permission levels.
        /// </summary>
        [TestMethod]
        public void ChangeRole_UpdatesRoleID()
        {
            // Create a new User object with default values
            User user = new User();

            // Generate a new unique identifier to represent a different role
            Guid newRole = Guid.NewGuid();

            // Update the user's role using the ChangeRole method
            user.ChangeRole(newRole);

            // Verify that the RoleID property was successfully updated with the new
            // role identifier
            Assert.AreEqual(newRole, user.RoleID);
        }



        /// <summary>
        /// This test verifies that the public properties Name, Username, and Notes can be
        /// directly assigned values through their property setters. This ensures that these
        /// properties work correctly for normal assignment operations throughout the
        /// application where direct property access is used.
        /// </summary>
        [TestMethod]
        public void PublicProperties_CanBeAssigned()
        {
            // Create a new User object with default values
            User user = new User();

            // Assign values directly to the public properties using standard property
            // assignment syntax
            user.Name = "Alice";
            user.Username = "alice01";
            user.Notes = "Volunteer coordinator";

            // Verify that each property was successfully assigned its new value
            Assert.AreEqual("Alice", user.Name);
            Assert.AreEqual("alice01", user.Username);
            Assert.AreEqual("Volunteer coordinator", user.Notes);
        }
    }
}