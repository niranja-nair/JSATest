/*
  Date of creation : 28-Nov-2014
  Created by : Suyati
  Description - Test class for Opportunity trigger and helper class

*/

@IsTest(seeAllData = TRUE)
 public class JSAOpportunityTrigger_Test
 {
         //-- Testing the Email field in Opportunity is updated according with the changes in email field of Contact [before insert] 
      static testMethod void CreateOpportunity1()
      {      
          Contact con = new Contact(
                                      LastName ='testContactName',
                                      Parent_or_Guardian_s_Email__c = 'contactemail@gmail.com'
                                    );
          INSERT con;
          
          Opportunity opt = new Opportunity(
                                              Name='optname', 
                                              CloseDate=Date.Today(),
                                              StageName='Qualification',
                                              Primary_Contact__c = con.Id 
                                            );
          INSERT opt;
          Opportunity opportunityWithChangedMail = [
                                                        SELECT 
                                                          Id,
                                                          Parent_Email__c 
                                                        FROM 
                                                          Opportunity 
                                                        WHERE 
                                                          Id =: opt.Id
                                                    ];

          System.assertEquals(opportunityWithChangedMail.Parent_Email__c == 'contactemail@gmail.com',TRUE);

      }
      // Checks opportunitylineitems without priceBookEntry
     
     
      //-- Checks two opprtunity and its pdoducts are created along each opportunity and its creation
      static testMethod void CreateOpportunity2()
      {

          // -- Created a contact record
          Contact con = new Contact(
                                      LastName ='testContactName',
                                      Parent_or_Guardian_s_Email__c = 'contactemail@gmail.com'
                                    );
          INSERT con;
          //-- Created an Opportunity with the above Contact
          Opportunity optInitial = new Opportunity(
                                                Name='optname', 
                                                CloseDate=Date.Today(),
                                                StageName='Qualification',
                                                Primary_Contact__c = con.Id
                                              );
          INSERT optInitial;
          Product2 p2 = new Product2(Name='p2name');
          Insert p2;
          
          Pricebook2 pb2 = [select id from Pricebook2 where IsStandard = true limit 1];
          PriceBookEntry pbe = new PriceBookEntry(
                                                    UnitPrice=100,
                                                    Product2Id=p2.Id,
                                                    Pricebook2Id=pb2.Id,
                                                    UseStandardPrice = false,
                                                    IsActive = true
                                                 );
          INSERT pbe;
         
          OpportunityLineItem oli = new OpportunityLineItem(
                                                              OpportunityId=optInitial.Id,
                                                              PriceBookEntryId=pbe.Id,
                                                              Quantity=10,
                                                              TotalPrice=10
                                                            );
          INSERT oli;
           // -- Query for the Shangai and travel id of inserted Opportunity
          Opportunity insertedOpp = [
                                        SELECT 
                                            Id,
                                            Shanghai_Extension__c,
                                            Travel_Extension__c
                                        FROM
                                            Opportunity
                                        WHERE
                                            Id =: optInitial.Id
                                    ];
          //-- Newly created 2 opportunity line items stored in the list
          //-- Select the OLI based on the product name and opportunity id
          list <OpportunityLineItem> newlyCreatedOLI = [
                                                          SELECT 
                                                              Id,
                                                              Name,
                                                              Product2.Name, 
                                                              OpportunityId 
                                                          FROM 
                                                              OpportunityLineItem 
                                                          WHERE 
                                                                (
                                                                  Product2.Name ='Diplomat Program Airfare' 
                                                                  AND 
                                                                  OpportunityId =: insertedOpp.Travel_Extension__c
                                                                )
                                                            OR (
                                                                  Product2.Name ='Diplomat Shanghai Ext Program' 
                                                                  AND 
                                                                  OpportunityId =: insertedOpp.Shanghai_Extension__c
                                                              )
                                                        ];
         System.assertEquals(newlyCreatedOLI.size() == 2,TRUE);  
      }
 }