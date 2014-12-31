global with sharing class mainPortalController 
{
    public Opportunity op {get; set;}
    
    public string opname {get; set;}
    public string opdate {get; set;}
    public Contact contact {get; set;}
    public Boolean showEvents{get;set;}
    
    public static final string CONFIRM_MESSAGE = 'Success, your chapter registration is now available.';
    public static final string ERROR_MESSAGE = 'Registration failed to save';
    public static final string REDUNDANT_MESSAGE = 'A registration has already been created for your chapter';
    
    public Id ChapterConventionRecTypeId
    {
        get
        {
            RecordType rec = [select Id from RecordType where Name = 'Chapter Convention Registration' LIMIT 1];
            if(rec != null)
            {
                return rec.Id;
            }
            return null;
        }
        private set;
    }
    
    public Id SummerSchoolRecTypeId
    {
        get
        {
            RecordType rec = [select Id from RecordType where Name = 'Summer School Registration' LIMIT 1];
            if(rec != null)
            {
                return rec.Id;
            }
            return null;
        }
        private set;
    }
    
    public Id SymposiumRecTypeId
    {
        get
        {
            RecordType rec = [select Id from RecordType where Name = 'Symposium Registration' LIMIT 1];
            if(rec != null)
            {
                return rec.Id;
            }
            return null;
        }
        private set;
    }
    
    
    public integer selectedCon = 0;
    public string selectedConvention 
    {
        get { return selectedCon.format(); } 
        set { selectedCon = integer.valueof(value); }
    }
    
    public List<Conventions__c> theCons
    {
        get
        {
            
            List<Conventions__c> allCons = portalServices.queryAllConventions();
            List<Conventions__c> eligibleCons = new List<Conventions__c>{};
            for(Conventions__c con : allCons){
                if(con.JSA_State__c == theSchool.JSA_State__c){
                    eligibleCons.add(con);
                }
            }
            
            return eligibleCons;
            
        }
        private set;
    }
    
    public List<SelectOption> conSelection
    {
        get
        {
            if(conSelection == null)
            {
                
                Set<id> registeredCons = new Set<Id>{};
                
                for(Opportunity o: portalServices.queryRelatedOpportunities(theSchool)){
                    registeredCons.add(o.Convention_Id__c);
                    
                }
                
                conSelection = new List<SelectOption>();
                for(integer i=0;i<theCons.size();++i)
                {
                    //don't show con in list if school is already registered for it
                    //or registration date is past
                    if(! registeredCons.contains(theCons[i].Id) && theCons[i].Registration_Close_Date__c > System.today()){
                        conSelection.add(new SelectOption(i.format(),theCons[i].Name));
                    }
                }
            }
            return conSelection;
        }
        private set;
    }
    
    public High_School__c theSchool {get; set;}
        
    
    public mainPortalController()
    {
        Id contactId = [select ContactId from User where Id = :UserInfo.getUserId()].ContactId;
        contact = [select FirstName, LastName, AccountId, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
                          MobilePhone, HomePhone, Gender__c, High_School_Graduation_Year__c, Birthdate, Parent_Guardian_First_Name__c,
                          Parent_Guardian_Last_Name__c, Parent_or_Guardian_s_Email__c, High_School__c , JSA_Role__c
                   from Contact
                   where Id = :contactId];
        op = new Opportunity();
        theSchool = queryHighSchool();
        
        
        showEvents = portalServices.showEvents();
        
        system.debug('WULGUS: ' + theSchool);
        
        if(theSchool != null)
        {
            //otherStudents = portalServices.queryRelatedContacts(theSchool);
        }
    }
    
    public string SummerSchoolPBId
    {
        get
        {
            if(string.isblank(SummerSchoolPBId)) {
                SummerSchoolPBId = portalServices.queryProductIdByName('Summer School'); 
            }
            return SummerSchoolPBId;
        }
        private set;
    }
    
    public string SymposiumPBId
    {
        get
        {
            if(SymposiumPBId == null) {
                SymposiumPBId = portalServices.queryProductIdByName('Symposia');
            }
            return SymposiumPBId;
        }
        private set;
    }
    
    public List<PriceBookEntry> SummerSchoolEntries
    {
        get
        {
            if(SummerSchoolEntries == null) {
                system.debug('in summer schhol entries. ss product id is: ' + SummerSchoolPBId);
                List<PricebookEntry> SSEntries = [Select Product2Id From PricebookEntry  where Pricebook2Id =:SummerSchoolPBId ];
                //'01s40000000EsfF'
                SummerSchoolEntries = SSEntries;
            }
            return SummerSchoolEntries;
        }
        private set;
    }
    
    public List<PriceBookEntry> SymposiaEntries
    {
        get
        {
            if(SymposiaEntries == null) {
                system.debug('in symposium entries. symposim product id is: ' + SymposiumPBId);
                List<PriceBookEntry> SympEntries = [Select p.Product2Id from PriceBookEntry p where p.Pricebook2Id =:SymposiumPBId ];
                //'01s40000000Eucw'
                SymposiaEntries = SympEntries;
            }
            return SymposiaEntries;
        }
        private set;
    }
    
    public List<Product2> SummerSchoolProducts
    {
        get {
            if(SummerSchoolProducts == null) {
                List<Id> productIds = new List<Id>();
                for(PriceBookEntry pbe : SummerSchoolEntries ){
                    productIds.add(pbe.Product2Id);
                }
                List<Product2> prods = [Select ProductCode, Next_Year_Offered__c, Name  From Product2 where Id IN :productIds and Course_Type__c = 'Parent' and IsActive = true];
                SummerSchoolProducts = prods;
            }
            return SummerSchoolProducts;
        }
        private set;
    }
    
    public List<Product2> SymposiaProducts
    {
        get
        {
            if(SymposiaProducts == null)
            {
                List<Id> productIds = new List<Id>();
                for(PriceBookEntry pbe : SymposiaEntries ){
                    productIds.add(pbe.Product2Id);
                }
                List<Product2> prods = [Select ProductCode, Next_Year_Offered__c, Name  From Product2 where Id IN :productIds and Course_Type__c = 'Parent'  and IsActive = true];
                SymposiaProducts = prods;
                
            }
            return SymposiaProducts;
        }
        private set;
    }
    
    public integer SSLatestYear
    {
        get
        {   
            integer Latestyear= 0;
            integer year;
            for(Product2 p : SummerSchoolProducts) {
                if(!String.IsBlank(p.Next_Year_Offered__c)) {
                    year = Integer.Valueof(p.Next_Year_Offered__c);
                    if(year > LatestYear) {
                        LatestYear = year;
                    }
                }
            }
            return LatestYear;
        }
        set;
    }
    
    public integer SymposiaLatestYear
    {
        get
        {
            integer latestYear = 0;
            integer year;
            for(Product2 p: SymposiaProducts) {
                if(!String.IsBlank(p.Next_Year_Offered__c)) {
                    year = Integer.Valueof(p.Next_Year_Offered__c);
                    if(year > LatestYear) {
                        LatestYear = year;
                    }
                }
            }
            return latestYear;
        }
        set;
    }
    
    public List<SelectOption> SSProductNames
    {
        get {
            if(SSProductNames == null) {
                List<SelectOption> options = new List<SelectOption>();
                options.add(new SelectOption('None','-- Select One --'));
                for(Product2 p: SummerSchoolProducts) {
                    options.add(new SelectOption(p.ProductCode,p.Name));
                }
                SSCourses = new List<SelectOption>();
                SSProductNames = options;
            }
            return SSProductNames;
        }
        set;    
    }
    
    public List<SelectOption> SymposiaProductNames
    {
        get {
            if(SymposiaProductNames == null) {
                List<SelectOption> options = new List<SelectOption>();
                options.add(new SelectOption('None','-- Select One --'));
                for(Product2 p: SymposiaProducts) {
                    options.add(new SelectOption(p.ProductCode,p.Name));
                }
                SymposiaProductNames = options;
            }
            return SymposiaProductNames;
        }
        set;    
    } 
    
    public void onSessionSelected()
    {
        SSCourses =  fetchSSCourses(); 
    }
    
    public List<SelectOption> SSCourses
    {
        get{
            if(SSCourses == null) {
                SSCourses = fetchSSCourses();
            }
            else if(SSCourses.size() == 0) {                
                SSCourses.add(new SelectOption('None',' --Select One-- '));
            }
            return SSCourses;
        }
        set;
   }
    
    
    public List<SelectOption> fetchSSCourses()
    {
                            
                List<SelectOption> courses = new List<SelectOption>();
                courses.add(new SelectOption('None','-- Select One --'));
                List<Courses__C> prodCourses = [select Course_Name__c, Id FROM Courses__c where Campus_Session__c =:SelectedSSSession];
                if(prodCourses != null) 
                {
                    for(Courses__c c : prodCourses) 
                    {
                        courses.add(new SelectOption(c.Id, c.Course_Name__c));  
                    }
                }
                SSCourses = courses;
                return SSCourses;   
        
    }
    
    public List<SelectOption> ReferralOptions
    {
        get
        {
            if(ReferralOptions == null) {
                ReferralOptions = new List<SelectOption>();
                ReferralOptions.add(new SelectOption('None','-- Select One--'));
                ReferralOptions.addAll(portalServices.getPicklistValues(new Opportunity(name='Test'), 'How_did_you_learn_about_us__c')) ;
            }
            return ReferralOptions;
        }
        set;
    }
    
    public boolean IsScholarshipNeeded {get;set;}
    
    //-- Suyati Modified - 25/Nov/2014
    //-- Added a variable to store the user input for HonorStudentCode
    public string HonorStudentCode  {get;set;}
    
    public string SelectedSSRefSource {get;set;}
    
    public string SelectedSympRefSource{get;set;}
    
    public String SelectedSSCourse {get;set;}
    
    public String SelectedSSSession {get;set;}
    
    public string SelectedSympSession {get;set;}
    
    public String SelectedSecondSSSession {get;set;}
    
    public High_School__c queryHighSchool()
    {
        try
        {
            User requeriedUser = [SELECT Id,ContactId,Contact.High_School__c,Contact.High_School__r.JSA_State__c,Contact.High_School__r.Name,Contact.High_School__r.Account__c FROM USER WHERE Id = :UserInfo.getUserId()];
            return requeriedUser.Contact.High_School__r;
        }
        catch(Exception ex)
        {
            system.debug('BORGO: ' + ex);
            return null;
        }
    }
    
    public List<Opportunity> allOpps
    {
        get
        {
            if(allOpps == null)
            {
                List<Opportunity> opps;
                if(contact != null) {
                    opps = portalServices.queryRelatedOpportunities(theSchool,contact.AccountId);
                }
                else {
                    opps = portalServices.queryRelatedOpportunities(theSchool);
                }
                allOpps = opps;
            }
            return allOpps;
        }
        private set;
    }
    
    public Map<Id,String> openOpps
    {
        get
        {
            if(openOpps == null)
            {
                list<Opportunity> opps = portalServices.queryRelatedOpportunities(theSchool);
                openOpps = new Map<Id,String>();
                
                for(Opportunity opp : opps)
                {
                    openOpps.put(opp.id,opp.Name);
                }
            }
            
            return openOpps;
        }
        private set;
    }
    
    public Map<Id,String> chapterConvnRegOpps
    {
        get
        {
            if(chapterConvnRegOpps == null)
            {
                chapterConvnRegOpps = GetOppsByRecordTypeId(ChapterConventionRecTypeId,theSchool.Account__c);                   
            }
            return chapterConvnRegOpps;
        }
        private set;
    }
    public Boolean notAllChaptConvnShown
    {
         get
         {
             if(chapterConvnRegOpps.Size() > 10)
             {
                 return true;
             }         
             return false;
         }
         private set;
    }
    
    public Map<Id,String> summerSchoolRegOpps
    {
        get
        {
            if(summerSchoolRegOpps == null)
            {
                if(contact != null) {
                    summerSchoolRegOpps = GetOppsByRecordTypeId(SummerSchoolRecTypeId, contact.AccountId);
                }
            }
            return summerSchoolRegOpps;
        }
        private set;
    }
    public Boolean notAllSummerSchoolShown
    {
        get
        {
            if(summerSchoolRegOpps.size() > 4)
            {
                return true;
            }
            return false;
        }
        private set;
    }
        
    public Map<Id,String> SymposiumRegOpps
    {
        get
        {
            if(SymposiumRegOpps == null)
            {
                if(contact != null) {
                    SymposiumRegOpps = GetOppsByRecordTypeId(SymposiumRecTypeId, contact.AccountId);
                }
            }
            return SymposiumRegOpps;
        }
        private set;
    }
    
    public Boolean notAllSymposiumShown
    {
        get
        {
            if(SymposiumRegOpps.size() > 4)
            {
                return true;
            }
            return false;
        }
    }
    
    public Map<Id,String> GetOppsByRecordTypeId(Id recTypeId, Id accountId)
    {        
        Map<Id,String> result ;
        if(!String.IsBlank(recTypeId) && allOpps != null) 
        {
            result = new Map<Id,String>();
        
            for(Opportunity opp: allOpps)
            {
                if(opp.RecordTypeId == recTypeId && opp.AccountId == accountId)
                {
                    result.put(opp.Id,opp.Name);            
                }
            }
        }
        return result;       
    }
    
    public set<Id> openKeys
    {
        get 
        { 
            return openOpps.keySet(); 
        }
    }

    public Set<Id> GetTop10IdsFromMap(Map<Id,String> inputMap) {
        if(inputMap.size() <= 10) {
            return inputMap.keyset();
        }
        else {
            Set<Id> result = new Set<Id>();
            List<Id> IdList = new List<Id>();
            IdList.addAll(inputMap.keyset());   
            result.add(IdList[0]);
            result.add(IdList[1]);
            result.add(IdList[2]);
            result.add(IdList[3]);
            result.add(IdList[4]);
            result.add(IdList[5]);
            result.add(IdList[6]);
            result.add(IdList[7]);
            result.add(IdList[8]);
            result.add(IdList[9]);
            return result;
        }
    }
    
    public Set<Id> openChapterConvnKeys
    {
        get 
        { 
            return GetTop10IdsFromMap(ChapterConvnRegOpps);
        }
        set;
    }
    
    public Set<Id> openSummerSchoolKeys
    {
        get { return GetTop10IdsFromMap(SummerSchoolRegOpps); }
    }
    
    public Set<Id> openSymposiumKeys
    {
        get { return GetTop10IdsFromMap(SymposiumRegOpps); }
    }
    
    public pagereference saveOp()
    {
        system.debug('inside saveop');
        system.debug('selected con value is: ' + selectedCon);
        Conventions__c theCon = theCons[selectedCon];
        system.debug('con name is: ' + theCon.Name);
        op.Name = theCon.name + ' - ' +theSchool.name;
        op.Convention_Id__c = theCon.Id;
        op.CloseDate = theCon.open_date__c;
        op.StageName = 'Application Started';
        op.AccountId = theSchool.Account__c;
        op.Type = theCon.Type__c;
        op.RecordTypeId = portalServices.CONVENTION_RECORDTYPE_ID;
        op.Convention__c = portalServices.getRegionName(theSchool.JSA_State__c);
        op.ocHigh_School__c = theSchool.id;
        op.Pricebook2Id = portalServices.getPriceBookId(theSchool);
        system.debug('check opportunity here: ' + op  );
        if(portalServices.checkForPreExistingOpp(op.Name , op.CloseDate, op.AccountId))
        {
            system.debug('looks like the opp already exists');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,REDUNDANT_MESSAGE));
            return null;
        }
        else {
            system.debug('the opp doesnt already exist');
        }
        
        if(portalServices.saveOpportunities(new List<Opportunity>{op.clone()}))
        {
            theCons.remove(selectedCon);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM,CONFIRM_MESSAGE));
            
            list<Opportunity> opps = portalServices.queryRelatedOpportunities(theSchool);
            openOpps = new Map<Id,String>();
            String lastOppId = opps[0].Id;
            for(Opportunity opp : opps)
            {
                openOpps.put(opp.id,opp.Name);
            }
            //return the user to the newly created opportunity
            return new PageReference('/apex/JSAEvent?OpId=' + lastOppId);
        }
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ERROR_MESSAGE));
        return null;
    }
    
    public string selectedTestVal {get;set;}
    
    @RemoteAction
    global static  string getOpportunity(string session, string secondSession, string courseId, string refSource, string latestYear,string accountId, boolean IsSS, boolean IsScholarshipNeeded, string HonorStudentCode )
    {       
        if(!string.isblank(session)) {
            string oppName = latestYear + ' ' + session + ' - ' + UserInfo.getName() ;
            
            string oppId = portalServices.DoesOppExist(oppName);
            system.debug('oppId received is' + oppId);
            
            if(!string.IsBlank(oppId)) {
                system.debug('looks like theres already an opportunit with that name');
                return oppId;
            }
            else {
                OpportunityContactRole ocr;
                User u = [select ContactId from User where Id = :UserInfo.getUserId() limit 1];
                Id contactId;
                if(u != null) { contactId = u.ContactId; }
                system.debug('theres no existing opp. creating a new one');
                Opportunity opp = new Opportunity();
                opp.Name = oppName;
                if(IsSS) {
                    opp.Campus_Session__c = session;
                    opp.Second_Choice__c = secondSession;
                    opp.Course_A__c = courseId;
                    opp.RecordTypeId = '012400000005P4d';    
                    string SSPBId = portalServices.queryProductIdByName('Summer School');  
                    opp.Pricebook2Id = SSPBId;      
                }
                else {
                    opp.Symposium__c = session;
                    opp.Campus_Session__c = session;
                    opp.RecordTypeId = '012400000005Rob';
                    string SympPBId = portalServices.queryProductIdByName('Symposia');  
                    opp.Pricebook2Id = SympPBId;
                }
                if(!string.isBlank(contactId)) {
                    opp.Primary_Contact__c = contactId;
                    Contact con = [Select Contact_Role__c from Contact where Id=: contactId limit 1];
                    if(con != null) {
                        ocr = new OpportunityContactRole();
                        ocr.ContactId = contactId;
                        ocr.IsPrimary = true;
                        ocr.Role = con.Contact_Role__c;
                    }
                }
                opp.AccountId = accountId;
                opp.StageName = 'Application Started';
                opp.closeDate = system.Today().addDays(14);
                opp.Transcript_Status__c = 'Requested';
                opp.Teacher_recommendation_letter__c = 'Requested';
                
                //-- Suyati Modified - 25/Nov/2014
                //-- Assigned honorStudentCode field to opportunity
                opp.Honor_Student_Code__c = HonorStudentCode;
                
                if(IsScholarshipNeeded == true) {
                    opp.Need_scholarship_fundraising_packet__c = true;
                    opp.Scholarship_Status__c = 'Requested';
                }           
                if(!String.isblank(refSource) && refSource != 'None' ) {
                    opp.How_did_you_learn_about_us__c = refSource;
                }           
                insert opp;
                                
                if(ocr != null) {
                    ocr.OpportunityId = opp.Id;
                    portalServices.AddOpportunityContactRole(ocr);
                }
                
                portalServices.AddOpportunityProduct(opp.Id, session, opp.Pricebook2Id);
                
                return opp.Id;
            }
        } 
        else {
            return '';
        }       
    }    
}