public with sharing class WarrantyIndicatorExtension {
	public list<Case> caseList {get;set;}
	public WarrantyIndicatorExtension(ApexPages.StandardController ctrl){
		caseList = new list<Case>();
		caseList.add((Case)ctrl.getRecord());
	}
     
}