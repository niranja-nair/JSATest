/*
  Date of creation : 21-Nov-2014
  Created by : Suyati
* Description - Helper class for trigger on contact
*/
public with sharing class ContactTriggerManager
{
 /*
 * Description - Method to update Account's Shipping and Billing address according to contact's 
 *      mailing address
setRelatedAccountsAddress

 */
    public static Account setRelatedAccountsAddress(Contact con){
    
  Account accoutToUpdate =     new Account(
            Id = con.accountId,
            BillingStreet = con.MailingStreet ,
            BillingCity = con.MailingCity,
            BillingState = con.MailingState,
            BillingPostalCode = con.MailingPostalCode,
            BillingCountry = con.MailingCountry,
            ShippingStreet = con.MailingStreet ,
            ShippingCity = con.MailingCity,
            ShippingState = con.MailingState,
            ShippingPostalCode = con.MailingPostalCode,
            ShippingCountry = con.MailingCountry
           );
        return accoutToUpdate;
    }
 

/*
 * Description - Update the list of sObject passed as argument
 */
 public static void updateSObjectList(List<sObject> sObjectList){
  
  try{
   if(sObjectList.size() > 0)
    UPDATE sObjectList;
  }
  catch(Exception e){
      System.debug('Error while updating sObjectList : ' + e.getMessage());
  }
 }
}