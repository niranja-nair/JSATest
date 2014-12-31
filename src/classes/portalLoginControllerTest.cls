@isTest
public with sharing class portalLoginControllerTest 
{
	public static portalLoginController testController;
	
	public static void setup()
	{
		testController = new portalLoginController();
		String ssUrl = testController.ssoLoginURL;
	}
	
	public static testMethod void testLogin_noPw()
	{
		setup();

		test.startTest();
			pageReference ref = testController.portalLogin(); 
		test.stopTest();
		
		system.assertEquals(null,ref,'the login should fail');
	}
}