/*
    * Description - This test class checks 2 usecase and its negative test cases too.
    * 1.a)  Checks the changes in the Account Address field according to the changes in the corresponding Contact Address
    * 1.b)  Checks the account address field retains without any changes after the Contact Address updation. [Negative testing of 1.a]
    * 2.a)  Checks the Opportunity email field changes with respect to the changes in the Contact email field
    * 2.b)  Checks the Opportunity email field retains without any changes after the Contact email [Negative testing of 2.a]
 */
@IsTest(seeAllData = TRUE)
 public class ContactTriggerManagerTest {
        //-- Testing the changes in the Billing and Shipping address field of Account, when the Mailing address field of Contact
      static testMethod void ContactTriggerManagerTest1() {
      RecordType recTypeOfAccount = [   SELECT 
                                            Id,
                                            Name 
                                        FROM 
                                            RecordType 
                                        WHERE 
                                            Name = 'HouseHold'
                                            and 
                                            sObjectType='Account'
                                    ];
      Account acc = new Account(
                                    Name = 'testName',
                                    RecordTypeId = recTypeOfAccount.Id,
                                    BillingStreet ='testBStreet',
                                    BillingCity ='testBCity',
                                    BillingState ='testBState',
                                    BillingPostalCode = 'testBPostalBCode',
                                    BillingCountry = 'testBCountry',

                                    ShippingStreet ='testSStreet',
                                    ShippingCity ='testSCity',
                                    ShippingState ='testSState',
                                    ShippingPostalCode = 'testSPostalCode',
                                    ShippingCountry = 'testSCountry'
                                );  
        INSERT acc;
        RecordType recTypeOfContact = [
                                        SELECT 
                                            Id,
                                            Name 
                                        FROM 
                                            RecordType
                                        WHERE  
                                            sObjectType='Contact' 
                                            and 
                                            Name = 'Student'
                                      ];                                   
        Contact con = new Contact(
                                    LastName = 'testLastName',
                                    AccountId = acc.Id,
                                    RecordTypeId = recTypeOfContact.Id,
                                    MailingStreet ='testMStreet',
                                    MailingCity ='testMCity',
                                    MailingState ='testMState',
                                    MailingPostalCode = 'testMPostalCode',
                                    MailingCountry = 'testMCountry'
                                 );
        INSERT con;     

        con.MailingStreet ='MailingStreetChanged';
        UPDATE con;
        
        Account updatedAccount  = [
                                    SELECT 
                                        Id,
                                        BillingStreet,
                                        ShippingStreet
                                    FROM 
                                        Account
                                    WHERE 
                                        Id =: acc.Id
                                  ];
        //-- Tests the BillingStreet in the Account changed according to the changes in the MailingStreet of the Contact.           
        System.assertEquals(updatedAccount.BillingStreet=='MailingStreetChanged',TRUE);
        //-- Tests the ShippingStreet in the Account changed according to the changes in the MailingStreet of the Contact.
        System.assertEquals(updatedAccount.ShippingStreet =='MailingStreetChanged',TRUE); 
        //-- Negative Testing
        //-- Ensure that the BillingStreet is not the old one, after update the MailingStreet of the Contact.         
        System.assertNotEquals(updatedAccount.BillingStreet=='testBStreet',TRUE);
        //-- Ensure that the ShippingStreet is not the old one, after update the MailingStreet of the Contact. 
        System.assertNotEquals(updatedAccount.ShippingStreet =='testSStreet',TRUE);                
      }

      //-- Tests the email field[Parent_Email__c] in the Opportunity changes with respect to the changes in the contact email field[Parent_or_Guardian_s_Email__c]
      static testMethod void ContactTriggerManagerTest2() {
      
        Contact con = new Contact(
                                    LastName = 'testLastName',
                                    Parent_or_Guardian_s_Email__c = 'testemail@gmail.com'
                                );
        INSERT con;
        
        Opportunity opt = new Opportunity(
                                            Name='opportunityName', 
                                            CloseDate=Date.Today(),
                                            StageName='Qualification',
                                            Primary_Contact__c = con.Id,
                                            Parent_Email__c = ''
                                         );
        INSERT opt;
        con.Parent_or_Guardian_s_Email__c = 'updatedemail@gmil.com';
        UPDATE con;
        Opportunity updatedOpp = [
                                    SELECT 
                                        Id,
                                        Parent_Email__c 
                                    FROM 
                                        Opportunity
                                    WHERE 
                                        Id =: opt.Id 
                                 ];
        //--Tests the Parent_Email__c field of Opportunity changed
        System.assertEquals(updatedOpp.Parent_Email__c == 'updatedemail@gmil.com',TRUE);
        //--Tests the Parent_Email__c field of Opportunity is the the old one
        System.assertNotEquals(updatedOpp.Parent_Email__c == '',TRUE);
      }
 }