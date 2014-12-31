public with sharing class myJSAroomSelectionContExt 
{
    public static final string MALE_GENDER= 'Male';
    public static final string FEMALE_GENDER= 'Female';
    
    public static final string TEACHER_ROLE = 'Teacher';
    public static final string STUDENT_ROLE = 'Student';
    
    public static final integer STUDENT_TYPE = 0;
    public static final integer TEACHER_TYPE = 1;
    
    public static Map<String,integer> categoryToType = new Map<String,Integer>
    {
        'Alum' => TEACHER_TYPE,
        TEACHER_ROLE => TEACHER_TYPE,
        'Other' => TEACHER_TYPE,
        'Parent' => TEACHER_TYPE,
        'HS Educator' => TEACHER_TYPE,
        STUDENT_ROLE => STUDENT_TYPE
    };
    
    public static list<Contact> filterByGender(list<Contact> contacts, string Gender)
    {
        list<Contact> filtered = new List<Contact>();
        
        for(contact c : contacts)
        {
            if(c.Gender__c == gender || c.Gender__c == '' || c.Gender__c == null)
            {
                filtered.add(c);
            }
        }
        
        return filtered;
    }
    
    public static list<Contact> filterByRole(list<Contact> contacts, string roomType)
    {
        integer contactType;
        if(roomType == 'Student')
        {
            contactType = STUDENT_TYPE;
        } 
        else
        {
            contactType = TEACHER_TYPE;
        }
        
        list<Contact> filtered = new List<Contact>();
        
        for(contact c : contacts)
        {
            if(categoryToType.get(c.Category__c) == contactType)
            {
                filtered.add(c);
            }
        }
        
        return filtered;
    }
    
    public class roomWrapper
    {
        public HotelRoom__c room { get; set; }
        public integer index { get; set; }
        public list<Contact> allContacts;
        private boolean contactsSetUp;
        
        public boolean readyForDelegates
        {
            get
            {
                 return contactsSetUp && typeAndGenderSet;
            }
        }
        
        public boolean hasDelegates()
        {
            if((room.D1__c != null) || (room.D2__c != null) || (room.D3__c != null) || (room.D4__c != null))
            {
                return true;
            }
            
            return false;
        }
        
        public boolean typeAndGenderSet
        {
            get
            {
                return !(room.Room_Type__c == null || room.Gender__c == null);
            }
        }
        
        public portalServices.selectSObject d1Contacts {get; private set;}
        public portalServices.selectSObject d2Contacts {get; private set;}
        public portalServices.selectSObject d3Contacts {get; private set;}
        public portalServices.selectSObject d4Contacts {get; private set;}
        
        public roomWrapper(integer idx,HotelRoom__c theRoom,list<Contact> contacts)
        {
            room = theRoom;
            contactsSetUp = false;
            
            index = idx;
            allContacts = contacts;
            
            if(typeAndGenderSet)
            {
                setupContactSelectors();
            }
        }
        
        private void setupContactSelectors()
        {
            System.debug('allContacts : ' + allContacts);
            list<Contact> relevantContatcs = filterByGender(allContacts,room.gender__c);
            
            relevantContatcs = filterByRole(relevantContatcs,room.room_type__c);
            System.debug('relevantContatcs : ' + relevantContatcs);
            
            final string NONE_TEXT= '--none selected--';
            
            d1Contacts = new portalServices.selectSObject(relevantContatcs,NONE_TEXT);
            d1Contacts.selectedId = room.D1__c;
            
            d2Contacts = new portalServices.selectSObject(relevantContatcs,NONE_TEXT);
            d2Contacts.selectedId = room.D2__c;
            
            d3Contacts = new portalServices.selectSObject(relevantContatcs,NONE_TEXT);
            d3Contacts.selectedId = room.D3__c;
            
            d4Contacts = new portalServices.selectSObject(relevantContatcs,NONE_TEXT);
            d4Contacts.selectedId = room.D4__c;
            
            contactsSetUp = true;
        }
        
        public void setLookups()
        {
            room.D1__c = d1Contacts.selectedId;
            room.D2__c = d2Contacts.selectedId;
            room.D3__c = d3Contacts.selectedId;
            room.D4__c = d4Contacts.selectedId;
        }
        
        public void resetRoom()
        {
            room.D1__c = null;
            d1Contacts = null;
            
            room.D2__c = null;
            d2Contacts = null;
            
            room.D3__c = null;
            d3Contacts = null;
            
            room.D4__c = null;
            d4Contacts = null;
            
            room.room_type__c = null;
            room.gender__c = null;

            room.CheckInDate__c = null;
            room.CheckOutDate__c = null;
            
            contactsSetUp = false;
        }
        
        public void delegateButtonAction()
        {
            if(typeAndGenderSet)
            {
                setupContactSelectors();
            }
            else
            {
                apexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'the type and gender of a room must be selected first'));
            }
        }
    }
    
    public jsaPortalEventController subController;
    
    public list<Contact> allAppliedContacts {get; set;}
    public list<RoomWrapper> theRooms {get; set;}
    
    //summary data
    public integer totalDelegates 
    { 
        get
        {
            return allAppliedContacts.size();
        }
    }
    
    public integer assigned
    {
        get
        {
            //use a set to avoid counting duplicates;
            set<Id> contactIds = new set<Id>();
            for( RoomWrapper wrap : theRooms)
            {
                HotelRoom__c room = wrap.room;
                
                if(room.D1__c != null)
                {
                    contactIds.add(room.D1__c);
                }
                
                if(room.D2__c != null)
                {
                    contactIds.add(room.D2__c);
                }
                
                if(room.D3__c != null)
                {
                    contactIds.add(room.D3__c);
                }
                
                if(room.D4__c != null)
                {
                    contactIds.add(room.D4__c); 
                }
            }
            
            return contactIds.size();
        }
    }
    
    private integer countByRoleAndGender(string role,string gender)
    {
        list<Contact> appliedbyRole = filterByRole(allAppliedContacts,role);
        list<Contact> gendered = filterbyGender(appliedbyRole,gender);
        return gendered.size();
    }
    
    public integer appliedMaleStudents 
    {
        get
        {
            return countByRoleAndGender(STUDENT_ROLE,MALE_GENDER);
        }
         
        private set;
    }
    
    public integer appliedFemaleStudents
    {
        get
        {
            return countByRoleAndGender(STUDENT_ROLE,FEMALE_GENDER);
        }
         
        private set;
    }
    
    public integer appliedUnknownStudents
    {
        get
        {
            return countByRoleAndGender(STUDENT_ROLE,null);
        }
         
        private set;
    }
    
    public integer appliedMaleTeachers
    {
        get
        {
            return countByRoleAndGender(TEACHER_ROLE,MALE_GENDER);
        }
         
        private set;
    }
    
    public integer appliedFemaleteachers
    {
        get
        {
            return countByRoleAndGender(TEACHER_ROLE,FEMALE_GENDER);
        }
         
        private set;
    }
    
    public integer appliedUnknownTeachers
    {
        get
        {
            return countByRoleAndGender(TEACHER_ROLE,null);
        }
         
        private set;
    }
    
    public void updateRoomsAndContacts()
    {
        allAppliedContacts = new List<Contact>();
        System.debug('Applications : ' + subController.op.Applications__r);
        for(Application__c app : subController.op.Applications__r)
        {
            allAppliedContacts.add(app.contact__r);
        }       
        
        list<HotelRoom__c> presentRooms = 
        [
            SELECT Id,Room_Type__c,Gender__c,
            D1__c,D1__r.Name,D2__c,D2__r.Name,
            D3__c,D3__r.Name,D4__c,D4__r.Name,
            Opportunity__c, Special_Requirements__c,
            CheckInDate__c, CheckOutDate__c, Opportunity__r.id,
            R1__c, R2__c,R3__c,R4__c,Opportunity__r.type
            FROM HotelRoom__c 
            Where Opportunity__c = :subController.op.id
        ];
        
        System.debug('presentRooms:' +presentRooms);
        System.debug('subController.op.id :' +subController.op.id);
        
        theRooms = new List<RoomWrapper>();
        String test = '';
        for(integer i=0;i<presentRooms.size();++i)
        {
            HotelRoom__c rm = presentRooms[i].clone(false);
            //HotelRoom__c rm = presentRooms[i];
            roomWrapper wrap = new RoomWrapper(i,rm,allAppliedContacts);
            //test += ', ' + i + ' - ' + wrap.room.Opportunity__c;
            theRooms.add(wrap);
        }
       System.debug('theRooms'+theRooms);
    }
    
    public void addRoom()
    {
        HotelRoom__c rm = new HotelRoom__c (opportunity__c = subController.op.id);
        theRooms.add(new RoomWrapper(theRooms.size(),rm,allAppliedContacts));
    }
        
    public myJSAroomSelectionContExt(jsaPortalEventController cont)
    {
        subController = cont;
        updateRoomsAndContacts();
    }
    
    public integer roomToDelete { get; set; }
    public void deleteRoom()
    {
        theRooms.remove(roomToDelete);
        
        //now reset the indicies.
        for(integer i = 0;i<theRooms.size(); ++i)
        {
            theRooms[i].index = i;  
        }
    }
    
    public boolean saveRooms()
    {
        List<HotelRoom__c> currentRooms = [SELECT Id FROM HotelRoom__c WHERE Opportunity__c = :subController.op.id];
        
        Savepoint sp = Database.setSavepoint();
        
        try
        {
            delete currentRooms;        
        }
        catch(Exception e)
        {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error deleting previous hotel rooms'));
            return false;
        }
        
        //ok get all the new rooms together
        List<HotelRoom__c> newRooms = new List<HotelRoom__c>();
        
        for(roomWrapper wrap : theRooms)
        {
            
            if(wrap.readyForDelegates)
            {
                wrap.setLookups();
                newRooms.add(wrap.room);
            }
            else
            {
                string errMess = 'incomplete rooms were not saved';
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.info,errMess));
            }
        }
        System.debug('Before update, newRooms :'+newRooms);
        if(!portalServices.upsertHotelRooms(newRooms))
        {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error saving new hotel rooms'));
            Database.rollback(sp);
            System.debug('After update, newRooms :'+newRooms);
            return false;
        }
        
        return true;
    }
    
    public void saveAction()
    {
        saveRooms();
        updateRoomsAndContacts();
    }
    
    public void saveDelegates()
    {
        subController.addPackagesForParticipatingMembers();
        updateRoomsAndContacts();
    }
    
    public void submitWithRooms()
    {
        if(saveRooms())
        {
            subController.submitOpp();
            updateRoomsAndContacts();
        }
    }
}