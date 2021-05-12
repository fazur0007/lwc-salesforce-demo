public class Ltng_OrderObjectUtil{
    public static string errorMessage = 'Please click Calculate\Recalculate button before activating';
    public static string errorMessageStatus = 'Success';
    public Ltng_OrderObjectUtil(){
        
    }
    @AuraEnabled 
    public static String getOrderDetails(String recordId){
        try{
            Order ordr = [Select Id,AccountType__c,IsCalculated__c,ActivatedByPartner__c From Order where Id =:recordId Limit 1];
            if(ordr.AccountType__c == 'Retailer' && !ordr.IsCalculated__c){
                throw new AuraHandledException('Please click Calculate\Recalculate button before activating');
            }else{
                Update new Order(
                    Id = recordId,
                    ActivatedByPartner__c = true
                );
            return 'success';
            }
        }catch(Exception e){
            throw new AuraHandledException('Error Occured :'+e.getMessage());
        }
    }
    @AuraEnabled 
    public static String getOrderDetail(String recordId){
        Order ordr = [Select Id,AccountType__c,IsCalculated__c,ActivatedByPartner__c From Order where Id =:recordId Limit 1];
        return 'success';
        
    }
    @AuraEnabled 
    public static String closeTask(String recordId){
        try{
            update new Task(
                Id = recordId,
                Status = 'Closed'
            );
            return 'success';
        }catch(Exception e){
            throw new AuraHandledException('Error Occured :'+e.getMessage());
        }
    }
}