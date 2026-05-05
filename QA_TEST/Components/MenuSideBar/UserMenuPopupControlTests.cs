using Microsoft.VisualStudio.TestTools.UnitTesting;
using PAWS.WinForms.Components.MenuSideBar;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace QA_TEST.Components.MenuSideBar
{
    // FILENAME: UserMenuPopupControlTests.cs
    //
    // WRITTEN BY: Max Yaw
    // DATE CREATED: March 5 2026
    //
    // PART OF PROJECT: PAWS.WinForms (QA Testing)
    //
    // FILE PURPOSE:
    // This file contains unit tests for UserMenuPopupControl.
    // Tests verify constructor defaults, public method behavior,
    // fallback binding values, role badge color updates, and button events.
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
    public class UserMenuPopupControlTests
    {

        // cannot actually chcek the labels and buttons directly since they are private, but we can at least check that the constructor sets up the control without throwing exceptions and that the public methods can be called without errors.

        // Verifies constructor initializes expected default dimensions, color, and child controls.
        // Goal: ensure popup baseline UI structure is created correctly.
        [TestMethod]
        public void Constructor_InitializesCorrectly()
        {

            var popup = new UserMenuPopupControl(); // just creating an instance should not throw any exceptions

            // check basic properties defined in constructor
            Assert.AreEqual(Color.White, popup.BackColor, "Background color should be White.");
            Assert.AreEqual(270, popup.Width, "Width should be 270.");
            Assert.AreEqual(150, popup.Height, "Height should be 150.");

            // check that the 4 internal controls (Name, Role, Edit btn, Logout btn) were added
            Assert.AreEqual(4, popup.Controls.Count, "The popup should contain exactly 4 child controls.");
        }

        // Verifies public methods Bind and SetRoleBadgeColor execute without exceptions.
        // Goal: confirm externally callable API methods are safe to invoke.
        [TestMethod]
        public void PublicMethods_ExecuteWithoutExceptions()
        {

            var popup = new UserMenuPopupControl(); // create an instance to test the public methods

            // call the public data binding methods
            // if these methods contain errors, the test will fail here.
            popup.Bind("Test User", "Admin");
            popup.SetRoleBadgeColor(Color.Green);

            // since the internal labels are private only can simply asserting 
            // that invoking the public methods successfully updates the UI memory without crashing.
            Assert.IsTrue(true, "Bind and SetRoleBadgeColor executed successfully.");
        }


        // Verifies Bind applies fallback labels when null values are provided.
        // Goal: confirm robust null handling for display name and role text.
        [TestMethod]
        public void Bind_NullValues_FallsBackToDefaults()
        {
            var popup = new UserMenuPopupControl();

            popup.Bind("Test User", "Admin");
            popup.Bind(null, null); // binding null values should not throw an error and should fall back to default labels

            var labels = popup.Controls.OfType<Label>().ToList(); // get all labels of this popup to check their text

            // we expect 2 labels (Name and Role) and they should fall back to "User" and "Role" respectively when null is passed
            Assert.AreEqual(2, labels.Count, "Popup should contain two labels.");
            Assert.IsTrue(labels.Any(l => l.Text == "User"), "Name label should fall back to 'User'.");
            Assert.IsTrue(labels.Any(l => l.Text == "Role"), "Role label should fall back to 'Role'.");
        }

        // Verifies SetRoleBadgeColor updates the role label background color.
        // Goal: ensure role badge styling API updates UI state.
        [TestMethod]
        public void SetRoleBadgeColor_UpdatesRoleLabelBackColor()
        {
            var popup = new UserMenuPopupControl();
            popup.Bind("Name", "Admin");

            Label roleLabel = popup.Controls
                .OfType<Label>()
                .Single(l => l.Text == "Admin"); // grab role label by its text

            popup.SetRoleBadgeColor(Color.Green); // fire the color change method

            Assert.AreEqual(Color.Green, roleLabel.BackColor); // check that the role label's background color was updated to green
        }


        // Verifies clicking Edit and Log Out buttons raises the corresponding events.
        // Goal: confirm popup action buttons are wired to public event outputs.
        [TestMethod]
        public void ButtonClicks_RaiseExpectedEvents()
        {
            var popup = new UserMenuPopupControl();
            bool editRaised = false;
            bool logoutRaised = false;

            // subscribe to the events to track if they are raised when the buttons are clicked
            popup.EditUserClicked += (_, __) => editRaised = true;
            popup.LogoutClicked += (_, __) => logoutRaised = true;

            // get both of the buttons by their text and perform clicks on them to trigger the events
            Button editButton = popup.Controls
                .OfType<Button>()
                .Single(b => b.Text.Trim() == "Edit User");

            Button logoutButton = popup.Controls
                .OfType<Button>()
                .Single(b => b.Text.Trim() == "Log Out");

            // perform clicks on both buttons to trigger the events
            editButton.PerformClick();
            logoutButton.PerformClick();


            // assert that both events were raised as expected when the buttons were clicked
            Assert.IsTrue(editRaised, "EditUserClicked should be raised when Edit User is clicked.");
            Assert.IsTrue(logoutRaised, "LogoutClicked should be raised when Log Out is clicked.");
        }


    }
}
