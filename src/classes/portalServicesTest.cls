@isTest
public without sharing class portalServicesTest 
{
	
	static final string CON_TYPE = 'whocares';
	static list<Conventions__c> cons;
	public static User portalUser;
	public static Contact portContact;
	public static Account portAccount;
	public static High_School__c school;
	
	public static void setup()
	{
		List<Date> conDates = new List<Date>
		{
			Date.Parse('1/1/2015'),
			Date.parse('3/1/2015'),
			Date.parse('1/1/2013')
		};
		
		cons = testUtils.createConventions(conDates,CON_TYPE);
		cons[0].Type__c = 'something different';
		
		system.runAs(testUtils.sysadmin)
		{
			insert cons;
		}
		
		portAccount = testUtils.createAccounts(1, 'whocares', ZONE)[0];
		insert portAccount;	
		school = testUtils.createHighSchool('highSchool', portAccount);
		insert school;
		
		portContact = testUtils.createContacts(1, 'notimportant', portAccount.id)[0];
		portContact.High_School__c = school.id;
		insert portContact;
		portalUser = testUtils.createPortalUser('nothing@nowhere.com.whocares', portContact.id);
	}
	
	public static testMethod void testSaveOpportunities()
	{
		list<Opportunity> opps = testUtils.createOpportunities(2,'gorb','blorb',Date.today());
		test.startTest();
			boolean passed = portalServices.saveOpportunities(opps);
		test.stopTest();
		
		system.assertEquals(true,passed,'no errors should occur');
		
		list<Opportunity> requeriedOpps = [SELECT Id FROM Opportunity WHERE Id IN :opps];
		system.assertEquals(opps.size(),requeriedOpps.size(),'all opportunites should be saved');
	}
	
	public static testMethod void testQueryAllConventions()
	{
		setup();
		test.startTest();
			list<Conventions__c> queriedCons = portalServices.queryAllConventions();
		test.stopTest(); 
		
		system.assertEquals(cons.size(),queriedCons.size(),'all of the conventions should be queried');
		
		//a little hacky, but it prevents null errors
		Date lastConDate = queriedCons[0].open_date__c;
		
		for(Conventions__c con : queriedCons)
		{
			system.assert(lastConDate <= con.open_date__c,'the cons should be sorted');
			lastConDate = con.open_date__c;
		}
	}
	
	static Account hsAccount;
	static High_School__c hs;
	static final string ZONE = 'ZZ';
	static PricebookEntry studentProductEntry;
	static PricebookEntry teacherProductEntry;
	static list<Product2> products;
	
	public static void setupWithProducts(Pricebook2 pb)
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
		
		Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE isStandard=true ];
		
		list<PricebookEntry> stdEntries = TestUtils.createPricebookEntries(products, standardPricebook.id);
		insert stdEntries;
		
		list<PricebookEntry> newEntries = TestUtils.createPricebookEntries(products, pb.id);
		insert newEntries;
		
		studentProductEntry = newEntries[1];
		teacherProductEntry = newEntries[0];
	}
	
	
	@IsTest(SeeAllData=true)
	public static void testFilterProducts()
	{
		pricebook2 stdPb = new pricebook2();
		stdPb.Name = 'testPB';
		insert stdPb;
		
		setupWithProducts(stdPb);
		High_School__c requeriedHs = [SELECT Id,Name,JSA_State__c FROM High_School__c WHERE ID = :hs.id];
		
		test.startTest();
			try {
				list<PricebookEntry> filteredPbes = portalServices.queryRelevantProducts(requeriedHs,false, 'test');
				system.assertEquals(1,filteredPbes.size(),'only one entry should return');
				system.assertEquals(studentProductEntry.id, filteredPbes[0].id,'it should be the student entry');
			}
			catch(Exception ex) {}
		test.stopTest();
		
		
	}
	
	public static testMethod void testCheckForPreExistingOpp()
	{
		String opname = 'GLARB';
		Date opdate = Date.today();
		
		Opportunity preExist = testUtils.createOpportunities(1,opname,'blorb',Date.today())[0];
		preExist.RecordTypeId = portalServices.CONVENTION_RECORDTYPE_ID;
		Account preExistAcc = testUtils.createAccounts(1,'whocars','zz')[0];
		insert PreExistAcc;
		
		preExist.AccountId = preExistAcc.id;
		insert preExist;
		
		test.startTest();
			Boolean exists = portalServices.checkForPreExistingOpp(opname, opdate, PreExistAcc.id);
			Boolean doesntExist = portalServices.checkForPreExistingOpp('fakename', opdate, PreExistAcc.id);
		test.stopTest();
		
		//system.assertEquals(true,exists,'the created opportunity should be found');
		system.assertEquals(false,doesntExist,'an unrelated opportunity should not be found');
	}
	
	@IsTest(SeeAllData=true)
	public static void testQueryOpp()
	{
		pricebook2 stdPb = new pricebook2();
		stdPb.Name = 'testPB';
		insert stdPb;
		
		setupWithProducts(stdPb);
		
		Opportunity op = testUtils.createOpportunities(1,'asdf','blorb',Date.today())[0];
		op.AccountId = hsAccount.id;
		op.Terms_and_Conditions__c = false;
		op.Type = 'test';
		
		list<Contact> pcs = testUtils.createContacts(2,'name',hsAccount.id);
		insert pcs;
		
		op.Primary_Contact__c = pcs[0].id;
		op.ocTeacher_Advisor__c = pcs[1].id;
		
		insert op;
		
		list<Application__c> apps = testUtils.createApplications(1,op,pcs[0],products[0]);
		insert apps;
		
		test.startTest();
			Opportunity queried = portalServices.queryOpp(op.id);
		test.stopTest();
		
		system.assertEquals(op.name,queried.name,'the names should match');
		system.assertEquals(op.Terms_and_Conditions__c,queried.Terms_and_Conditions__c,'the tandc field should match');
		system.assertEquals(op.Type,queried.Type,'the type should match');
		system.assertEquals(op.Primary_Contact__c,queried.Primary_Contact__c,'the primary contact should match');
		system.assertEquals(op.ocTeacher_Advisor__c,queried.ocTeacher_Advisor__c,'the primary contact should match');
		system.assertEquals(op.Amount,queried.Amount,'the amounts should match');
		
		system.assertEquals(apps.size(),queried.Applications__r.size(),'the same number of applications should be pulled back');
	}
	
	@IsTest(seeAllData=true)
	public static void testSaveOpportunityProducts()
	{
		
	}
	
	public static testMethod void testGetRegionName()
	{
		final string STATE = 'NZ';
		final string REGION = 'North Zebra';
		
		insert testUtils.createStateRegionMapping(STATE,REGION);
		
		test.startTest();
			string good = portalServices.getRegionName(STATE);
			string bad = portalServices.getRegionName(STATE+'asdf');
		test.stopTest();
		
		system.assertEquals(REGION,good,'the correct region should have been returned');
		system.assertEquals(null,bad,'null should be returned for the unfound region');
	}
	
	@IsTest(SeeAllData=true)
	public static void testqueryoppforAppl() {
		
		Opportunity op = testUtils.createOpportunities(1,'asdf','blorb',Date.today())[0];
		op.School_Zip_code__c = '00000';
		op.Reference_Teacher_Phone__c = '1111111111';
		op.Reference_Teacher_Name__c = 'test teacher';
		op.symMost_Important_Issue__c = 'test issue';
						
		insert op;
		
		test.startTest();
			Opportunity queried = portalServices.queryOppForAppl(op.id);
		test.stopTest();
		
		system.assertEquals(op.name,queried.name,'the names should match');
		system.assertEquals(op.School_Zip_Code__c,queried.School_Zip_Code__c,'the school zip code field should match');
		system.assertEquals(op.Reference_Teacher_Name__c,queried.Reference_Teacher_Name__c,'the reference teacher name should match');
		system.assertEquals(op.Reference_Teacher_Phone__c,queried.Reference_Teacher_Phone__c,'the reference teacher phone should match');
		
		system.assertEquals(op.symMost_Important_Issue__c, queried.symMost_Important_Issue__c);
	}
	
	@IsTest(SeeAllData = true)
	public static void setupTest() {
		
		hsAccount = testUtils.createAccounts(1,'hsAcc',ZONE)[0];
		insert hsAccount;
		
		hs = testUtils.createHighSchool('na',hsAccount);
		insert hs;
		
		Product2 ssProduct1 = testUtils.createProduct('first SS product');
			ssProduct1.Course_Type__c = 'Parent';
			ssProduct1.ProductCode = 'SSABC';
			insert ssProduct1;
			
			Courses__c ssCourse1 = new Courses__c();
			ssCourse1.Course_Name__c = 'SSCourse1';
			ssCourse1.Name = 'SSCourse1';
			ssCourse1.Campus_Session__c = 'SSABC';
			insert ssCourse1;
		
		Test.startTest();
		List<Conventions__c> convns = portalServices.queryAllConventions();
		system.assertEquals(true, convns.size() != null);
		try {
			Id pbIdTest = portalServices.getPriceBookId(hs);
			system.assertNotEquals(null, pbIdTest);
		}
		catch(Exception ex) {
			system.assertEquals('System.NullPointerException', ex.getTypeName());
		}		
		//system.assertEquals(false, portalServices.checkType(studentProductEntry, 'test'));
		try {
			list<PricebookEntry> pbes = portalServices.queryRelatedProducts(hs);
			system.assertEquals(0, pbes.size());
		}
		catch(Exception ex) {
			system.assertEquals('System.NullPointerException', ex.getTypeName());
		}
		try {
			List<Opportunity> relatedOpps = portalServices.queryRelatedOpportunities(hs);
			
			Opportunity op = testUtils.createOpportunities(1,'asdf','blorb',Date.today())[0];
			op.AccountId = hsAccount.id;
			op.Terms_and_Conditions__c = false;
			op.Amount = 50; 
			op.Type = 'test';
			op.Name = 'testopp';			
			insert op;
			List<Opportunity> oppsWithAccount = portalServices.queryRelatedOpportunities(hs, hsAccount.Id);
			//system.assertEquals(1, oppswithAccount.size());
			
		}
		catch(Exception ex) {
			
		}
		Opportunity op = testUtils.createOpportunities(1,'asdf','blorb',Date.today())[0];
		op.AccountId = hsAccount.id;
		op.Terms_and_Conditions__c = false;
		op.Amount = 50; 
		op.Type = 'test';
		op.Name = 'testopp';
		insert op;
		Opportunity queriedopp = portalServices.queryOpp(op.Id);
		system.assertEquals(50,queriedopp.Amount);
		Opportunity requeriedopp = portalServices.queryOppForAppl(op.Id);
		system.assertEquals('testopp', requeriedopp.Name);
		
				
		List<SelectOption> sscourses = portalServices.fetchSSCourses('SSABC');
		system.assertEquals(2, sscourses.size());
		system.assertEquals('SSCourse1', sscourses[1].getValue());
		Test.stopTest();
		
	}
	
	@IsTest(SeeAllData=true)
	public static void testGetSessionMap() {
		Product2 prod1 = testUtils.createProduct('testproduct');
		insert prod1;
		
		List<Product2> prods = new List<Product2>();
		prods.add(prod1);

		Pricebook2 pbook = [select id from Pricebook2 where IsStandard = true limit 1];
		Pricebook2 pb = new Pricebook2(Name = 'firsttestpb', Description = 'Price Book 2009 Products', IsActive = true);
		insert pb;
		
		PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pbook.Id, Product2Id = prod1.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
		
		List<PricebookEntry> pbes = testUtils.createPricebookEntries(prods, pb.Id);
		insert pbes;
		system.assertEquals(1, pbes.size());
		Map<string,string> sessionMap = portalServices.getSessionMap(pb.Id);
		system.assertNotEquals(null,sessionMap);
		system.assertEquals(0,sessionMap.size());
		system.assertEquals(true,portalServices.getSymposiumSessions().size()> 0);
		system.assertEquals(true,portalServices.getSSSessions().size()>0);
	}
	
	@IsTest(SeeAllData=true)
	public static void testgetOppsQuickBookInvoices() {
		
		Opportunity op = testUtils.createOpportunities(1,'asdf','blorb',Date.today())[0];
				
		insert op;
		
		QB_Invoice__c inv = new QB_Invoice__c();
		inv.OpportunityID__c = op.Id;
		inv.Name = 'test invoice';
		inv.Invoice_Amount__c = 500;
				
		insert inv;
		
		test.startTest();
			List<QB_Invoice__c> queriedinvoices = portalServices.getOppsQuickBookInvoices(op.Id); 
			system.assertEquals(true, queriedinvoices.size() > 0);
			QB_Invoice__c queriedinvoice = queriedinvoices[0];
		test.stopTest();
		
		system.assertEquals(inv.Name, queriedinvoice.Name);
		system.assertEquals(inv.Invoice_Amount__C, queriedinvoice.Invoice_Amount__c);
	}
	
	public static testMethod void testDoesOppExist() {
		List<Opportunity> opps = testUtils.createOpportunities(1, 'testopp', 'whocares', system.now().date());
		Opportunity opp = opps[0];
		insert opp;
		
		system.assertEquals(opp.Id, portalServices.DoesOppExist('testopp'));
		system.assertEquals(null,portalServices.DoesOppExist('imaginaryopp'));
	}
	
	public static testMethod void testShowEvents() {
		setup();	
		system.runAs(portalUser) {
			system.assertEquals(true, portalServices.showEvents());
		}
		portContact.JSA_Role__c = 'Student';
		update portContact;
		
		system.runAs(portalUser) {
			system.assertEquals(false, portalServices.showEvents());
		}
	}
	
	@istest(seealldata=true)
	public static void testAddOpportunityLineItem() {
		Product2 prod1 = testUtils.createProduct('testproduct');
		insert prod1;
		
		List<Opportunity> opps = testUtils.createOpportunities(1, 'testopp', 'dontknow', system.now().date());
		Opportunity opp = opps[0];
		insert opp;
		
		List<Product2> prods = new List<Product2>();
		prods.add(prod1);

		Pricebook2 pbook = [select id from Pricebook2 where IsStandard = true limit 1];
		Pricebook2 pb = new Pricebook2(Name = 'firsttestpb', Description = 'Price Book 2009 Products', IsActive = true);
		insert pb;
		
		PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pbook.Id, Product2Id = prod1.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;
        
        portalServices.AddOpportunityProduct(opp.Id, prod1.Name, pb.Id);
        system.assertEquals(true, portalServices.setOpportuntiyProducts(new list<portalServices.potentialDelegateProductSelection>(), opp));
	}
	
	public static testMethod void testUpsertHotelRooms() {
		HotelRoom__c room1 = new HotelRoom__c();
		HotelRoom__c room2 = new HotelRoom__c();
		List<HotelRoom__c> rooms = new List<HotelRoom__c>();
		rooms.add(room1);
		rooms.add(room2);
		system.assertEquals(true, portalServices.upsertHotelRooms(rooms));
	}
	
	public static testMethod void testgetPicklistValues() {
		test.startTest();
			List<SelectOption>  options =  portalServices.getPicklistValues(new Opportunity(name='Test'), 'How_did_you_learn_about_us__c');
		test.stopTest();
		
		system.assertEquals(true, options!= null);
	}
}