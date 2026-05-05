using PAWS.WinForms.Components.Common;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Reflection;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Windows.Forms;

namespace QA_TEST.Components.MenuSideBar
{
    // FILENAME: IconButtonTests.cs
    //
    // WRITTEN BY: Max Yaw
    // DATE CREATED: March 5 2026
    //
    // PART OF PROJECT: PAWS.WinForms (QA Testing)
    //
    // FILE PURPOSE:
    // This file contains unit tests for IconButton.
    // Tests verify default values, property set/get behavior,
    // and Clicked event raising using reflection for internal class access.
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
    public class IconButtonTests
    {


        // Verifies IconButton default property values using reflection.
        // Goal: confirm internal control defaults are initialized as expected.
        [TestMethod]
        public void Constructor_SetsDefaultValuesCorrectly()
        {

            Assembly assembly = typeof(StyleConstants).Assembly; // using reflection to get the assembly where StyleConstants is defined

            Type iconButtonType = assembly.GetType("PAWS.WinForms.Components.Common.IconButton", throwOnError: true)!; // find the IconButton type

            object iconButton = Activator.CreateInstance(iconButtonType)!; // create an instance of IconButton using the default constructor

            // extract the default properties via Reflection
            int defaultIconSize = (int)iconButtonType.GetProperty("IconSize")!.GetValue(iconButton)!;
            string defaultId = (string)iconButtonType.GetProperty("Id")!.GetValue(iconButton)!;

            // assert defaults defined in the class
            Assert.AreEqual(22, defaultIconSize, "Default IconSize should be 22.");
            Assert.AreEqual(string.Empty, defaultId, "Default Id should be an empty string.");
        }


        // Verifies reflected set/get of IconButton properties persists values correctly.
        // Goal: confirm internal property assignments are functioning.
        [TestMethod]
        public void Properties_SetAndGetCorrectly()
        {
            // setup reflection to access IconButton and create instance
            Assembly assembly = typeof(StyleConstants).Assembly;
            Type iconButtonType = assembly.GetType("PAWS.WinForms.Components.Common.IconButton", throwOnError: true)!;
            object iconButton = Activator.CreateInstance(iconButtonType)!;

            // set properties via Reflection
            iconButtonType.GetProperty("Id")!.SetValue(iconButton, "MenuButton");
            iconButtonType.GetProperty("IconSize")!.SetValue(iconButton, 48);
            iconButtonType.GetProperty("BackColorNormal")!.SetValue(iconButton, Color.Red);
            iconButtonType.GetProperty("BackColorHover")!.SetValue(iconButton, Color.White);

            // extract properties via Reflection and assert they hold the set values
            string id = (string)iconButtonType.GetProperty("Id")!.GetValue(iconButton)!;
            int size = (int)iconButtonType.GetProperty("IconSize")!.GetValue(iconButton)!;
            Color normalColor = (Color)iconButtonType.GetProperty("BackColorNormal")!.GetValue(iconButton)!;
            Color hoverColor = (Color)iconButtonType.GetProperty("BackColorHover")!.GetValue(iconButton)!;

            Assert.AreEqual("MenuButton", id, "Id property did not hold value.");
            Assert.AreEqual(48, size, "IconSize property did not hold value.");
            Assert.AreEqual(Color.Red, normalColor, "BackColorNormal did not hold value.");
            Assert.AreEqual(Color.White, hoverColor, "BackColorHover did not hold value.");
        }

        // Verifies Clicked event is raised when a click is simulated.
        // Goal: confirm click event contract for the internal IconButton control.
        [TestMethod]
        public void ClickedEvent_IsRaised_WhenControlIsClicked()
        {

            // getting the IconButton type and creating an instance using reflection
            Assembly assembly = typeof(StyleConstants).Assembly;
            Type iconButtonType = assembly.GetType("PAWS.WinForms.Components.Common.IconButton", throwOnError: true)!;
            object iconButton = Activator.CreateInstance(iconButtonType)!;

            // create a flag to check if the Clicked event is raised
            // we use reflection to attach the event handler to the Clicked event of the IconButton instance
            bool clickedRaised = false;
            EventInfo clickedEvent = iconButtonType.GetEvent("Clicked")!; // get the icon buttons clicked event
            EventHandler handler = (_, __) => clickedRaised = true;
            clickedEvent.AddEventHandler(iconButton, handler);

            // invoke the OnClick method via reflection to simulate a click on the control
            MethodInfo onClick = typeof(Control).GetMethod("OnClick", BindingFlags.Instance | BindingFlags.NonPublic)!;
            onClick.Invoke(iconButton, new object[] { EventArgs.Empty });

            Assert.IsTrue(clickedRaised, "Clicked event should be raised when OnClick is invoked.");
        }
    }
}
