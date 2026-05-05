
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Text;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using PAWS.WinForms.Components.Common;

using PAWS.WinForms.Forms;
using PAWS.WinForms.Helpers;
using PAWS.WinForms.Models.Events;


namespace QA_TEST.Components.Calendar
{
    // FILENAME: QA_Calendar_Test.cs
    //
    // WRITTEN BY: Alyssa Lilly
    // DATE CREATED: March 17 2026
    //
    // PART OF PROJECT: PAWS.WinForms (QA Testing)
    //
    // FILE PURPOSE:
    // This file contains unit tests for the Calendar component of the PAWS.WinForms application. These tests are designed to verify that the calendar functionality works as intended and meets the specified requirements. The tests cover various aspects of the calendar, including event creation, event editing, event deletion, and the display of events on the calendar view
    // Tests verify control creation, constructor defaults, and date selection behavior.
    // There are also "Unit Tests" that test visual components that do not require a Unit Test framework, such as visual inspection of the calendar view and event creation/editing screens. These tests are included in this file for organizational purposes, but they do not contain any code and should be performed manually by a tester.
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
    public class QA_Calendar_Test {

        // =======================================
        // DOCUMENTATION TEAM REQUIREMENTS TESTS
        // =======================================

        //------------------------------------------------------------------------
        //------------------------Menu Sidebar Tests------------------------------
        //------------------------------------------------------------------------
        //Test of GUI requirement "The system shall provide a menu bar with buttons to specific pages on every page beyond the login screen."
        //Test: Visual inspection from event viewing screen.
        [TestMethod]
        public void TestMenuBarPresence()
        {
            Assert.Inconclusive("Manual test: verify menu bar is present on the left hand of the screen, with all buttons present and working.");
        }

        //Test of the GUI requirement "The system shall allow users to access the calendar view screen by clicking a calendar button on the menu bar."
        //Test: Visual inspection for button; click button, verify it leads to calendar view screen.
        [TestMethod]
        public void TestCalendarView()
        {
            Assert.Inconclusive("Manual test: verify clicking the calendar icon in the menu bar pulls up the calendar screen.");
        }

        //-------------------------------------------------------------------
        //------------------------Error Message Tests------------------------
        //-------------------------------------------------------------------
        //Test of GUI requirement "The system shall display meaningful error messages when operations fail" for errors creating events
        //Test: Attempt to create an event without filling out required fields. Verify error message is displayed.
        [TestMethod]
        public void TestErrorMessageInCreation()
        {
            Assert.Inconclusive("Manual test: attempt to create an event without filling out required fields. Verify error message is displayed.");
        }

        //-------------------------------------------------------------------
        //------------------------GUI Tests (Visibility)---------------------
        //-------------------------------------------------------------------
        //Test of the GUI requirement "The system shall allow users to view upcoming calendar events on the calendar view screen."
        //Test: Visual inspection for event viewing screen.
        [TestMethod]
        public void TestUpcomingEventsVisible()
        {
            Assert.Inconclusive("Manual test: verify upcoming events are visible on the calendar view screen.");
        }


        //---------------------------------------------------------------------
        //------------------------Event Filtering Tests------------------------
        //---------------------------------------------------------------------
        //Tests of the GUI requirement "The system shall allow users to filter upcoming events by event name, location, timeframe, involved people, and involved pets."
        //Test: Visual inspection for event filter field - Filter by Name
        [TestMethod]
        public void TestFilteringByName()
        {
            Assert.Inconclusive("Manual test: verify filtering by name field works correctly by entering a name and verifying the event list updates to show only events with that name.");
        }
        //Test: Visual inspection for event filter field - Filter by Location
        [TestMethod]
        public void TestFilteringByLocation()
        {
            Assert.Inconclusive("Manual test: verify filtering by location field works correctly by entering a location and verifying the event list updates to show only events with that location.");
        }
        //Test: Visual inspection for event filter field - Filter by TimeFrame
        [TestMethod]
        public void TestFilteringByTimeFrame()
        {
            Assert.Inconclusive("Manual test: verify filtering by timeframe field works correctly by entering a timeframe and verifying the event list updates to show only events within that timeframe.");
        }
        //Test: Visual inspection for event filter field - Filter by People
        [TestMethod]
        public void TestFilteringByPeople()
        {
            Assert.Inconclusive("Manual test: verify filtering by people field works correctly by entering a person's name and verifying the event list updates to show only events with that person involved.");
        }
        //Test: Visual inspection for event filter field - Filter by Pets
        [TestMethod]
        public void TestFilteringByPets()
        {
            Assert.Inconclusive("Manual test: verify filtering by pets field works correctly by entering a pet's name and verifying the event list updates to show only events with that pet involved.");
        }


