using PAWS.WinForms.Models.People;
namespace QA_TEST
{
    [TestClass]
    public sealed class PersonTests
    {
        /// <summary>
        /// Purpose: Test Method checks to see if person fields
        /// default values for FirstName, LastName, Email,
        /// PhoneNumber, and FullName is not null.
        /// Tests initialization of clock to lastModified by
        /// at run-time.
        /// </summary>
        [TestMethod]
        public void Constructor_SetsSafeDefaults()
        {
            // variable to test time before person is instantiated
            var before = DateTime.Now;

            var person = new Person();

            // variable to test time after person is instantiated
            var after = DateTime.Now;

            // Assertions to check if fields are equal to empty string initially
            Assert.AreEqual("", person.FirstName);
            Assert.AreEqual("", person.LastName);
            Assert.AreEqual("", person.Email);
            Assert.AreEqual("", person.PhoneNumber);

            // Assert to check if Volunteer ID is null upon instantiaion
            // Assert.IsNull(person.VolunteerID); // commented out: VolunteerID no longer exists on Person

            // Assert to check if IsVolunteer is set to false initially
            Assert.IsFalse(person.IsVolunteer);

            // Assert to check if FullName is empty string initially
            Assert.AreEqual("", person.FullName);

            // Assert that clock assigns time to variables chronologically at run-time
            Assert.IsTrue(person.LastModified >= before && person.LastModified <= after);
        }

        /// <summary>
        /// Purpose: Checks Person fields: FirstName, LastName, Email, and
        /// PhoneNumber, to these properties are safeguarded from null values.
        /// </summary>
        [TestMethod]
        public void StringSetters_ConvertNullToEmpty()
        {
            // instantiates person object
            var person = new Person();

            // Initialize properties to null
            person.FirstName = null;
            person.LastName = null;
            person.Email = null;
            person.PhoneNumber = null;

            // Assertions to check properties are assigned to empty string
            Assert.AreEqual("", person.FirstName);
            Assert.AreEqual("", person.LastName);
            Assert.AreEqual("", person.Email);
            Assert.AreEqual("", person.PhoneNumber);
        }

        /// <summary>
        /// Purpose: Test full name to ensure formatting handles as expected.
        /// first, last, and expected are used as parameters to pass first name,
        /// last name, and expected match with the result
        /// </summary>
        /// <param name="first"></param>
        /// <param name="last"></param>
        /// <param name="expected"></param>
        [DataTestMethod]
        [DataRow("Joe", "Mama", "Joe Mama")]
        [DataRow("Joe", "", "Joe")]
        [DataRow("", "Mama", "Mama")]
        [DataRow("", "", "")]
        [DataRow("  ", "  ", "")]

        // this row fails because current implementation does not handle internal
        // whitespace between Joe and Mama
        [DataRow("  Joe  ", "  Mama  ", "Joe Mama")]
        public void FullName_BehavesAsExpected(string first, string last, string expected)
        {
            // instantiate person and assign first/last name to passed values
            var person = new Person
            {
                FirstName = first,
                LastName = last
            };

            // initialize result to full name
            var result = person.FullName;

            // Assert to check if expect and result are equal
            Assert.AreEqual(expected, result);
        }

        /// <summary>
        /// Purpose: Checks to see if VolunteerID is set when volunteer.tuid is inititalized
        /// </summary>        //
        //         [TestMethod]
        //         public void VolunteerSetter_WhenAssigned_SetsVolunteerID()
        //         {
        //             // declare people objects
        //             var person = new Person();
        //             var volunteer = new Volunteer();
        //
        //             // initializde tuid
        //             volunteer.Tuid = 5;
        //
        //             // initialize volunteer object to volunteer property of person
        //             person.Volunteer = volunteer;
        //
        //             // check to see if the newly made volunteer has the ID value 5
        //             Assert.AreEqual(5, person.VolunteerID);
        //             Assert.AreSame(volunteer, person.Volunteer);
        //             Assert.IsTrue(person.IsVolunteer);
        //         }

        /// <summary>
        /// Purpose: Checks that Volunteer ID is cleared when volunteer object
        /// is set to null.
        /// </summary>        //
        //         [TestMethod]
        //         public void VolunteerSetter_WhenSetToNull_ClearsVolunteerID()
        //         {
        //             // instantiate people objects
        //             var person = new Person();
        //             var volunteer = new Volunteer();
        //
        //             // assign a tuid to volunteer
        //             volunteer.Tuid = 10;
        //
        //             // assign volunteer property to volunteer object, thus volunteer ID == volunteer.tuid
        //             person.Volunteer = volunteer;
        //
        //             // assign volunteer to null, volunteerID now gets null
        //             person.Volunteer = null;
        //
        //             // checks to see if ID and object is null, checks isVolunteer to see if it is false
        //             // Assert.IsNull(person.VolunteerID); // commented out: VolunteerID no longer exists on Person
        //             Assert.IsNull(person.Volunteer);
        //             Assert.IsFalse(person.IsVolunteer);
        //         }

        /// <summary>
        /// Purpose: Confirms that IsVolunteer is derived from
        /// VolunteerID (foreign key) even if Volunteer
        /// property is null. Thus, this is not a bug.
        /// </summary>        //
        //         [TestMethod]
        //         public void SettingVolunteerID_Alone_MakesIsVolunteerTrue()
        //         {
        //             // instantiate person object
        //             var person = new Person();
        //
        //             // set volunteerID to 99
        //             person.VolunteerID = 99;
        //
        //             // check to see if person is a volunteer and volunteer property is null
        //             Assert.IsTrue(person.IsVolunteer);
        //             Assert.IsNull(person.Volunteer);
        //         }
    }

    [TestClass]
    public sealed class VolunteerTests
    {
        /// <summary>
        /// Purpose: Verifies volunteer object has safe values upon instantiation
        /// </summary>
        [TestMethod]
        public void Constructor_InitializesVolunteerWithSafeDefaults()
        {
            // assign variable to hold time before volunteer is instatiated
            var before = DateTime.Now;

            // instatiate volunteer object
            var volunteer = new Volunteer();

            // assign variable to hold time after volunteer is instatiated
            var after = DateTime.Now;


            // checks that volunteer.notes is set to empty string
            Assert.AreEqual("", volunteer.Notes);

            // checks volunteer properties CreatedOn and LastModified were initalized
            // after the before variable but prior to after variable
            Assert.IsTrue(volunteer.CreatedOn >= before && volunteer.CreatedOn <= after);
            Assert.IsTrue(volunteer.LastModified >= before && volunteer.LastModified <= after);
        }

        /// <summary>
        /// Purpose: Verifies that when volunteer.notes is null that empty string is returned
        /// </summary>
        [TestMethod]
        public void NotesSetter_WhenNull_AssignsEmptyString()
        {
            // instantiate volunteer object
            var volunteer = new Volunteer();

            // assign volunteer.notes to null
            volunteer.Notes = null;

            // checks to see if notes is equal to empty string
            Assert.AreEqual("", volunteer.Notes);
        }
    }
}
