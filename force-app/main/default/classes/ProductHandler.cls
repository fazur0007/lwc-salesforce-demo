/* 
* ProductHandler is the handler of ProductTrigger on Product 
* which will run on after update
*
* Functionality :
* 1)The trigger will run on update field 'Available to sell' on Product.
* 
* 2)AutoPopulate 'Available to sell' field on OrderItem.
*
* Revision History: 
*
* Version       Author             Date                  Description 
*  1.0        Yogesh Sharma      05/24/2016             Initial Draft
*/
public with sharing class ProductHandler {
    //method will execute after update on product field
    public void afterUpdate(map<Id,Product2> newMap, map<Id,Product2> oldMap){

        map<Id,Boolean> mapProductIdBoolean = new map<Id,Boolean>();

        for(Product2 objProduct : newMap.values()){
            if((objProduct.Available_To_Sell__c == true || objProduct.Available_To_Sell__c == false) 
            && ((oldMap.get(objProduct.Id).Available_To_Sell__c <> objProduct.Available_To_Sell__c) || 
                (oldMap.get(objProduct.Id).AX_Reserved_Inventory__c <> objProduct.AX_Reserved_Inventory__c))){

                mapProductIdBoolean.put(objProduct.Id,objProduct.Available_To_Sell__c);

            }// end if  
        }// end for

        if(mapProductIdBoolean <> NULL && !mapProductIdBoolean.isEmpty()){
            orderProductUpdate(mapProductIdBoolean);
        }// end if      
    }// end afterUpdate method

    //method to populate orderItem's field depending on status and 'Avaialble to sell' field value.
    public void orderProductUpdate(map<Id,Boolean> mapProductIdBoolean){

        list<OrderItem> listOrderItemUpdate= new list<OrderItem>();

        for(OrderItem objOrderItem :[SELECT Id,
                                            Available_To_Sell__c,OrderId,Order.Type,Order.Country__c,Order.AX_Order_Account__c,
                                            PricebookEntry.Product2Id,PricebookEntry.Product2.AX_Reserved_Inventory__c,
                                            PricebookEntry.Product2.Available_To_Sell__c
                                       FROM OrderItem
                                      WHERE PricebookEntry.Product2Id IN: mapProductIdBoolean.keySet()
                                       AND (Order.Status =: System.label.Open OR 
                                            Order.Status =: System.label.In_Approval OR
                                            Order.Status =: System.label.Order_Pending)]){
            if(objOrderItem <> NULL) {
                
                //SF-816 | Neil Thaware | Create new field in SF for Reserved Inventory for Accomodation Orders
                //Updating OrderItems whenever Inventory is getting updated
              //  Reserved_Inventory_Accounts__c acc = Reserved_Inventory_Accounts__c.getValues('Reserved Inventory Acc');
                
                objOrderItem.Available_To_Sell__c = Utility.isAvailableToSell(objOrderItem.Order,objOrderItem.PricebookEntry.Product2);
                listOrderItemUpdate.add(objOrderItem);
            }// end if                              
        }// end for
        
        if(listOrderItemUpdate != NULL && !listOrderItemUpdate.isEmpty()){
            System.enqueueJob(new UpdateOrderLineItemAvailableToSell(listOrderItemUpdate)); 
        }// end if          
    }// end orderProductUpdate method
}// end class