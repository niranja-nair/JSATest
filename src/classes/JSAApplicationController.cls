global without sharing class JSAApplicationController {
    
    public static final string ID_PARAM = 'opId';
    
         public String  OrientationGuide
    {
        get
        {
            if(OrientationGuide == null) {
                OrientationGuide = op.Orientation_Guide__c;
            }
            return OrientationGuide;
        }
        set;
    }
    
             public String  MakeAPaymentLink
    {
        get
        {
            if(MakeAPaymentLink == null) {
                MakeAPaymentLink = op.make_a_payment__c;
            }
            return MakeAPaymentLink;
        }
        set;
    }
    
         public String  OnlinePaymentLink
    {
        get
        {
            if(OnlinePaymentLink == null) {
                OnlinePaymentLink = op.Online_Payment_Link__c;
            }
            return OnlinePaymentLink;
        }
        set;
    }
    
    /* Adding checkbox for online invoice question on summer ops */
    public boolean IsInvoiceNeeded {
        get {
            if(IsInvoiceNeeded == null) {
                IsInvoiceNeeded = op.Send_Online_Invoice__c;
            }
            return IsInvoiceNeeded;
        }
        set;
    }
    
    public PaymentWrapper PaymentDetails {
        get{ 
            if(PaymentDetails != null) {
                PaymentDetails = new PaymentWrapper(InvoiceNumbers);
            }
            
            return PaymentDetails;
        }
        set;
    }
        
    public Contact contact { get;set;}
    
    public Opportunity op 
    {
        get {
            if(op == null) {
                op = portalServices.queryOppForAppl(opIdParam);
            }
            return op;
        }
        private set;
    }
    
    public String opName
    {
        get { return op.Name; }
    }   
    
    public String opId
    {
        get { return op.Id; }
    }
    
    public String ApplicationType {get;set;} 
    
    public boolean IsSSApplication
    {
        get { return (ApplicationType == 'SS'); }       
    }
    
    public boolean IsSympApplication
    {
        get { return (ApplicationType == 'Symp'); }
    }
    
    //-- Suyati Modified - 25/Nov/2014
    //-- Declared variable for HonorStudentCode
    public String HonorStudentCode 
    {   
        get { 
                if(String.isblank(HonorStudentCode)) {
                    HonorStudentCode = op.Honor_Student_Code__c; 
                }
                return HonorStudentCode; 
        }
        set;
    }
    
    public String RefTeacherName
    {       
        get { 
                if(String.isblank(RefTeacherName)) {
                    RefTeacherName = op.Reference_Teacher_Name__c; 
                }
                return RefTeacherName; 
        }
        set ;
    }
    
    public String RefTeacherEmail
    {
        get {
            if(RefTeacherEmail == null) {
                RefTeacherEmail = op.Reference_Teacher_Email__c;
            }
            return RefTeacherEmail ; 
        }
        set;
    }
    
    public String RefTeacherPhone
    {
        get { 
            if(RefTeacherPhone == null) {
                RefTeacherPhone = op.Reference_Teacher_Phone__c;
            }
            return RefTeacherPhone;
        }
        set;
    }
    
    public String extracurricularActivities
    {
        get { 
            if(extracurricularActivities == null) {
                extracurricularActivities = op.Extracurricular_Activities__c; 
            }
            return extracurricularActivities; 
        }
        set;
    }
    
    public String personalEssay
    {
        get {
            if(personalEssay == null) {
                personalEssay = op.Personal_Essay__c;
            }
            return personalEssay ; 
        }
        set;
    }
    
    public String LeadershipPositions
    {
        get {
            if(LeadershipPositions == null) {
                LeadershipPositions = op.symLeadership_Positions__c;
            }
            return LeadershipPositions;
        }
        set;
    }
    
    public string MostImportantIssue
    {
        get
        {
            if(MostImportantIssue == null) {
                MostImportantIssue = op.symMost_Important_Issue__c;
            }
            return MostImportantIssue;          
        }
        set;
    }
    
    public String TotalAmount
    {
        get
        {
            if(TotalAmount == null) {
                TotalAmount = String.valueof(op.Amount);
            }
            return TotalAmount;
        }
        set;
    }
    
    public String  SalesOrderNumber
    {
        get
        {
            if(SalesOrderNumber == null) {
                SalesOrderNumber = op.Order_Number__c;
            }
            return SalesOrderNumber;
        }
        set;
    }
    
    public string OppInvoiceNumber
    {
        get
        {
            if(OppInvoiceNumber == null) {
                  if(invoices.size()>0 ) {
                    OppInvoiceNumber = invoices[0].Name;
                  }
                  else {
                    OppInvoiceNumber = 'N/A';
                  }
            }
            return OppInvoiceNumber;
        }
        set;
    }
    
    public String TotalBalance
    {
        get
        {
            if(TotalBalance == null) {
                if(invoices.size() > 0) {
                    TotalBalance = string.valueof(invoices[0].Remaining_Balance__c);
                }
                else {
                    TotalBalance = 'N/A';
                }
            }
            return TotalBalance;
        }
        private set;
    }
    
    public List<String> InvoiceNumbers
    {
        get
        {
            if(InvoiceNumbers == null) {
                InvoiceNumbers = new List<String>();
                for(QB_Invoice__c inv : invoices) {
                    InvoiceNumbers.add(inv.Id);
                }
            }
            return InvoiceNumbers;
        }
        private set;
    }
    
    public List<QB_Invoice__c> invoices
    {
        get
        {
            if(invoices == null) {
                invoices = portalServices.getOppsQuickbookInvoices(opIdparam);
            }
            return invoices;
        }
        set;
    }
    
   
    
    public String SelectedSession
    {
        get { 
            if(SelectedSession == null) {
                List<Product2> prods =  [Select ProductCode  From Product2 where Name = :op.Campus_Session__c LIMIT 1];
                if(prods != null && prods.size() > 0) {
                    SelectedSession = prods[0].ProductCode;
                }
            }           
            return SelectedSession;
        }
        set;
    }
    
    public List<SelectOption> SSSessionOptions
    {
        get {
            if(SSSessionOptions == null) {
                SSSessionOptions = portalServices.getSSSessions();
                system.debug('result from portal services is null?' + (SSSessionOptions == null));
            }
            return SSSessionOptions;
        }
        set;
    }
    
    public List<SelectOption> SympSessionOptions
    {
        get {
            if(SympSessionOptions == null) {
                SympSessionOptions = portalServices.getSymposiumSessions();
                system.debug('are symp session options null? ' + (SympSessionOptions == null));
                system.debug('symp sessions size is: ' + SympSessionOptions.size());
            }
            return SympSessionOptions;
        }
        set;
    }
    
    public Map<string,string> SSSessionMap
    {       
        get {
            if(SSSessionMap == null) {
                string SummerSchoolPBId = portalServices.queryProductIdByName('Summer School'); 
                SSSessionMap = portalServices.getSessionMap(SummerSchoolPBId);
                system.debug('SS session mao is null? ' + (SSSessionMap == null));
                system.debug('SS session map size is:' + SSSessionMap.size());
            }
            return SSSessionMap;
        }
        private set;
    }
    
   public String SelectedSecondChoice
    {
        get { 
            if(SelectedSecondChoice == null) {
                if(!String.isblank(op.Second_Choice__c)) {
                    Product2 prod =  [Select ProductCode  From Product2 where Name = :op.Second_Choice__c LIMIT 1];
                    if(prod != null) {
                        SelectedSecondChoice = prod.ProductCode;
                    }
                }
            }           
            return SelectedSecondChoice; 
        }
        set;            
    }
         
   public List<SelectOption> SSCourses
    {
        get{
            if(IsSSApplication) {
                if(SSCourses == null) {
                    SSCourses = portalServices.fetchSSCourses(SelectedSession);
                }
                else if(SSCourses.size() == 0) {                
                    SSCourses.add(new SelectOption('None',' --Select One-- '));
                }
            }
            return SSCourses;
        }
        set;
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
   
   public string SelectedSSRefSource
   {
        get { if(SelectedSSRefSource == null) { SelectedSSRefSource = op.How_did_you_learn_about_us__c; } return SelectedSSRefSource; }
        set;
   } 
   
   public String SelectedSSCourse
   {
         get {  
            if(SelectedSSCourse == null) {
                SelectedSSCourse =  op.Course_A__c;
            } 
            return SelectedSSCourse;            
         }
         set;
   }  
    
    public Set<String> OverviewContentKeys
    {
        get {
            if(OverviewContentKeys == null ) {
                OverviewContentKeys = new Set<String>();
                OverviewContentKeys.add('Personal Data Complete?');
                If(IsSSApplication) {
                    OverviewContentKeys.add('Recommendation Section Complete?');
                }
                If(IsSSApplication) {
                    OverviewContentKeys.add('Teacher Recommendation Status?');
                }
                If(IsSSApplication) {
                    OverviewContentKeys.add('Transcript Status?');
                }
                OverviewContentKeys.add('Essay Status?');
                If(IsSSApplication) {
                    OverviewContentKeys.add('Scholarship Status?');
                    /* OverviewContentKeys.add('Need scholarship / fundraising packet?'); */
                }
                OverviewContentKeys.add('Acceptance Status');
            }
            return OverviewContentKeys;
        }
        private set;
    }
    
    public Map<String,String> OverviewContent
    {
        get { 
            if(OverviewContent == null) {
                
                OverviewContent = new Map<String,String>();
                if(!string.isBlank(op.Personal_Data_Complete__c)) {
                    OverviewContent.put('Personal Data Complete?',string.valueof(op.Personal_Data_Complete__c));
                }
                else {
                    OverviewContent.put('Personal Data Complete?', 'Incomplete');
                }
                if(!String.IsBlank(op.Academics_Complete__c)) {
                    OverviewContent.put('Recommendation Section Complete?', op.Academics_Complete__c);
                }
                else {
                    OverviewContent.put('Recommendation Section Complete?', 'Incomplete');
                }
                if(!String.isblank(op.Teacher_recommendation_letter__c)){
                OverviewContent.put('Teacher Recommendation Status?',op.Teacher_recommendation_letter__c);
                }
                else {
                    OverviewContent.put('Teacher Recommendation Status?', 'Requested');
                }               
                
                if(IsSSApplication) {
                    
                    if(!String.isblank(op.Transcript_Status__c)) {
                        OverviewContent.put('Transcript Status?', op.Transcript_Status__c);
                    }
                    else {
                        OverviewContent.put('Transcript Status?', 'Requested');
                    }
                }
                if(!String.isblank(op.Personal_Essay_Status__c)) {
                    OverviewContent.put('Essay Status?',op.Personal_Essay_Status__c);
                }
                else {
                    OverviewContent.put('Essay Status?', 'None');
                }
                if(IsSSApplication) {   
                    if(!String.IsBlank(op.Scholarship_Status__C)) {
                        OverviewContent.put('Scholarship Status?',op.Scholarship_Status__c);
                    }
                    else {
                        OverviewContent.put('Scholarship Status?','Not Applicable');
                    }
                    
                    if(op.Need_scholarship_fundraising_packet__c != null) {
                        OverviewContent.put('Need scholarship / fundraising packet?',string.valueof(op.Need_scholarship_fundraising_packet__c));
                    }
                    else {
                        OverviewContent.put('Need scholarship / fundraising packet?','Not Applicable');
                    }
                }               
                if(!string.isBlank(op.Acceptance_Status__c))  {             
                    OverviewContent.put('Acceptance Status',string.valueof(op.Acceptance_Status__c));
                }   
            }
            return OverviewContent; 
        }
        set;
    }
    
    public string opIdparam {get;set;}     
    
    public String highSchoolState {get; set;}
    
    public String HighSchoolText {get;set;} 
    
    public String HighSchool {get;set;}
    
    public List<SelectOption> highSchoolStateOptions {
        get {
            if (highSchoolStateOptions == null) {
                highSchoolStateOptions = new List<SelectOption>();
                
                Set<String> states = new Set<String>();
                
                for (High_School__c highSchool : [select State__c from High_School__c where State__c != null]) {
                    states.add(highSchool.State__c);
                }
                
                List<String> stateList = new List<String>();
                stateList.addAll(states);
                stateList.sort();
                
                for (String state : stateList) {
                    highSchoolStateOptions.add(new SelectOption(state, state));
                }
            }

            return highSchoolStateOptions;
        }
        
        private set;
    }
    
    public PageReference SaveOpp()
    {
        
        try {           
            Opportunity opp = [select Id from Opportunity where Id =: opId];
            opp.Current_Secondary_School__c = highSchoolText;
            //-- Suyati Modified - 25/Nov/2014
            //-- Assigned user assigned value to HonorStudentCode
            opp.Honor_Student_Code__c = HonorStudentCode;
            opp.Reference_Teacher_Name__c = refTeacherName;
            system.debug('teacher name is:' + refTeacherName);
            opp.Reference_Teacher_Email__c = refTeacherEmail;
            opp.Reference_Teacher_Phone__c = refTeacherPhone;
            opp.Send_Online_Invoice__c = IsInvoiceNeeded;
            if(IsSSApplication) {
                opp.Extracurricular_Activities__c = extracurricularActivities;
                opp.Personal_Essay__c = personalEssay;
                opp.Second_Choice__c = SSSessionMap.get(SelectedSecondChoice);          
                opp.Course_A__c = SelectedSSCourse;   
            }
            else {
                opp.symLeadership_Positions__c = LeadershipPositions;
                opp.symMost_Important_Issue__c = MostImportantIssue;
            }
                
            opp.How_did_you_learn_about_us__c = SelectedSSRefSource;
            
            update opp;
            
            return new PageReference('/apex/JSAeventSummary');        
        }
        catch(Exception e) {
             ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
             return null;
        }
    }
    
    public PageReference Submit()
    {
        try {           
            system.debug('inside submit');
            Opportunity opp = [select Id from Opportunity where Id =: opId];
            opp.Current_Secondary_School__c = highSchoolText;
            //-- Suyati Modified - 25/Nov/2014
            //-- Assigned user assigned value to HonorStudentCode
            opp.Honor_Student_Code__c = HonorStudentCode;
            opp.Reference_Teacher_Name__c = RefTeacherName;
            system.debug('teacher name is:' + refTeacherName);
            opp.Reference_Teacher_Email__c = refTeacherEmail;
            system.debug('teacher email is:' + refTeacherEmail );
            opp.Reference_Teacher_Phone__c = refTeacherPhone;
            system.debug('teacher phone is:'+ refTeacherPhone);
            opp.Send_Online_Invoice__c = IsInvoiceNeeded;
            if(IsSSApplication) {
                opp.Extracurricular_Activities__c = extracurricularActivities;
                opp.Personal_Essay__c = personalEssay;
                opp.Second_Choice__c = SSSessionMap.get(SelectedSecondChoice);          
                opp.Course_A__c = SelectedSSCourse;   
            }
            else {
                opp.symLeadership_Positions__c = LeadershipPositions;
                opp.symMost_Important_Issue__c = MostImportantIssue;
            }               
            opp.How_did_you_learn_about_us__c = SelectedSSRefSource;
            system.debug('referral source: ' + SelectedSSRefSource );
            opp.Application_Submitted__c = true;
            update opp;
            SubmittedForApproval = true; 
            return null; 
            //return new PageReference('/apex/myJSAeventSummary');      
        }
        catch(Exception e) {
            system.debug('exception occured:' + e.getMessage());
             ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
             return null;
        }   
    }
    
    public boolean SubmittedForApproval {get;set;}
    
    public boolean Submitted
    {
        get {
            if(Submitted == null) {
                Submitted = (op.StageName == 'C: Complete');
            }
            return Submitted;
        }
        private set;
    }
    
    
    public jsaApplicationController()
    {
        Id opId = ApexPages.currentPage().getParameters().get(ID_PARAM);
        system.debug('inside constructor. opp id is' + opId);
        ApplicationType =  ApexPages.currentPage().getParameters().get('ApplicationType');
        
        
        if(opId == null)
        {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'no opportunity Id'));
            return;
        }        
        opIdParam = opId;
        op = portalServices.queryOppforAppl(opId);
        
        Id contactId = [select ContactId from User where Id = :UserInfo.getUserId()].ContactId; 
        contact = [select High_School__c , High_School_Text__c
                   from Contact
                   where Id = :contactId];
        
        if (contact.High_School__c != null) {
            High_School__c hs = [select Id, Name, State__c from High_School__c where Id = :contact.High_School__c];
            highSchoolState = hs.State__c;
            highSchoolText = hs.Name;
            highSchool = hs.Id;
        }
        
        PaymentDetails = new PaymentWrapper(InvoiceNumbers);        
    }
    
    @remoteAction
    global static List<Map<String,String>> findSchools(String searchTerm, String highSchoolState){
        //send back the json that jquery autocomplete expects
        List<Map<String,String>> schools = new  List<Map<String,String>> {};
        //wrap the search term in wildcard characters for most flexible search
        searchTerm = '%' + searchTerm + '%';
        //SOQL in a for loop for maximum rows returned
        for(High_School__c school : [select Id, Name from High_School__c where Name like : searchTerm and State__c =: highSchoolState order by Name]){
            //using literal syntax to add anonymous maps to the list
            schools.add(new Map<String,String>{'label' => school.Name, 'value' => school.Id});
        }
        //list of maps turns to JSON by itself with JSR
        return schools;
    }
    
    
    public class QBPayment
    {
            public string Id {get;set;}
            public string PaymentMethod {get;set;}
            public string PaymentDate{get;set;}
            public decimal PaymentAmount {get;set;}
            
            public QBPayment(string pmtId, string pmtMethod, datetime pmtDate, decimal pmtAmount) {
                Id = pmtId;
                PaymentMethod = pmtMethod;
                PaymentDate = string.Valueof(pmtDate.date());
                PaymentAmount = pmtAmount;
            }
    }
    
    public class QBCreditMemoLineItem
    {
            public string CreditMemoNumbersDate {get;set;}
            public string LineDescription{get;set;}
            public decimal LineAmount{get;set;}
            
            public QBCreditMemoLineItem(datetime memodate, string description, decimal amount) {
                CreditMemoNumbersDate = string.ValueOf(memodate.date());
                LineDescription = description;
                LineAmount = amount;
            }
    }
    
    public class PaymentWrapper
    {
        public List<String> InvoiceNumbers {get;set;}
        
         public List<QBPayment> QuickbookPayments
         {
            get
            {
                if(QuickbookPayments == null) {
                    QuickbookPayments = new List<QBPayment>();
                    List<QB_Payment__c> payments = [select Payment_Method__c, Payment_Date__c, Payment_Amount__c, Id
                                                    from QB_Payment__c where Invoice_Number__C in : InvoiceNumbers];
                    
                    if(payments != null) {
                        for(QB_Payment__c pmt : payments) {
                            QuickbookPayments.add(new QBPayment(pmt.Id, pmt.Payment_Method__c, pmt.Payment_Date__c, pmt.Payment_Amount__c));
                        }
                    }       
                }
                return QuickbookPayments;           
            }
            private set;
        }
        
        public List<Id> QBCreditMemos
        {
            get
            {
                if(QBCreditMemos == null) {
                    if(invoiceNumbers != null) {
                        List<QB_Credit_Memo__c> memos = [select Id from QB_Credit_Memo__c where Invoice_Number__c in :InvoiceNumbers];
                        if(memos != null && memos.size() > 0) {
                            QBCreditMemos = new List<Id>();
                            for(QB_Credit_Memo__c mem : memos) {
                                QBCreditMemos.add(mem.Id);
                            }
                        }
                    }
                }
                
                return QBCreditMemos;
            }
            private set;
        }
        
        public List<QBCreditMemoLineItem> QBCreditMemoLineItems
        {
            get
            {
                if(QBCreditMemoLineItems == null) {
                    if(QBCreditMemos != null ) {
                        QBCreditMemoLineItems = new List<QBCreditMemoLineItem>();
                        List<QB_Credit_Memo_Line__c> lineitems = [Select Line_Description__c, Line_Amount__c, Credit_Memo_Number__r.Credit_Memo_Date__c 
                                                From QB_Credit_Memo_Line__c q
                                                where Credit_Memo_Number__c in :QBCreditMemos];
                        if(lineItems != null) {
                            for(QB_Credit_Memo_Line__c li : lineItems) {
                                QBCreditMemoLineItems.add(new QBCreditMemoLineItem(li.Credit_Memo_Number__r.Credit_Memo_Date__c, li.Line_Description__c, li.Line_Amount__c) );  
                            }   
                        }
                    }
                }
                
                return QBCreditMemoLineItems;
            }
            private set;
        }
    
        
        public PaymentWrapper(List<String> invoices) {
            system.debug('inside payment wrapper constructor');
            InvoiceNumbers = invoices;
            system.debug('invoicenumbers size is' + InvoiceNumbers.size());
        }
    }    
}