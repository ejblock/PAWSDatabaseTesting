using PAWS.WinForms.Models.Events;
using PAWS.WinForms.Models.People;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace QA_TEST
{
    // FILENAME: QA_Event_Test.cs
    //
    // WRITTEN BY: Alyssa Lilly
    // DATE CREATED: February 3 2026
    //
    // PART OF PROJECT: PAWS.WinForms
    //
    // PROJECT PURPOSE:
    // The purpose of this project is to test the Event class in the PAWS.WinForms application,
    // which is used for managing people, volunteers, adopter homes, foster homes, and
    // related data for an animal shelter or rescue organization.
    //
    // FILE PURPOSE:
    // This file defines a set of unit tests for the Event class, which represents an action that
    // occurs at a set time within the system. The tests cover the creation of Event objects,
    // the existence and types of the properties of the Event class, the default values of those properties,
    // and the ability to set those properties to various values, including edge cases and error cases.
    //
    // COMPILATION NOTES:
    // This file compiles normally under Microsoft Visual Studio using
    // the .NET Windows Forms framework. No special compiler options
    // or optimizations are required.
    //
    // LIBRARIES AND 3RD PARTY DEPENDENCIES:
    // Microsoft .NET
    //MS Test Framework
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
    //

    [TestClass]
    public class TestEvent
    {

        // TEST NAME: TESTCREATENOTNULLEVENT
        //
        // TEST PURPOSE:
        // Test to see if an Event object can be created and is not null.
        [TestMethod]
        public void TestCreateNotNullEvent()
        {
            Event testEvent = new Event();
            Assert.IsNotNull(testEvent);
        }


        // TEST NAMES: TESTEVENT[PROPERTY NAME]EXISTS
        //
        // TEST PURPOSES:
        // Test to see if the properties of the Event class exist.

        [TestMethod]
        public void TestEventTUIDExists()
        {
            Event testEvent = new Event();
            Assert.IsTrue(testEvent.GetType().GetProperty("TUID") != null);
        }

        [TestMethod]
        public void TestEventCreatedByExists()
        {
            Event testEvent = new Event();
            Assert.IsTrue(testEvent.GetType().GetProperty("CreatedBy") != null);
        }

        [TestMethod]
        public void TestEventModifiedByExists()
        {
            Event testEvent = new Event();
            Assert.IsTrue(testEvent.GetType().GetProperty("ModifiedBy") != null);
        }

        [TestMethod]
        public void TestEventDayPeriodExists()
        {
            Event testEvent = new Event();
            Assert.IsTrue(testEvent.GetType().GetProperty("DayPeriod") != null);
        }

        [TestMethod]
        public void TestEventNameExists()
        {
            Event testEvent = new Event();
            Assert.IsTrue(testEvent.GetType().GetProperty("Name") != null);
        }

        [TestMethod]
        public void TestEventDescriptionExists()
        {
            Event testEvent = new Event();
            Assert.IsTrue(testEvent.GetType().GetProperty("Description") != null);
        }

        [TestMethod]
        public void TestEventRecurringExists()
        {
            Event testEvent = new Event();
            Assert.IsTrue(testEvent.GetType().GetProperty("Recurring") != null);
        }

        [TestMethod]
        public void TestEventStartTimeExists()
        {
            Event testEvent = new Event();
            Assert.IsTrue(testEvent.GetType().GetProperty("StartTime") != null);
        }

        [TestMethod]
        public void TestEventLastModifiedExists()
        {
            Event testEvent = new Event();
            Assert.IsTrue(testEvent.GetType().GetProperty("LastModified") != null);
        }

        [TestMethod]
        public void TestEventCreatedOnExists()
        {
            Event testEvent = new Event();
            Assert.IsTrue(testEvent.GetType().GetProperty("CreatedOn") != null);
        }

        [TestMethod]
        public void TestEventPastEventExists()
        {
            Event testEvent = new Event();
            Assert.IsTrue(testEvent.GetType().GetProperty("PastEvent") != null);
        }


        // TEST NAMES: TESTEVENT[PROPERTY NAME]TYPE
        //
        // TEST PURPOSES:
        // Test to see if the properties of the Event class are of the correct type.
        // This is important to ensure that the properties can be used correctly in the application
        // and that they will not cause errors when accessed or modified.

        [TestMethod]
        public void TestEventTUIDType()
        {
            Event testEvent = new Event();
            Assert.IsInstanceOfType(testEvent.TUID, typeof(int));
        }

        [TestMethod]
        public void TestEventCreatedByType()
        {
            Event testEvent = new Event();
            Assert.IsInstanceOfType(testEvent.CreatedBy, typeof(int));
        }

        [TestMethod]
        public void TestEventModifiedByType()
        {
            Event testEvent = new Event();
            Assert.IsInstanceOfType(testEvent.ModifiedBy, typeof(int));
        }

        [TestMethod]
        public void TestEventDayPeriodType()
        {
            Event testEvent = new Event();
            Assert.IsInstanceOfType(testEvent.DayPeriod, typeof(int));
        }

        [TestMethod]
        public void TestEventNameType()
        {
            Event testEvent = new Event();
            Assert.IsInstanceOfType(testEvent.Name, typeof(string));
        }

        [TestMethod]
        public void TestEventDescriptionType()
        {
            Event testEvent = new Event();
            Assert.IsInstanceOfType(testEvent.Description, typeof(string));
        }

        [TestMethod]
        public void TestEventRecurringType()
        {
            Event testEvent = new Event();
            Assert.IsInstanceOfType(testEvent.Recurring, typeof(bool));
        }

        [TestMethod]
        public void TestEventStartTimeType()
        {
            Event testEvent = new Event();
            Assert.IsInstanceOfType(testEvent.StartTime, typeof(DateTime));
        }

        [TestMethod]
        public void TestEventLastModifiedType()
        {
            Event testEvent = new Event();
            Assert.IsInstanceOfType(testEvent.LastModified, typeof(DateTime));
        }

        [TestMethod]
        public void TestEventCreatedOnType()
        {
            Event testEvent = new Event();
            Assert.IsInstanceOfType(testEvent.CreatedOn, typeof(DateTime));
        }

        [TestMethod]
        public void TestEventPastEventType()
        {
            Event testEvent = new Event();
            testEvent.StartTime = DateTime.Now.AddDays(-1); // Set start time to a past date
            Assert.IsInstanceOfType(testEvent.PastEvent, typeof(bool));
        }


        // TEST NAMES: TESTEVENTDEFAULT[PROPERTY NAME]VALUE
        //
        // TEST PURPOSES:
        // Test to see if the properties of the Event class have
        // the correct default values when an Event object is created.

        [TestMethod]
        public void TestEventDefaultTUID()
        {
            Event testEvent = new Event();
            Assert.AreEqual(testEvent.TUID, 0);
        }

        [TestMethod]
        public void TestEventDefaultCreatedBy()
        {
            Event testEvent = new Event();
            Assert.AreEqual(testEvent.CreatedBy, 0);
        }

        [TestMethod]
        public void TestEventDefaultModifiedBy()
        {
            Event testEvent = new Event();
            Assert.AreEqual(testEvent.ModifiedBy, 0);
        }

        [TestMethod]
        public void TestEventDefaultDayPeriod()
        {
            Event testEvent = new Event();
            Assert.AreEqual(testEvent.DayPeriod, 1);
        }


        [TestMethod]
        public void TestEventDefaultNameValue()
        {
            Event testEvent = new Event();
            Assert.AreEqual(testEvent.Name, string.Empty);
        }

        [TestMethod]
        public void TestEventDefaultDescriptionValue()
        {
            Event testEvent = new Event();
            Assert.AreEqual(testEvent.Description, string.Empty);
        }


        [TestMethod]
        public void TestEventDefaultRecurringValues()
        {
            Event testEvent = new Event();
            Assert.IsFalse(testEvent.Recurring);
        }

        [TestMethod]
        public void TestEventDefaultStartTime()
        {
            Event testEvent = new Event();
            Assert.AreEqual(testEvent.StartTime, DateTime.MinValue);
        }


        [TestMethod]
        public void TestEventDefaultLastModified()
        {
            Event testEvent = new Event();
            Assert.AreEqual(testEvent.LastModified, DateTime.MinValue);
        }

        [TestMethod]
        public void TestEventDefaultCreatedOn()
        {
            Event testEvent = new Event();
            Assert.AreEqual(testEvent.CreatedOn, DateTime.MinValue);
        }

        [TestMethod]
        public void TestEventDefaultPastEvent()
        {
            Event testEvent = new Event();
            Assert.IsTrue(testEvent.PastEvent);
        }

        // TEST NAMES: TESTEVENTDSETTUID[VALUE]
        //
        // TEST PURPOSES:
        // Test to see if the TUID property of the Event class can be set to various values,
        // including error cases such as non-int values (if applicable),
        // and that those values are correctly stored in the object.

        [TestMethod]
        public void TestEventSetTUIDZero()
        {
            Event testEvent = new Event();
            testEvent.TUID = 0;
            Assert.AreEqual(testEvent.TUID, 0);
        }


        //TUID should never be able to be set to negative values
        [TestMethod]
        public void TestEventSetTUIDNegative()
        {
            Event testEvent = new Event();
            testEvent.TUID = -1;
            Assert.AreNotEqual(testEvent.TUID, -1);
        }

        [TestMethod]
        public void TestEventSetTUIDPositive()
        {
            Event testEvent = new Event();
            testEvent.TUID = 100;
            Assert.AreEqual(testEvent.TUID, 100);
        }

        /* Note that the compiler refuses to run this test because the TUID property is of type int, 
         * so it cannot be set to a non-int value.
         * Problem in the future: If the TUID property is manually changed by a user to the wrong type,
         *  it could cause errors in the application. 
         * 
        [TestMethod]
        public void TestEventSetTUIDInvalid()
        {
            Event testEvent = new Event();

            Assert.ThrowsException<FormatException>(() =>
            {
                testEvent.TUID = "not-a-number";
            });
        }
        */

        // TEST NAMES: TESTEVENTDSETCREATEDBY[VALUE]
        //
        // TEST PURPOSES:
        // Test to see if the CreatedBy property of the Event class can be set to various values,
        // including error cases such as non-int values (if applicable),
        // and that those values are correctly stored in the object.
        [TestMethod]
        public void TestEventSetCreatedByZero()
        {
            Event testEvent = new Event();
            testEvent.CreatedBy = 0;
            Assert.AreEqual(testEvent.CreatedBy, 0);
        }

        //CreatedBy should never be allowed to be Negative
        [TestMethod]
        public void TestEventSetCreatedByNegative() 
        {
            Event testEvent = new Event();
            testEvent.CreatedBy = -1;
            Assert.AreNotEqual(testEvent.CreatedBy, -1);
        }

        [TestMethod]
        public void TestEventSetCreatedByPositive()
        {
            Event testEvent = new Event();
            testEvent.CreatedBy = 100;
            Assert.AreEqual(testEvent.CreatedBy, 100);
        }

         /* Note that the compiler refuses to run this test because the CreatedBy property is of type int, 
         * so it cannot be set to a non-int value.
         * Problem in the future: If the CreatedBy property is manually changed by a user to the wrong type,
         *  it could cause errors in the application. 
         *  
        [TestMethod]
        public void TestEventSetCreatedByInvalid()
        {
            Event testEvent = new Event();
            testEvent.CreatedBy = "invalid";
            Assert.IsFalse(testEvent.CreatedBy == "invalid");
        }
         */


        // TEST NAMES: TESTEVENTDSETMODIFIEDBY[VALUE]
        //
        // TEST PURPOSES:
        // Test to see if the ModifiedBy property of the Event class can be set to various values,
        // including error cases such as non-int values (if applicable),
        // and that those values are correctly stored in the object.
        [TestMethod]
        public void TestEventSetModifiedByZero()
        {
            Event testEvent = new Event();
            testEvent.ModifiedBy = 0;
            Assert.AreEqual(testEvent.ModifiedBy, 0);
        }

        //ModifiedBy should never be allowed to be Negative
        [TestMethod]
        public void TestEventSetModifiedByNegative() 
        {
            Event testEvent = new Event();
            testEvent.ModifiedBy = -1;
            Assert.AreNotEqual(testEvent.ModifiedBy, -1);
        }

        [TestMethod]
        public void TestEventSetModifiedByPositive()
        {
            Event testEvent = new Event();
            testEvent.ModifiedBy = 100;
            Assert.AreEqual(testEvent.ModifiedBy, 100);
        }


         /* Note that the compiler refuses to run this test because the TUID property is of type int, 
         * so it cannot be set to a non-int value.
         * Problem in the future: If the ModifiedBy property is manually changed by a user to the wrong type,
         *  it could cause errors in the application. 
         *  
        [TestMethod]
        public void TestEventSetModifiedByInvalid()
        {
            Event testEvent = new Event();
            testEvent.ModifiedBy = "invalid";
            Assert.IsFalse(testEvent.ModifiedBy == "invalid");
        }
         */


        // TEST NAMES: TESTEVENTDSETDAYPERIOD[VALUE]
        //
        // TEST PURPOSES:
        // Test to see if the DayPeriod property of the Event class can be set to various values,
        // including edge cases such as negative numbers and zero,
        // and that those values are correctly stored in the object.

        [TestMethod]
        public void TestEventSetDayPeriodNegative() //Should correct itself to a positive 1
        {
            Event testEvent = new Event();
            testEvent.DayPeriod = -1;
            Assert.AreEqual(testEvent.DayPeriod, 1);
        }

        [TestMethod]
        public void TestEventSetDayPeriodZero() // Should correct itself to a positive 1
        {
            Event testEvent = new Event();
            testEvent.DayPeriod = 0;
            Assert.AreEqual(testEvent.DayPeriod, 1);
        }

        [TestMethod]
        public void TestEventSetDayPeriodPositive()
        {
            Event testEvent = new Event();
            testEvent.DayPeriod = 10;
            Assert.AreEqual(testEvent.DayPeriod, 10);
        }

         /* Note that the compiler refuses to run this test because the DayPeriod property is of type int, 
         * so it cannot be set to a non-int value.
         * Problem in the future: If the DayPeriod property is manually changed by a user to the wrong type,
         *  it could cause errors in the application. 
         *  
        [TestMethod]
        public void TestEventSetDayPeriodInvalid()
        {
            Event testEvent = new Event();
            testEvent.DayPeriod = "invalid";
            Assert.IsFalse(testEvent.DayPeriod == "invalid");
        }
         */


        // TEST NAMES: TESTEVENTDSETNAME[VALUE]
        //
        // TEST PURPOSES:
        // Test to see if the Name property of the Event class can be set to various values,
        // including error cases such as non-string values (if applicable),
        // and that those values are correctly stored in the object.


        [TestMethod]
        public void TestEventSetNameEmpty()
        {
            Event testEvent = new Event();
            testEvent.Name = string.Empty;
            Assert.AreEqual(testEvent.Name, string.Empty);
        }

        [TestMethod]
        public void TestEventSetName()
        {
            Event testEvent = new Event();
            testEvent.Name = "Test Event";
            Assert.AreEqual(testEvent.Name, "Test Event");
        }

        [TestMethod]
        public void TestEventSetNameNull()
        {
            Event testEvent = new Event();
            testEvent.Name = null;
            Assert.AreEqual(testEvent.Name, null);
        }

        /* Note that the compiler refuses to run this test because the Name property is of type string, 
            * so it cannot be set to a non-string value.
            * Problem in the future: If the Name property is manually changed by a user to the wrong type,
            *  it could cause errors in the application. 
            *
        [TestMethod]
        public void TestEventSetNameWrongType()
        {
            Event testEvent = new Event();
            testEvent.Name = 123;
            Assert.IsFalse(testEvent.Name == 123);
        }
        */

        // TEST NAMES: TESTEVENTDSETDESCRIPTION[VALUE]
        //
        // TEST PURPOSES:
        // Test to see if the Description property of the Event class can be set to various values,
        // including error cases such as non-string values (if applicable),
        // and that those values are correctly stored in the object.

        [TestMethod]
        public void TestEventSetDescriptionEmpty()
        {
            Event testEvent = new Event();
            testEvent.Description = string.Empty;
            Assert.AreEqual(testEvent.Description, string.Empty);
        }

        [TestMethod]
        public void TestEventSetDescription()
        {
            Event testEvent = new Event();

            testEvent.Description = "This is a test event.";
            Assert.AreEqual(testEvent.Description, "This is a test event.");
        }

        [TestMethod]
        public void TestEventSetDescriptionNull()
        {
            Event testEvent = new Event();
            testEvent.Description = null;
            Assert.AreEqual(testEvent.Description, null);
        }


         /* Note that the compiler refuses to run this test because the Description property is of type string 
         * so it cannot be set to a non-string value.
         * Problem in the future: If the Description property is manually changed by a user to the wrong type,
         *  it could cause errors in the application. 
         *  
        [TestMethod]
        public void TestEventSetDescriptionWrongType() {
            Event testEvent = new Event();
            testEvent.Description = 123;
            Assert.IsFalse(testEvent.Description == 123);
        }
         */


        // TEST NAMES: TESTEVENTDSETRECURRING[VALUE]
        //
        // TEST PURPOSES:
        // Test to see if the Recurring property of the Event class can be set to various values,
        // including error cases such as non-boolean values (if applicable),
        // and that those values are correctly stored in the object.

        [TestMethod]
        public void TestEventSetRecurringTrue()
        {
            Event testEvent = new Event();
            testEvent.Recurring = true;
            Assert.IsTrue(testEvent.Recurring);
        }

        [TestMethod]
        public void TestEventSetRecurringFalse()
        {
            Event testEvent = new Event();
            testEvent.Recurring = false;
            Assert.IsFalse(testEvent.Recurring);
        }


         /* Note that the compiler refuses to run this test because the Recurring property is of type boolean
         * so it cannot be set to a non-boolean value.
         * Problem in the future: If the Recurring property is manually changed by a user to the wrong type,
         *  it could cause errors in the application. 
         *  
        [TestMethod]
        public void TestEventSetRecurringInvalid()
        {
            Event testEvent = new Event();
            testEvent.Recurring = 1;
            Assert.IsFalse(testEvent.Recurring == 1);
        }
        */


        // TEST NAMES: TESTEVENTDSETSTARTTIME[VALUE]
        //
        // TEST PURPOSES:
        // Test to see if the StartTime property of the Event class can be set to various values,
        // including error cases such as non-DateTime values (if applicable),
        // and that those values are correctly stored in the object.

        [TestMethod]
        public void TestEventSetStartTimeMinValue()
        {
            Event testEvent = new Event();
            testEvent.StartTime = DateTime.MinValue;
            Assert.AreEqual(testEvent.StartTime, DateTime.MinValue);
        }


        [TestMethod]
        public void TestEventSetStartTimeMaxValue()
        {
            Event testEvent = new Event();
            testEvent.StartTime = DateTime.MaxValue;
            Assert.AreEqual(testEvent.StartTime, DateTime.MaxValue);
        }


        [TestMethod]
        public void TestEventSetStartTimeNow()
        {
            Event testEvent = new Event();
            DateTime now = DateTime.Now;
            testEvent.StartTime = now;
            Assert.AreEqual(testEvent.StartTime, now);
        }


         /* Note that the compiler refuses to run this test because the StartTime property is of type DateTime
         * so it cannot be set to a non-DateTime value.
         * Problem in the future: If the StartTime property is manually changed by a user to the wrong type,
         *  it could cause errors in the application. 
         *  
        [TestMethod]
        public void TestEventSetStartTimeInvalid()
        {
            Event testEvent = new Event();
            testEvent.StartTime = "invalid";
            Assert.IsFalse(testEvent.StartTime == "invalid");
        }
        */




        // TEST NAMES: TESTEVENTDSETLASTMODIFIED[VALUE]
        //
        // TEST PURPOSES:
        // Test to see if the LastModified property of the Event class can be set to various values,
        // including error cases such as non-DateTime values (if applicable),
        // and that those values are correctly stored in the object.
        [TestMethod]
        public void TestEventSetLastModifiedPastValue()
        {
            Event testEvent = new Event();
            DateTime past = DateTime.Now.AddDays(-1); // Set Modified time to a past date
            testEvent.LastModified = past;
            Assert.AreEqual(testEvent.LastModified, past);
        }

        //LastModified should never be able to be set to a future date since it represents the last time the event was modified,
        //so it should not be able to be set to a future date
        [TestMethod]
        public void TestEventSetLastModifiedFutureValue()
        {
            Event testEvent = new Event();
            DateTime future = DateTime.Now.AddDays(1); // Set last Modified time to a future date
            testEvent.LastModified = future;
            Assert.AreNotEqual(testEvent.LastModified, future);
        }
        [TestMethod]
        public void TestEventSetLastModifiedNow()
        {
            Event testEvent = new Event();
            DateTime now = DateTime.Now;
            testEvent.LastModified = now;
            Assert.AreEqual(testEvent.LastModified, now);
        }

        /*Note that the compiler refuses to run this test because the LastModified property is of type DateTime
         * so it cannot be set to a non-DateTime value.
         * Problem in the future: If the LastModified property is manually changed by a user to the wrong type,
         *  it could cause errors in the application. 
         * 
        [TestMethod]
        public void TestEventSetLastModifiedInvalid()
        {
            Event testEvent = new Event();
            testEvent.LastModified = "invalid";
            Assert.IsFalse(testEvent.LastModified == "invalid");
        }
        */


        // TEST NAMES: TESTEVENTDSETCREATEDON[VALUE]
        //
        // TEST PURPOSES:
        // Test to see if the CreatedOn property of the Event class can be set to various values,
        // including error cases such as non-DateTime values (if applicable),
        // and that those values are correctly stored in the object.
        [TestMethod]
        public void TestEventSetCreatedOnPastValue()
        {
            Event testEvent = new Event();
            DateTime past = DateTime.Now.AddDays(-1); // Set Creation time to a past date
            testEvent.CreatedOn = past;
            Assert.AreEqual(testEvent.CreatedOn, past);
        }

        //CreatedOn should never be able to be set to a future date since it represents the time the event was created,
        //so it should not be able to be set to a future date
        [TestMethod]
        public void TestEventSetCreatedOnFutureValue()
        {
            Event testEvent = new Event();
            DateTime future = DateTime.Now.AddDays(1); // Set creation time to a future date
            testEvent.CreatedOn = future;
            Assert.AreNotEqual(testEvent.CreatedOn, future);
        }
        [TestMethod]
        public void TestEventSetCreatedOnNow()
        {
            Event testEvent = new Event();
            DateTime now = DateTime.Now;
            testEvent.CreatedOn = now;
            Assert.AreEqual(testEvent.CreatedOn, now);
        }

        /*Note that the compiler refuses to run this test because the CreatedOn property is of type DateTime
         * so it cannot be set to a non-DateTime value.
         * Problem in the future: If the CreatedOn property is manually changed by a user to the wrong type,
         *  it could cause errors in the application. 
         *  
        [TestMethod]
        public void TestEventSetCreatedOnInvalid()
        {
            Event testEvent = new Event();
            testEvent.CreatedOn = "invalid";
            Assert.IsFalse(testEvent.CreatedOn == "invalid");
        }
        */


       
       
        // TEST NAMES: TESTEVENTDSETPASTEVENT[VALUE]
        //
        // TEST PURPOSES:
        // Test to see if the PastEvent property of the Event class can be set to various value via modifying the start time,
        // including error cases such as non-DateTime values (if applicable),
        // and that those values are correctly stored in the object.

        [TestMethod]
        public void TestEventSetPastEventPast()
        {
            Event testEvent = new Event();
            testEvent.StartTime = DateTime.Now.AddDays(-1); // Set start time to a past date
            Assert.IsTrue(testEvent.PastEvent);
        }
        [TestMethod]
        public void TestEventSetPastEventFuture()
        {
            Event testEvent = new Event();
            testEvent.StartTime = DateTime.Now.AddDays(1); // Set start time to a future date
            Assert.IsFalse(testEvent.PastEvent);
        }
        [TestMethod]
        public void TestEventSetPastEventNow()
        {
            Event testEvent = new Event();
            DateTime now = DateTime.Now;
            testEvent.StartTime = now;
            Assert.IsFalse(testEvent.PastEvent); // Depending on the exact timing, this could be true or false, so we check for false to ensure it's not considered a past event since its still happening
        }


        /* Note that the compiler refuses to run this test because the StartTime property is of type DateTime
         * so it cannot be set to a non-DateTime value.
         * Problem in the future: If the StartTime property is manually changed by a user to the wrong type,
         *  it could cause errors in the application. 
         *  
        [TestMethod]
        public void TestEventSetPastEventInvalid()
        {
            Event testEvent = new Event();
            testEvent.StartTime = "invalid";
            Assert.IsFalse(testEvent.PastEvent == "invalid");
        }
        */
    }
 }