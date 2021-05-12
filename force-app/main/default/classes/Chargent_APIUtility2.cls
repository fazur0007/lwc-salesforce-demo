global class Chargent_APIUtility2 {
    webservice static String chargectAPIcall(Id chargentOrderId, Id parentRecordId, Id ownerId){
       String message= '';
       try{
            ChargentOrders.TChargentOperations.TChargentResult chargentResult= ChargentOrders.TChargentOperations.AuthorizeOrder_Click(chargentOrderId);
            String response = Chargent_APIUtility.parseChargentResultV2(chargentResult,chargentOrderId,'Method-Chargent_APIUtility-Authorize Chargent Order',parentRecordId,ownerId);
            if(response.contains('TRX-')){
                message = 'Payment successful.';
                if(activateOrder(parentRecordId)) {
                    message = 'Payment successful and Order Activated.';
                }
            } else {
                message = response;
            }
        }catch(Exception ex){
            ErrorLog.LogErrorActivity(ex, 'Authorize ChargentOrder ',true,'Payment Error',chargentOrderId,parentRecordId,ownerId);            
        }
        return message;  
    }
    
    webservice static boolean activateOrder(Id orderId) {
        Order newOrder = new Order();
        newOrder.Id = orderId;
        newOrder.ActivatedByPartner__c= true; 
        newOrder.status = 'In Approval';
        newOrder.ActivatedById = neworder.OwnerId;
        
        try{
            update newOrder;
            return true;
        } catch(Exception ex) {
            System.debug('ex.getMessage() ::::: '+ ex.getMessage());
            ErrorLog.LogErrorActivity(ex, 'OrderActivation',true,'Order Activation Error',orderId,null,neworder.OwnerId);
        }
        return false;
    }
    
    webservice static String chargectAPIcallWithCVV(String chargentOrderParams, Id parentRecordId, Id ownerId){      
       String message= '';
       Id chargentOrderId= null;
        
       JSONParser parser = Json.createParser(chargentOrderParams);
       while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'ObjectId')) {
                parser.nextToken();
                chargentOrderId = parser.getIdValue();
            }
       }
       
       
       try{          
            ChargentOrders.TChargentOperations.TChargentResult chargentResult= ChargentOrders.TChargentOperations.AuthorizeOrder_ClickJSON(chargentOrderParams);
           
            String response = Chargent_APIUtility.parseChargentResultV2(chargentResult,chargentOrderId,'Method-Chargent_APIUtility-Authorize Chargent Order',parentRecordId,ownerId);
           
           	System.debug('===response===' + response);
            if(response.contains('TRX-')){
                message = 'Payment successful.';
                if(activateOrder(parentRecordId)) {
                    message = 'Payment successful and Order Activated.';
                }
            } else {
                message = response;
            }
        }catch(Exception ex){
            ErrorLog.LogErrorActivity(ex, 'Authorize ChargentOrder ',true,'Payment Error',chargentOrderId,parentRecordId,ownerId);            
        }
        return message;  
    }
}