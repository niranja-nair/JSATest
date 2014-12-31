trigger JSAOpportunityTrigger on Opportunity ( after update, after insert, before insert){
    
    List<Opportunity> newOpportunityList = new List<Opportunity>();
    //-- List of all new Opportunities
    newOpportunityList = [
                            SELECT 
                                id,
                                Name, 
                                Primary_Contact__c,
                                Primary_Contact__r.Email, 
                                Parent_or_Guardian_s_Email__c, 
                                CloseDate,
                                AccountId, 
                                Account.Name,
                                Pricebook2Id, 
                                Shanghai_Extension__c,
                                Travel_Extension__c,
                                StageName,
                                (
                                    SELECT 
                                        id, 
                                        PriceBookEntryId 
                                    FROM 
                                        OpportunityLineItems
                                    )
                            FROM 
                                Opportunity
                            WHERE 
                                id IN : trigger.New
                        ];
    //-- Initialisations   
    //--List of opportunity for Shangai created along with Original opportunity.                  
    List<Opportunity> shanghaiOpportunityList = new List<Opportunity>(); 
    //--List of opportunity for Travel created along with Original opportunity.
    List<Opportunity> travelOpportunityList = new List<Opportunity>();
    //--List of opportunity that has to be updated 
    List<Opportunity> updateOpportunityList = new List<Opportunity>();
    List<OpportunityLineItem> newOpportunityLineItemList = new List<OpportunityLineItem>();
    
    //-- Set value of Parent Email from Parent Contact in before insert
    if((Trigger.isInsert) && (Trigger.isBefore)){
        for(Opportunity newOpp : trigger.New){
            newOpp.Parent_Email__c = newOpp.Parent_or_Guardian_s_Email__c;
        }
    }
    
    //-- Create two Opportunities after insert of original opportunity
    if((Trigger.isInsert) && (Trigger.isAfter)){
        for(Integer i = 0; i < newOpportunityList.size(); i++){
            
            Opportunity newOpp = newOpportunityList.get(i);
            if((!newOpp.Name.contains(', Shanghai-')) && (!newOpp.Name.contains(', Travel-'))){
                
                Opportunity newOppForShanghai = OpportunityHelper.createShanghaiOpportunity(newOpp);
                shanghaiOpportunityList.add(newOppForShanghai);
                Opportunity newOppForTravel = OpportunityHelper.createTravelOpportunity(newOpp);
                travelOpportunityList.add(newOppForTravel);
            }
        }   
        //-- Insert Opportunity in the shanghaiOpportunityList 
        if(shanghaiOpportunityList.size() > 0){
            OpportunityHelper.insertOpportunity(shanghaiOpportunityList);
        }
        //-- Insert Opportunity in the travelOpportunityList 
        if(travelOpportunityList.size() > 0){
            OpportunityHelper.insertOpportunity(travelOpportunityList);
        }
        
        //-- Update original opportunity with Shanghai and Travel Extension Opportunity Ids for Lookups
        if((shanghaiOpportunityList.size() > 0) && (travelOpportunityList.size() > 0))
            OpportunityHelper.updateOriginalOpportunity(shanghaiOpportunityList, travelOpportunityList, newOpportunityList);
    }
    
    //-- Create Opportunity Product and update PriceBook Id for related Shanghai and Travel Opportunity
    if((Trigger.isUpdate) && (Trigger.isAfter)){
        
        for(Opportunity newOpp : newOpportunityList){ 
            // Avoid recurcive creation of Opportunity along with the initially created Opportunity
            if((!newOpp.Name.startsWith('2015 JSA Diplomat Program, Shanghai')) &&
               (!newOpp.Name.startsWith('2015 JSA Diplomat Program, Travel')) && 
                newOpp.PriceBook2Id != null &&
                trigger.OldMap.get(newOpp.id).PriceBook2Id == null && 
                newOpp.Shanghai_Extension__c != null && 
                newOpp.Travel_Extension__c != null
            ){
                //Avoid recursive invoke of triggers when child opportunities are created
                if(MyJSACheckRecursive.runOnce()){
                    // Set the priceBook2Id of Shangai Opportunity with the priceBook2Id of Original Opportunity
                    Opportunity updateOpp = new Opportunity();
                    updateOpp.id = newOpp.Shanghai_Extension__c;
                    updateOpp.PriceBook2Id = newOpp.PriceBook2Id;
                    
                    //-- Add Opportunity Line Item for Shanghai Extension Opportunity as per original Opportunity
                    OpportunityLineItem newOppLineItemsForShanghai  = OpportunityHelper.createOpportunityProductForShanghai(newOpp, updateOpp);             
                    newOpportunityLineItemList.add(newOppLineItemsForShanghai);
                    
                    //-- Update Shanghai Extension opportunity with price book id as original opportunity
                    updateOpportunityList.add(updateOpp);
                    
                    updateOpp = new Opportunity();
                    updateOpp.id = newOpp.Travel_Extension__c;
                    updateOpp.PriceBook2Id = newOpp.PriceBook2Id;
                    
                    //-- Add Opportunity Line Item for Travel Extension Opportunity as per original Opportunity
                    OpportunityLineItem newOppLineItemsForTravel  = OpportunityHelper.createOpportunityProductForTravel(newOpp, updateOpp);             
                    newOpportunityLineItemList.add(newOppLineItemsForTravel);
                    
                    //-- Update Travel Extension opportunity with price book id as original opportunity
                    updateOpportunityList.add(updateOpp);
                }
            }
        }
        //-- Update opportunities in the List
        OpportunityHelper.updateOpportunity(updateOpportunityList);
        //-- Update opportunity line items in the List
        OpportunityHelper.insertOpportunityProduct(newOpportunityLineItemList);
        
    }
}