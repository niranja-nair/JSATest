public with sharing class extGroupRegistration {
	//public Opportunity group_opp {get;set;}
	public List<Opportunity> lstRegs {get;set;}
	public String strName {get;set;}
	 
    public extGroupRegistration(ApexPages.StandardController controller) {
		//Opportunity group_opp = new Opportunity();//(Opportunity)controller.getRecord();
		
		if ((Opportunity)controller.getRecord() != null){
			Opportunity group_opp = (Opportunity)controller.getRecord(); //[Select Id, Name from Opportunity where Id = : (Opportunity)controller.getRecord().Id];
			group_opp = [Select Id, Name from Opportunity where Id = : group_opp.Id];
			if (group_opp.Id != null){
				lstRegs = [Select Id, Name, Primary_Contact__r.Name, JSA_Role__c, Assign_Room__c, Male_Female__c, Permission_Form_Received__c
					from Opportunity where Group__c =: group_opp.Id order by Primary_Contact__r.LastName, Primary_Contact__r.FirstName];
				strName = group_opp.Name;
			}
		} else { 
			//group_opp = new Opportunity();
			lstRegs = new List<Opportunity>(); 
		}
    }
    
    //Everything below is to test the code
    
    static Contact testConGen(Id idGroup, String strFirst, String strLast){
    	Contact c = new Contact(
    		FirstName = strFirst,
    		LastName = strLast,
    		AccountId = idGroup
    	);
    	
    	insert c;
    	return c;
    }//end testConGen
    
    static Opportunity testRegGen(Id idCon, Date dte, String strGen, Id idGroup, Id idRT,  String strPref, Integer intPref){
    	Opportunity o = new Opportunity(
    		Convention__c = 'Northeast', 
    		CloseDate = dte, 
    		Male_Female__c = strGen, 
    		Group__c = idGroup,
    		RecordTypeId = idRT,
    		Primary_Contact__c = idCon,
    		StageName = 'Interested',
    		Name = 'Reg'
    		);
    
    	insert o;
    

    	return o;
    }
	
	static testMethod void testPageActions() {
		Date dteCon = System.today().addDays(90);
    	Account a = new Account(
    		Name = 'Nonnewaug',
    		BillingStreet = 'Street',
    		BillingState = 'Connecticut',
    		BillingPostalCode = '06751',
    		BillingCity = 'Woodbury'
    	);
    	insert a;
    	
    	High_School__c h = new High_School__c(
            Name = 'Jessie Test HS', 
            Account__c = a.Id);
        insert h;
        
        //Get record type Ids
        Id idRTReg = [Select Id from RecordType where DeveloperName = 'Individual_Convention_Registration'][0].Id;
    	Id idRTCon = [Select Id from RecordType where DeveloperName = 'ChapterConventionRegistration'][0].Id;
    	
    	//Create Group opportunity
		Opportunity oCon = new Opportunity(
    		Convention__c = 'Northeast', 
    		CloseDate = dteCon, 
    		ocHigh_School__c = h.Id,
    		RecordTypeId = idRTCon,
    		StageName = 'Interested',
    		Name = 'Group'
    		);
    	
    	insert oCon;
    	
    	//Test to load page with a group with no registrations
    	ApexPages.StandardController stdCon = new ApexPages.StandardController(oCon);
    	extGroupRegistration ext = new extGroupRegistration(stdCon);
    	
    	//Create a registration
    	Contact c1 = testConGen(a.Id, 'Rainbow', 'Paper');
    	Opportunity r1 = testRegGen(c1.Id, dteCon, 'Female', oCon.Id, idRTReg,  '', 1);
    	
    	//Test page with group with registration
		stdCon = new ApexPages.StandardController(oCon);
		ext = new extGroupRegistration(stdCon);
	}
}