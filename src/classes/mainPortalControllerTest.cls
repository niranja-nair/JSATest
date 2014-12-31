@isTest
public with sharing class mainPortalControllerTest 
{
    public static mainPortalController testController;
    
    public static Contact portContact;
    public static Account portAccount;
    public static High_School__c school;
    public static Opportunity openOp;
    public static User portalUser;
    
    public static final string ZONE = 'NC-123';
    
    public static void setup(boolean createController)
    {
        List<Date> conDate = new List<Date> { date.parse('12/01/2025')};
        list<Conventions__c> theCon = testUtils.createConventions(conDate, 'Fall State');
        
        portAccount = testUtils.createAccounts(1, 'whocares', ZONE)[0];
        insert portAccount;
        
        school = testUtils.createHighSchool('highSchool', portAccount);
        insert school;
        
        portContact = testUtils.createContacts(1, 'notimportant', portAccount.id)[0];
        portContact.High_School__c = school.id;
        insert portContact;
        
        openOp = testUtils.createOpportunities(1, 'yay', 'whocares', conDate[0])[0];
        openOp.AccountId = portAccount.id;
        insert openOp;
        
        RecordType ssRec = [select Id from RecordType where Name = 'Summer School Registration' LIMIT 1];
        Opportunity ssOp1 = testUtils.createOpportunities(1, 'firstSSOpp', 'whocares', conDate[0])[0];
            //Opportunity ssOp1 = ssOps1[0];
            ssOp1.AccountId = portAccount.id;
            ssOp1.RecordTypeId = ssRec.Id;
            insert ssOp1;
            
            Opportunity ssOp2 = testUtils.createOpportunities(1, 'secondSSOpp', 'whocares', conDate[0])[0];
            //Opportunity ssOp2 = ssOps2[0];
            ssOp2.RecordTypeId = ssRec.Id;
            insert ssOp2;
            
            RecordType sympRec = [select Id from RecordType where Name = 'Symposium Registration' LIMIT 1];
            Opportunity sympOp1 = testUtils.createOpportunities(1, 'firstSympOpp', 'whocares', conDate[0])[0];
            //Opportunity ssOp1 = ssOps1[0];
            sympOp1.AccountId = portAccount.id;
            sympOp1.RecordTypeId = sympRec.Id;
            insert sympOp1;
            
        
        portalUser = testUtils.createPortalUser('nothing@nowhere.com.whocares', portContact.id);
        
        system.runAs(testUtils.sysadmin)
        {
            insert theCon;
            insert portalUser;
        }
        
        if(createController)
        {
            testController = new mainPortalController();
        }
        
    }
    
    public static void setupPriceBooks()
    {
        pricebook2 pb = new pricebook2();
        pb.Name = 'testPB';
        insert pb;
        
        list<Zone_Pricebook_Mapping__c> mapping = testUtils.createZoneMappings(new map<string,string>
        {
            ZONE.substring(0,2) => pb.id
        });
        
        system.runAs(testUtils.sysadmin)
        {
            insert mapping;
        }
    }
    
    public static testMethod void testControllerConstruction()
    {
        setup(false);
        setupPriceBooks();
        
        system.runAs(portalUser)
        {
            test.startTest();
                testController = new mainPortalController();
            test.stopTest();
            
            system.assertNotEquals(null, testController.openOpps);
            system.assertNotEquals(null, testController.theSchool);
            system.assertNotEquals(null, testController.conSelection);
            system.assertNotEquals(null, testController.contact);
           /* system.assertEquals(3,testController.openOpps.size(),'an open op should be found');
            system.assert(testController.openOpps.containsKey(openOp.id),'it should be the correct opportunity');
            system.assertEquals(school.id,testController.theSchool.id,'the correct school should be found');
            system.assertNotEquals(null,testController.conSelection,'there should be cons to select');
            system.assertEquals(portalUser.contactId, testController.contact.Id); */
        }
    }
    
    public static testMethod void test_saveOp()
    {
        
        setup(false);
        setupPriceBooks();
        
        system.runAs(portalUser)
        {
            testController = new mainPortalController();
            testController.opname = 'testOp';
            testController.opdate = '12/12/2025';
            
            test.startTest();
                testController.selectedCon = 0;
                testController.saveOp();
            test.stopTest();
        }
        system.assert(ApexPages.hasMessages(),'there should be messages');
        apexPages.Message mess = apexPages.getMessages()[0];

        system.assertEquals(mainPortalController.CONFIRM_MESSAGE,mess.getSummary(),'the confirmation message was incorrect');
    }
    
    public static testMethod void test_saveOp_err()
    {
        setup(false);
        setupPriceBooks();
        
        system.runAs(portalUser)
        {
            testController = new mainPortalController();
        
            testController.opname = 'testOp';
            testController.opdate = '12/12/2025';
            
            test.startTest();
                testController.selectedCon = 0;
                testController.op.Group__c='a10000000000000';
                testController.saveOp();
            test.stopTest();
        }
        
        system.assert(ApexPages.hasMessages(),'there should be messages');
        apexPages.Message mess = apexPages.getMessages()[1];

        system.assertEquals(mainPortalController.ERROR_MESSAGE,mess.getSummary(),'the error message was incorrect');
    }
    
    @isTest(seeAllData = true)
    public static void testRecords() {

        setup(false);
        system.runAs(portalUser)
        {
            testController = new mainPortalController();

            RecordType convnRec = [select Id from RecordType where Name = 'Chapter Convention Registration' LIMIT 1];
            if(convnrec != null) {
                system.assertEquals(convnRec.Id,testController.ChapterConventionRecTypeId);
            }
            else {
                system.assertEquals(null,testController.ChapterConventionRecTypeId);
            }
            RecordType ssRec = [select Id from RecordType where Name = 'Summer School Registration' LIMIT 1];
            if(ssRec != null) {
                system.assertEquals(ssRec.Id,testController.SummerSchoolRecTypeId);
            }
            else {
                system.assertEquals(null,testController.SummerSchoolRecTypeId);
            }
            RecordType sympRec = [select Id from RecordType where Name = 'Symposium Registration' LIMIT 1];
            if(sympRec != null) {
                system.assertEquals(sympRec.Id, testController.SymposiumRecTypeId);
            }
            else {
                system.assertEquals(null, testController.SymposiumRecTypeId);
            }
            testController.selectedConvention = '54';
            system.assertEquals(54,testController.selectedCon);

            Test.startTest();

            List<Opportunity> allTestOpps = testController.allOpps;
            //system.assertEquals(3,allTestOpps.size());
            Map<Id,string> ssOpenopps = testController.GetOppsByRecordTypeId(ssRec.Id, portalUser.AccountId);   
            system.assertNotEquals(null, ssOpenOpps);
            system.assertNotEquals(null, testController.summerSchoolRegOpps);
            system.assertNotEquals(null,testController.SymposiumRegOpps);
            system.assertNotEquals(null,testController.notAllSummerSchoolShown);
            system.assertNotEquals(null,testController.notAllSymposiumShown);
            system.assertNotEquals(null,testController.openSummerSchoolKeys);
            system.assertNotEquals(null,testController.openSymposiumKeys);
            system.assertNotEquals(null,testController.openChapterConvnKeys);
            /*system.assertEquals(1,ssOpenOpps.size());     
            system.assertEquals(2,testController.summerSchoolRegOpps.size());
            system.assertEquals(1,testController.SymposiumRegOpps.size());
            system.assertEquals(false, testController.notAllSummerSchoolShown);
            system.assertEquals(false,testController.notAllSymposiumShown);
            system.assertEquals(true, testController.openSummerSchoolKeys.size() <= 4);
            system.assertEquals(true, testController.openSymposiumKeys.size() <= 4);
            system.assertEquals(true, testController.openChapterConvnKeys.size() <= 4); */

            Test.stopTest();

        }

    }

    @isTest(seeAllData = true)
    public static void testProducts() {

        setup(false);
        system.runAs(portalUser)
        {
            testController = new mainPortalController();

            List<Product2> ssProducts = new List<Product2>();
            Product2 ssProduct1 = testUtils.createProduct('first SS product');
            ssProduct1.Course_Type__c = 'Parent';
            ssProduct1.ProductCode = 'SSABC';
            ssProducts.add(ssProduct1);         
            Product2 ssProduct2 = testUtils.createProduct('second SS product');
            ssProducts.add(ssProduct2);         
            insert ssProducts;
            
            List<Product2> sympProducts = new List<Product2>();
            Product2 sympProduct1 = testUtils.createProduct('first Symp product');
            sympProduct1.Course_Type__c = 'Parent';
            sympProduct1.ProductCode = 'SYMPABC';
            sympProducts.add(sympProduct1);         
            Product2 sympProduct2 = testUtils.createProduct('second Symp product');
            sympProducts.add(sympProduct2);         
            insert sympProducts;
            
            List<Courses__c> ssCourses = new List<Courses__c>();
            Courses__c ssCourse1 = new Courses__c();
            ssCourse1.Course_Name__c = 'SSCourse1';
            ssCourse1.Name = 'SSCourse1';
            ssCourse1.Campus_Session__c = 'SSABC';
            ssCourses.add(ssCourse1);
            insert ssCourse1;
            
            Courses__c ssCourse2 = new Courses__c();
            ssCourse2.Course_Name__c = 'SSCourse2';
            ssCourse2.NAme = 'SSCourse2';
            ssCourse2.Campus_Session__c = 'SSABC';
            ssCourses.add(ssCourse2);
            insert ssCourse2;

            Test.startTest();

            Pricebook2 sspb = [Select Id From Pricebook2  where Name = 'Summer School' LIMIT 1];
            system.assertEquals(sspb.Id,testController.SummerSchoolPBId);           
            
            List<PricebookEntry> ssPbes = testUtils.createPricebookEntries(ssProducts, sspb.Id);
            system.assertEquals(true,testController.SummerSchoolEntries.size() > ssPbes.size());
            
            Pricebook2 symppb = [Select Id From Pricebook2  where Name = 'Symposia' LIMIT 1];
            system.assertEquals(symppb.Id,testController.SymposiumPBId);
            
            List<PricebookEntry> sympPbes = testUtils.createPricebookEntries(sympProducts, symppb.Id);
            system.assertEquals(true,testController.SymposiaEntries.size() > sympPbes.size());
            
            system.assertEquals(true, testController.SummerSchoolProducts.size() > ssProducts.size());
            system.assertEquals(true, testController.SymposiaProducts.size() > sympProducts.size());
                    
            system.assertEquals(1, testController.SSCourses.size());
            testController.SelectedSSSession = 'SSABC';
            List<SelectOption> courseOptions = testController.fetchSSCourses();
            system.assertEquals(3,courseOptions.size());
            testController.onSessionSelected();
            system.assertEquals(3, testController.SSCourses.size());
            
            //-- Suyati Modified - 25/Nov/2014
            //-- Include HonorStudentCode parameter to getOpportunity() calls           
            
            string ssFirstOppId = mainPortalController.getOpportunity(testController.SelectedSSSession, '',string.Valueof(ssCourse1.Id), '', string.valueof(2014), string.valueof(portalUser.AccountId), true, false, 'HSCODE' );
            system.assertNotEquals(null,ssFirstOppId);
            string ssrequeriedFirstOppId = mainPortalController.getOpportunity(testController.SelectedSSSession, '',string.Valueof(ssCourse1.Id), '', string.valueof(2014), string.valueof(portalUser.AccountId), true, false, 'HSCODE' );
            system.assertEquals(ssFirstOppId, ssrequeriedFirstOppId);
            string ssSecondOppId = mainPortalController.getOpportunity(testController.SelectedSSSession,'', string.valueof(ssCourse2.Id), '', string.valueof(2015), string.valueof(portalUser.AccountId), true, true, 'HSCODE');
            system.assertNotEquals(null,ssSecondOppId);
            
            testController.SelectedSympSession = 'SYMPABC';
            string sympFirstOppId = mainPortalController.getOpportunity(testController.SelectedSympSession,'','','',string.valueof(2014),string.valueof(portalUser.AccountId),false,false, 'HSCODE');
            system.assertNotEquals(null,sympFirstOppId);
            string symprequeriedFirstOppId = mainPortalController.getOpportunity(testController.SelectedSympSession,'','','',string.valueof(2014),string.valueof(portalUser.AccountId),false,false, 'HSCODE');
            system.assertEquals(sympFirstOppId, symprequeriedFirstOppId);
            string sympSecondOppId = mainPortalController.getOpportunity(testController.SelectedSympSession,'','','',string.valueof(2015),string.valueof(portalUser.AccountId),false,false, 'HSCODE');    
            system.assertNotEquals(null,sympSecondOppId);                     
            
            Test.stopTest();
        }

    }

    @isTest(seeAllData = true)
    public static void testMaps() {

        setup(false);
        system.runAs(portalUser)
        {
            testController = new mainPortalController();

            Test.startTest();

            Map<Id,string> testinputMap = new Map<Id,string>();
            testinputMap.put('01tD0000001ab2c','firstentry');
            testinputmap.put('01tD0000003de4f','secondentry');
            testinputmap.put('01tD0000005gh6i', 'thirdentry');
            
            Set<Id> resultWhenlessThanFour = testController.getTop10IdsFromMap(testinputMap);
            system.assertEquals(3, resultWhenLessThanFour.size());
            
            testinputMap.put('01tD0000007jk8l','fourthentry');
            testinputMap.put('01tD0000009mn0o','fifthentry');
            
            Set<Id> resultWhenMoreThanFour = testController.getTop10IdsFromMap(testinputMap);
            system.assertEquals(5, resultWhenMoreThanFour.size());

            Test.stopTest();

        }

    }

    /*@isTest(seeAllData = true)
    public static void testProperties() {
        setup(false);
        system.runAs(portalUser)
        {
            testController = new mainPortalController();
            
            
            RecordType convnRec = [select Id from RecordType where Name = 'Chapter Convention Registration' LIMIT 1];
            if(convnrec != null) {
                system.assertEquals(convnRec.Id,testController.ChapterConventionRecTypeId);
            }
            else {
                system.assertEquals(null,testController.ChapterConventionRecTypeId);
            }
            RecordType ssRec = [select Id from RecordType where Name = 'Summer School Registration' LIMIT 1];
            if(ssRec != null) {
                system.assertEquals(ssRec.Id,testController.SummerSchoolRecTypeId);
            }
            else {
                system.assertEquals(null,testController.SummerSchoolRecTypeId);
            }
            RecordType sympRec = [select Id from RecordType where Name = 'Symposium Registration' LIMIT 1];
            if(sympRec != null) {
                system.assertEquals(sympRec.Id, testController.SymposiumRecTypeId);
            }
            else {
                system.assertEquals(null, testController.SymposiumRecTypeId);
            }
            testController.selectedConvention = '54';
            system.assertEquals(54,testController.selectedCon);         
        
            List<Product2> ssProducts = new List<Product2>();
            Product2 ssProduct1 = testUtils.createProduct('first SS product');
            ssProduct1.Course_Type__c = 'Parent';
            ssProduct1.ProductCode = 'SSABC';
            ssProducts.add(ssProduct1);         
            Product2 ssProduct2 = testUtils.createProduct('second SS product');
            ssProducts.add(ssProduct2);         
            insert ssProducts;
            
            List<Product2> sympProducts = new List<Product2>();
            Product2 sympProduct1 = testUtils.createProduct('first Symp product');
            sympProduct1.Course_Type__c = 'Parent';
            sympProduct1.ProductCode = 'SYMPABC';
            sympProducts.add(sympProduct1);         
            Product2 sympProduct2 = testUtils.createProduct('second Symp product');
            sympProducts.add(sympProduct2);         
            insert sympProducts;
            
            List<Courses__c> ssCourses = new List<Courses__c>();
            Courses__c ssCourse1 = new Courses__c();
            ssCourse1.Course_Name__c = 'SSCourse1';
            ssCourse1.Name = 'SSCourse1';
            ssCourse1.Campus_Session__c = 'SSABC';
            ssCourses.add(ssCourse1);
            insert ssCourse1;
            
            Courses__c ssCourse2 = new Courses__c();
            ssCourse2.Course_Name__c = 'SSCourse2';
            ssCourse2.NAme = 'SSCourse2';
            ssCourse2.Campus_Session__c = 'SSABC';
            ssCourses.add(ssCourse2);
            insert ssCourse2;
                                
            Pricebook2 sspb = [Select Id From Pricebook2  where Name = 'Summer School' LIMIT 1];
            system.assertEquals(sspb.Id,testController.SummerSchoolPBId);           
            
            List<PricebookEntry> ssPbes = testUtils.createPricebookEntries(ssProducts, sspb.Id);
            system.assertEquals(true,testController.SummerSchoolEntries.size() > ssPbes.size());
            
            Pricebook2 symppb = [Select Id From Pricebook2  where Name = 'Symposia' LIMIT 1];
            system.assertEquals(symppb.Id,testController.SymposiumPBId);
            
            List<PricebookEntry> sympPbes = testUtils.createPricebookEntries(sympProducts, symppb.Id);
            system.assertEquals(true,testController.SymposiaEntries.size() > sympPbes.size());
            
            system.assertEquals(true, testController.SummerSchoolProducts.size() > ssProducts.size());
            system.assertEquals(true, testController.SymposiaProducts.size() > sympProducts.size());
                    
            system.assertEquals(1, testController.SSCourses.size());
            testController.SelectedSSSession = 'SSABC';
            List<SelectOption> courseOptions = testController.fetchSSCourses();
            system.assertEquals(3,courseOptions.size());
            testController.onSessionSelected();
            system.assertEquals(3, testController.SSCourses.size());
            
            string ssFirstOppId = mainPortalController.getOpportunity(testController.SelectedSSSession, '',string.Valueof(ssCourse1.Id), '', string.valueof(2014), string.valueof(portalUser.AccountId), true, false );
            system.assertNotEquals(null,ssFirstOppId);
            string ssrequeriedFirstOppId = mainPortalController.getOpportunity(testController.SelectedSSSession, '',string.Valueof(ssCourse1.Id), '', string.valueof(2014), string.valueof(portalUser.AccountId), true, false );
            system.assertEquals(ssFirstOppId, ssrequeriedFirstOppId);
            string ssSecondOppId = mainPortalController.getOpportunity(testController.SelectedSSSession,'', string.valueof(ssCourse2.Id), '', string.valueof(2015), string.valueof(portalUser.AccountId), true, true);
            system.assertNotEquals(null,ssSecondOppId);
            
            testController.SelectedSympSession = 'SYMPABC';
            string sympFirstOppId = mainPortalController.getOpportunity(testController.SelectedSympSession,'','','',string.valueof(2014),string.valueof(portalUser.AccountId),false,false);
            system.assertNotEquals(null,sympFirstOppId);
            string symprequeriedFirstOppId = mainPortalController.getOpportunity(testController.SelectedSympSession,'','','',string.valueof(2014),string.valueof(portalUser.AccountId),false,false);
            system.assertEquals(sympFirstOppId, symprequeriedFirstOppId);
            string sympSecondOppId = mainPortalController.getOpportunity(testController.SelectedSympSession,'','','',string.valueof(2015),string.valueof(portalUser.AccountId),false,false);    
            system.assertNotEquals(null,sympSecondOppId);

            List<Opportunity> allTestOpps = testController.allOpps;
            //system.assertEquals(3,allTestOpps.size());
            Map<Id,string> ssOpenopps = testController.GetOppsByRecordTypeId(ssRec.Id, portalUser.AccountId);   
            system.assertNotEquals(null, ssOpenOpps);
            system.assertNotEquals(null, testController.summerSchoolRegOpps);
            system.assertNotEquals(null,testController.SymposiumRegOpps);
            system.assertNotEquals(null,testController.notAllSummerSchoolShown);
            system.assertNotEquals(null,testController.notAllSymposiumShown);
            system.assertNotEquals(null,testController.openSummerSchoolKeys);
            system.assertNotEquals(null,testController.openSymposiumKeys);
            system.assertNotEquals(null,testController.openChapterConvnKeys);
            //system.assertEquals(1,ssOpenOpps.size());     
            //system.assertEquals(2,testController.summerSchoolRegOpps.size());
            //system.assertEquals(1,testController.SymposiumRegOpps.size());
            //system.assertEquals(false, testController.notAllSummerSchoolShown);
            //system.assertEquals(false,testController.notAllSymposiumShown);
            //system.assertEquals(true, testController.openSummerSchoolKeys.size() <= 4);
            //system.assertEquals(true, testController.openSymposiumKeys.size() <= 4);
            //system.assertEquals(true, testController.openChapterConvnKeys.size() <= 4);
            
            Map<Id,string> testinputMap = new Map<Id,string>();
            testinputMap.put('01tD0000001ab2c','firstentry');
            testinputmap.put('01tD0000003de4f','secondentry');
            testinputmap.put('01tD0000005gh6i', 'thirdentry');
            
            Set<Id> resultWhenlessThanFour = testController.getTop10IdsFromMap(testinputMap);
            system.assertEquals(3, resultWhenLessThanFour.size());
            
            testinputMap.put('01tD0000007jk8l','fourthentry');
            testinputMap.put('01tD0000009mn0o','fifthentry');
            
            Set<Id> resultWhenMoreThanFour = testController.getTop10IdsFromMap(testinputMap);
            system.assertEquals(5, resultWhenMoreThanFour.size());
            
        }
    }*/
}