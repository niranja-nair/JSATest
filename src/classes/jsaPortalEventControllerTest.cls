@isTest
public with sharing class jsaPortalEventControllerTest 
{
	public static Opportunity testOp;
	public static Account testAcc;
	public static High_School__c testHs;
	
	public static jsaPortalEventController testController;
	
	public static void setup()
	{
		testOp = testUtils.createOpportunities(1, 'testName', 'Application Started', Date.today())[0];
		testAcc = testUtils.createAccounts(1, 'mmm', 'zz')[0];
		
		insert testAcc;
		
		testHs = testUtils.createHighSchool('superSchool', testAcc);
		
		insert testHs;
		
		testOp.AccountId = testAcc.id;
		
		insert testOp;
	}
	
	public static jsaPortalEventController createController(Id opId)
	{
		ApexPages.currentPage().getParameters().put(jsaPortalEventController.ID_PARAM, testOp.id);
		return new jsaPortalEventController();		
	}
	
	public static testMethod void testConstruction()
	{
		setup();
		test.startTest();
			testController = createController(testOp.id);
		test.stopTest();
		
		system.assertEquals(testOp.id, testController.op.id,'the same opportunity should be quieried');
	
		system.assertEquals(false,testController.TandC,'the tems should not be accepted yet');
		system.assertEquals(null,testController.leadDelegateId,'no lead delegate should be selected');
		system.assertEquals(null,testController.advisorId,'no advisor should be selected');
		system.assertEquals(testOp.name,testController.opName,'the correct name should be found');
		system.assertEquals(null,testController.totalAmount,'since no products have been made the total amount should be null');
		system.assertNotEquals(null,testController.orderNumber,'an order number should be present');
		system.assertEquals(false,testController.submissionApproved,'submission should not be approved');
		system.assertEquals(false,testController.submitted,'should not be submitted');
		system.assertEquals(false,testController.leadershipSelected,'leadership should not be selected');
		system.assertEquals(0,testController.tabState,'the tab state should be initialized');
	}
	
	public static testMethod void testGoTos()
	{
		setup();
		testController = createController(testOp.id);
		
		test.startTest();
			testController.goToOverview();
			integer overState = testController.tabState;
			
			testController.goToTandC();
			integer tcState = testController.tabState;
			
			testController.goToProducts();
			integer prodState = testController.tabState;
			
			testController.goToRooms();
			integer roomState = testController.tabState;
			
			testController.goToInvoice();
			integer invState = testController.tabState;
		test.stopTest();
		
		system.assertEquals(0,overState,'the overview state should be correct');
		system.assertEquals('overview',testController.tabNames[overState],'the overview name should be correct');
			
		system.assertEquals(1,tcState,'the terms and conditions state should be correct');
		system.assertEquals('TandC',testController.tabNames[tcState],'the terms and conditions name should be correct');
			
		system.assertEquals(2,prodState,'the product state should be correct');
		system.assertEquals('delegates',testController.tabNames[prodState],'the delegates name should be correct');
		
		system.assertEquals(3,roomState,'the rooms state should be correct');
		system.assertEquals('rooms',testController.tabNames[roomState],'the rooms name should be correct');
		
		system.assertEquals(4,invState,'the inventory state should be correct');
		system.assertEquals('invoice',testController.tabNames[invState],'the inventory name should be correct');
	}
	
	public static testMethod void testupdateOp()
	{
		setup();
		testController = createController(testOp.id);
		final string NEW_NAME = 'NEW_NAME';
		
		test.startTest();
			testController.op.Name = NEW_NAME;
			testController.updateOp();
		test.stopTest();

		system.assert(!apexPages.hasMessages(),'there should be no error messages');		
		
		Opportunity requeriedOp = [SELECT Id,Name FROM Opportunity WHERE Id = :testOp.id];
		system.assertEquals(NEW_NAME,requeriedOp.name,'the name update should have occured');
		
	}
	
	public static testMethod void testAcceptTandC()
	{
		setup();
		testController = createController(testOp.id);
		
		test.startTest();
			testController.acceptTandC();
		test.stopTest();
		
		Opportunity requeriedOp = [SELECT Id,Terms_and_Conditions__c FROM Opportunity WHERE Id = :testOp.id];
		system.assertEquals(true,requeriedOp.Terms_and_Conditions__c,'the terms should have been accepted');
	}
	
	public static testMethod void testSetDelegateAndChaparone()
	{
		setup();

		List<Contact> contacts = testUtils.createContacts(2, 'bort', testAcc.id);
		
		for(Contact c: contacts)
		{
			c.high_school__c = 	testHs.id;
			c.Member_Status__c = 'tax-paid member';
		}
		
		Contact leadDelegate = contacts[0];
		Contact chaperone = contacts[1];
		
		leadDelegate.category__c = 'Student';
		chaperone.category__c = 'Alum';
		
		insert contacts;
		
		testController = createController(testOp.id);
		
		//plug in the high school
		testController.hs = testHs;
		
		test.startTest();
			testController.selectChapterDelegate.selectedId = leadDelegate.id;
			testController.selectChaperone.selectedId = chaperone.id;
			testController.setDelegateAndChaparone();
		test.stopTest();
		
		Opportunity requeried = [SELECT Id, ocTeacher_Advisor__c,ocStudent_Delegation_Leader__c FROM Opportunity WHERE Id = :testController.op.id];
		
		system.assertEquals(leadDelegate.id,requeried.ocStudent_Delegation_Leader__c,'the primary contact should be saved correctly');
		system.assertEquals(chaperone.id,requeried.ocTeacher_Advisor__c,'the advisor should be saved correctly');
		
		system.assertEquals(true,testController.leadershipSelected,'the leadership should be selected');
		system.assertEquals(1,testController.tabState,'the tab state should advance');
		
	}
	
	public static testMethod void testAddPackagesForParticipatingMembers()
	{

	}

	public static testMethod void testSubmitOpp()
	{

	}

	public static testMethod void testInflate() {

		setup();
		testController = createController(testOp.id);

		Test.startTest();

			Boolean result = testController.inflateTest();

		Test.stopTest();

		System.assert(result);

	}

}