using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using PAWS.WinForms.Components.Common;
using PAWS.WinForms.Models.Users;
using System.Windows.Forms;

namespace QA_TEST.Components.MenuSideBar
{
    // FILENAME: SideBarTests.cs
    //
    // WRITTEN BY: Max Yaw
    // DATE CREATED: March 5 2026
    //
    // PART OF PROJECT: PAWS.WinForms (QA Testing)
    //
    // FILE PURPOSE:
    // This file contains unit tests for the SideBar component.
    // Tests verify constructor defaults, session properties,
    // icon management behavior, click event routing, and custom event args.
    //
    // COMPILATION NOTES:
    // This file compiles normally under Microsoft Visual Studio using
    // the .NET Windows Forms framework. No special compiler options
    // or optimizations are required.
    //
    // LIBRARIES AND 3RD PARTY DEPENDENCIES:
    // Microsoft .NET
    // Microsoft.VisualStudio.TestTools.UnitTesting (MSTest)
    //
    // COMMAND LINE PARAMETER LIST (in Parameter Order):
    // (None)
    //
    // ENVIRONMENTAL RETURNS:
    // (Nothing)
    //
    // GLOBAL VARIABLE LIST (Alphabetically):
    // (None)
    //
    // MODIFICATION HISTORY:
    // WHO            WHEN            WHAT
    // ---            ----            ----------------------------------------

    [TestClass]
    public class SideBarTests
    {

        // Verifies SideBar constructor default configuration values.
        // Goal: ensure initial layout and sizing behavior start from expected defaults.
        [TestMethod]
        public void Constructor_SetsExpectedDefaults()
        {
            // create SideBar instance with constructor defaults.
            var sideBar = new SideBar();

            // verify default property values expected from constructor.
            // Assert.AreEqual(52, sideBar.FixedWidth); // commented out: property removed
            // Assert.AreEqual(44, sideBar.IconButtonHeight); // commented out: property removed
            // Assert.AreEqual(22, sideBar.IconSize); // commented out: property removed
            Assert.IsTrue(sideBar.AutoPopulateIcons);
            Assert.AreEqual(DockStyle.Left, sideBar.Dock);
            // Assert.AreEqual(sideBar.FixedWidth, sideBar.Width); // commented out: property removed
        }


        // Verifies user/session and content host properties can be assigned and retrieved.
        // Goal: confirm session/context state storage works correctly.
        [TestMethod]
        public void SessionProperties_SetAndGetCorrectly()
        {
            // create SideBar and sample session objects.
            var sideBar = new SideBar();

            var user = new User
            {
                Name = "Max Yaw",
                Username = "mnyaw"
            };

            var role = new Role(Guid.NewGuid())
            {
                RoleName = "Admin",
                RoleColor = "#0D4B88"
            };

            // assign session and host-related properties.
            sideBar.CurrentUser = user;
            sideBar.CurrentRole = role;
            sideBar.ContentHost = new Panel();
            sideBar.ContentHostName = "MyHost";

            // verify assigned values are preserved.
            Assert.AreSame(user, sideBar.CurrentUser);
            Assert.AreSame(role, sideBar.CurrentRole);
            Assert.IsNotNull(sideBar.ContentHost);
            Assert.AreEqual("MyHost", sideBar.ContentHostName);
        }

        // Verifies adding a top icon creates an IconButton child control.
        // Goal: validate icon creation pipeline for top panel entries.
        [TestMethod]
        public void AddTopIcon_ValidInput_AddsIconButton()
        {
            // disable auto-load so test only includes icons added here.
            var sideBar = new SideBar
            {
                AutoPopulateIcons = false
            };

            // add one icon to the top icon section.
            sideBar.AddTopIcon("test", new Bitmap(1, 1), "Test");

            // confirm one IconButton exists in control hierarchy.
            int iconButtonCount = GetAllDescendants(sideBar)
                .Count(c => c.GetType().Name == "IconButton");

            Assert.AreEqual(1, iconButtonCount); // expect exactly 1 IconButton to be added to the control hierarchy
        }

