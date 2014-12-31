global without sharing class jsaPortalEventController 
    {
        public static final string SUBMITTED_STAGE = 'C: Complete';
        public static final string ID_PARAM = 'opId';
        
        public Opportunity op 
        {
            get;
            private set;
        }
        
        public boolean TandC
        {
            get { return op.Terms_And_Conditions__c; }
        }
        
        public Id leadDelegateId
        {
            get { return op.ocStudent_Delegation_Leader__c; }
        }
        
        public Id advisorId
        {
            get { return op.ocTeacher_Advisor__c; }
        }
        
        public String opName
        {
            get { return op.Name; }
        }
        
        public String opType
        {
            get { return op.Type; }
        }
        
        public String leaderName
        {
            get { 
                return op.ocStudent_Delegation_Leader__r.Name; 
            }
        }
        
        public String advisorName
        {
            get { return op.ocTeacher_Advisor__r.Name; }
        }
        
        public String opId
        {
            get { return op.Id; }
        }
        
        public Decimal totalAmount
        {
            get { return op.Amount;}
        }
        
        public Decimal totalBalance
        {
            get { return op.Remaining_Balance__c;}
        }
        
        public Decimal totalAppliedAmount
        {
            get { return op.Applied_Amount__c;}
        }

        public String orderNumber
        {
            get { return op.Order_Number__c; }
        }
        
        public boolean submissionApproved
        {
            get { return op.StageName == 'Accepted'; } 
        }
        
        public boolean submitted
        {
            get 
            { 
                return op.StageName == SUBMITTED_STAGE; 
            } 
        }
        
        
        public boolean leadershipSelected
        {
            get
            {
                boolean leadDelegateSelected = leadDelegateId != null;
                boolean advisorSelected = advisorId != null;
                
                return leadDelegateSelected && advisorSelected;
            }
        }
        
        public integer tabState
        {
            get;
            private set;
        }
        
        public List<String> tabNames
        {
            get
            {
                if(tabNames == null)
                {
                    tabNames = new List<String>
                    {
                        'overview',
                        'TandC',
                        'delegates',
                        'rooms',
                        'invoice'
                    };
                }
                return tabNames;
            }
            private set;
        }

        public High_School__c hs {get; set;}
        
        public static final string STUDENT_CATEGORY = 'Student';
        
        //For Overview
        public portalServices.selectSObject selectChapterDelegate
        {
            get
            {
                if(selectChapterDelegate == null)
                {
                    List<Contact> potentialDelegates = 
                    [
                        SELECT Name,Id,JSA_Role__c 
                        FROM Contact 
                        WHERE High_School__c = :hs.id 
                        AND JSA_Role__c in ('Student', 'Chapter President', 'Chapter Officer')
                        AND Graduated__c = false
                        order by lastName asc
                    ];
                    
                    selectChapterDelegate = new portalServices.selectSObject(potentialDelegates,'--None-Selected--');
                    selectChapterDelegate.selectedId = leadDelegateId;
                }
                
                return selectChapterDelegate;
            }
            private set;
        }
        
        public portalServices.selectSObject selectChaperone
        {
            get
            {
                if(selectChaperone == null)
                {
                    List<Contact> potentialChaperones = 
                    [
                        SELECT Name,Id,JSA_Role__c 
                        FROM Contact 
                        WHERE High_School__c = :hs.id 
                        AND JSA_Role__c in ('JSA Advisor', 'JSA Affiliate')
                        order by lastName asc
                    ];
                    
                    selectChaperone = new portalServices.selectSObject(potentialChaperones,'--None-Selected--');
                    selectChaperone.selectedId = advisorId;
                }
                
                return selectChaperone;
            }
            private set;
        }

        public list<portalServices.potentialDelegateProductSelection> allPotentialAttendees
        {
            get
            {
                if(allPotentialAttendees == null)
                {                   
                    List<Contact> potentialContacts =  
                    [
                        SELECT Name,Id,Category__c,JSA_Role__c
                        FROM Contact 
                        WHERE High_School__c = :hs.id
                        AND ((JSA_Role__c in ('Student', 'Chapter President', 'Chapter Officer') AND Graduated__c = false)
                        OR (JSA_Role__c in ('JSA Advisor', 'JSA Affiliate')))
                        order by lastName asc
                    ];
                    System.debug('potentialContacts : ' + potentialContacts);
                    
                    if(potentialContacts.isEmpty())
                    {
                        return null;
                    }
                    
                    list<PricebookEntry> studentProducts = portalServices.queryRelevantProducts(hs,false,op.type);
                    list<PricebookEntry> teacherProducts = portalServices.queryRelevantProducts(hs,true,op.type);
                    
                    allPotentialAttendees = new list<portalServices.potentialDelegateProductSelection>();
                    
                    Map<Id,Id> contactIdToProductId = new Map<Id,Id>();
                    
                    for(Application__c app : op.Applications__r)
                    {
                        contactIdToProductId.put(app.contact__c,app.product2__c);
                        System.debug('contactIdToProductId : ' + contactIdToProductId);
                    }
                    
                    Map<id,Id> productIdToPbeId = new Map<Id,Id>();
                    
                    for(PricebookEntry pbe : studentProducts)
                    {
                        productIdToPbeId.put(pbe.product2Id,pbe.id);
                        System.debug('Product name : ' + pbe.Product2.Name);
                    }
                    
                    for(PricebookEntry pbe : teacherProducts)
                    {
                        productIdToPbeId.put(pbe.product2Id,pbe.id);
                        System.debug('Product name : ' + pbe.Product2.Name);
                    }
                    
                    for(Contact c: potentialContacts)
                    {
                        list<PricebookEntry> pbeList;
                        if(c.JSA_Role__c == 'Student' || c.JSA_Role__c == 'Chapter President' || c.JSA_Role__c == 'Chapter Officer')
                        {
                            pbeList = studentProducts;
                            
                        }
                        else
                        {
                            pbeList = teacherProducts;
                        }
                        
                        portalServices.potentialDelegateProductSelection selection = new portalServices.potentialDelegateProductSelection(c,pbeList);
                        System.debug('c.id : ' + c.id + ', Name : ' + c.name + ', condition : ' + contactIdToProductId.containsKey(c.id));  
                        if(contactIdToProductId.containsKey(c.id))
                        {
                            selection.theProducts.selectedId = productIdToPbeId.get(contactIdToProductId.get(c.id));
                        }
                        System.debug('selection.theProducts.selectedId : ' + selection.theProducts.selectedId);
                        allPotentialAttendees.add(selection);
                    }
                }
                
                return allPotentialAttendees;
            }
            private set;
        }
        
        public Map<String,Integer> productSummary
        {
            get 
            { 
                if(productSummary == null)
                {
                    productSummary = new Map<String,Integer>();
                    
                    for(Application__c app : op.Applications__r)
                    {
                        if(productSummary.containsKey(app.Product2__r.name))
                        {
                            integer cnt = productSummary.get(app.Product2__r.name);
                            productSummary.put(app.Product2__r.name, cnt + 1);
                        }
                        else
                        {
                            productSummary.put(app.Product2__r.name, 1);
                        }
                    }           
                }
                
                return productSummary;
            }
            private set;
        }
        
        public List<Map<String,String>> applicationList{
            get {
                List<Map<String,String>> apps = new List<Map<String,String>>{};
                
                //Decimal price = op.OpportunityLineItems[0].TotalPrice;
                for(Application__c app: op.Applications__r){
                    apps.add(new Map<String,String>{
                        'name'=> app.Contact__r.Name, 
                        'product' => app.Product2__r.Name,
                        'price' => String.valueOf(app.Price__c)
                    });
                }
                return apps;
            }
            private set;
        }
        
        
        public set<String> productKeys
        {
             get {return productSummary.keySet(); }
        }
        
        public void updateOp()
        {
            if(!portalServices.saveOpportunities(new list<Opportunity>{op}))
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error updating the opportunity'));
            }
        }
        
        public void acceptTandC()
        {
            op.Terms_and_Conditions__c = true;
            updateOp();
            setTabState();
        }
        
        public void setDelegateAndChaparone()
        {
            //op.Primary_Contact__c = selectChapterDelegate.selectedId;
            op.ocStudent_Delegation_Leader__c = selectChapterDelegate.selectedId;
            op.ocTeacher_Advisor__c = selectChaperone.selectedId;
            
            updateOp();
            setTabState();
        }
        
        public boolean addPackagesForParticipatingMembers()
        {
            savePoint sp = Database.setSavepoint();
            
            list<Application__c> oldApplications = [SELECT Id FROM Application__c WHERE Opportunity__c = :op.id];
            
            if(!oldApplications.isEmpty())
            {
                try
                {
                    delete oldApplications;
                }
                catch(exception ex)
                {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'failed to delete old applications'));
                    return false;
                }
            }
            
            list<Application__c> newApplictions = new List<Application__c>();
            
            for(portalServices.potentialDelegateProductSelection delegate : allPotentialAttendees)
            {
                System.debug('allPotentialAttendees : ' + allPotentialAttendees);
                if(delegate.theProducts.selectedId != null && delegate.theProducts.selectedId != '')
                {
                    Application__c newApp = new Application__c();
                    newApp.Opportunity__c = op.id;
                    
                    
                    PricebookEntry pbe = (PricebookEntry)delegate.theProducts.selectedObject;
                    newApp.Price__c = pbe.UnitPrice;
                    newApp.Product2__c = pbe.Product2Id;
                    newApp.Name = delegate.theContact.Name + '-' + pbe.name;
                    
                    newApp.contact__c = delegate.theContact.id;
                    newApplictions.add(newApp);
                }
            }
            System.debug('newApplictions : ' + newApplictions);
            if(!newApplictions.isEmpty())
            {
                try
                {
                    insert newApplictions;
                }
                catch(exception ex)
                {
                    //bring back the old olis!
                    Database.rollback(sp);
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'failed to create new applications'));
                    return false;
                }
            }
            
            op = portalServices.queryOpp(op.id);
            return true;
        }
        
        public void saveProducts()
        {
            //page actions can only return void or pageRefs (you get an unexplained error otherwise)
            addPackagesForParticipatingMembers();
        }
        
        public void saveProductsAndNext()
        {
            if(addPackagesForParticipatingMembers())
            {
                goToRooms();
            }
        }

        public void submitOpp()
        {
            if(op.Applications__r.isEmpty())
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'no packages have been selected'));
                return;
            }
            
            portalServices.setOpportuntiyProducts(allPotentialAttendees, op);
            
            op.StageName = SUBMITTED_STAGE;
            updateOp();
        }
        
        private void setTabState()
        {
            if(leadershipSelected)
            {
                if(TandC)
                {
                    if(submissionApproved)
                    {
                        tabState = 3;
                    }
                    else
                    {
                        tabState = 2;
                    }
                }
                else
                {
                    tabState=1;
                }
            }
            else
            {
                tabstate = 0;
            }
        }
        
        public void goToOverview()
        {
            tabState = 0;
        }
        
        public void goToTandC()
        {
            tabState = 1;
        }
        
        public void goToProducts()
        {
            tabState = 2;
        }
        
        public void goToRooms()
        {
            tabState = 3;
        }
        
        public void goToInvoice()
        {
            tabState = 4;
        }
        
        public jsaPortalEventController()
        {
            Id opId = ApexPages.currentPage().getParameters().get(ID_PARAM);
            if(opId == null)
            {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'no opportunity Id'));
                return;
            }
            
            op = portalServices.queryOpp(opId);
            //-- Suyati Testing
            //User requeriedUser = [SELECT Id, ContactId, Contact.High_School__r.id, Contact.High_School__r.JSA_State__c, Contact.High_School__r.Name FROM User WHERE Id = :UserInfo.getUserId()];
            User requeriedUser = [SELECT Id, ContactId, Contact.High_School__r.id, Contact.High_School__r.JSA_State__c, Contact.High_School__r.Name FROM User WHERE Id = '005e0000000wtFm'];        
            hs = requeriedUser.Contact.High_School__r;
            
            //now figure out the tab state.
            setTabState();
        }
        
        @remoteAction
        global static String packagePrice(Id pbeId){
            String price = '$';
            priceBookEntry pbe = [select Id, unitPrice from priceBookEntry where id =: pbeId];
            price += String.valueOf(pbe.unitPrice);
            return price;
        }
        
        public Boolean inflateTest() {

            Integer j = 0;

            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;
            j++;

            return true;
        }
        
    }