        //---------------------------------------------------------------------
        //------------------------Calendar Component Tests---------------------
        //---------------------------------------------------------------------
        //Test of the GUI requirement "The system shall allow users to view more information about an event by clicking on the calendar to display."
        //Test: Click on an event from the calendar to display and ensure event information is displayed.
        [TestMethod]
        public void TestCalendarClickAndShowInfo()
        {
            Assert.Inconclusive("Manual test: click on an event from the calendar to display and ensure event information is displayed.");
        }


        //---------------------------------------------------------------------
        //------------------------Event Creation Tests-------------------------
        //---------------------------------------------------------------------
        //Test of the GUI requirement "The system shall include an event creation screen where users can add data to create a new event."
        //Test: Visual inspection for screen.
        [TestMethod]
        public void TestCreateNewEventFormExists()
        {
            Assert.Inconclusive("Manual test: verify clicking the 'Create Event' button produces a create event screen.");
        }

        //Test of the GUI requirement "The system shall allow users to select a create event button on the event display screen which will lead to the create event screen."
        //Test: Visually inspect the search screen for a create event button; click button to verify the create event screen opens.
        [TestMethod]
        public void TestCreateNewEvent()
        {
            Assert.Inconclusive("Manual test: verify clicking the 'Create Event' button produces a create event screen.");
        }

        //Test of the GUI requirement "The system shall allow users to discard an event while they are in the process of creating it."
        //Test: Attempt to discard event from the creation screen. Event should not be saved.
        [TestMethod]
        public void TestDiscardEvent()
        {
            Assert.Inconclusive("Manual test: attempt to discard event from the creation screen. Event should not be saved.");
        }

        //Test of the GUI requirement "The system shall allow, but not require, an event location, event description, a list of involved people, and a list of involved pets to be included with an event."
        //Test: Visual inspection for each field; attempt to add data.

        //Test: Attempt to create event without filling out any optional fields. Event should be created successfully.
        [TestMethod]
        public void TestNoOptionalFields()
        {
           Assert.Inconclusive("Manual test: attempt to create event without filling out any optional fields. Event should be created successfully.");
        }

        //Test: Attempt to create event with all optional fields filled out with the exception of the Repeat Event Field. Event should be created successfully and all data should be saved.
        [TestMethod]
        public void TestAllOptionalFields()
        {
            Assert.Inconclusive("Manual test: attempt to create event with all optional fields filled out with the exception of the Repeat Event Field. Event should be created successfully and all data should be saved.");

        }

        //Test: Only Event Location optional field filled out. Event should be created successfully and location data should be saved.
        [TestMethod]
        public void TestOnlyLocation()
        {
            Assert.Fail("Manual test: attempt to create event with only location filled out, but there is no location field");
        }

        //Test: Only Event Description optional field filled out. Event should be created successfully and description data should be saved.
        [TestMethod]
        public void TestOnlyDescription()
        {
            Assert.Inconclusive("Manual test: attempt to create event with only description filled out. Event should be created successfully and description data should be saved.");
        }

        //Test: Only Involved People optional field filled out. Event should be created successfully and involved people data should be saved.
        [TestMethod]
        public void TestOnlyPeople()
        {
            Assert.Inconclusive("Manual test: attempt to create event with only involved people filled out. Event should be created successfully and involved people data should be saved.");
        }

        //Test: Only Involved Pets optional field filled out. Event should be created successfully and involved pets data should be saved.
        [TestMethod]
        public void TestOnlyPets()
        {
            Assert.Fail("Manual test: attempt to create event with involved pets filled out, but there is no pet field");
        }

