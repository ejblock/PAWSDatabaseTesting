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
    // FILENAME: SettingsMenuPopupControlTests.cs
    //
    // WRITTEN BY: Max Yaw
    // DATE CREATED: March 5 2026
    //
    // PART OF PROJECT: PAWS.WinForms (QA Testing)
    //
    // FILE PURPOSE:
    // This file contains unit tests for SettingsMenuPopupControl.
    // Tests verify constructor defaults and event behavior for Import/Export actions.
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
    public class SettingsMenuPopupControlTests
    {

        // Verifies constructor initializes size, color, and child controls correctly.
        // Goal: ensure base popup structure is created with expected defaults.
        [TestMethod]
        public void Constructor_InitializesCorrectly()
        {

            var popup = new SettingsMenuPopupControl(); // instantiate the control

            // check basic properties
            Assert.AreEqual(Color.White, popup.BackColor, "Background color should be White.");
            Assert.AreEqual(340, popup.Width, "Width should be 340.");
            Assert.AreEqual(140, popup.Height, "Height should be 140.");

            // check that the 3 internal controls (Label, Button, Button) were added
            Assert.AreEqual(3, popup.Controls.Count, "The popup should contain exactly 3 child controls.");
        }

        // Verifies Import and Export button clicks raise their corresponding events.
        // Goal: confirm popup action buttons are correctly wired to event handlers.
        [TestMethod]
        public void ButtonClicks_RaiseExpectedEvents()
        {
            var popup = new SettingsMenuPopupControl();
            // flags to track if events were raised
            bool importRaised = false;
            bool exportRaised = false;

            popup.ImportClicked += (_, __) => importRaised = true; // when clicked set import flag to true
            popup.ExportClicked += (_, __) => exportRaised = true; // when clicked set export flag to true

            Button importButton = popup.Controls // all controls inside of the popup
                .OfType<Button>() 
                .Single(b => b.Text == "Import"); // of the type button and text is import

            // same: getting the button from the popup with export text and casting it to button
            Button exportButton = popup.Controls
                .OfType<Button>()
                .Single(b => b.Text == "Export");

            // click the buttons programmatically
            importButton.PerformClick();
            exportButton.PerformClick();

            Assert.IsTrue(importRaised, "ImportClicked should be raised when Import is clicked.");
            Assert.IsTrue(exportRaised, "ExportClicked should be raised when Export is clicked.");
        }
    }
}
