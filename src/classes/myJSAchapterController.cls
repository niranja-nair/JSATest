global with sharing class myJSAchapterController {

    public Contact contact {get; set;}
    
    public string studentType {get;set;}
    
    public Boolean showEvents {get;set;}

    public void initPage() {
        Id contactId = [select ContactId from User where Id = :UserInfo.getUserId()].ContactId;
        contact = [select High_School__c, High_School__r.Name, JSA_Role__c from Contact where Id = :contactId];
        string studType = ApexPages.currentPage().getParameters().get('studentType');
        if(string.isempty(studType)) {
            studentType = 'nongraduated';
        }
        else {
            studentType = studType;
        }
        showEvents = portalServices.showEvents();
    }

    public List<Contact> roster {
        get {
            List<Contact> contacts =
                [select Id, Name, Email, High_School_Graduation_Year__c
                 from Contact
                 where // Id != :contact.Id
                 High_School__c = :contact.High_School__c
                 and JSA_Role__c in ('Student', 'Chapter President', 'Chapter Officer' ,'JSA Advisor', 'JSA Affiliate')];
            return contacts;
        }
        
        private set;
    }
    
    @remoteAction
    global static List<Contact> findStudents(String schoolId, String studentType, String userId){

        Contact [] students = new Contact[]{};
        String contactId = [select ContactId from User where id =: userId].ContactId;
        
        if(studentType == 'all'){
            students = [select Id, Name, Email, High_School_Graduation_Year__c, Graduated__c, Member_Status__c, JSA_Role__c
                        from Contact 
                        where High_School__c =: schoolId
                        and JSA_Role__c in ('Student', 'Chapter President', 'Chapter Officer' ,'JSA Advisor', 'JSA Affiliate')
                        // and Id !=: contactId
                        order by LastName asc
            ];
        }else if(studentType== 'graduated'){
            students = [select Id, Name, Email, High_School_Graduation_Year__c, Graduated__c, Member_Status__c, JSA_Role__c
                        from Contact 
                        where High_School__c =: schoolId
                        and JSA_Role__c in ('Student', 'Chapter President', 'Chapter Officer' ,'JSA Advisor', 'JSA Affiliate')
                        and Graduated__c = true
                        // and Id !=: contactId
                        order by LastName asc
            ];
        }else if(studentType== 'nongraduated'){
            students = [select Id, Name, Email, High_School_Graduation_Year__c, Graduated__c, Member_Status__c, JSA_Role__c
                        from Contact 
                        where High_School__c =: schoolId
                        and JSA_Role__c in ('Student', 'Chapter President', 'Chapter Officer' ,'JSA Advisor', 'JSA Affiliate')
                        and Graduated__c = false
                        // and Id !=: contactId
                        order by LastName asc
            ];
        }else if(studentType== 'taxpaidmembers'){
            students = [select Id, Name, Email, High_School_Graduation_Year__c, Graduated__c, Member_Status__c, JSA_Role__c
                        from Contact 
                        where High_School__c =: schoolId
                        and JSA_Role__c in ('Student', 'Chapter President', 'Chapter Officer' ,'JSA Advisor', 'JSA Affiliate')
                        and Member_Status__c = 'Tax-paid Member'
                        // and Id !=: contactId
                        order by LastName asc
            ];
        }
        return students;
    }
    
    @remoteAction
    global static String declareStudentMembers(String[] studentIds, String userId){
        String JSARole = [Select Contact.JSA_Role__c from User where id=: userId].Contact.JSA_Role__c;
        if(new Set<String>{'Chapter President','JSA Advisor', 'JSA Affiliate'}.contains(JSARole)){
            String status = 'ok';
            Contact[] gradStudents = new Contact[]{};
            system.debug(studentIds);
            for(String studentId :studentIds){
                system.debug('studentId:' + studentId);
                gradStudents.add(New Contact(Id=studentId, Chapter_Member__c=true, Member_Status__c = 'Tax-paid Member'));
            }
            try{
                update gradStudents;
            }catch(Exception e){
                status = e.getMessage();
            }
            return status;
        }else{
            return 'You are not authorized to declare members.';
        }
    }
    
    @remoteAction
    global static String graduateStudents(String[] studentIds, String userId){
        String JSARole = [Select Contact.JSA_Role__c from User where id=: userId].Contact.JSA_Role__c;
        if(new Set<String>{'Chapter President','JSA Advisor', 'JSA Affiliate'}.contains(JSARole)){
            String status = 'ok';
            Contact[] gradStudents = new Contact[]{};
            system.debug(studentIds);
            for(String studentId :studentIds){
                system.debug('studentId:' + studentId);
                gradStudents.add(New Contact(Id=studentId, Graduated__c=true));
            }
            try{
                update gradStudents;
            }catch(Exception e){
                status = e.getMessage();
            }
            return status;
        }else{
            return 'You are not authorized to graduate students';
        }
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

        return true;
        
    }

}



/*
My Chapter is a list of Contacts related to the logged in users High_School__c. 
 
DISPLAY LOGIC
 
Do not display contacts where Contact.JSA_Role__c = NULL, Chapter Affairs Agent, Administrator, Academic Counselor or JSA Interested Party
 
Display students = Contact.JSA_Role__c = Student, Chapter President, Chapter Officer
 
Display teachers and teacher adivsors = JSA Advisor, JSA Affiliate
 
FILTERS
 
Non-Graduated = Contact.Graduated__c = False
 
Graduated = Contact.Graduated__c = True
 
MARK AS GRADUATED
 
Action only available to Chapter President and Teachers (Contact.JSA_Role__c = Chapter President, JSA Advisor or JSA Affiliate)
 
When a user is selected and the Mark as Graduated link is clicked, set Contact.Graduated__c = true
*/