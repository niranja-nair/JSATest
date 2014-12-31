/*
  Date of creation : 27-Nov-2014
  Created by : Suyati
  Description - Helper class for trigger on opprtunity

*/
public class OpportunityHelper
{
    //-- Set a Opportunity whenever a new opportunity created
    public static Opportunity createShanghaiOpportunity(Opportunity opp){        
        Opportunity newOpp = new Opportunity(
                                                type = 'travel',
                                                Name=opp.Name + ', Shanghai-'+opp.Account.Name,
                                                StageName= 'Application Started',
                                                CloseDate = opp.CloseDate,
                                                AccountId= opp.AccountId,
                                                Primary_Contact__c = opp.Primary_Contact__c
                                            );
        return newOpp;
    }

    //-- Set a Opportunity whenever a new opportunity created
    public static Opportunity createTravelOpportunity(Opportunity opp){
        Opportunity newOpp = new Opportunity(
                                                type = 'travel',
                                                Name=opp.Name + ', Travel-'+opp.Account.Name,
                                                StageName= opp.StageName,
                                                CloseDate = opp.CloseDate,
                                                AccountId= opp.AccountId,
                                                Primary_Contact__c = opp.Primary_Contact__c
                                            );
        return newOpp;
    }
    
    //-- Insert Opportunity by using this method
    public static void insertOpportunity(List<Opportunity> newOppsList){
        try{
            if(newOppsList.size() > 0)
                INSERT newOppsList; 
        }catch(Exception e){
            System.debug('Exception : ' + e.getMessage());
        }
    }
    // -- update the fields(Shanghai_Extension__c,Travel_Extension__c) in the originally created opportunity.
    public static void updateOriginalOpportunity(List<Opportunity> shanghaiOpportunityList, List<Opportunity> travelOpportunityList, List<Opportunity> originalOpportunity){
    
            for(Integer i = 0; i < originalOpportunity.size(); i++){
                originalOpportunity.get(i).Shanghai_Extension__c = shanghaiOpportunityList.get(i).id;
                originalOpportunity.get(i).Travel_Extension__c = travelOpportunityList.get(i).id;
            }
            try{
                UPDATE originalOpportunity;
            }catch(Exception e){
            }
    }

    //-- Set a opportunity product for the Shangai opportunity
    public static OpportunityLineItem createOpportunityProductForShanghai(Opportunity originalOpp, Opportunity shanghaiOpp){

        list<Product2> prod2=   [
                                    SELECT 
                                        Id, 
                                        Name 
                                    FROM 
                                        Product2 
                                    WHERE 
                                        name = 'Diplomat Shanghai Ext Program'
                                ];
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        // -- Select PriceBookEntry records with ProductName = 'Diplomat Shanghai Ext Program'
        // -- and Pricebook2Id of Origianal Opportunity
        pbeList = [
                    SELECT 
                        id,
                        UnitPrice 
                    FROM 
                        PriceBookEntry 
                    WHERE 
                        Product2Id = :prod2[0].id 
                    AND 
                        Pricebook2Id = : originalOpp.Pricebook2Id 
                    LIMIT 1
                  ];
        
        PriceBookEntry pbe = new PriceBookEntry();
        // If the selected PriceBookEntry list doesn't contain any records, then create a new record in PriceBookEntry 
        if(pbeList.size() == 0){
                pbe = new PriceBookEntry(
                                            Product2Id = prod2[0].id, 
                                            PriceBook2Id = originalOpp.Pricebook2Id, 
                                            UnitPrice = 1, 
                                            isActive = true
                                        );
                insert pbe;
        }else
        {        
            pbe = pbeList[0];
        }
        OpportunityLineItem newOppLItem = new OpportunityLineItem(
                                                                    PriceBookEntryId=pbe.Id,
                                                                    TotalPrice = pbe.UnitPrice, 
                                                                    Quantity = 1, 
                                                                    OpportunityId = shanghaiOpp.id
                                                                 );
        return newOppLItem;
    }

    //-- Set a opportunity product for the Shangai opportunity
    public static OpportunityLineItem createOpportunityProductForTravel(Opportunity originalOpp, Opportunity travelOpp){

        list<Product2> prod2= [
                                SELECT 
                                    Id, 
                                    Name 
                                FROM 
                                    Product2 
                                WHERE 
                                    name = 'Diplomat Program Airfare'
                              ];
        
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        // -- Select PriceBookEntry records with ProductName = 'Diplomat Program Airfare'
        // -- and Pricebook2Id of Origianal Opportunity
        pbeList = [
                    SELECT
                        id,
                        UnitPrice 
                    FROM 
                        PriceBookEntry
                    WHERE
                        Product2Id = :prod2[0].id 
                    AND 
                        Pricebook2Id = : originalOpp.Pricebook2Id 
                    LIMIT 1
                    ];
        
        PriceBookEntry pbe = new PriceBookEntry();
        // If the selected PriceBookEntry list doesn't contain any records, then create a new record in PriceBookEntry 
        if(pbeList.size() == 0){
            pbe = new PriceBookEntry(
                                        Product2Id = prod2[0].id, 
                                        PriceBook2Id = originalOpp.Pricebook2Id,
                                        UnitPrice = 1, isActive = true
                                    );
            insert pbe;
        }else{        
            pbe = pbeList[0];
        }        
        
        OpportunityLineItem newOppLItem = new OpportunityLineItem(
                                                                    PriceBookEntryId=pbe.Id,
                                                                    TotalPrice = pbe.UnitPrice, 
                                                                    Quantity = 1, 
                                                                    OpportunityId = travelOpp.id
                                                                 );
                                            
        return newOppLItem;
    }
    
    //-- Update the Opportunity
    public static void updateOpportunity(List<Opportunity> updateOpportunityList)
    {        
        if(updateOpportunityList.size() > 0){
            try{
                UPDATE updateOpportunityList;
            }catch(Exception e){
            }
        }
    }
    
    //-- Insert Opportunity product
    public static void insertOpportunityProduct(List<OpportunityLineItem> newOpportunityLineItemList)
    {    
        if(newOpportunityLineItemList.size() > 0){
            try{
                INSERT newOpportunityLineItemList;
            }catch(Exception e){
                System.debug('Exception : ' + e.getMessage());
            }
        }
    }
    
    
}