@isTest
public with sharing class portalRegistrationControllerTest 
{
	public static portalRegistrationController testController;
	
	public static void setup()
	{
		testController = new portalRegistrationController();	
	}
	
	public static testMethod void testcreateAccount()
	{
		setup();
		
		testController.a.name = 'testAcc';
		
		test.startTest();
			id retId = testController.createAccount();
		test.stopTest();
		
		system.assertEquals(testcontroller.a.id,retId,'the two object\'s Ids should match');
		
		Account requeriedAcc = [SELECT Id FROM Account WHERE Id = :retId];
		system.assertNotEquals(null,requeriedAcc,'an account should have been saved');
	}
	
	public static testMethod void testCreateContact()
	{
		setup();
		
		testController.c.LastName = 'whocares';
		testController.c.firstName = 'whoknows';
		
		testController.a.name = 'testAcc';
		id accId = testController.createAccount();
		
		test.startTest();
			id retId = testController.createContact(testController.a.id);
		test.stopTest();
		
		system.assertEquals(testcontroller.c.id,retId,'the two object\'s Ids should match');
		
		Contact requeriedContact = [SELECT Id FROM Contact WHERE Id = :retId];
		system.assertNotEquals(null,requeriedContact,'a contact should have been saved');
	}
	
	public static testMethod void testUpdateContact()
	{
		setup();
		
		testController.c.LastName = 'whocares';
		testController.c.firstName = 'whoknows';
		
		testController.a.name = 'testAcc';
		id accId = testController.createAccount();
		id conId = testController.createContact(testController.a.id);
		
		final string NEWNAME = 'differentThing'; 
		test.startTest();
			testController.c.FirstName = NEWNAME;
			pageReference retPR = testController.updateContact();
		test.stopTest();
		
		system.assertEquals(null,retPR,'the returned page reference should be correct');
		
		Contact requeriedContact = [SELECT Id,FirstName FROM Contact WHERE Id = :conId];
		system.assertNotEquals(null,requeriedContact,'a contact should have been saved');
		system.assertEquals(NEWNAME,requeriedContact.FirstName,'the name should have been changed');
	}

	public static testMethod void testFindSchools()
	{
		setup();
		
		String autoSearchTerm = 'Alameda H.S.';
		String hsState = 'CA';
		//List<String> autoSearchHSListReturn = new List<String>();
		
		test.startTest();
		
		portalRegistrationController.findSchools(autoSearchTerm, hsState);
		
		test.stopTest();
		
		//system.assertEquals( testController.autoSearchHSListReturn[0],'Alameda H.S.');
	
	}

	public static testMethod void testInflation() {

		setup();

		Test.startTest();

		Boolean result = testController.inflateTest();

		System.assert(result);

		Test.stopTest();

	}	
	
	
}