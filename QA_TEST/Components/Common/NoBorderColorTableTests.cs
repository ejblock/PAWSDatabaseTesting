using System;
using System.Collections.Generic;
using System.Drawing;
using System.Reflection;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using PAWS.WinForms.Components.Common;

namespace QA_TEST.Components.Common
{
    // FILENAME: NoBorderColorTableTests.cs
    //
    // WRITTEN BY: Max Yaw
    // DATE CREATED: March 5 2026
    //
    // PART OF PROJECT: PAWS.WinForms (QA Testing)
    //
    // FILE PURPOSE:
    // This file contains unit tests for NoBorderColorTable.
    // Tests verify that overridden ToolStrip border properties return transparent colors.
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
    public class NoBorderColorTableTests
    {

        // Verifies NoBorderColorTable border-related properties return transparent values.
        // Goal: ensure ToolStrip popup chrome borders are effectively removed.
        [TestMethod]
        public void OverriddenProperties_ShouldReturnTransparent()
        {

            // since NoBorderColorTable is 'internal', we can't reference it directly.
            // we use the StyleCOnstants pbublic class as a way to access the assembly and create an instance of the NoBorderColorTable using reflection.
            Assembly assembly = typeof(StyleConstants).Assembly; // aseembly containing the NoBorderColorTable class is the same as StyleConstants, so we can get it from there
            Type colorTableType = assembly.GetType("PAWS.WinForms.Components.Common.NoBorderColorTable", throwOnError: true)!; // get the table type using reflection
            object colorTable = Activator.CreateInstance(colorTableType)!; // create an instance of the color table

            // get the overridden properties using reflection
            Color menuBorder = (Color)colorTableType.GetProperty("MenuBorder")!.GetValue(colorTable)!;
            Color toolStripBorder = (Color)colorTableType.GetProperty("ToolStripBorder")!.GetValue(colorTable)!;
            Color menuItemBorder = (Color)colorTableType.GetProperty("MenuItemBorder")!.GetValue(colorTable)!;

            // assert values are set to default
            Assert.AreEqual(Color.Transparent, menuBorder, "MenuBorder should be transparent.");
            Assert.AreEqual(Color.Transparent, toolStripBorder, "ToolStripBorder should be transparent.");
            Assert.AreEqual(Color.Transparent, menuItemBorder, "MenuItemBorder should be transparent.");
        }
    }
}
