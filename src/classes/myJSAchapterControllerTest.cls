@isTest
public with sharing class myJSAchapterControllerTest
{
	static Contact testContact;
	static Account testAccount;
	static High_School__c testHs;
	static list<Contact> testHsRoster;
	
	static User portalUser;
	
	static final integer ROSTER_SIZE = 4;
	
	static void setup()
	{
		
		
		
		testAccount = testUtils.createAccounts(1,'hsAcc','OH-616')[0];
		insert testAccount;
		
		testHs = testUtils.createHighSchool('supertown', testAccount);
		insert testHs;
		
		testHsRoster = testUtils.createContacts(ROSTER_SIZE, 'bort', testAccount.id);
		
		for(contact c: testHsRoster)
		{
			// c.member_status__c = 'tax-paid member';
			c.JSA_Role__c = 'Student';
			c.High_School__c = testHs.id;
		}
		
		insert testHsRoster;
		testContact = testHsRoster[ROSTER_SIZE-1];
		// testHsRoster.remove(ROSTER_SIZE-1);
		
		portalUser = testUtils.createPortalUser('chapsuperbort@bort.com.bort', testContact.id);
		
		system.runAs(testUtils.sysadmin)
		{
			insert portalUser;
		}
	}
	
	@future
	private static void insertPortalUser(){
		
	}
	
	static testMethod void testGetRoster()
	{
		setup();
		myJSAchapterController cont = new myJSAchapterController();
		list<Contact> queriedRoster;
		
		test.startTest();
			system.runAs(portalUser)
			{
				cont.initPage();
				//force the query to happen while runnign as the test user
				queriedRoster = cont.roster;
			}
		test.stopTest();
			Set<Id> testIds= new Map<Id,Contact>(testHsRoster).keySet();
			
			for(contact c: queriedRoster)
			{
				system.assert(testIds.contains(c.id),'every contact in the roster should be found');
				// testIds.remove(c.id);
			}
			
			system.assertEquals(testHsRoster.size(),queriedRoster.size(),'all the contacts should have been found');
		
	}

	static testMethod void testInflate() {

		myJSAchapterController cont = new myJSAchapterController();

		Test.startTest();

		Boolean result = cont.inflateTest();
		System.assert(result);

		Test.stopTest();
		
	}
}