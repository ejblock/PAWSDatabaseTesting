using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace QA_TEST.Helpers
{
    /// <summary>
    /// FILENAME: FileRecordHelperTests.cs
    /// 
    /// WRITTEN BY: Rosh Mizoory
    /// DATE CREATED: March 17, 2026
    /// 
    /// PART OF PROJECT: QA_TEST
    /// 
    /// FILE PURPOSE:
    /// These tests check the local behavior of FileRecordHelper 
    /// I focused on constructor defaults, parameter setup, 
    /// and path formatting because those are the parts that can
    /// be verified consistently in isolated automated tests.
    /// </summary>
    [TestClass]
    public class FileRecordHelperTests
    {
        private const string FileRecordHelperTypeName =
            "PetPortal.WinForms.Helpers.Documents.FileRecordHelper, PAWS.WinForms";

        [TestMethod]
        public void Constructor_InitializesConnectionStringFilesAndParameters()
        {
            // Arrange
            object helper = CreateFileRecordHelper();
            Type helperType = helper.GetType();

            // Act
            string connectionString =
                (string)helperType.GetProperty("ConnectionString")!.GetValue(helper)!;

            object files =
                helperType.GetProperty("Files")!.GetValue(helper)!;

            object parameters =
                helperType.GetProperty("Parameters")!.GetValue(helper)!;

            int fileCount =
                (int)files.GetType().GetProperty("Count")!.GetValue(files)!;

            int parameterCount =
                (int)parameters.GetType().GetProperty("Count")!.GetValue(parameters)!;

            // Assert
            Assert.IsFalse(string.IsNullOrWhiteSpace(connectionString),
                "The helper should start with a connection string.");

            Assert.IsNotNull(files,
                "The helper should initialize its file list in the constructor.");

            Assert.IsNotNull(parameters,
                "The helper should initialize its parameter list in the constructor.");

            Assert.AreEqual(0, fileCount,
                "The file list should start empty.");

            Assert.AreEqual(0, parameterCount,
                "The parameter list should start empty.");
        }

        [TestMethod]
        public void GetNextLayerFiles_AddsFolderIdParameter()
        {
            // Arrange
            object helper = CreateFileRecordHelper();
            Type helperType = helper.GetType();

            // Act
            helperType.GetMethod("getNextLayerFiles")!
                .Invoke(helper, new object[] { 22 });

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
                "Exactly one parameter should be added for next-layer file loading.");

            Assert.AreEqual("@FolderID", parameterName,
                "The helper should use the @FolderID parameter name.");

            Assert.AreEqual(22, Convert.ToInt32(value),
                "The folder id parameter value should match the input value.");
        }

        [TestMethod]
        public void NewFile_BuildsExpectedParameters()
        {
            // Arrange
            object helper = CreateFileRecordHelper();
            Type helperType = helper.GetType();

            // Act
            helperType.GetMethod("NewFile")!
                .Invoke(helper, new object[] { "notes.txt", "/Animals", 3, true, false, 15, 9 });

            // Assert
            object parameters =
                helperType.GetProperty("Parameters")!.GetValue(helper)!;

            int parameterCount =
                (int)parameters.GetType().GetProperty("Count")!.GetValue(parameters)!;

            Assert.AreEqual(7, parameterCount,
                "NewFile should prepare all seven expected SQL parameters before execution.");

            object fileLocationParameter =
                parameters.GetType().GetProperty("Item")!.GetValue(parameters, new object[] { 1 })!;

            object fileNameParameter =
                parameters.GetType().GetProperty("Item")!.GetValue(parameters, new object[] { 2 })!;

            string fileLocation =
                fileLocationParameter.GetType().GetProperty("Value")!.GetValue(fileLocationParameter)?.ToString()
                ?? string.Empty;

            string fileName =
                fileNameParameter.GetType().GetProperty("Value")!.GetValue(fileNameParameter)?.ToString()
                ?? string.Empty;

            Assert.AreEqual("/Animals/notes.txt", fileLocation,
                "The helper should combine filepath and name into the stored file location.");

            Assert.AreEqual("notes.txt", fileName,
                "The file name parameter should match the passed in name.");
        }

        [TestMethod]
        public void DeleteFile_AddsFileTuidParameter()
        {
            // Arrange
            object helper = CreateFileRecordHelper();
            Type helperType = helper.GetType();

            // Act
            helperType.GetMethod("DeleteFile")!
                .Invoke(helper, new object[] { 44 });

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
                "DeleteFile should prepare exactly one SQL parameter.");

            Assert.AreEqual("@FileTUID", parameterName,
                "DeleteFile should use the @FileTUID parameter.");

            Assert.AreEqual(44, Convert.ToInt32(value),
                "The file id parameter value should match the input.");
        }

        [TestMethod]
        public void RenameFile_BuildsUpdatedPathFromOriginalPath()
        {
            // Arrange
            object helper = CreateFileRecordHelper();
            Type helperType = helper.GetType();

            // Act
            helperType.GetMethod("RenameFile")!
                .Invoke(helper, new object[] { 4, 10, 99, "/Animals/oldname.txt" });

            // Assert
            object parameters =
                helperType.GetProperty("Parameters")!.GetValue(helper)!;

            object fileLocationParameter =
                parameters.GetType().GetProperty("Item")!.GetValue(parameters, new object[] { 3 })!;

            object fileNameParameter =
                parameters.GetType().GetProperty("Item")!.GetValue(parameters, new object[] { 2 })!;

            string updatedPath =
                fileLocationParameter.GetType().GetProperty("Value")!.GetValue(fileLocationParameter)?.ToString()
                ?? string.Empty;

            string newName =
                fileNameParameter.GetType().GetProperty("Value")!.GetValue(fileNameParameter)?.ToString()
                ?? string.Empty;

            Assert.AreEqual("/Animals/99", updatedPath,
                "RenameFile should rebuild the location using the original folder path and the new name value.");

            Assert.AreEqual("99", newName,
                "The helper currently passes the new name as its numeric value converted to text.");
        }

        private static object CreateFileRecordHelper()
        {
            Type helperType = Type.GetType(FileRecordHelperTypeName, throwOnError: true)!;
            return Activator.CreateInstance(helperType)!;
        }
    }
}