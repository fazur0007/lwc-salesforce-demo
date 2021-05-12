public  class ProductRegistrationCustomApprovalCtrl {
    @AuraEnabled
    public static Id getWorkItemId(Id targetObjectId) {
        Id retVal = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: targetObjectId AND p.ProcessInstance.Status='Pending' AND  ActorId = : UserInfo.getUserId()]) {
            retVal  =  workItem.Id;
        }
        return retVal;
    }
    @AuraEnabled
    public static String rejectRecord(Id targetObjectId, string rejectedReason, string comments) {
        try {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(rejectedReason);
            req.setAction('Reject');
            Id workItemId = getWorkItemId(targetObjectId); 
            if(workItemId == null) {
                return 'No ProcessInstanceWorkitem Id is Found';
            }
            else {
                req.setWorkitemId(workItemId);
                // Submit the request for approval
                Approval.ProcessResult result =  Approval.process(req);
                Asset asset = new Asset();
                asset.Id = targetObjectId;
                asset.Approval_Rejection_Reason__c = rejectedReason;
                update asset;
                return 'sucess';
    
            }
        } catch(Exception ex){
            return ex.getMessage();
        }
       
    }
    @AuraEnabled
    public static String approveRecord(Id targetObjectId, string comments) {
        try {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            if (comments == null || comments == '') {
                req.setComments('Approving manuallly');
            } else {
                req.setComments(comments);
            }
            req.setAction('Approve');
            Id workItemId = getWorkItemId(targetObjectId); 
            if (workItemId == null) {
                return 'No ProcessInstanceWorkitem Id is Found';
            }
            else {
                req.setWorkitemId(workItemId);
                // Submit the request for approval
                Approval.ProcessResult result =  Approval.process(req);
                return 'sucess';
            }
        } catch(Exception ex){
            return ex.getMessage();
        }
    }
    
}