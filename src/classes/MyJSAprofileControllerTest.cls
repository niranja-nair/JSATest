@isTest
public with sharing class MyJSAprofileControllerTest 
{
	static Contact testContact;
	static Account testAccount;
	static High_School__c testHs;
	
	static User portalUser;
	static final string HS_STATE = 'Texas';
	
	static void setup()
	{
		testAccount = testUtils.createAccounts(1,'hsAcc','OH-616')[0];
		testAccount.BillingState = HS_STATE;
		insert testAccount;
		
		testHs = testUtils.createHighSchool('supertown', testAccount);
		insert testHs;
		
		testContact = testUtils.createContacts(1, 'bort', testAccount.id)[0];
		
		testContact.member_status__c = 'tax-paid member';
		testContact.JSA_Role__c = 'Student';
		testContact.High_School__c = testHs.id;
		insert testContact;
		
		portalUser = testUtils.createPortalUser('superbort@bort.com.bort', testContact.id);
		
		system.runAs(testUtils.sysadmin)
		{
			insert portalUser;
		}
	}
	
	static testMethod void testInitPage()
	{
		setup();
		myJSAProfileController testCont = new myJSAProfilecontroller();
		
		test.startTest();
			system.runAs(portalUser)
			{
				testCont.initPage();
			}
		test.stopTest();
		
		system.assertEquals(testContact.id,testCont.contact.id,'the correct contact should be found');
		system.assertEquals(HS_STATE,testCont.highSchoolState,'the high schools state should be found');
		system.assertEquals(1,testCont.highSchoolStateOptions.size(),'there should be only one high school state option');
		system.assertEquals(HS_STATE,testCont.highSchoolStateOptions[0].getValue(),'the high school state option should be that of the test high school');
		
		//system.assertNotEquals(null,testCont.roleOptions,'the static options lists should be created');
		system.assertNotEquals(null,testCont.genderOptions,'the static options lists should be created');
		//system.assertNotEquals(null,testCont.countryOptions,'the static options lists should be created');
		//system.assertNotEquals(null,testCont.stateProvinceOptions,'the static options lists should be created');
	}
}