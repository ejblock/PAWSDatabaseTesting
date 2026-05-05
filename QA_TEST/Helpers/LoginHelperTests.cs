using System;
using System.Reflection;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using PAWS.WinForms.Helpers;

namespace QA_TEST.Helpers
{
    /// <summary>
    /// FILENAME: LoginHelperTests.cs
    /// 
    /// WRITTEN BY: Rosh Mizoory
    /// DATE CREATED: March 20, 2026
    /// 
    /// PART OF PROJECT: QA_TEST
    /// 
    /// FILE PURPOSE:
    /// These tests check the safe local logic in LoginHelper that does not require a live database.
    /// I focused on empty credential handling, logout behavior, and permission parsing because those
    /// are deterministic and can be verified cleanly in automated tests.
    /// </summary>
    [TestClass]
    public class LoginHelperTests
    {
        [TestInitialize]
        public void Setup()
        {
            // Reset session state before every test so one test does not affect another.
            LoginHelper.Logout();
        }

        [TestMethod]
        public void ValidateLogin_ReturnsFalse_WhenUsernameIsEmpty()
        {
            // Act
            bool result = LoginHelper.ValidateLogin(string.Empty, "password");

            // Assert
            Assert.IsFalse(result,
                "Login should fail when the username is blank.");
        }

        [TestMethod]
        public void ValidateLogin_ReturnsFalse_WhenPasswordIsEmpty()
        {
            // Act
            bool result = LoginHelper.ValidateLogin("rosh", string.Empty);

            // Assert
            Assert.IsFalse(result,
                "Login should fail when the password is blank.");
        }

        [TestMethod]
        public void ValidateLogin_ReturnsFalse_WhenUsernameAndPasswordAreWhitespace()
        {
            // Act
            bool result = LoginHelper.ValidateLogin("   ", "   ");

            // Assert
            Assert.IsFalse(result,
                "Login should fail when both fields are just whitespace.");
        }

        [TestMethod]
        public void Logout_ClearsCurrentUserAndCurrentRole()
        {
            // Act
            LoginHelper.Logout();

            // Assert
            Assert.IsNull(LoginHelper.CurrentUser,
                "CurrentUser should be null after logout.");
            Assert.IsNull(LoginHelper.CurrentRole,
                "CurrentRole should be null after logout.");
        }

        [TestMethod]
        public void ParseBooleanPermission_ReturnsTrue_ForAcceptedTrueValues()
        {
            // Arrange
            MethodInfo parseMethod = GetParseBooleanPermissionMethod();

            // Act
            bool oneValue = InvokeParseBooleanPermission(parseMethod, "1");
            bool trueValue = InvokeParseBooleanPermission(parseMethod, "true");
            bool fullValue = InvokeParseBooleanPermission(parseMethod, "full");
            bool yesValue = InvokeParseBooleanPermission(parseMethod, "yes");

            // Assert
            Assert.IsTrue(oneValue, "The string '1' should be treated as true.");
            Assert.IsTrue(trueValue, "The string 'true' should be treated as true.");
            Assert.IsTrue(fullValue, "The string 'full' should be treated as true.");
            Assert.IsTrue(yesValue, "The string 'yes' should be treated as true.");
        }

        [TestMethod]
        public void ParseBooleanPermission_ReturnsFalse_ForUnexpectedOrBlankValues()
        {
            // Arrange
            MethodInfo parseMethod = GetParseBooleanPermissionMethod();

            // Act
            bool nullValue = InvokeParseBooleanPermission(parseMethod, null);
            bool blankValue = InvokeParseBooleanPermission(parseMethod, "   ");
            bool zeroValue = InvokeParseBooleanPermission(parseMethod, "0");
            bool noValue = InvokeParseBooleanPermission(parseMethod, "no");

            // Assert
            Assert.IsFalse(nullValue, "Null should be treated as false.");
            Assert.IsFalse(blankValue, "Blank text should be treated as false.");
            Assert.IsFalse(zeroValue, "The string '0' should be treated as false.");
            Assert.IsFalse(noValue, "The string 'no' should be treated as false.");
        }

        private static MethodInfo GetParseBooleanPermissionMethod()
        {
            MethodInfo? parseMethod = typeof(LoginHelper).GetMethod(
                "ParseBooleanPermission",
                BindingFlags.NonPublic | BindingFlags.Static);

            Assert.IsNotNull(parseMethod,
                "The ParseBooleanPermission method should exist on LoginHelper.");

            return parseMethod!;
        }

        private static bool InvokeParseBooleanPermission(MethodInfo parseMethod, string? rawValue)
        {
            object? result = parseMethod.Invoke(null, new object?[] { rawValue });

            Assert.IsNotNull(result,
                "ParseBooleanPermission should return a bool result.");

            return (bool)result;
        }
    }
}