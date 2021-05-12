public with sharing class CreateReturnLabelExt {
	Case caseRecord {get; set;}
	public Boolean hasWorkOrder {get; set;}
	
	public CreateReturnLabelExt(ApexPages.StandardController con){
    	// If Case has WorkOrder
    	caseRecord = (Case) con.getRecord();
		hasWorkOrder = false;
		Integer workOrderCount = [SELECT count() FROM WorkOrder WHERE CaseId =:caseRecord.id AND Status != 'Repeat Workorder'];
		if(workOrderCount > 0){
			hasWorkOrder = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, System.Label.CreateReturnLabelWorkOrderError));
		}
    }
}