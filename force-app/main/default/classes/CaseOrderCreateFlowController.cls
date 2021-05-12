public class CaseOrderCreateFlowController{
   
   public List<Order> lstOrder { get; set; }
   RecordType objRecordType;
   
   public Id caseId;
 
    
    //Constructor
    public CaseOrderCreateFlowController() {
        
    }

   public pageReference getOrderId(){
       
        PageReference reRedirect;
        lstOrder = new List<Order>();
        caseId = Apexpages.currentpage().getparameters().get('id');
        
        if (caseId!= null) {
            lstOrder = [Select id,
                               RecordTypeId
                          From Order 
                            where Case__c =: caseId order by CreatedDate desc limit 1];
            
            if (!lstOrder.IsEmpty() && lstOrder!= null) {
                objRecordType = new RecordType();
            objRecordType = [SELECT Id,
                                    DeveloperName 
                               FROM RecordType 
                              WHERE SobjectType = 'Order' 
                                AND Id =: lstOrder[0].RecordTypeId];
             if(objRecordType.DeveloperName==System.Label.ServiceRecordType || 
                 objRecordType.DeveloperName==System.Label.CanServiceRecordType){
                 reRedirect = new PageReference('/' + lstOrder[0].Id);
             }else{
                 reRedirect = new PageReference('/_ui/busop/orderitem/SelectSearch?addTo=' + lstOrder[0].Id);
             }
                reRedirect.setRedirect(false);
            }
          
        }
        return reRedirect ;
    }
}