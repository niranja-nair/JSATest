trigger JSAContactTrigger on Contact ( after update){
    // Query the contact to get Mailing address and RecordType Name, 
    // id and parent email from Related Opportunities 
    // and account's record type name.
    List<Contact> contactRecordsList = [
                                        SELECT 
                                            Id,
                                            Email, 
                                            RecordType.Name,
                                            Account.RecordType.Name,
                                            MailingStreet,
                                            MailingCity,
                                            MailingState, 
                                            MailingPostalCode, 
                                            MailingCountry,
                                            Parent_or_Guardian_s_Email__c,
                                                   (
                                                    SELECT 
                                                        id, 
                                                        Parent_Email__c
                                                    FROM 
                                                        Opportunities__r
                                                    )
                                        FROM 
                                            Contact 
                                        WHERE 
                                            Id IN: trigger.new
                                    ];
    
    //-- Initialise List for DML operations
    List<Account> updateAccountList = new List<Account>();
    List<Opportunity> updateOpportunityList = new List<Opportunity>();
    //-- Looping through the updated contact records
    for(Contact newContact : contactRecordsList){
        //-- Get old values of the each updated contact record
        Contact oldContact = Trigger.oldMap.get(newContact.Id);
        
        //-- Check if Contact's record type is Student and Parent Account's Record Type is Household
        if(newContact.RecordType.Name == 'Student' && newContact.Account.RecordType.Name == 'HouseHold'){                
        
            //-- Check if mailing address of contact has been updated
            if (
                    oldContact.MailingStreet != newContact.MailingStreet || 
                    oldContact.MailingCity != newContact.MailingCity || 
                    oldContact.MailingState != newContact.MailingState || 
                    oldContact.MailingPostalCode != newContact.MailingPostalCode || 
                    oldContact.MailingCountry != newContact.MailingCountry
            ) {
                //-- Update the parent account's address according to contact's mailing address and add to list
                // Sets accounts billing & shipping address with contacts mailing address and adding to list.
                updateAccountList.add(ContactTriggerManager.setRelatedAccountsAddress(newContact));
                
            }
        }
        //-- Check if Contact's email has been updated
        if(newContact.Parent_or_Guardian_s_Email__c != oldContact.Parent_or_Guardian_s_Email__c){
            for(Opportunity opp : newContact.Opportunities__r){
                //-- update all related Opportunities email according to contact's email
                opp.Parent_Email__c = newContact.Parent_or_Guardian_s_Email__c;
                updateOpportunityList.add(opp);
            }
        }
    }
    
    //-- Perform update on list of updated accounts
    ContactTriggerManager.updateSObjectList(updateAccountList);
    
    //-- Perform update on list of updated Opportunities
    ContactTriggerManager.updateSObjectList(updateOpportunityList);

}