        // Verifies AddTopIcon rejects empty icon identifiers.
        // Goal: enforce required input validation for icon IDs.
        [TestMethod]
        [ExpectedException(typeof(ArgumentException))]
        public void AddTopIcon_EmptyId_ThrowsArgumentException()
        {
            // disable auto-load so only explicit test action is evaluated.
            var sideBar = new SideBar
            {
                AutoPopulateIcons = false
            };

            // empty ID should throw.
            sideBar.AddTopIcon("", new Bitmap(1, 1));
        }


        // Verifies AddTopIcon rejects null icon images.
        // Goal: enforce required input validation for icon assets.
        [TestMethod]
        [ExpectedException(typeof(ArgumentNullException))]
        public void AddTopIcon_NullIcon_ThrowsArgumentNullException()
        {
            // disable auto-load so only explicit test action is evaluated.
            var sideBar = new SideBar
            {
                AutoPopulateIcons = false
            };

            // null icon should throw
            sideBar.AddTopIcon("test", null!);
        }

        // Verifies ClearIcons removes all previously added icon controls.
        // Goal: confirm icon state can be fully reset between loads.
        [TestMethod]
        public void ClearIcons_RemovesAllAddedIconButtons()
        {
            // create sidebar and add icons to both sections.
            var sideBar = new SideBar
            {
                AutoPopulateIcons = false
            };

            sideBar.AddTopIcon("top", new Bitmap(1, 1));
            sideBar.AddBottomIcon("bottom", new Bitmap(1, 1));

            // clear all icon collections.
            sideBar.ClearIcons();

            // no IconButton should remain in descendants.
            int iconButtonCount = GetAllDescendants(sideBar)
                .Count(c => c.GetType().Name == "IconButton");

            Assert.AreEqual(0, iconButtonCount);
        }


        // Verifies non-special icon clicks raise IconClicked with matching ID.
        // Goal: confirm click routing for generic sidebar actions.
        [TestMethod]
        public void NonSpecialIconClick_RaisesIconClickedWithMatchingId()
        {
            // create sidebar with a custom non-special icon.
            var sideBar = new SideBar
            {
                AutoPopulateIcons = false
            };

            sideBar.AddTopIcon("test-id", new Bitmap(1, 1));

            string? capturedId = null;
            sideBar.IconClicked += (_, args) => capturedId = args.Id; // subscribe to the IconClicked event to capture the ID of the clicked icon

            Control iconButton = GetAllDescendants(sideBar)
                .First(c => c.GetType().Name == "IconButton"); // find the IconButton instance we added

            // invoke protected OnClick via reflection to simulate a click.
            MethodInfo onClick = typeof(Control).GetMethod("OnClick", BindingFlags.Instance | BindingFlags.NonPublic)!; // access the protected OnClick method to simulate a click
            onClick.Invoke(iconButton, new object[] { EventArgs.Empty });

            // emitted event ID should match icon ID.
            Assert.AreEqual("test-id", capturedId);
        }

        // Verifies SidebarIconClickedEventArgs stores and exposes the provided ID.
        // Goal: validate event argument data integrity.
        [TestMethod]
        public void SidebarIconClickedEventArgs_StoresId()
        {
            // create args with known ID.
            var args = new SidebarIconClickedEventArgs("pets");

            // ID is stored exactly as provided.
            Assert.AreEqual("pets", args.Id);
        }

        // Verifies CsvFileSelectedEventArgs stores and exposes the provided file path.
        // Goal: validate CSV event argument data integrity.
        [TestMethod]
        public void CsvFileSelectedEventArgs_StoresFilePath()
        {
            // prepare expected path.
            string path = @"C:\\temp\\pets.csv";

            // create args object with expected path.
            var args = new CsvFileSelectedEventArgs(path);

            // path is stored exactly as provided.
            Assert.AreEqual(path, args.FilePath);
        }

        // helper method used by tests to walk all nested controls recursively
        private static IEnumerable<Control> GetAllDescendants(Control root)
        {
            // loop each immediate child and return it first
            foreach (Control child in root.Controls)
            {
                yield return child;

                // recursively return descendants of each child control.
                foreach (Control descendant in GetAllDescendants(child))
                {
                    yield return descendant;
                }
            }
        }

    }
}
