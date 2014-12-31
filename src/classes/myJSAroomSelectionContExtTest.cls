@isTest
public with sharing class myJSAroomSelectionContExtTest
{
	public static Opportunity testOp;
	public static High_School__c testHs;
	
	public static jsaPortalEventController testController;
	public static myJSAroomSelectionContExt testContExt;
	
	static Account hsAccount;
	static High_School__c hs;
	static final string ZONE = 'ZZ';
	static PricebookEntry studentProductEntry;
	static PricebookEntry teacherProductEntry;
	static list<Product2> products;
	static list<Application__c> applications;
	static list<Contact> contacts;
	
	static final integer NUM_APPLICATIONS = 3;
	
	public static void setup(Pricebook2 pb)
	{
		hsAccount = testUtils.createAccounts(1,'hsAcc',ZONE)[0];
		insert hsAccount;
		
		hs = testUtils.createHighSchool('na',hsAccount);
		insert hs;

		list<Zone_Pricebook_Mapping__c> mapping = testUtils.createZoneMappings(new map<string,string>
		{
			ZONE => pb.id
		});
		
		system.runAs(testUtils.sysadmin)
		{
			delete Zone_Pricebook_Mapping__c.getAll().values();
			insert mapping;
		}
		
		products = new list<product2>
		{
			testUtils.createProduct('Teacher Package - test'),
			testUtils.createProduct('Student Package - test'),
			testUtils.createProduct('unrelated')
		};
		
		insert products;
		
		Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE isStandard=true];
		
		list<PricebookEntry> stdEntries = TestUtils.createPricebookEntries(products, standardPricebook.id);
		insert stdEntries;
		
		list<PricebookEntry> newEntries = TestUtils.createPricebookEntries(products, pb.id);
		insert newEntries;
		
		studentProductEntry = newEntries[1];
		teacherProductEntry = newEntries[0];
		
		testOp = testUtils.createOpportunities(1, 'testOp', 'I:Intent', Date.today())[0];
		testOp.AccountId = hsAccount.id;
		testOp.ocHigh_School__c = hs.id;
		insert testOp;
		
		contacts = testUtils.createContacts(NUM_APPLICATIONS, 'whocares', hsAccount.id);
		for(contact c : contacts)
		{
			c.High_School__c = hs.id;
			c.Category__c = myJSAroomSelectionContExt.TEACHER_ROLE;
			c.Gender__c = myJSAroomSelectionContExt.FEMALE_GENDER;
		}
		
		insert contacts;
		
		Applications = new List<Application__c>
		{
			testUtils.createApplications( 1, testOp, contacts[0], products[0] )[0],
			testUtils.createApplications( 1, testOp, contacts[1], products[0] )[0],
			testUtils.createApplications( 1, testOp, contacts[2], products[0] )[0]
		};
		
		insert applications;
		
		ApexPages.currentPage().getParameters().put(jsaPortalEventController.ID_PARAM, testOp.id);
		testController = new jsaPortalEventController();
		testContExt = new myJSAroomSelectionContExt(testController);			
	}
	
	@isTest(seeAllData=true)
	public static void testSummaryData()
	{
		pricebook2 pb = new pricebook2();
		pb.Name = 'testPB';
		insert pb;
		
		test.startTest();
			setup(pb);
		test.stopTest();
		
		system.assertEquals(NUM_APPLICATIONS,testContExt.totalDelegates,'the correct number of applicants should be counted');
		system.assertEquals(0,testContExt.appliedFemaleStudents,'no female students should have applied');
		system.assertEquals(0,testContExt.appliedMaleStudents,'no male students should have applied');
		system.assertEquals(0,testContExt.appliedMaleTeachers,'no male teachers should have applied');
		system.assertEquals(NUM_APPLICATIONS,testContExt.appliedFemaleteachers,'the correct number of female teachers should have been found');
		system.assertEquals(0,testContext.assigned,'nobody should be assigned yet');	
	}
	
	@isTest(seeAllData=true)
	public static void testRoomWrappers()
	{
		pricebook2 pb = new pricebook2();
		pb.Name = 'testPB';
		insert pb;
		setup(pb);
		
		List<HotelRoom__c> rooms = testUtils.createHotelRooms(1, testOp);
		rooms[0].Room_Type__c = 'Teacher';
		rooms[0].Gender__c = 'Female';
		insert rooms;
		
		test.startTest();
			testContExt.updateRoomsAndContacts();
		test.stopTest();
		
		system.assertNotEquals(null,testContExt.theRooms,'there should be rooms');
		
		myJSAroomSelectionContExt.roomWrapper room = testContExt.theRooms[0];
		
		system.assertEquals(true,room.readyForDelegates,'the room should be ready for delegates');
		system.assertEquals(false,room.hasDelegates(),'the room should not have any delegates');
		
		room.resetRoom();
		
		system.assertEquals(false,room.readyForDelegates,'after a reset the room should be unready for delegates');

	}
}