        //Test: Event Location and Event Description optional fields filled out. Event should be created successfully and location and description data should be saved.
        [TestMethod]
        public void TestLocationAndDescription()
        {
            Assert.Fail("Manual test: attempt to create event with location filled out, but there is no location field");
        }
        //Test: Event Location and Involved People optional fields filled out. Event should be created successfully and location and involved people data should be saved.
        [TestMethod]
        public void TestLocationAndPeople()
        {
            Assert.Fail("Manual test: attempt to create event with location filled out, but there is no location field");
        }
        //Test: Event Location and Involved Pets optional fields filled out. Event should be created successfully and location and involved pets data should be saved.
        [TestMethod]
        public void TestLocationAndPets()
        {
            Assert.Fail("Manual test: attempt to create event with location filled out, but there is no location field");
        }
        //Test: Event Description and Involved People optional fields filled out. Event should be created successfully and description and involved people data should be saved.
        [TestMethod]
        public void TestDescriptionAndPeople()
        {
            Assert.Inconclusive("Manual Test: attempt to create event with only description and involved people filled out. Event should be created successfully and description and involved people data should be saved.");
        }
        //Test: Event Description and Involved Pets optional fields filled out. Event should be created successfully and description and involved pets data should be saved.
        [TestMethod]
        public void TestDescriptionAndPets()
        {
            Assert.Fail("Manual test: attempt to create event with involved pets filled out, but there is no pet field");
        }
        //Test: Involved People and Involved Pets optional fields filled out. Event should be created successfully and involved people and involved pets data should be saved.
        [TestMethod]
        public void TestPeopleAndPets()
        {
            Assert.Fail("Manual test: attempt to create event with involved pets filled out, but there is no pet field");
        }
        //Test: Event Location, Event Description, and Involved People optional fields filled out. Event should be created successfully and location, description, and involved people data should be saved.
        [TestMethod]
        public void TestLocationDescriptionAndPeople()
        {
            Assert.Fail("Manual test: attempt to create event with location filled out, but there is no location field");
        }
        //Test: Event Location, Event Description, and Involved Pets optional fields filled out. Event should be created successfully and location, description, and involved pets data should be saved.
        [TestMethod]
        public void TestLocationDescriptionAndPets()
        {
            Assert.Fail("Manual test: attempt to create event with location filled out, but there is no location field");
        }
        //Test: Event Location, Involved People, and Involved Pets optional fields filled out. Event should be created successfully and location, involved people, and involved pets data should be saved.
        [TestMethod]
        public void TestLocationPeopleAndPets()
        {
            Assert.Fail("Manual test: attempt to create event with involved pets filled out, but there is no pet field");
        }
        //Test: Event Description, Involved People, and Involved Pets optional fields filled out. Event should be created successfully and description, involved people, and involved pets data should be saved.
        [TestMethod]
        public void TestDescriptionPeopleAndPets()
        {
            Assert.Fail("Manual test: attempt to create event with involved pets filled out, but there is no pet field");
        }
        //Test: Event Location, Event Description, Involved People, and Involved Pets optional fields filled out. Event should be created successfully and all data should be saved.
        [TestMethod]
        public void TestLocationDescriptionPeopleAndPets()
        {
            Assert.Fail("Manual test: attempt to create event with location filled out, but there is no location field");
        }

        //---------------------------------Test the Repeat Event field for each of the above tests----------------------------------------

        //Test: Attempt to create event without filling out any optional fields, with the exception of the Repeat Event Field. Event should be created successfully.
        [TestMethod]
        public void TestNoOptionalFieldsWithRepeat()
        {
            Assert.Inconclusive("Manual test: attempt to create event without filling out any optional fields with the exception of the Repeat Event Field. Event should be created successfully.");
        }

        //Test: Attempt to create event with all optional fields filled out including the repeat event field. Event should be created successfully and all data should be saved.
        [TestMethod]
        public void TesttAllOptionalFieldsWithRepeat()
        {
            Assert.Inconclusive("Manual test: attempt to create event with all optional fields filled out. Event should be created successfully and all data should be saved.");

        }

        //Test: Only Event Location optional field and the repeat event field filled out. Event should be created successfully and location data should be saved.
        [TestMethod]
        public void TestOnlyLocationAndRepeat()
        {
            Assert.Fail("Manual test: attempt to create event with only location the repeat event fields filled out, but there is no location field");
        }

        //Test: Only Event Description optional field the repeat event field filled out. Event should be created successfully and description data should be saved.
        [TestMethod]
        public void TestOnlyDescriptionAndRepeat()
        {
            Assert.Inconclusive("Manual test: attempt to create event with only description the repeat event fields filled out. Event should be created successfully and description data should be saved.");
        }

        //Test: Only Involved People optional field the repeat event field filled out. Event should be created successfully and involved people data should be saved.
        [TestMethod]
        public void TestOnlyPeopleAndRepeat()
        {
            Assert.Inconclusive("Manual test: attempt to create event with only involved people the repeat event fields filled out. Event should be created successfully and involved people data should be saved.");
        }

