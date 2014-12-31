public without sharing class portalServices
{
    public static Id PORTAL_ACCOUNT_OWNER_ID
    {
        get
        {
            if(PORTAL_ACCOUNT_OWNER_ID == null)
            {
                PORTAL_ACCOUNT_OWNER_ID = [SELECT Id FROM User WHERE name = 'Junior Statesmen'].id;
            }
            
            return PORTAL_ACCOUNT_OWNER_ID;
        }
        private set;
    }
    
    public static Id CONVENTION_RECORDTYPE_ID 
    {
        get
        {
            if(CONVENTION_RECORDTYPE_ID == null)
            {
                CONVENTION_RECORDTYPE_ID = [SELECT Id FROM RecordType WHERE name = 'Chapter Convention Registration'].id;
            }
            
            return CONVENTION_RECORDTYPE_ID;
        }
        private set;
    }
    
    public class selectSObject
    {
        public Map<Id,sObject> objectMap
        {
            get;
            set;
        }
        
        public List<SelectOption> optionList
        {
            get;
            set;
        }
        
        public string selectedId
        {
            get;
            set;
        }
        
        public sObject selectedObject
        {
            get
            {
                return objectMap.get(selectedId);
            }
        }
        
        public selectSObject(list<sObject> objectList)
        {
            objectMap = new Map<id,sObject>(objectList);
            
            optionList = new List<SelectOption>();
            
            for(sObject so : objectList)
            {
                optionList.add(new SelectOption((ID)so.get('Id'),(String)so.get('Name') ));
            }
        }
        
        public selectSObject(list<sObject> objectList,String noneText)
        {
            objectMap = new Map<id,sObject>(objectList);
            
            optionList = new List<SelectOption>();
            
            optionList.add(new SelectOption('',noneText));
            
            for(sObject so : objectList)
            {
                optionList.add(new SelectOption((ID)so.get('Id'),(String)so.get('Name')   ));
            }
        }
    }   
    
    public static boolean saveOpportunities(list<Opportunity> opptys)
    {
        try
        {
            upsert opptys;
        }
        catch(DmlException dmx)
        {
            return false;
        }
        
        return true;
    }
    
    private class conWrapper implements comparable
    {
        public Conventions__c con;
        public conWrapper(Conventions__c theCon)
        {
            con = theCon;
        }
        
        public Integer compareTo(Object compareTo) 
        {
            Date myDate = con.open_date__c;
            Conventions__c comp = ((conWrapper)compareTo).con;
            if(myDate == comp.open_date__c)
            {
                return 0;   
            }
            else if(myDate > comp.open_date__c)
            {
                return 1;
            }
            else
            {
                return -1;
            }        
        }
    }
    
    public static List<Conventions__c> queryAllConventions()
    {
        //ALL THIS JUST TO SORT SOME STUFF?!
        List<conWrapper> cons = new List<conWrapper>();
        for(Conventions__c con : Conventions__c.getAll().values())
        {
            if(con.Active__c)
            {
                cons.add(new conWrapper(con));
            }
        }
        
        //sort by date
        cons.sort();
        
        list<Conventions__c> unwrappedCons = new list<Conventions__c>();
        
        for(conWrapper cw : cons)
        {
            unwrappedCons.add(cw.con);
        }
        
        return unwrappedCons;
    }
    
    public static List<Contact> queryRelatedContacts(High_School__c hs)
    {
        list<Contact> relatedContacts = [SELECT Name,High_School__c FROM Contact WHERE High_School__c = :hs.id];
        return relatedContacts;
    }
    
    public static Id getPriceBookId(High_School__c hs)
    {
        map<string,Zone_Pricebook_mapping__c> zoneMap = Zone_Pricebook_Mapping__c.getAll();
        return (Id)zoneMap.get(hs.JSA_State__c).pricebookId__c; 
    }
    
    private static boolean checkStudentOrTeacher(PricebookEntry pbe, Boolean isTeacher)
    {
        if(isTeacher)
        {
            if(pbe.Name.contains('Teacher Package'))
            {
                return true;        
            }
        }
        else
        {
            if(pbe.Name.contains('Student Package'))
            {
                return true;    
            }
        }
        
        return false;
    }
    
    private static boolean checkType(pricebookEntry pbe, string Type)
    {
        return pbe.name.contains(Type);
    }
    
    public static list<PricebookEntry> queryRelevantProducts(High_School__c hs, Boolean isTeacher, String conventionType )
    {
        Id pbId = getPriceBookId(hs);

        list<PricebookEntry> relatedProducts = 
        [
            SELECT Id,Product2.Name,Product2Id,Name,UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :pbId
            AND isActive = true
            AND Product2.isActive = true
        ];
        
        list <PricebookEntry> filteredProducts = new List<PricebookEntry>();
        
        for(PricebookEntry pbe : relatedProducts)
        {
            if(checkStudentOrTeacher(pbe,isTeacher) && checkType(pbe,conventionType))
            {
                filteredProducts.add(pbe);
            }
        }
        
        return filteredProducts;
    }
    
    public static String queryProductIdByName(string name) {
        string PBId;
        List<Pricebook2> pbs = [Select Id From Pricebook2  where Name = :name LIMIT 1];
        if(pbs != null && pbs.size() > 0) {
            PBId = pbs[0].Id;
        }
        return PBId;
    }
    
    public static list<PricebookEntry> queryRelatedProducts(High_School__c hs )
    {
        Id pbId = getPriceBookId(hs);

        list<PricebookEntry> relatedProducts = 
        [
            SELECT Id,Product2.Name,Product2Id,Name
            FROM PricebookEntry
            WHERE Pricebook2Id = :pbId
        ];
        
        return relatedProducts;
    }
    
    public static list<Opportunity> queryRelatedOpportunities(High_School__c hs)
    {
        Date aYearAgo = system.today() - 365;
        list<Opportunity> allOps = 
            [SELECT Id,Name, Convention_Id__c, RecordTypeId, AccountId
            FROM Opportunity 
            WHERE AccountId = :hs.Account__c 
            AND CloseDate >=: aYearAgo
            order by createdDate desc];       
        return allOps;
    }
    
    public static list<Opportunity> queryRelatedOpportunities(High_School__c hs, Id accountId) {
        Date aYearAgo = system.today() - 365;
        list<Opportunity> allOps = 
            [SELECT Id,Name, Convention_Id__c, RecordTypeId, AccountId
            FROM Opportunity 
            WHERE (AccountId = :hs.Account__c or AccountId =:accountId) 
            AND CloseDate >=: aYearAgo
            order by createdDate desc];       
        return allOps;
    }
    
    public static Opportunity queryOpp(Id oppId)
    {
        Opportunity op = 
        [
            SELECT Id,Name,Primary_Contact__c,ocTeacher_Advisor__c, ocTeacher_Advisor__r.Name,
            Terms_and_Conditions__c,Type,Order_Number__c,StageName, ocStudent_Delegation_Leader__r.Name,
            Amount, Online_Payment_Link__c, Orientation_Guide__c, Remaining_Balance__c, Applied_Amount__c,
            (
                SELECT id,Contact__c,Contact__r.Name,Contact__r.Category__c,Contact__r.Gender__c,
                Product2__c, Opportunity__c,   Product2__r.Name, Price__c
                FROM Applications__r 
            ),
            (Select Id, TotalPrice from OpportunityLineItems)
            FROM Opportunity
            WHERE Id = :oppId
            LIMIT 1
        ];
        
        return op;
    }
    
    public static Opportunity queryOppForAppl(Id oppId)
    {
        //-- Suyati Modified - 24/Nov/2014
        //-- Added field Honor_Student_Code__c to the query 
        Opportunity op =
        [
            SELECT Transcript_Status__c, Teacher_recommendation_letter__c, StageName, School_ZIP_Code__c,Scholarship_Status__c,
             Reference_Teacher_Phone__c,Reference_Teacher_Name__c, Reference_Teacher_Email__c, Personal_Essay__c, 
             Personal_Essay_Status__c, Personal_Data_Complete__c, Need_scholarship_fundraising_packet__c, Name, 
             How_did_you_learn_about_us__c, Extracurricular_Activities__c, Acceptance_Status__c,Academics_Complete__c,
             Second_Choice__c, Course_A__c, Campus_Session__c ,ocHigh_School__c , Order_Number__c, Amount, symLeadership_Positions__c,
             symMost_Important_Issue__c, Send_Online_Invoice__c, Online_Payment_Link__c, Orientation_Guide__c, Remaining_Balance__c,
             Applied_Amount__c, Honor_Student_Code__c
            FROM Opportunity
            WHERE Id =: oppId
            LIMIT 1
        ];
        
        return op;
    }
     
    public static List<QB_Invoice__c> getOppsQuickBookInvoices(string oppId) {
        List<QB_Invoice__c> qbInvoices =
        [
            SELECT Name, Invoice_Amount__c, Id, CreatedDate, Remaining_Balance__c
            FROM QB_Invoice__c
            WHERE OpportunityID__c = :oppId
            ORDER BY CreatedDate desc            
        ];
        return qbInvoices;
    }
    
    
    public class potentialDelegateProductSelection
    {
        public Contact theContact {get; set;}
        public selectSObject theProducts{get; set;}
        
        public potentialDelegateProductSelection(Contact c,list<PricebookEntry> pbes)
        {
            theContact = c;
            theProducts = new selectSObject(pbes.deepClone(true),'--not attending--');
        }
    }
    
    public static boolean setOpportuntiyProducts(list<potentialDelegateProductSelection> productSelections,Opportunity op)
    {
        savePoint sp = Database.setSavepoint();
        
        list<OpportunityLineItem> oldOlis = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :op.id];
        
        if(!oldOlis.isEmpty())
        {
            try
            {
                delete oldOlis;
            }
            catch(exception ex)
            {
                return false;
            }
        }
        
        list<OpportunityLineItem> newOlis = new List<OpportunityLineItem>();
        
        for(potentialDelegateProductSelection delegate : productSelections)
        {
            if(delegate.theProducts.selectedId != null && delegate.theProducts.selectedId != '')
            {
                OpportunityLineItem newOli = new OpportunityLineItem();
                newOli.OpportunityId = op.id;
                newOli.PricebookEntryId = delegate.theProducts.selectedId;
                newOli.Quantity = 1;
                newOli.UnitPrice = (Decimal)delegate.theProducts.selectedObject.get('unitPrice');
                newOlis.add(newOli);
                newOli.Description = 'For: ' + delegate.theContact.name;
            }
        }
        
        if(!newOlis.isEmpty())
        {
            try
            {
                insert newOlis;
            }
            catch(exception ex)
            {
                //bring back the old olis!
                Database.rollback(sp);
                return false;
            }
        }
        
        return true;
    }
    
    public static void AddOpportunityProduct(string oppId, string selectedProduct, string pricebookId ) {
            List<Product2> prods = [select Id, ProductCode,IsActive from Product2 where Name =: selectedProduct];
            if(prods != null && prods.size() > 0) {
                Product2 prod = prods[0];
                
                List<PricebookEntry> pbes = [select Id,UnitPrice,IsActive from PricebookEntry where Product2ID =: prod.Id and Pricebook2Id =:pricebookId ];
                if(pbes != null && pbes.size() > 0) {
                    if(pbes[0].IsActive == true && prod.IsActive == true) {
                        OpportunityLineItem li = new OpportunityLineItem();
                        li.PricebookEntryID = pbes[0].Id;
                        li.OpportunityId = oppId;
                        li.Quantity = 1;
                        li.UnitPrice = pbes[0].UnitPrice;
                        insert li;  
                    }
                }               
            }
    }
    
    public static void AddOpportunityContactRole(OpportunityContactRole ocr) {
        insert ocr;
    }
    
    public static boolean checkForPreExistingOpp(string opname,Date opdate,Id opAccountId)
    {
        List<Opportunity> ops = 
        [
            SELECT Id 
            FROM Opportunity 
            WHERE Name = :opname
            AND CloseDate = :opdate
            AND AccountId = :opAccountId
        ];
        
        return !ops.isEmpty();
    }
    
    public static string getRegionName(string jsaState)
    {
        Map<String,state_region_mapping__c> stateToRegion = state_region_mapping__c.getAll();
        if(stateToRegion.containsKey(jsaState))
        {
            return stateToRegion.get(jsaState).region_name__c;
        }
        else
        {
            return null;
        }
    }
    
    public static boolean upsertHotelRooms(list<HotelRoom__c> rooms)
    {
        try
        {
            upsert rooms;
            System.debug('rooms:'+rooms);
        }
        catch(exception e)
        {
            return false;
        }
        
        return true;
    }
    
    public static Boolean showEvents(){
        
        Id contactId = [select ContactId from User where Id = :UserInfo.getUserId()].ContactId;
        Contact c = [select JSA_Role__c
                   from Contact
                   where Id = :contactId];
        set<String> dontShowRoles = new Set<String>{'Student','Chapter Officer','Chapter Affairs Agent'};
        
        if(dontShowRoles.contains(c.JSA_Role__c)){
            return false;
        }else{
            return true;
        }
    }
    
    public static string DoesOppExist(string oppName)
    {
        List<Opportunity> opps = [select Id from Opportunity where Name=:oppName];
        if(opps != null && opps.size() > 0) {
            return opps[0].Id;
        } 
        return null;
    }
    
    public static list<SelectOption> getPicklistValues(SObject obj, String fld)
    {
      list<SelectOption> options = new list<SelectOption>();
      Schema.sObjectType objType = obj.getSObjectType();       
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();     
      map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
      
      if(fieldMap != null && fieldMap.get(fld) != null ) {
        list<Schema.PicklistEntry> values =
         fieldMap.get(fld).getDescribe().getPickListValues();
      
          for (Schema.PicklistEntry a : values)
          { 
             options.add(new SelectOption(a.getLabel(), a.getValue())); 
          }
      }
      return options;
   }
    
   public static List<SelectOption> getSSSessions() {
        List<SelectOption> result = new List<SelectOption>();
        string SSPBId = portalServices.queryProductIdByName('Summer School');           
        Map<String,String> sessions = portalServices.getSessionMap(SSPBId);
        
        for(string key : sessions.keyset()) {
            result.add(new SelectOption(key, sessions.get(key)));
        }
        
        return result;
   }
   
   public static List<SelectOption> getSymposiumSessions() {
        List<SelectOption> result = new List<SelectOption>();
        string SymposiaPBId = portalServices.queryProductIdByName('Symposia'); 
        Map<String,String> sessions = portalServices.getSessionMap(SymposiaPBId);
        
        for(string key : sessions.keyset()) {
            result.add(new SelectOption(key, sessions.get(key)));
        }
        
        return result;
   }
   
   public static Map<String,String> getSessionMap(string pricebookId) {
        Map<String,String> result = new Map<String,String>();
        List<PricebookEntry> SSEntries = [Select Product2Id From PricebookEntry  where Pricebook2Id = :pricebookId];
        
        List<Id> productIds = new List<Id>();
        for(PriceBookEntry pbe : SSEntries ){
            productIds.add(pbe.Product2Id);
        }
        
        List<Product2> prods = [Select ProductCode, Next_Year_Offered__c, Name  From Product2 where Id IN :productIds and Course_Type__c = 'Parent' and IsActive = true];
       
        for(Product2 p: prods) {
            result.put(p.ProductCode, p.Name);
        }
        
        return result;
   } 
   
   public static  List<SelectOption> fetchSSCourses(string sessionId) {
        List<SelectOption> courses = new List<SelectOption>();
        courses.add(new SelectOption('None','-- Select One --'));
                    
        List<Courses__C> prodCourses = [select Course_Name__c, Id FROM Courses__c where Campus_Session__c =:sessionId];
        if(prodCourses != null) {
            for(Courses__c c : prodCourses) 
            {
                courses.add(new SelectOption(c.Course_Name__c, c.Course_Name__c));  
            }
        }
        return courses;     
    }    
}