@isTest
private class TestJSAApplicationController {

    static User portalUser;
   
    static testMethod void setupandTest() {
  
        
        Test.startTest();
        
        Product2 prod = testUtils.createProduct('testsession');
        prod.ProductCode = 'SSABC';
        insert prod;
             
        List<Opportunity> opps = TestUtils.createOpportunities(1,'testsummeropp','Application Started', system.Today().addDays(14));
        Opportunity opp = opps[0];
        
        opp.RecordTypeId = '012400000005P4d';
        opp.Reference_Teacher_Name__c= 'Tester teacher';
        opp.ExtraCurricular_Activities__c = 'sample extracurricular activities';
        opp.Personal_Essay__c = 'sample personal essay';
        opp.symLeadership_Positions__c = 'sample leadership desc';
        opp.Amount = 500.00;
        opp.symMost_Important_Issue__c = 'sample important issue';
        opp.Campus_Session__c = 'testsession';
        opp.Second_Choice__c = 'testsession';
        opp.Teacher_recommendation_letter__c = 'teststatus';
        //-- Suyati Modified - 25/Nov/2014
        //-- Included Honor Student Code
        opp.Honor_Student_Code__c = 'HSCODE';
        insert opp;  
      
        List<Account> accs = TestUtils.createAccounts(1,'Test Account','PST');
        Account acc = accs[0];
        insert acc;
        List<Contact> contacts = TestUtils.createContacts(1,'test contact', acc.Id);
        Contact con = contacts[0];
        insert con;
        portalUser = testUtils.createPortalUser('appsuperbort@bort.com.bort', con.id);
        system.runAs(testUtils.sysadmin)
        {
            insert portalUser;
        }          
        
        system.runas(portalUser) {
            ApexPages.currentPage().getParameters().put('opId', opp.Id);     
            ApexPages.currentPage().getParameters().put('ApplicationType', 'SS');      
            
            JSAApplicationController c = new JSAApplicationController();
            
            system.assertEquals(c.OpId, opp.Id);
            system.assertEquals('SS', c.ApplicationType);
            system.assertEquals(opp.Id, c.Op.Id);
            system.assertEquals('testsummeropp', c.OpName);
            system.assertEquals(true, c.IsSSApplication);
            system.assertEquals(false, c.IsSympApplication);
            system.assertEquals(opp.Reference_Teacher_Name__c, c.RefTeacherName);
            system.assertEquals(opp.ExtraCurricular_Activities__c, c.ExtraCurricularActivities);
            system.assertEquals(opp.Personal_Essay__c,c.personalEssay);
            system.assertEquals(string.valueof(opp.Amount), c.TotalAmount);
            system.assertNotEquals(null, c.SalesOrderNumber);
            system.assertEquals(opp.symLeadership_Positions__c, c.LeadershipPositions);
            system.assertEquals(opp.symMost_Important_Issue__c, c.MostImportantIssue);
            system.assertEquals(prod.ProductCode, c.SelectedSession);
            system.assertEquals(prod.ProductCode, c.SelectedSecondChoice);
            system.assertEquals(1, c.SSCourses.size());
            
            //-- Suyati Modified - 25/Nov/2014
            //-- Included assertion for Honor Student Code
            system.assertEquals('HSCODE', c.HonorStudentCode);
            
            
            //verify content map keys added to the list
            system.assertEquals(true, c.OverviewContentKeys.contains('Personal Data Complete?'));
            system.assertEquals(true, c.OverviewContentKeys.contains('Recommendation Section Complete?'));
            system.assertEquals(true, c.OverviewContentKeys.contains('Teacher Recommendation Status?'));
            system.assertEquals(true, c.OverviewContentKeys.contains('Transcript Status?'));
            system.assertEquals(true, c.OverviewContentKeys.contains('Essay Status?'));
            system.assertEquals(true, c.OverviewContentKeys.contains('Scholarship Status?'));
            /*system.assertEquals(true, c.OverviewContentKeys.contains('Need scholarship / fundraising packet?'));*/
            system.assertEquals(true, c.OverviewContentKeys.contains('Acceptance Status'));
            
            system.assertEquals( c.contact.Id, con.Id);
            system.assertEquals(c.Submitted, false);
            system.assertEquals(c.OverviewContent.size() > 0, true);
            system.assertEquals(c.op.Academics_Complete__c,c.overviewContent.get('Recommendation Section Complete?'));
            //system.assertEquals('Incomplete',c.overviewContent.get('Personal Data Complete?'));
            system.assertEquals('teststatus', c.overviewContent.get('Teacher Recommendation Status?'));
            system.assertEquals('Requested', c.overviewContent.get('Transcript Status?'));
            system.assertEquals(c.op.Personal_Essay_Status__c, c.overviewContent.get('Essay Status?'));
            system.assertEquals('Not Applicable', c.overviewContent.get('Scholarship Status?'));
            system.assertEquals('false', c.overviewContent.get('Need scholarship / fundraising packet?'));
            system.assertEquals(c.ReferralOptions.size()> 0, true);
            system.assertEquals(true,c.highschoolstateOptions != null);
            system.assertEquals(true, c.SSSessionMap != null );
            system.assertEquals(true, c.SympSessionOptions != null );
            system.assertEquals(true, c.SSSessionOptions != null);
            system.assertEquals(true, c.invoices != null);
            system.assertEquals(c.invoices.size(), c.invoiceNumbers.size());
            system.assertEquals(true,string.isblank(c.highschool));
            system.assertEquals(true, string.isblank(c.highschoolstate));
            system.assertEquals(true, string.isblank(c.highschooltext));
            
            if(c.invoices.size() ==  0) {
                system.assertEquals('N/A', c.oppInvoiceNumber);
            }
            system.assertEquals('testsummeropp', c.opName);
            system.assertEquals(opp.Id, c.OpIdparam);
            system.assertEquals(true, c.op!=null );
            
            string refteacherName = 'test developer';
            c.RefTeacherName = refteacherName;
            c.extracurricularActivities = 'test extra curricular activities';
            c.personalEssay = 'test personal essay';
            c.saveopp();            
                    
            string refteacherEmail = 'test@test.com';
            c.RefTeacherEmail = refteacherEmail ;
            c.submit();
             
           // Opportunity requeriedOpp = [select Id, Reference_Teacher_Email__c,Application_Submitted__c from Opportunity where Id =:opp.Id ];
            //system.assertequals(refteacherEmail, requeriedOpp.Reference_Teacher_Email__c);
            system.assertEquals(true, JSAApplicationController.findSchools('Ala','CA' ) != null );
            //system.assertEquals(true,requeriedOpp.Application_Submitted__c);
            system.assertEquals(false, c.Submitted);
            //system.assertEquals(true, requeriedOpp.Application_Submitted__c);
            
            JSAApplicationController.QBPayment pmt = new JSAApplicationController.QBPayment('111', 'Paypal', system.now(),35.35);
            system.assertEquals('111', pmt.Id);
            system.assertEquals('Paypal', pmt.PaymentMethod);
            system.assertEquals(string.valueof(system.now().date()), pmt.PaymentDate);
            system.assertEquals(35.35, pmt.PaymentAmount);
            
            JSAApplicationController.QBCreditMemoLineItem memoitem = new JSAApplicationController.QBCreditMemoLineItem(system.now(), 'test' , 55.55);
            system.assertEquals(string.ValueOf(system.now().date()),memoitem.CreditMemoNumbersDate);
            system.assertEquals('test', memoitem.LineDescription);
            system.assertEquals(55.55, memoitem.LineAmount);
        }
        Test.stopTest();
        
    }
}