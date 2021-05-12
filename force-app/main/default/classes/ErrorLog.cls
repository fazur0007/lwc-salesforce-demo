/*
*   Class : ErrorLog.cls 
*   Desc  : Log the exception into Error_Log__c object for future debugging the isse. 
*   Created By & Date : Santosh Kumbar & 12/10/2014
*/
public class ErrorLog { 
     
    /*
    *   Method : logErrorActivity
    *   Desc   : insert error logs in salesforce object
    *   @param e : exception object, occured while apex transction,
    *   @param operation : String that holds any identification we need put in, ex. 'While Confirmation Surprise', 'Searching Article', 'Case Insert'
    *   @param isInsertimmediate : Boolean var indicates whether the logs are inserted immediatly or after preparing list of error logs, insert in bulk.
    *   @return Error_Log__c
    */
    public static Error_Log__c logErrorActivity(exception e, string operation, boolean isInsertimmediate) {
        Error_Log__c eL = new Error_Log__c();
        eL.Operation__c = operation;
        eL.Trace_Log__c = e.getStackTraceString();
        eL.Error_Message__c = e.getMessage();
        
        if(isInsertimmediate) {
            insert eL;
        }
        
        return eL; 
    }
    /*
    *   Method : logErrorActivity
    *   Desc   : insert error logs in salesforce object
    *   @param e : exception object, occured while apex transction,
    *   @param operation : String that holds any identification we need put in, ex. 'While Confirmation Surprise', 'Searching Article', 'Case Insert'
    *   @param isInsertimmediate : Boolean var indicates whether the logs are inserted immediatly or after preparing list of error logs, insert in bulk.
    *   @param type: String var indicates type of log Info or Error
    *   @return Error_Log__c
    */
    public static Error_Log__c logErrorActivity(exception e, string operation, boolean isInsertimmediate,String errorType) {
        Error_Log__c eL = new Error_Log__c();
        eL.Operation__c = operation;
        eL.Trace_Log__c = e.getStackTraceString();
        eL.Error_Message__c = e.getMessage();
        el.Type__c = errorType;
        
        if(isInsertimmediate) {
            insert eL;
        }
        
        return eL; 
    }
    public static Error_Log__c logErrorActivity(exception e, string operation, boolean isInsertimmediate,String errorType,String recordId,Id parentRecordId,Id OwnerId) {
        Error_Log__c eL = new Error_Log__c();
        eL.Operation__c = operation;
        eL.Trace_Log__c = e.getStackTraceString();
        eL.Error_Message__c = e.getMessage();
        el.Type__c = errorType;
        
        eL.Record_Id__c = recordId;
        if(parentRecordId != null){
        	
        	String objectAPIName = parentRecordId.getSObjectType().getDescribe().getName();
        	if(objectAPIName == 'Order'){
        		eL.Order__c = parentRecordId;
        	}else if(objectAPIName == 'WorkOrder'){
        		eL.Work_Order__c = parentRecordId;
        	}
        	
        }
        if(OwnerId != null){
        	eL.OwnerId = OwnerId;
        	
        }
        if(isInsertimmediate) {
            insert eL;
        }
        
        return eL; 
    }
    //added by tapan
    /*
    *   Method : logErrorActivity future
    *   Desc   : insert error logs in salesforce object
    *   @param e : String object, occured while apex transction, send serilized exception 
    *   @param operation : String that holds any identification we need put in, ex. 'While Confirmation Surprise', 'Searching Article', 'Case Insert'
    *   @return Error_Log__c
    */
    
    public static Error_Log__c logErrorActivity(String TraceLog,String message, String operation,boolean isInsertimmediate, String errorType) {
        Error_Log__c eL = new Error_Log__c();
        eL.Operation__c = operation;
        eL.Trace_Log__c = trimString(TraceLog);
        eL.Error_Message__c = message;
        eL.Type__c = errorType;
        if(isInsertimmediate) {
            insert eL;
        }
        return eL; 
    }
    public static Error_Log__c logErrorActivity(String TraceLog,String message, String operation,boolean isInsertimmediate, String errorType,String recordId) {
        Error_Log__c eL = new Error_Log__c();
        eL.Operation__c = operation;
        eL.Trace_Log__c = trimString(TraceLog);
        eL.Error_Message__c = message;
        eL.Type__c = errorType;
        eL.Record_Id__c = recordId;
        
        if(isInsertimmediate) {
            insert eL;
        }
        return eL; 
    }
    
    public static Error_Log__c logErrorActivity(String TraceLog,String message, String operation,boolean isInsertimmediate, String errorType,
    																String recordId,Id parentRecordId,Id OwnerId) {
        Error_Log__c eL = new Error_Log__c();
        eL.Operation__c = operation;
        eL.Trace_Log__c = trimString(TraceLog);
        eL.Error_Message__c = message;
        eL.Type__c = errorType;
        eL.Record_Id__c = recordId;
        if(parentRecordId != null){
        	
        	String objectAPIName = parentRecordId.getSObjectType().getDescribe().getName();
        	if(objectAPIName == 'Order'){
        		eL.Order__c = parentRecordId;
        	}else if(objectAPIName == 'WorkOrder'){
        		eL.Work_Order__c = parentRecordId;
        	}else if(objectAPIName == 'Case'){
        		eL.Case__c = parentRecordId;
        	}
        	
        }
        if(OwnerId != null){
        	eL.OwnerId = OwnerId;
        	
        }
        if(isInsertimmediate) {
            insert eL;
        }
        return eL; 
    }
    
    public static string additionalInfo;
    
    public static void logAdditionalErrorInfo(string infoMsg) {
        
        if(additionalInfo == null) 
            additionalInfo = infoMsg;
        else
            additionalInfo += infoMsg;
        
    }
    
    //Substring errorstring message to string length to 131071
    private static string trimString(string msg) {
        string msgString;
        if(msg.length() > 131072) {
            msgString = msg.substring(0, 131071);
        }else{
            msgString = msg;
        }
        
        return msgString;
    }
}