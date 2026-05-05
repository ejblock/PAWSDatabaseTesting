using System;
using System.Collections.Generic;
using System.Drawing;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using PAWS.WinForms.Components.Checkbox;

namespace QA_TEST.Components.Checkbox
{
    // FILENAME: CheckboxComponentTest.cs
    //
    // WRITTEN BY: Max Yaw
    // DATE CREATED: March 5 2026
    //
    // PART OF PROJECT: PAWS.WinForms (QA Testing)
    //
    // FILE PURPOSE:
    // This file contains unit tests for the CheckboxComponent custom control.
    // Tests verify control creation, constructor defaults, and checked state behavior.
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
    public class CheckboxComponentTest
    {

        // Verifies that CheckboxComponent can be instantiated and has expected base defaults.
        // Goal: confirm control creation does not fail and Name starts empty.
        [TestMethod]
        public void CheckboxComponent_Should_Be_Created()
        {
            var checkbox = new CheckboxComponent(); // create instance of checkbox component

            // assert that the instance is not null and has default name to null
            Assert.IsNotNull(checkbox);
            Assert.AreEqual(string.Empty, checkbox.Name, "Name should default to an empty string.");
        }

        // Verifies constructor-applied defaults for sizing and font settings.
        // Goal: ensure initial appearance values are consistently configured.
        [TestMethod]
        public void Constructor_SetsDefaultPropertiesCorrectly()
        {

            var checkbox = new CheckboxComponent(); // create instance of checkbox component

            // assert that the default properties are set correctly
            Assert.IsTrue(checkbox.AutoSize, "AutoSize should be true by default.");
            Assert.AreEqual(8f, checkbox.Font.Size, 0.1f, "Font size should be 8.");
            Assert.AreEqual(FontStyle.Regular, checkbox.Font.Style, "Font style should be Regular.");

            // the constructor sets Height = Math.Max(_boxSize + 2, FontHeight + 4)
            // _boxSize is 16, so Height should be at least 18.
            Assert.IsTrue(checkbox.Height >= 18, "Height should be correctly calculated based on box size and font.");
        }


        // Verifies Checked state can be toggled true/false and persists correctly.
        // Goal: confirm basic checkbox state behavior functions as expected.
        [TestMethod]
        public void Checkbox_State_ChangesCorrectly()
        {

            var checkbox = new CheckboxComponent();

            checkbox.Checked = true; // check the box

            Assert.IsTrue(checkbox.Checked, "Checkbox state should update to true.");

            checkbox.Checked = false; // uncheck the box

            Assert.IsFalse(checkbox.Checked, "Checkbox state should update to false.");
        }
    }
}
