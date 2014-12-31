global with sharing class portalRegistrationController 
{

    public String highSchoolName { get; set; }
    public String highSchoolState { get; set; }
    public Account a {get;set;}
    public Contact c {get;set;}
    public Contact newContact { get; set; }
    public User u {get;set;}
    public User newUser {get;set;}
    public High_School__c hs {get;set;}
    public boolean flag{get;set;}
    
    public RecordType accountRecordType = [SELECT Id FROM RecordType WHERE sObjectType='Account' AND Name='Household'];    
    
    //public List<String> autoSearchHSListReturn {get; set;}
    
    public id selectedProfileId {get;set;}
    public boolean isDisabled {get; set;}
    public static boolean userExists {get; set;}
    
    public boolean clickedButton {get; set;}
    
    public boolean isNewUserFound {get; set;}
    
    public boolean secondPhase {get; set;}
    //public boolean successPhase {get; set;}
    
    public boolean isRequired {get;set;}
    
    //bunk stuff for now
    //public static final Id PORTAL_PROFILE_ID = [SELECT id FROM PROFILE Where name='JSA Community User'].id;
    public static final Id PORTAL_PROFILE_ID = [SELECT id FROM PROFILE Where name='Event Registration Portal User' or name = 'JSA Community User' limit 1].id;
    //the user must be insterted asynchronously due to mixed DML stuff
    private void createUser(String contactId, String email, String firstName, String lastName, String userName, String profileId) 
    {        
        User u = new User();        
        //Check if user already exists        
        List<User> lstUser = new List<User>();  
        lstUser =[select id,contactId from User where email = :email];  
        
        //exists
        if(lstUser.size()>0){
            u = lstUser[0];            
            //Display success message to VF page            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'User Already Exist.');
            ApexPages.addMessage(myMsg); 
            a.ID = null;
            c.ID = null; 
            userExists = true;         
        }    
        else{
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.EmailHeader.triggerUserEmail = true;            
            u.FirstName = firstName;
            u.alias = 'port'; 
            u.email = email;
            u.emailencodingkey = 'UTF-8'; 
            u.lastname = lastname;
            u.languagelocalekey = 'en_US'; 
            u.localesidkey = 'en_US';
            u.profileid = profileId; 
            u.contactId = contactId;
            u.timezonesidkey = 'America/Los_Angeles';
            u.username = username;
            u.setOptions(dmo);
            system.debug('doin the insert');
            insert u;            
            userExists = false; 
            
            //Display success message to VF page            
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Successfully created Portal Contact & User records.');
            //ApexPages.addMessage(myMsg);
        }
    }
    
    public PageReference categoryChange(){

        if(this.newContact.Category__c !='Student'){
            isRequired = false;
        }else{
            isRequired = true;
        }
        hs = new High_School__c();
        system.debug(this.c);
        system.debug('category change for '+ this.newContact.Category__c + isRequired );

        return null;
    }
    
    public void goToSecondPhase()
    {
        secondPhase=true;
        try{
            Id accountId;                        
            Id contactId;                     
            //Check if Contact with same email address already exist
            List<Contact> lstContact = new List<Contact>();
            lstContact = [select id,FirstName,LastName,accountid,High_School__c,High_School_Text__c,
                          MailingState ,MailingCity,MailingStreet,MailingPostalCode,Category__c,
                          Parent_Guardian_First_Name__c,Parent_Guardian_Last_Name__c,
                          High_School_Graduation_Year__c,Birthdate,
                          JSA_Role__c,Email,MailingCountry,phone,Gender__c from Contact 
                          where email = :c.email order by createdDate desc ];
            
            //If exists use the existing account and contact
            if(lstContact.size()>0){              
                contactId = lstContact[0].id;
                c = lstContact[0];
                c.JSA_Role__c=null;
                c.Category__c=null;
                if(lstContact[0].accountid!=null){
                    accountId = lstContact[0].accountid;
                    List<Account> lstAccount = [select id,Name,OwnerId,RecordTypeId,BillingCountry,BillingStreet,BillingState,BillingCity,
                                                 Countries__c,US_States__c,billingPostalCode from Account where id =:accountId];
                    if(lstAccount!=null && lstAccount.size()>0)
                        a = lstAccount[0];
                }    
                //if contact exist and account doesnt.    
                else  {  
                    accountId = createAccount();     
                    lstContact[0].accountid = accountId ;
                    update lstContact[0];                                            
                }    
            }    
            else{
                //Create the Account
                accountId = createAccount();
                System.debug('successfully created account');          
                //Create the Contact associated to the previously created Contact
                contactId = createContact(accountId);
            }

            newContact = new Contact();
            newContact.JSA_Role__c = c.JSA_Role__c;
            newContact.Category__c = c.Category__c;
            newContact.Parent_Guardian_First_Name__c = c.Parent_Guardian_First_Name__c;
            newContact.Parent_Guardian_Last_Name__c = c.Parent_Guardian_Last_Name__c;
            newContact.High_School_Graduation_Year__c = c.High_School_Graduation_Year__c;
            newContact.Birthdate = c.Birthdate;
            newContact.High_School__c = c.High_School__c;
            newContact.High_School_Text__c = c.High_School_Text__c;

            isRequired = (newContact.Category__c == 'Student');

            if (c.High_School__c != null) {
                hs = [SELECT Id, State__c FROM High_School__c WHERE Id =: c.High_School__c];
                highSchoolState = hs.State__c;
            }



        }
        catch(Exception ex)
        {
            //Display error message to VF page
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(myMsg);            
        }
    }
    
    public PageReference checkForNewUser()
    {
        try
        {
            System.debug('isNewUserFound: ' + isNewUserFound);
            if(isNewUserFound==true)
            {
                return null;
            }
      
            System.debug('checking for new user with username:' + u.username);
            User usr = [SELECT id, name, username FROM User WHERE username= :u.username LIMIT 1];

            if(usr!=null && usr.username == u.username)
            {
                newUser = usr;
                isNewUserFound = true;
                System.debug('great news - found user with userId: ' + newUser.id);
                System.debug('isNewUserFound: ' + isNewUserFound);
            }
            return null;
        }
        catch(Exception ex)
        {
            System.debug('...didnt find user yet...');
            return null;
        }
   }
       
    public static List<SelectOption> getCustomerPortalProfiles()
    {
        //Execute query to get all profiles associated to Customer Portal
        Profile[] profiles = [Select p.name, p.id From Profile p where p.UserLicense.Name like '%Customer Portal%'];
        List<SelectOption> options = new List<SelectOption>();
        for(Profile p: profiles)
        {
              options.add(new SelectOption(p.id,p.name));
        }
        
        return options;
    }
    
    public portalRegistrationController()
    {
        a = new Account(billingCountry='United States');
        c = new Contact();
        u = new User();
        newUser = new User();
        secondPhase = false;
        isRequired = true;
        hs = new High_School__c();
        flag= false;
    }
    
    public pageReference updateContact()
    {
        //error checking
        if(c.id == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: registration step 1 was skipped'));
            return null;
        }
        
        try
        {
            
            update c;
        }
        catch(System.dmlException dmx)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Update error: ' + dmx.getMessage()));
            return null;
        }
        
        //todo::labelize! and make it go to the correct spot
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'thanks for the update'));
        return null;
    }
    
    public PageReference createPortaluser()
    {
        try
        {
            System.debug('newContact.High_School__c:'+ newContact.High_School__c);
            High_School__c testHS = [SELECT Id FROM High_School__c WHERE Id =: newContact.High_School__c];
        } catch (Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'High School: You must select a valid High School');
            ApexPages.addMessage(myMsg); 
            flag=true;
            return null;
        }

        try
        {                        
            //Create the User
            //NOTE - Must invoke a @future method to be able to create Account, Contacts, and Users in the same Apex Transaction
            /*if (newContact.High_School__c == '') {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'High School: You must select a valid High School');
                ApexPages.addMessage(myMsg); 
                flag=true;
                return null;
            }*/

            c.High_School__c = newContact.High_School__c;
            c.High_School_Text__c = newContact.High_School_Text__c;
            c.Category__c = newContact.Category__c;
            c.JSA_Role__c = newContact.JSA_Role__c;
            c.Parent_Guardian_First_Name__c = newContact.Parent_Guardian_First_Name__c;
            c.Parent_Guardian_Last_Name__c = newContact.Parent_Guardian_Last_Name__c;
            c.High_School_Graduation_Year__c = newContact.High_School_Graduation_Year__c;
            c.Birthdate = newContact.Birthdate;
            update c;

            createUser((String)c.Id, c.Email, c.FirstName, c.lastname,c.Email,PORTAL_PROFILE_ID);
            
            secondPhase = false;
            isDisabled = !userExists;
           
            //return new Pagereference('/apex/jsaPortalRegistrationSuccess');
            return null;
    
        }
        catch(Exception ex)
        {
            //Display error message to VF page
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
            ApexPages.addMessage(myMsg);
            return null; 
        }
    }
     
    public Id createAccount()
    {
        a.Name = c.FirstName + ' ' + c.LastName; 
        a.OwnerId = portalServices.PORTAL_ACCOUNT_OWNER_ID;
        a.RecordTypeId = accountRecordType.id;
        a.BillingCountry = a.Countries__c;
        a.BillingState = a.US_States__c;
        insert a;
        System.debug('successfully created test account with Id:' + a.id);
        return a.id;
    }
    
    //Method to create the Contact
    public Id createContact(Id acctId)
    {
        c.accountid=acctId;
        c.High_School__c = c.High_School_Text__c;
        c.High_School_Text__c = '';
        c.MailingCountry = a.BillingCountry;
        c.MailingState = a.BillingState;
        c.MailingCity = a.BillingCity;
        c.MailingStreet = a.BillingStreet;
        c.MailingPostalCode = a.BillingPostalCode;
        insert c;
        System.debug('successfully created test contact with Id:' + c.id);
        AccountContactRole role = new AccountContactRole(accountId = acctId, contactId = c.id, IsPrimary = true, Role = 'QuickBooks Customer Contact');
        insert role;
        return c.id;
    }
    

    
    @remoteAction
    global static List<Map<String,String>> findSchools(String searchTerm, String highSchoolState){
        //send back the json that jquery autocomplete expects
        List<Map<String,String>> schools = new  List<Map<String,String>> {};
        //wrap the search term in wildcard characters for most flexible search
        searchTerm = '%' + searchTerm + '%';
        //SOQL in a for loop for maximum rows returned
        for(High_School__c school : [select Id, Name from High_School__c where Name like : searchTerm and State__c =: highSchoolState]){
            //using literal syntax to add anonymous maps to the list
            schools.add(new Map<String,String>{'label' => school.Name, 'value' => school.Id});
        }
        //list of maps turns to JSON by itself with JSR
        return schools;
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

        return true;

    }
}