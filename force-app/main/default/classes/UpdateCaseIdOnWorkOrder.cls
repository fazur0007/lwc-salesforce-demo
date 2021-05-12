public class UpdateCaseIdOnWorkOrder implements Queueable {
	
	Map<Id, String> workOrderIdToCaseNumberMap;
	Map<String, Case> caseNumberToCaseMap;
	
	public UpdateCaseIdOnWorkOrder(Map<Id, String> workOrderIdToCaseNumberMap){
		this.workOrderIdToCaseNumberMap = workOrderIdToCaseNumberMap;
		Set<String> caseNumberSet = new Set<String>();
		caseNumberSet.addAll(workOrderIdToCaseNumberMap.values());
		
		if(caseNumberSet != null && caseNumberSet.size() > 0){
			caseNumberToCaseMap = Utility.createCaseMap(caseNumberSet);
		}
	}
	
    public void execute(QueueableContext context) {
        list<WorkOrder> workorderList  = new list<WorkOrder>();
        if(caseNumberToCaseMap != null && caseNumberToCaseMap.size() > 0){
	        for(Id workOrderId : workOrderIdToCaseNumberMap.keySet()){
	        	if(caseNumberToCaseMap.containsKey(workOrderIdToCaseNumberMap.get(workOrderId))){
	        		workorderList.add(new WorkOrder( Id = workOrderId,
	        										 caseId = caseNumberToCaseMap.get(workOrderIdToCaseNumberMap.get(workOrderId)).Id,
	        										 AccountId = caseNumberToCaseMap.get(workOrderIdToCaseNumberMap.get(workOrderId)).AccountId));
	        	}
	        }    
	        
	        if(workorderList != null && workorderList.size() > 0){
	        	Database.update(workorderList, false); 
	        }   
        }
    }
}