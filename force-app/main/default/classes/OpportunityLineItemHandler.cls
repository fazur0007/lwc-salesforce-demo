/*
OpportunityLineItemHandler is a Class called by OpportunityLineItemTrigger Trigger.
To restrict to create duplicate opportunityLineItem for Opportunity whose record type is Forecast
* Version       Author             Date                   Description
*  1.0        Yogesh Sharma      02/02/2017             Initial Draft
*/

public with sharing class OpportunityLineItemHandler {

    //method to find duplicate Opportunity line items
    public void beforeInsert(list<OpportunityLineItem> lstOLI){
        map<Id,set<Id>> mapOppIdPrEntryId = new map<Id,set<Id>>();
        set<Id> setOppId= new set<Id>();
        for(OpportunityLineItem objOLI: lstOLI){
            if(objOLI.Opportunityid <> NULL){
                setOppId.add(objOLI.Opportunityid);
            }//end if
        }//end for
        if(setOppId <> NULL && !setOppId.isEmpty()){
            set<Id> setPricebookEntryId = new set<Id>();
            for(OpportunityLineItem objOLI:[SELECT ID,
                                                   OpportunityId,
                                                   PriceBookEntryId
                                              FROM OpportunityLineItem
                                              WHERE OpportunityId IN:setOppId
                                              AND Opportunity.RecordType.Name =: System.Label.Label_Forecast]){
                if(mapOppIdPrEntryId.containsKey(objOLI.OpportunityId)){
                    mapOppIdPrEntryId.get(objOLI.OpportunityId).add(objOLI.PriceBookEntryId);
                }
                else{
                    mapOppIdPrEntryId.put(objOLI.OpportunityId,new set<Id>{objOLI.PriceBookEntryId});
                }
            }// end for
        }//end if
        if(mapOppIdPrEntryId <> NULL && !mapOppIdPrEntryId.isEmpty()){
            set<Id> setPricebookEntryId = new set<Id>();
            for(OpportunityLineItem objOLI: lstOLI){
                setPricebookEntryId= new set<Id>();
                if(objOLI.OpportunityId != null && mapOppIdPrEntryId != null && mapOppIdPrEntryId.get(objOLI.OpportunityId) != null ){
                    setPricebookEntryId = mapOppIdPrEntryId.get(objOLI.OpportunityId);
                    if(setPricebookEntryId.contains(objOLI.PriceBookEntryId)){
                        objOLI.addError(system.label.Label_Exist);
                    }// end if
                }
            }// end for
        }//end if
    }// end method
}//end class