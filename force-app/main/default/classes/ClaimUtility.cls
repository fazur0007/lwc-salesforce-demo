global class ClaimUtility {
	WebService static String createClaim(Id workOrderId){
		Id personAccountRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
		list<WorkOrder> workOrderList = [SELECT FirstName__c, LastName__c, Email__c, Street, City, State, PostalCode, Country, ProcebookId__c, ApprovalStatus__c,
											ProductId__c, CurrencyIsoCode, Serial__c, BatchCode__c, AXAccountNumber__c, UsedServiceTaxRate__c, PurchaseDate__c, 
											ServicePricebook__c, ServiceCentre__c, PricesInclusiveOfTaxes__c, Discounted_Labor_Charge__c, Discounted_Freight_Charge__c,
											InspectionChargeTierLevel__c, LaborChargeTierLevel__c, IsFreightFeeApplicable__c, Discounted_Inspection_Charge__c
											FROM WorkOrder WHERE Id =: workOrderId];
											
		WorkOrder claim = new WorkOrder();
		claim.RecordTypeId = personAccountRecordTypeId; 
		claim.WorkOrder__c = workOrderList[0].Id; 
		claim.FirstName__c = workOrderList[0].FirstName__c; 
		claim.LastName__c = workOrderList[0].LastName__c; 
		claim.Email__c = workOrderList[0].Email__c; 
		claim.Street = workOrderList[0].Street; 
		claim.City = workOrderList[0].City; 
		claim.State = workOrderList[0].State; 
		claim.PostalCode = workOrderList[0].PostalCode; 
		claim.Country = workOrderList[0].Country ; 
		claim.Pricebook2Id = workOrderList[0].ProcebookId__c; 
		claim.Product__c= workOrderList[0].ProductId__c; 
		claim.CurrencyIsoCode = workOrderList[0].CurrencyIsoCode; 
		claim.Serial__c = workOrderList[0].Serial__c; 
		claim.BatchCode__c = workOrderList[0].BatchCode__c; 
		claim.AXAccountNumber__c = workOrderList[0].AXAccountNumber__c; 
		claim.UsedServiceTaxRate__c = workOrderList[0].UsedServiceTaxRate__c; 
		claim.ServicePricebook__c = workOrderList[0].ServicePricebook__c; 
		claim.ServiceCentre__c = workOrderList[0].ServiceCentre__c; 
		claim.PricesInclusiveOfTaxes__c = workOrderList[0].PricesInclusiveOfTaxes__c;
		
		if(workOrderList[0].PurchaseDate__c != null){
			claim.PurchaseDate__c = workOrderList[0].PurchaseDate__c;
		}		
		
		try{
			insert claim;
		}catch(DMLException e){
			ErrorLog.logErrorActivity(e,'Error in adding Claim from ClaimUtility METHOD createClaim',true,'Error');
		}
		
		if(ApplicationLiterals.applicableWorkOrderCurrencySet.contains(workOrderList[0].CurrencyIsoCode)){
			list<WorkOrderLineItem> workOrderLineItemList = [SELECT Id, ClaimAmount__c, IsApproved__c, PartnerUniqueLineId__c, SerialNoOfAppliance__c, Tier__c, Type__c, 
																	PricebookEntryId, Quantity, Status, Subtotal, TotalPrice, UnitPrice, StartDate, Discount, EndDate, ListPrice,
																	Product2Id
															FROM WorkOrderLineItem 
															WHERE WorkOrderId = :workOrderId];
			list<WorkOrderLineItem> workOrderLineItemsToAdd = new list<WorkOrderLineItem>();
			if(workOrderLineItemList != null && workOrderLineItemList.size() > 0){
				for(WorkOrderLineItem lineItem : workOrderLineItemList){
					WorkOrderLineItem lineItemToAdd = lineItem.clone(false, false, false, false);
					lineItemToAdd.WorkOrderId = claim.Id;
					lineItemToAdd.Product2Id = lineItem.Product2Id;
					lineItemToAdd.ClaimAmount__c = lineItem.TotalPrice;
					workOrderLineItemsToAdd.add(lineItemToAdd);
				}
			}
			if(workOrderList[0].InspectionChargeTierLevel__c != null && workOrderList[0].InspectionChargeTierLevel__c != '' && workOrderList[0].Discounted_Inspection_Charge__c != null
						&& workOrderList[0].Discounted_Inspection_Charge__c > 0){
				WorkOrderLineItem lineItemToAdd = new WorkOrderLineItem();
				if(workOrderList[0].ApprovalStatus__c != null && workOrderList[0].ApprovalStatus__c.equalsIgnoreCase('Approved')){
					lineItemToAdd.IsApproved__c = true;
				}
				lineItemToAdd.Type__c = 'Inspection Charge';
				lineItemToAdd.WorkOrderId = claim.Id;
				lineItemToAdd.Tier__c = workOrderList[0].InspectionChargeTierLevel__c;
				workOrderLineItemsToAdd.add(lineItemToAdd);
			}
			if(workOrderList[0].LaborChargeTierLevel__c != null && workOrderList[0].LaborChargeTierLevel__c != '' && workOrderList[0].Discounted_Labor_Charge__c != null
						&& workOrderList[0].Discounted_Labor_Charge__c > 0){
				WorkOrderLineItem lineItemToAdd = new WorkOrderLineItem();
				if(workOrderList[0].ApprovalStatus__c != null && workOrderList[0].ApprovalStatus__c.equalsIgnoreCase('Approved')){
					lineItemToAdd.IsApproved__c = true;
				}
				lineItemToAdd.Type__c = 'Labor Charge';
				lineItemToAdd.WorkOrderId = claim.Id;
				lineItemToAdd.Tier__c = workOrderList[0].LaborChargeTierLevel__c;
				workOrderLineItemsToAdd.add(lineItemToAdd);
			}
			if(workOrderList[0].IsFreightFeeApplicable__c && workOrderList[0].Discounted_Freight_Charge__c != null && workOrderList[0].Discounted_Freight_Charge__c > 0){
				WorkOrderLineItem lineItemToAdd = new WorkOrderLineItem();
				if(workOrderList[0].ApprovalStatus__c != null && workOrderList[0].ApprovalStatus__c.equalsIgnoreCase('Approved')){
					lineItemToAdd.IsApproved__c = true;
				}
				lineItemToAdd.Type__c = 'Freight Charge';
				lineItemToAdd.WorkOrderId = claim.Id;
				lineItemToAdd.Tier__c = workOrderList[0].InspectionChargeTierLevel__c;
				workOrderLineItemsToAdd.add(lineItemToAdd);
			}
			
			if(workOrderLineItemsToAdd != null && workOrderLineItemsToAdd.size() > 0){
				try{
					insert workOrderLineItemsToAdd;
				}catch(DMLException e){
					ErrorLog.logErrorActivity(e,'Error in adding WorkOrderLineItem from ClaimUtility METHOD createClaim',true,'Error');
				}
			}
		}
		
		if(claim.Id != null){
			return claim.Id;
		}
		
		return null;
	}
	
	public PageReference forwardToClaim(Id claimId){
		String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + claimId;
		PageReference pageRef = new PageReference(fullRecordURL);
		return pageRef;
	}
	
}