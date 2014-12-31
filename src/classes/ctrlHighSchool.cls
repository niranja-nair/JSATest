public with sharing class ctrlHighSchool {
    public String strHSSearch {get; set;}
    public String strResult {get; set;}
    public String strHS {get; set;}
    public List<Contact> lstStudents {get; set;}
    public Boolean ShowSearchResults {get; set;}
    public Boolean ShowStudents {get; set;}
    public List<pHS> lstPHS {get; set;}
   
    
    //This method runs when the page is loaded
    public ctrlHighSchool(){
        ShowSearchResults = false;
        //If there's a URL parameter for the school_id
        if (Apexpages.currentpage().getParameters().get('school_id') != null){
                //try loading the students, this will handle incorrect or missing passwords
            LoadStudents();
        } else {
                //if there's a value for the Search, run the search
            if (strHSSearch != null){
                FindHSs();
            }
        }
    }
    
    public PageReference FindHSs() {
        List<High_School__c> lstHS = new List<High_School__c>();
        String strSearch;
        lstPHS = new List<pHS>();
        
        //If there is a search value
        if (strHSSearch != null){
            ShowStudents = false;
            //Wrap search string with wildcard characters
            strSearch = '%' +strHSSearch +'%';
            
            //find the first ten records
            lstHS = [Select Id, Name, State__c, City__c, School_Id__c from High_School__c
                    where Name like :strSearch order by Name Limit 10];
            
            strResult = 'Found ' +lstHS.size();
            if (lstHS.size() > 0){
                //Check if there are more than 10 results by doing the search for 11 (avoids governor limits)
                if ([Select count() from High_School__c where Name like :strSearch Limit 11] == 11){
                    strResult = 'There are more than 10 results for this search, only the first 10 are displayed here.';
                } else {
                    strResult = null;
                }
                
                //Associate HSs with password input
                for (High_School__c h : lstHS){
                    lstPHS.add(new pHS(h));
                }
                
                ShowSearchResults = true;
            } else {
                strResult = 'No results found for this search.';
            }
        } else {
            strResult = 'Please enter a search value.';
        }
        System.debug('End of FindHSs, ShowSearchResults = ' +ShowSearchResults);
        return null;
    }//end FindHS
    
    public PageReference LoadStudents() {
        Id idSchool;
        String strPass;
        System.debug('LoadStudents method, school_id = ' +Apexpages.currentpage().getParameters().get('school_id') +', password = ' +Apexpages.currentpage().getParameters().get('password') );
        //make sure a school was selected
        if (Apexpages.currentpage().getParameters().get('school_id') != null){
            
            //get just this school
            List<High_School__c> lstHS = [Select Id, Name, State__c, City__c, School_Id__c, Report_Password__c from High_School__c
                    where School_Id__c =: Apexpages.currentpage().getParameters().get('school_id') Limit 1];
            
            if (lstHS.size() > 0){
                //If this was called when the page was loaded, this will retrieve the password parameter
                strPass = Apexpages.currentpage().getParameters().get('password');
                
                //Loop through the pHS collection, find the HS that was clicked and get the password entered
                if (lstPHS != null){
                    for (pHS p : lstPHS){
                        if (p.hs.School_ID__c == Apexpages.currentpage().getParameters().get('school_id')){
                            strPass = p.pass;
                        }
                    }
                }
                
                //If there is a password
                if (strPass != null &&strPass != ''){
                    
                    //Make sure it's correct
                    for (High_School__c hs : lstHS){
                        System.debug('Comparing submitted password ' +strPass +' to record password ' +hs.Report_Password__c);
                        if (hs.Report_Password__c != null &&strPass.compareTo(hs.Report_Password__c) == 0){
                            idSchool = hs.Id;
                            //Get the school name while we're at it
                            strHS = hs.Name;
                        }
                    }//end loop (there will be only one)
                    
                    //if the password was correct, get the students
                    if (idSchool != null){
                        lstStudents = [Select FirstName, LastName, Email, High_School_Graduation_Year__c, JSA_Role__c,
                                Member_Status__c, Graduated__c from Contact where High_School__c =: idSchool
                                order by LastName, FirstName];
                        
                        ShowSearchResults = false;
                        ShowStudents = true;
                    } else {
                        //Re-populate the pHS list
                        lstPHS = new List<pHS>();
                        lstPHS.add(new pHS(lstHS[0]));
                        strResult = 'Incorrect password, please retry.';
                        ShowStudents = false;
                        ShowSearchResults = true;
                    }
                } else {
                    System.debug('Blank password.');
                    lstPHS = new List<pHS>();
                    lstPHS.add(new pHS(lstHS[0]));
                    strResult = 'Please enter the report password for this school.';
                    ShowStudents = false;
                    ShowSearchResults = true;
                }//end if password null
            } else {
                strResult = 'This is not a valid School Id, please search for the school.';
                ShowStudents = false;
                ShowSearchResults = true;
            }
        }//end if school_id parameter not null
    
        return null;

    }//end Get Students
    
    //wrapper class to associate password with high schools
    public class pHS{
        public High_School__c hs {get; set;}
        public String pass {get; set;}
        
        //This is the contructor method. When a new pHS object is created, the High_School__c 
        //passed in is set to the hs property. It also sets the pass value to null
        public pHS(High_School__c h){
            hs = h;
            pass = null;
        }
    }
    
    //This method tests the code above
    static testMethod void testHSReport() {
        //Create some test data
        Account a = new Account(
            Name = 'Test acc', 
            BillingStreet = 'Street',
            BillingCity = 'City',
            BillingPostalCode = '10128',
            BillingState = 'New York');
        insert a;
        
        High_School__c h = new High_School__c(
            Name = 'Jessie Test HS', 
            Report_Password__c = 'Test',
            Account__c = a.Id);
        insert h;
        
        //Query so we have the School Id, which is auto-generated.
        h = [Select Id, Name, School_ID__c from High_School__c where Id =: h.Id];
        
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            AccountId = a.Id,
            High_School__c = h.Id);
        insert c;
                
                //Test as if page being called with URL parameters
        System.currentPagereference().getParameters().put('school_id',h.School_Id__c);
        //WRONG PASSWORD TEST
        System.currentPagereference().getParameters().put('password','BadTest');
        
        ctrlHighSchool ctrl = new ctrlHighSchool();

        //This shouldn't have loaded any students since it's the wrong password
        System.assertEquals(null, ctrl.lstStudents);
        
        //Clear the list of HSs, otherwise the code tries to get the password from here
        ctrl.lstPHS.clear();
        
        //BLANK PASSWORD TEST
        System.currentPagereference().getParameters().put('password','');
        
        ctrl.LoadStudents();

        //This shouldn't have loaded any students 
        System.assertEquals(null, ctrl.lstStudents);
        
        //Clear the list of HSs, otherwise the code tries to get the password from here
        ctrl.lstPHS.clear();
        
        //WRONG SCHOOL ID TEST
        System.currentPagereference().getParameters().put('school_id','bad');
        System.currentPagereference().getParameters().put('password','');
        
        ctrl.LoadStudents();

        //This shouldn't have loaded any students 
        System.assertEquals(null, ctrl.lstStudents);
        
        //Clear the list of HSs, otherwise the code tries to get the password from here
        ctrl.lstPHS.clear();
        
        //CORRECT PASSWORD TEST
        System.currentPagereference().getParameters().put('school_id',h.School_Id__c);
        System.currentPagereference().getParameters().put('password','Test');
        
        ctrl.LoadStudents();

        //There should be 1 student now
        System.assertEquals(true, ctrl.ShowStudents);
        System.assertEquals(1, ctrl.lstStudents.size());
        
        //Try a search for HSs that will return more than 10
        ctrl.strHSSearch = 'F';
        ctrl.FindHSs();
        System.assertEquals(10, ctrl.lstPHS.size()); 
        
        //Now search just for the test HS
        ctrl.strHSSearch = 'Jessie Test HS';
        ctrl.FindHSs();
        System.assertEquals(1, ctrl.lstPHS.size()); 
        
    }//end testHSReport
}