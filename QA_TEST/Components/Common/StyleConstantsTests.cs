using Microsoft.VisualStudio.TestTools.UnitTesting;
using PAWS.WinForms.Components.Common;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Text;

namespace QA_TEST.Components.Common
{
    // FILENAME: StyleConstantsTests.cs
    //
    // WRITTEN BY: Max Yaw
    // DATE CREATED: March 5 2026
    //
    // PART OF PROJECT: PAWS.WinForms (QA Testing)
    //
    // FILE PURPOSE:
    // This file contains unit tests for StyleConstants.
    // Tests verify color conversion behavior, color accessor mappings,
    // and font preset configuration values.
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
    public class StyleConstantsTests
    {

        // Verifies HexToColor parses valid #RRGGBB values.
        // Goal: confirm correct RGB conversion when hash is included.
        [TestMethod]
        public void HexToColor_ValidHexWithHash_ReturnsCorrectColor()
        {

            var styles = new StyleConstants();

            Color result = styles.HexToColor("#CA202D"); // MAIN color

            // assert: the expected rgb values for the hex color #CA202D are:
            Assert.AreEqual(202, result.R);
            Assert.AreEqual(32, result.G);
            Assert.AreEqual(45, result.B);
        }

        // Verifies HexToColor parses valid RRGGBB values without a leading hash.
        // Goal: ensure both common hex formats are supported.
        [TestMethod]
        public void HexToColor_ValidHexWithoutHash_ReturnsCorrectColor()
        {
            var styles = new StyleConstants();

            Color result = styles.HexToColor("CA202D"); // no hash

            // assert: the expected rgb values for the hex color CA202D are:
            Assert.AreEqual(202, result.R);
            Assert.AreEqual(32, result.G);
            Assert.AreEqual(45, result.B);
        }

        // Verifies HexToColor throws ArgumentException for empty input.
        // Goal: enforce invalid input guard behavior.
        [TestMethod]
        [ExpectedException(typeof(ArgumentException))]
        public void HexToColor_NullOrEmptyString_ThrowsArgumentException()
        {
            var styles = new StyleConstants();

            // passing an empy string should trigger the dev's exception
            styles.HexToColor("");
        }

        // Verifies HexToColor throws ArgumentException for invalid hex length.
        // Goal: enforce strict RRGGBB length validation.
        [TestMethod]
        [ExpectedException(typeof(ArgumentException))]
        public void HexToColor_InvalidLength_ThrowsArgumentException()
        {

            var styles = new StyleConstants();

            // passing as hex string with an invalid length should trigger the dev's exception
            styles.HexToColor("#123");
        }

        // Verifies selected color accessor properties return expected Color values.
        // Goal: validate constant-to-color mapping for key style colors.
        [TestMethod]
        public void ColorProperties_ReturnExpectedColors()
        {

            var styles = new StyleConstants();

            // act & assert: check a few properties to ensure the getters map correctly
            Assert.AreEqual(Color.FromArgb(202, 32, 45), styles.MainColor);
            Assert.AreEqual(Color.FromArgb(255, 255, 255), styles.BackgroundDefaultColor);
        }

        // Verifies all color accessor properties map exactly to their hex constants.
        // Goal: ensure full style color accessor coverage and consistency.
        [TestMethod]
        public void AllColorAccessors_MapToExpectedHexValues()
        {
            var styles = new StyleConstants();

            Assert.AreEqual(styles.HexToColor(StyleConstants.MAIN), styles.MainColor);
            Assert.AreEqual(styles.HexToColor(StyleConstants.MAIN_HOVER), styles.MainHoverColor);
            Assert.AreEqual(styles.HexToColor(StyleConstants.SECONDARY), styles.SecondaryColor);
            Assert.AreEqual(styles.HexToColor(StyleConstants.SECONDARY_HOVER), styles.SecondaryHoverColor);
            Assert.AreEqual(styles.HexToColor(StyleConstants.TEXT_PRIMARY), styles.TextPrimaryColor);
            Assert.AreEqual(styles.HexToColor(StyleConstants.TEXT_SECONDARY), styles.TextSecondaryColor);
            Assert.AreEqual(styles.HexToColor(StyleConstants.TEXT_BODY), styles.TextBodyColor);
            Assert.AreEqual(styles.HexToColor(StyleConstants.TEXT_LIGHT), styles.TextLightColor);
            Assert.AreEqual(styles.HexToColor(StyleConstants.BACKGROUND_DEFAULT), styles.BackgroundDefaultColor);
            Assert.AreEqual(styles.HexToColor(StyleConstants.BACKGROUND_PAPER), styles.BackgroundPaperColor);
            Assert.AreEqual(styles.HexToColor(StyleConstants.GREEN), styles.GreenColor);
            Assert.AreEqual(styles.HexToColor(StyleConstants.PURPLE), styles.PurpleColor);
            Assert.AreEqual(styles.HexToColor(StyleConstants.DARK_RED), styles.DarkRedColor);
        }

        // Verifies font preset sizes and styles are configured as expected.
        // Goal: confirm typography defaults are stable and reusable across UI components.
        [TestMethod]
        public void FontPresets_AreConfiguredCorrectly()
        {

            // fonts are static, so we don't need to instantiate StyleConstants
            Assert.AreEqual(32f, StyleConstants.ScreenTitle.Size);
            Assert.AreEqual(FontStyle.Bold, StyleConstants.ScreenTitle.Style);

            Assert.AreEqual(9f, StyleConstants.Body.Size);
            Assert.AreEqual(FontStyle.Regular, StyleConstants.Body.Style); // body should be regular
        }
    }
}