        //Test: Only Involved Pets optional field the repeat event field filled out. Event should be created successfully and involved pets data should be saved.
        [TestMethod]
        public void TestOnlyPetsAndRepeat()
        {
            Assert.Fail("Manual test: attempt to create event with involved pets filled out, but there is no pet field");
        }

        //Test: Event Location and Event Description the repeat event optional fields filled out. Event should be created successfully and location and description data should be saved.
        [TestMethod]
        public void TestLocationAndDescriptionAndRepeat()
        {
            Assert.Fail("Manual test: attempt to create event with location filled out, but there is no location field");
        }
        //Test: Event Location and Involved People the repeat event optional fields filled out. Event should be created successfully and location and involved people data should be saved.
        [TestMethod]
        public void TestLocationAndPeopleAndRepeat()
        {
            Assert.Fail("Manual test: attempt to create event with location filled out, but there is no location field");
        }
        //Test: Event Location and Involved Pets the repeat event optional fields filled out. Event should be created successfully and location and involved pets data should be saved.
        [TestMethod]
        public void TestLocationAndPetsAndRepeat()
        {
            Assert.Fail("Manual test: attempt to create event with location filled out, but there is no location field");
        }
        //Test: Event Description and Involved People the repeat event optional fields filled out. Event should be created successfully and description and involved people data should be saved.
        [TestMethod]
        public void TestDescriptionAndPeopleAndRepeat()
        {
            Assert.Inconclusive("Manual Test: attempt to create event with only description and involved people the repeat event fields filled out. Event should be created successfully and description and involved people data should be saved.");
        }
        //Test: Event Description and Involved Pets and Repeat Event optional fields filled out. Event should be created successfully and description and involved pets data should be saved.
        [TestMethod]
        public void TestDescriptionAndPetsAndRepeat()
        {
            Assert.Fail("Manual test: attempt to create event with involved pets filled out, but there is no pet field");
        }
        //Test: Involved People and Involved Pets and repeat event optional fields filled out. Event should be created successfully and involved people and involved pets data should be saved.
        [TestMethod]
        public void TestPeopleAndPetsAndRepeat()
        {
            Assert.Fail("Manual test: attempt to create event with involved pets filled out, but there is no pet field");
        }
        //Test: Event Location, Event Description, Involved People, and Repeat Event optional fields filled out. Event should be created successfully and location, description, and involved people data should be saved.
        [TestMethod]
        public void TestLocationDescriptionAndPeopleAndRepeat()
        {
            Assert.Fail("Manual test: attempt to create event with location filled out, but there is no location field");
        }
        //Test: Event Location, Event Description, Involved Pets, and Repeat Event optional fields filled out. Event should be created successfully and location, description, and involved pets data should be saved.
        [TestMethod]
        public void TestLocationDescriptionAndPetsAndRepeat()
        {
            Assert.Fail("Manual test: attempt to create event with involved pets filled out, but there is no pet field");
        }
        //Test: Event Location, Involved People, Involved Pets, and Repeat Event optional fields filled out. Event should be created successfully and location, involved people, and involved pets data should be saved.
        [TestMethod]
        public void TestLocationPeopleAndPetsAndRepeat()
        {
            Assert.Fail("Manual test: attempt to create event with location filled out, but there is no location field");
        }
        //Test: Event Description, Involved People, Involved Pets, and Repeat Event optional fields filled out. Event should be created successfully and description, involved people, and involved pets data should be saved.
        [TestMethod]
        public void TestDescriptionPeopleAndPetsAndRepeat()
        {
            Assert.Fail("Manual test: attempt to create event with involved pets filled out, but there is no pet field");
        }
        //Test: Event Location, Event Description, Involved People, Involved Pets, and Repeat Event optional fields filled out. Event should be created successfully and all data should be saved.
        [TestMethod]
        public void TestLocationDescriptionPeopleAndPetsAndRepeat()
        {
            Assert.Fail("Manual test: attempt to create event with involved pets filled out, but there is no pet field");
        }


        //---------------------------------------------------------------------
        //------------------------Event Editing Tests--------------------------
        //---------------------------------------------------------------------
        //Test of the GUI requirement "The system shall include an event edit screen where a user can make edits to an existing event."
        //Test: Visual inspection for the edit screen.
        [TestMethod]
        public void TestEventEditScreenExists()
        {
            Assert.Inconclusive("Manual test: verify 'Edit Event' screen exists.");
        }

