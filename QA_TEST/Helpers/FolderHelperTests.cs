using System;
using System.Reflection;
using Microsoft.Data.SqlClient;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace QA_TEST.Helpers
{
    /// <summary>
    /// FILENAME: FolderHelperTests.cs
    /// 
    /// WRITTEN BY: Rosh Mizoory
    /// DATE CREATED: March 17, 2026
    /// 
    /// PART OF PROJECT: QA_TEST
    /// 
    /// FILE PURPOSE:
    /// These tests check the local object behavior of FolderHelper without
    /// depending on a live SQL Server connection. Since this helper is internal, 
    /// I used reflection where needed.
    /// </summary>
    [TestClass]
    public class FolderHelperTests
    {

        private const string FolderHelperTypeName =
            "PetPortal.WinForms.Helpers.Documents.FolderHelper, PAWS.WinForms";

        [TestMethod]
        public void Constructor_InitializesConnectionStringFoldersAndParameters()
        {
            // Arrange
            object helper = CreateFolderHelper();
            Type helperType = helper.GetType();

            // Act
            string connectionString =
                (string)helperType.GetProperty("ConnectionString")!.GetValue(helper)!;

            object folders =
                helperType.GetProperty("Folders")!.GetValue(helper)!;

            object parameters =
                helperType.GetProperty("Parameters")!.GetValue(helper)!;

            int folderCount =
                (int)folders.GetType().GetProperty("Count")!.GetValue(folders)!;

            int parameterCount =
                (int)parameters.GetType().GetProperty("Count")!.GetValue(parameters)!;

            // Assert
            Assert.IsFalse(string.IsNullOrWhiteSpace(connectionString),
                "The helper should start with a connection string.");

            Assert.IsNotNull(folders,
                "The helper should initialize its folder list in the constructor.");

            Assert.IsNotNull(parameters,
                "The helper should initialize its parameter list in the constructor.");

            Assert.AreEqual(0, folderCount,
                "The folder list should start empty.");

            Assert.AreEqual(0, parameterCount,
                "The parameter list should start empty.");
        }

        [TestMethod]
        public void GetRootFolders_ClearsOldFoldersAndParameters_BeforeExecution()
        {
            // Arrange
            object helper = CreateFolderHelper();
            Type helperType = helper.GetType();

            // Add old folder and parameter values so the method has something to clear.
            SeedFolderAndParameterState(helperType, helper);

            // Act
            // This checks the local setup work done before the stored procedure call begins.
            helperType.GetMethod("GetRootFolders")!.Invoke(helper, null);

            // Assert
            object folders =
                helperType.GetProperty("Folders")!.GetValue(helper)!;

            object parameters =
                helperType.GetProperty("Parameters")!.GetValue(helper)!;

            int parameterCount =
                (int)parameters.GetType().GetProperty("Count")!.GetValue(parameters)!;

            Assert.AreEqual(0, parameterCount,
                "GetRootFolders should clear old SQL parameters before it runs.");

            Assert.IsNotNull(folders,
                "The folders list should still exist after the method call.");
        }

        [TestMethod]
        public void GetNextLayerFolders_AddsFolderIdParameter()
        {
            // Arrange
            object helper = CreateFolderHelper();
            Type helperType = helper.GetType();

            // Act
            // This checks that the helper builds the correct SQL parameter locally.
            helperType.GetMethod("getNextLayerFolders")!
                .Invoke(helper, new object[] { 42 });

            // Assert
            object parameters =
                helperType.GetProperty("Parameters")!.GetValue(helper)!;

            int parameterCount =
                (int)parameters.GetType().GetProperty("Count")!.GetValue(parameters)!;

            object firstParameter =
                parameters.GetType().GetProperty("Item")!.GetValue(parameters, new object[] { 0 })!;

            string parameterName =
                (string)firstParameter.GetType().GetProperty("ParameterName")!.GetValue(firstParameter)!;

            object value =
                firstParameter.GetType().GetProperty("Value")!.GetValue(firstParameter)!;

            Assert.AreEqual(1, parameterCount,
                "Exactly one parameter should be added for child folder loading.");

            Assert.AreEqual("@FolderID", parameterName,
                "The helper should use @FolderID when loading the next layer.");

            Assert.AreEqual(42, Convert.ToInt32(value),
                "The folder id value should match the value passed into the method.");
        }

        [TestMethod]
        public void GetFolderId_AddsFolderNameParameter()
        {
            // Arrange
            object helper = CreateFolderHelper();
            Type helperType = helper.GetType();

            // Act
            // This checks that getFolderID prepares the expected path parameter locally.
            helperType.GetMethod("getFolderID")!
                .Invoke(helper, new object[] { "/Docs/SubFolder" });

            // Assert
            object parameters =
                helperType.GetProperty("Parameters")!.GetValue(helper)!;

            int parameterCount =
                (int)parameters.GetType().GetProperty("Count")!.GetValue(parameters)!;

            object firstParameter =
                parameters.GetType().GetProperty("Item")!.GetValue(parameters, new object[] { 0 })!;

            string parameterName =
                (string)firstParameter.GetType().GetProperty("ParameterName")!.GetValue(firstParameter)!;

            string value =
                firstParameter.GetType().GetProperty("Value")!.GetValue(firstParameter)?.ToString()
                ?? string.Empty;

            Assert.AreEqual(1, parameterCount,
                "getFolderID should prepare exactly one SQL parameter.");

            Assert.AreEqual("@FolderName", parameterName,
                "getFolderID should use the @FolderName parameter.");

            Assert.AreEqual("/Docs/SubFolder", value,
                "The folder path value should match the path passed into the method.");
        }

        [TestMethod]
        public void NewFolder_UsesRootPath_WhenFilePathIsEmptyKeyword()
        {
            // Arrange
            object helper = CreateFolderHelper();
            Type helperType = helper.GetType();

            // Act
            // This checks the special root-folder path logic used when filepath is 'empty'.
            helperType.GetMethod("NewFolder")!
                .Invoke(helper, new object[] { "Docs", "empty", 7 });

            // Assert
            object parameters =
                helperType.GetProperty("Parameters")!.GetValue(helper)!;

            int parameterCount =
                (int)parameters.GetType().GetProperty("Count")!.GetValue(parameters)!;

            object userIdParameter =
                parameters.GetType().GetProperty("Item")!.GetValue(parameters, new object[] { 0 })!;

            object folderNameParameter =
                parameters.GetType().GetProperty("Item")!.GetValue(parameters, new object[] { 1 })!;

            string userIdName =
                (string)userIdParameter.GetType().GetProperty("ParameterName")!.GetValue(userIdParameter)!;

            string folderNameParamName =
                (string)folderNameParameter.GetType().GetProperty("ParameterName")!.GetValue(folderNameParameter)!;

            string folderPathValue =
                folderNameParameter.GetType().GetProperty("Value")!.GetValue(folderNameParameter)?.ToString()
                ?? string.Empty;

            Assert.AreEqual(2, parameterCount,
                "NewFolder should prepare two SQL parameters before execution.");

            Assert.AreEqual("@UserID", userIdName,
                "The first parameter should be @UserID.");

            Assert.AreEqual("@FolderName", folderNameParamName,
                "The second parameter should be @FolderName.");

            Assert.AreEqual("/Docs", folderPathValue,
                "When filepath is 'empty', the helper should create a root-level path like '/Docs'.");
        }

        [TestMethod]
        public void NewFolder_UsesChildPath_WhenFilePathIsNotEmptyKeyword()
        {
            // Arrange
            object helper = CreateFolderHelper();
            Type helperType = helper.GetType();

            // Act
            // This checks the normal child-folder path-building logic.
            helperType.GetMethod("NewFolder")!
                .Invoke(helper, new object[] { "Reports", "/Docs", 7 });

            // Assert
            object parameters =
                helperType.GetProperty("Parameters")!.GetValue(helper)!;

            object folderNameParameter =
                parameters.GetType().GetProperty("Item")!.GetValue(parameters, new object[] { 1 })!;

            string folderPathValue =
                folderNameParameter.GetType().GetProperty("Value")!.GetValue(folderNameParameter)?.ToString()
                ?? string.Empty;

            Assert.AreEqual("/Docs/Reports", folderPathValue,
                "When filepath is not 'empty', the helper should append the new folder name to the existing path.");
        }

        [TestMethod]
        public void DeleteFolder_AddsFolderTuidParameter()
        {
            // Arrange
            object helper = CreateFolderHelper();
            Type helperType = helper.GetType();

            // Act
            // This checks that DeleteFolder prepares the correct SQL parameter locally.
            helperType.GetMethod("DeleteFolder")!
                .Invoke(helper, new object[] { 55 });

            // Assert
            object parameters =
                helperType.GetProperty("Parameters")!.GetValue(helper)!;

            int parameterCount =
                (int)parameters.GetType().GetProperty("Count")!.GetValue(parameters)!;

            object firstParameter =
                parameters.GetType().GetProperty("Item")!.GetValue(parameters, new object[] { 0 })!;

            string parameterName =
                (string)firstParameter.GetType().GetProperty("ParameterName")!.GetValue(firstParameter)!;

            object value =
                firstParameter.GetType().GetProperty("Value")!.GetValue(firstParameter)!;

            Assert.AreEqual(1, parameterCount,
                "DeleteFolder should prepare exactly one SQL parameter.");

            Assert.AreEqual("@FolderTUID", parameterName,
                "DeleteFolder should use the @FolderTUID parameter.");

            Assert.AreEqual(55, Convert.ToInt32(value),
                "The folder id value should match the input.");
        }

        [TestMethod]
        public void RenameFolder_BuildsExpectedParameters()
        {
            // Arrange
            object helper = CreateFolderHelper();
            Type helperType = helper.GetType();

            // Act
            // This checks that RenameFolder prepares all expected SQL parameters locally.
            helperType.GetMethod("RenameFolder")!
                .Invoke(helper, new object[] { 8, 21, "Archive" });

            // Assert
            object parameters =
                helperType.GetProperty("Parameters")!.GetValue(helper)!;

            int parameterCount =
                (int)parameters.GetType().GetProperty("Count")!.GetValue(parameters)!;

            object userIdParameter =
                parameters.GetType().GetProperty("Item")!.GetValue(parameters, new object[] { 0 })!;

            object folderTuidParameter =
                parameters.GetType().GetProperty("Item")!.GetValue(parameters, new object[] { 1 })!;

            object folderNameParameter =
                parameters.GetType().GetProperty("Item")!.GetValue(parameters, new object[] { 2 })!;

            string userIdName =
                (string)userIdParameter.GetType().GetProperty("ParameterName")!.GetValue(userIdParameter)!;

            string folderTuidName =
                (string)folderTuidParameter.GetType().GetProperty("ParameterName")!.GetValue(folderTuidParameter)!;

            string folderNameParamName =
                (string)folderNameParameter.GetType().GetProperty("ParameterName")!.GetValue(folderNameParameter)!;

            string folderNameValue =
                folderNameParameter.GetType().GetProperty("Value")!.GetValue(folderNameParameter)?.ToString()
                ?? string.Empty;

            Assert.AreEqual(3, parameterCount,
                "RenameFolder should prepare three SQL parameters.");

            Assert.AreEqual("@UserID", userIdName,
                "The first parameter should be @UserID.");

            Assert.AreEqual("@FolderTUID", folderTuidName,
                "The second parameter should be @FolderTUID.");

            Assert.AreEqual("@FolderName", folderNameParamName,
                "The third parameter should be @FolderName.");

            Assert.AreEqual("Archive", folderNameValue,
                "The new folder name should match the value passed into RenameFolder.");
        }

        /// <summary>
        /// Creates an instance of the internal FolderHelper class through reflection.
        /// </summary>
        /// <returns>A reflected FolderHelper object.</returns>
        private static object CreateFolderHelper()
        {
            Type helperType = Type.GetType(FolderHelperTypeName, throwOnError: true)!;
            return Activator.CreateInstance(helperType)!;
        }

        /// <summary>
        /// Seeds the helper with temporary folder and parameter data so GetRootFolders
        /// can be tested for clearing old state before execution.
        /// </summary>
        /// <param name="helperType">The reflected FolderHelper type.</param>
        /// <param name="helper">The reflected FolderHelper instance.</param>
        private static void SeedFolderAndParameterState(Type helperType, object helper)
        {
            object folders =
                helperType.GetProperty("Folders")!.GetValue(helper)!;

            object parameters =
                helperType.GetProperty("Parameters")!.GetValue(helper)!;

            MethodInfo addFolderMethod =
                folders.GetType().GetMethod("Add")!;

            MethodInfo addParameterMethod =
                parameters.GetType().GetMethod("Add")!;

            Type folderType =
                Type.GetType("PAWS.WinForms.Models.Documents.Folder, PAWS.WinForms", throwOnError: true)!;

            object folder =
                Activator.CreateInstance(folderType, 1, "/Temp", DateTime.Now, 1, DateTime.Now, 1)!;

            addFolderMethod.Invoke(folders, new[] { folder });
            addParameterMethod.Invoke(parameters, new object[] { new SqlParameter("@Old", 1) });
        }
    }
}