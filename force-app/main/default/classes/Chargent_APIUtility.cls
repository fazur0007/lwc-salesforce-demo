public with sharing class Chargent_APIUtility {
    
    @future (callout=true)
    
    public static void chargeAuthorizedTransactionFuture(Id transactionId,String customTypeError,Id parentRecordId,Id ownerId){
        chargeAuthorizedTransaction(transactionId,customTypeError,parentRecordId,ownerId);
    }
    
    public static Boolean chargeAuthorizedTransaction(Id transactionId,String customTypeError,Id parentRecordId,Id ownerId){
        Boolean isSuccess  =false;
        try{
            ChargentOrders.TChargentOperations.TChargentResult chargentResult = ChargentOrders.TChargentOperations.ChargeAuthorizedTransaction_Click(transactionId);
            isSuccess = parseChargentResult(chargentResult,transactionId,'Method-Chargent_APIUtility-chargeAuthorizedTransaction',parentRecordId,ownerId);
        }catch(Exception ex){
            ErrorLog.LogErrorActivity(ex, 'Charge Authorized Transaction ',true,customTypeError != null ?customTypeError:'Payment Error',
                                            transactionId,parentRecordId,ownerId);
            
        } 
        return isSuccess;
    }
    public static Boolean voidTransaction(Id transactionId,String customTypeError,Id parentRecordId,Id ownerId){
        Boolean isSuccess  =false;
        try{
            ChargentOrders.TChargentOperations.TChargentResult chargentResult= ChargentOrders.TChargentOperations.VoidTransaction_Click(transactionId);
            isSuccess = parseChargentResult(chargentResult,transactionId,'Method-Chargent_APIUtility-voidTransaction',parentRecordId,ownerId);
        }catch(Exception ex){
            ErrorLog.LogErrorActivity(ex, 'Void Transaction ',true,customTypeError != null ?customTypeError:'Payment Error',transactionId,parentRecordId,ownerId);
            
        } 
        return isSuccess;
    }
    public static Boolean chargeChargentOrder(Id chargentOrderId,String customTypeError,Id parentRecordId,Id ownerId){
        Boolean isSuccess  =false;
        try{    
    		ChargentOrders.TChargentOperations.TChargentResult chargeResult=ChargentOrders.TChargentOperations.ChargeOrder_Click(chargentOrderId);
            isSuccess = parseChargentResult(chargeResult,chargentOrderId,'Method-Chargent_APIUtility-Charge Chargent Order',parentRecordId,ownerId);
        }catch(Exception ex){
            ErrorLog.LogErrorActivity(ex, 'Charge ChargentOrder ',true,customTypeError != null ?customTypeError:'Payment Error',chargentOrderId,parentRecordId,ownerId);
            
        }
        return isSuccess;  
    }
    public static Boolean authorizeChargentOrder(Id chargentOrderId,String customTypeError,Id parentRecordId,Id ownerId){
        Boolean isSuccess  =false;
        try{
            ChargentOrders.TChargentOperations.TChargentResult chargentResult= ChargentOrders.TChargentOperations.AuthorizeOrder_Click(chargentOrderId);
            isSuccess = parseChargentResult(chargentResult,chargentOrderId,'Method-Chargent_APIUtility-Authorize Chargent Order',parentRecordId,ownerId);
        }catch(Exception ex){
            ErrorLog.LogErrorActivity(ex, 'Authorize ChargentOrder ',true,customTypeError != null ?customTypeError:'Payment Error',chargentOrderId,parentRecordId,ownerId);
            
        }
        return isSuccess;  
    }
    public static Boolean parseChargentResult(ChargentOrders.TChargentOperations.TChargentResult result,Id recordId,String traceLog,Id parentRecordId,Id ownerId){
        
        String transactionStatus = '';
        String transactionMsg = '';
        String transactionID = '';
        
        List<String> tmp = result.Message.split('\r\n');
        if(tmp.size() == 3){
            transactionStatus = tmp[1].substring(tmp[1].indexOf('"') + 1,tmp[1].length() -1);
            transactionMsg = tmp[2].substring(tmp[2].indexOf('"') + 1,tmp[2].length() -1);
            transactionID = tmp[0].mid(tmp[0].indexOf('(')+1,tmp[0].indexOf(')') - tmp[0].indexOf('(')-1);
        }else{
             transactionStatus = 'UNKNOWN';
             transactionMsg = 'UNKNOWN Response';
        }      
        Boolean isSuccess = (transactionStatus != 'Error' && transactionStatus != 'UNKNOWN' );
        
        if(!(result.Status != null && result.Status.equalsIgnoreCase('OK')) || !isSuccess ){
            
            //log a error record 
            ErrorLog.logErrorActivity('\ntraceLog-'+traceLog,result.toString(), 
                                                'Chargent_APIUtility-Updating transaction',true, 'Payment Error',recordId,parentRecordId,ownerId);
            
        }
        return isSuccess;
    }
    
    public static String parseChargentResultV2(ChargentOrders.TChargentOperations.TChargentResult result,Id recordId,String traceLog,Id parentRecordId,Id ownerId){
        
        String transactionStatus = '';
        String transactionMsg = '';
        String transactionID = '';
        List<String> tmp = new List<String>();
        if(result != null && result.Message != null) {
        	tmp = result.Message.split('\r\n');
        }
        if(tmp != null && tmp.size() > 0) {
        	return tmp[0];
        } else{
        	return 'Something went wrong. Please contact System Administrator.';
        }
    }
    
    @future (callout=true)
    
    public static void refundChargedTransactionFuture(Id transactionId,String customTypeError,Id parentRecordId,Id ownerId){
        refundChargedTransaction(transactionId,customTypeError,parentRecordId,ownerId);
    }
    
    public static Boolean refundChargedTransaction(Id transactionId,String customTypeError,Id parentRecordId,Id ownerId){
        Boolean isSuccess  =false;
        try{
            ChargentOrders.TChargentOperations.TChargentResult chargentResult = ChargentOrders.TChargentOperations.RefundTransaction_ClickJSON(transactionId);
            isSuccess = parseChargentResult(chargentResult,transactionId,'Method-Chargent_APIUtility-chargeAuthorizedTransaction',parentRecordId,ownerId);
        }catch(Exception ex){
            ErrorLog.LogErrorActivity(ex, 'Charge Authorized Transaction ',true,customTypeError != null ?customTypeError:'Payment Error',
                                            transactionId,parentRecordId,ownerId);
            
        } 
        return isSuccess;
    }
}