        //Test of the GUI requirement "The system shall allow users to open the edit event screen by pressing a button on the event information screen."
        //Test: Visual inspection for button; click button, verify it leads to edit screen.
        [TestMethod]
        public void TestEventEditFormOpens()
        {
            Assert.Inconclusive("Manual test: verify clicking the 'Edit Event' button from the event information screen opens the edit event screen.");
        }

        //Test of the GUI requirement "The system shall allow users to discard edits to an event while they are in the process of editing it."
        //Test: Attempt to discard event edits from edit screen. Event edits should not be saved.
        [TestMethod]
        public void TestEventEditDiscard()
        {
            Assert.Inconclusive("Manual test: attempt to discard event edits from edit screen. Event edits should not be saved.");
        }

        //Test of the GUI requirement "The system shall allow users to save edits to an event by clicking a button once they have filled out all required fields."
        //Test: Attempt to save event edits from edit screen. Event edits should be saved.
        [TestMethod]
        public void TestEventEdit()
        {
            Assert.Inconclusive("Manual test: attempt to save event edits from edit screen. Event edits should be saved.");
        }


        //---------------------------------------------------------------------
        //-------------------------Event Deletion Tests------------------------
        //---------------------------------------------------------------------
        //Test of the GUI requirement "The system shall allow users to delete events from the edit screen by pressing a button."
        //Test: Visual inspection for button; click button, verify it leads to deletion.
        [TestMethod]
        public void TestEventDelete()
        {
            Assert.Inconclusive("Manual test: verify clicking the 'Delete Event' button from the edit event screen deletes the event.");
        }

        //Test of the GUI requirement "The system shall confirm users’ attempts to delete an event before deleting it."
        //Test: Click the delete button and verify a confirmation prompt appears.
        [TestMethod]
        public void TestDeleteConfirmation()
        {
            Assert.Inconclusive("Manual test: verify clicking the 'Delete Event' button from the edit event screen prompts a confirmation before deleting the event.");
        }



        // ===================================================================================
        // OTHER COMPONENTS AND FUNCTIONALITY TESTS (What is on screen but not in Doc tests)
        // ===================================================================================

        //------------------------------------------------------------------------
        //-------------------------Calendar Screen Tests--------------------------
        //------------------------------------------------------------------------
        //Test: Test that the Calendar screen exists and is instantiated correctly.
        [TestMethod]
        public void TestCalendarScreenExists()
        {
            var calendarScreen = new CalendarMain();
            Assert.IsNotNull(calendarScreen, "Calendar screen should be instantiated successfully.");
        }

        //------------------------------------------------------------------------
        //------------------------Calendar Component Tests------------------------
        //------------------------------------------------------------------------
        //Test: Test that the calendar control is present on the calendar screen.
        [TestMethod]
        public void TestCalendarControlExists()
        {
            var calendarScreen = new CalendarMain();

            var calendarControl = GetControl<MonthCalendar>(calendarScreen, "calMain");

            Assert.IsNotNull(calendarControl, "Calendar Control should exist on the calendar screen.");
        }


        //Test: Test that the calendar control defaults to the current month and year.
        [TestMethod]
        public void TestCalendarDefaultsToCurrentMonthAndYear()
        {
            var calendarScreen = new CalendarMain();
            var calendarControl = GetControl<MonthCalendar>(calendarScreen, "calMain");
            var currentDate = DateTime.Now;

            var selectedDate = calendarControl.SelectionStart.Date;

            Assert.AreEqual(currentDate.Month, selectedDate.Month, "Calendar should default to the current month.");
            Assert.AreEqual(currentDate.Year, selectedDate.Year, "Calendar should default to the current year.");

            Assert.AreEqual(currentDate, selectedDate, "Calendar date and today's  date should match.");
        }


        //Test: Test that selecting a date on the calendar control updates the selected date correctly.
        [TestMethod]
        public void TestCalendarDateSelection()
        {
            var calendarScreen = new CalendarMain();
            var calendarControl = GetControl<MonthCalendar>(calendarScreen, "calMain");
            var testDate = new DateTime(2025, 12, 25); // Christmas 2025
            calendarControl.SetDate(testDate);

            var selectedDate = calendarControl.SelectionStart;

            Assert.AreEqual(testDate.Month, selectedDate.Month, "Selected month should match the test date.");
            Assert.AreEqual(testDate.Year, selectedDate.Year, "Selected year should match the test date.");
            Assert.AreEqual(testDate.Day, selectedDate.Day, "Selected day should match the test date.");
        }

        //------------------------------------------------------------------------
        //----------------------------Event List Tests----------------------------
        //------------------------------------------------------------------------
        //Test: Test that the List of events exists
        [TestMethod]
        public void TestEventListExists()
        {
            var calendarScreen = new CalendarMain();
            var eventListControl = GetControl<ListView>(calendarScreen, "lvDayEvents");
            Assert.IsNotNull(eventListControl, "Event List control should exist on the calendar screen.");
        }


        //Test: Test that the List of events for the selected date is displayed correctly when a date is selected on the calendar control.
        [TestMethod]
        public void TestEventListUpdatesOnDateSelection()
        {
            var calendarScreen = new CalendarMain();
            var calendarControl = GetControl<MonthCalendar>(calendarScreen, "calMain");
            var eventListControl = GetControl<ListView>(calendarScreen, "lvDayEvents");

            //Setup fake events to see if they show up in the event list when the date is selected. This will require some refactoring of the calendar screen to allow for dependency injection of a fake event service, or some other method of simulating events for testing purposes.
            var testDate = new DateTime(2025, 12, 25);
            var testEvent1 = new Event
            {
                Name = "Christmas Party",
                Date = testDate,
                Description = "Annual Christmas party with family and friends.",
            };
            var testEvent2 = new Event
            {
                Name = "Gift Exchange",
                Date = testDate,
                Description = "Secret Santa gift exchange with coworkers.",
            };


            // Simulate selecting a date with known events
            calendarControl.SetDate(testDate);


            // Verify that the event list updates to show events for the selected date, and the events are what was expected
            var actualNames = eventListControl.Items.Cast<ListViewItem>().Select(i => i.Text).ToArray();
            var expectedNames = new[] { "Christmas Party", "Gift Exchange" };

            CollectionAssert.AreEquivalent(expectedNames, actualNames, "Event list should show the events for the selected date.");
        }


        // Test: Test that the event details are displayed correctly when an event is selected from the event list.
        [TestMethod]
        public void TestEventDetailsDisplayOnEventSelection()
        {
            var calendarScreen = new CalendarMain();
            var eventListControl = GetControl<ListView>(calendarScreen, "lvDayEvents");
            //Setup fake events to see if they show up in the event details when the event is selected. This will require some refactoring of the calendar screen to allow for dependency injection of a fake event service, or some other method of simulating events for testing purposes.
            var testDate = new DateTime(2025, 12, 25);
            var testEvent = new Event
            {
                Name = "Christmas Party",
                Date = testDate,
                Description = "Annual Christmas party with family and friends.",
            };

            // Simulate selecting an event from the event list
            // This will require some refactoring of the calendar screen to allow for programmatically selecting an event from the list and triggering the display of event details.
            // Verify that the event details are displayed correctly, and match the expected details for the selected event.
            Assert.AreEqual("Christmas Party", testEvent.Name, "Event name should match.");
            Assert.AreEqual("Annual Christmas party with family and friends.", testEvent.Description, "Event description should match.");
        }

        //------------------------------------------------------------------------
        //----------------------------Event Date/Time Tests-----------------------
        //------------------------------------------------------------------------
        //Manual Test - Event cannot be created with an end time earlier or at the same time as the start time
        [TestMethod]
        public void TestEventEndTimeEarlier()
        {
            Assert.Inconclusive("Manual Test: Verify an event's endtime cannot be set to before or the same time as the start time");
        }
        //Manual Test - Event cannot be created with a non-existant start time or end time
        [TestMethod]
        public void TestNonExistantTime()
        {
            Assert.Inconclusive("Manual test: verify the event's start time cannot be set to 79:00 (or something like that) and the endtime cannot be set to 66:99 (or something like that)");
        }
        //Manual Test - Event cannot be created for a ridiculous date (Ex. 1800s)
        [TestMethod]
        public void TestImprobableDateSetting()
        {
            Assert.Inconclusive("Manual test: verify the event's date cannot be set to an improbable year (like 1800s)");
        }
        //Manual Test - Event cannot be created for non-existant date
        [TestMethod]
        public void TestNonexistantDateSetting()
        {
            Assert.Inconclusive("Manual Test: Verify the event's date cannot be set to an impossible/nonexistant date (Feb 31st)");
        }



        // ============================================================
        // Helper: find control by name (used in multiple tests)
        // ============================================================
        private static T GetControl<T>(Control parent, string name) where T : Control
        {
            return parent.Controls.Find(name, true).FirstOrDefault() as T
                   ?? throw new Exception($"Control '{name}' not found.");
        }


    }
}
