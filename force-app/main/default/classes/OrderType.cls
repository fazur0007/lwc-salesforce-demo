/**
 * This class is a driver class off of the Cases trigger. This class takes in 
 * a list of triggers and if the product ids associated with the case have 
 * been changed or are newly inserted the class will sum up the Authorization
 * Amount for each product and insert that amount into the CC_Authorization_Amount
 * on the case.
 *
 * @author james@highondemand.com
 * @version 1.0
 * @since February 6, 2013
 */
public class OrderType {
/*	
	private Map<Id, Product2> prodMap;
	private Set<Id> pids;
	
	//This method is fired from the before insert trigger.
	public void onInsert(Case[] cases){
		Case[] filtered = new Case[0];
		pIds = new Set<Id>();
		 for(Case c : cases){
		 	if(c.Order_Type__c == 'ACCOMMODATION'){
    	  		Boolean addCase = false;
      			if(c.Item_1__c != null){
        			addCase = true;
      			}
	      		if(c.Item_2__c != null){
    	    		addCase = true;
      			}
	      		if(c.Item_3__c != null){
    	    		addCase = true;
      			}
	      		if(c.Item_4__c != null){
    	    		addCase = true;
      			}
	      		if(c.Item_5__c != null){
    	    		addCase = true;
      			}
	      		if(addCase){
    	    		filtered.add(c);
        			pids.add(c.Item_1__c);
        			pids.add(c.Item_2__c);
        			pids.add(c.Item_3__c);
  	    	  		pids.add(c.Item_4__c);
    	    		pids.add(c.Item_5__c);
	      		}
      		}
		 }
		 pids.remove(null);
		 if(filtered.size() > 0){
		 	updateCases(filtered);
		 }
	}
	
	//This trigger is fired from the before update trigger
	public void onUpdate(Case[] cases, Case[] old){
		Case[] filtered = new Case[0];
    	pIds = new Set<Id>();
    	for(Integer i = 0; i < cases.size(); i++){
    		if(cases[i].Order_Type__c == 'ACCOMMODATION'){
 	     		Boolean addCase = false;
    	  		if(cases[i].Item_1__c != old[i].Item_1__c){
        			addCase = true;
	      		}
    	  		if(cases[i].Item_2__c != old[i].Item_2__c){
        			addCase = true;
      			}
	      		if(cases[i].Item_3__c != old[i].Item_3__c){
    	    		addCase = true;
      			}
	      		if(cases[i].Item_4__c != old[i].Item_4__c){
    	    		addCase = true;
      			}
	      		if(cases[i].Item_5__c != old[i].Item_5__c){
    	    		addCase = true;
      			}
	      		if(addCase){
    	    		filtered.add(cases[i]);
        			pids.add(cases[i].Item_1__c);
        			pids.add(cases[i].Item_2__c);
        			pids.add(cases[i].Item_3__c);
       		 		pids.add(cases[i].Item_4__c);
        			pids.add(cases[i].Item_5__c);
      			}
    	
    		}
    	}
   	 	pids.remove(null);
    	if(filtered.size() > 0){
      		updateCases(filtered);
    	}
    }
  	
  	//This method calculates teh appropriate value for the CC_Authorization_Amount field
	private void updateCases(Case[] filtered){
		for(Case c : filtered){
			Decimal value1 = getValue(c.Item_1__c);
			Decimal value2 = getValue(c.Item_2__c);
			Decimal value3 = getValue(c.Item_3__c);
			Decimal value4 = getValue(c.Item_4__c);
			Decimal value5 = getValue(c.Item_5__c);
			c.CC_Authorization_Amount__c = value1 + value2 + value3 + value4 + value5;
			
		}
	}
	
	 //Returns the value for the Authorization Amount from the product associated with the case.
	private Decimal getValue(Id pId){
		Product2 prod = getProdMap().get(pId);
		if(prod != null && prod.Authorization_Amount__c != null){
			return prod.Authorization_Amount__c;
		}
		return 0;
	}
	
	//Creates the map of the product id to product to be used in calculating the case field.
	private Map<ID, Product2> getProdMap(){
		if(prodMap == null){
			prodMap = new Map<Id, Product2>(queryForProducts(pIds));
		}
		return prodMap;
	}
	
	//Queries for data on products associated with the case.
	private Product2[] queryForProducts(Set<ID> pIds){
		return [SELECT Id, Authorization_Amount__c
				FROM Product2
				WHERE Id IN :pIds];
	}
	
//@isTest(SeeAllData=true)
	
	/*static void testAll()
	{ 
		TestObjects to = new TestObjects();
		Account acct = to.getAccount(true);
		Product2 prod = to.getProduct(true);
		Case c = to.getCase2(acct.Id, prod.id, false); 
		c.Item_2__c = prod.id;
		c.Item_3__c = prod.id;
		c.Item_4__c = prod.id;
		c.Item_5__c = prod.id;
		c.Order_Type__c = 'ACCOMMODATION';
		insert c;
		Case cse = [SELECT Id, Item_1_Cost__c, CC_Authorization_Amount__c
					FROM Case
					WHERE Id = :c.id];
	
		system.assert(cse.CC_Authorization_Amount__c == 50.0);
	}*/
	/*
@isTest
	static void test()
	{ 
		RecordType objRecordType = [select id from RecordType where isActive=:true AND DeveloperName =: 'New_Case' AND sobjectType =: 'Case'];
		system.debug('******objRecordType: '+objRecordType);
		
		Product2 objProduct2 = new Product2();
		objProduct2.Name = 'Test Product';
		objProduct2.SKU__c = 'test sku';
		objProduct2.Qty__c = 2;
		objProduct2.CurrencyIsoCode = 'USD';//'CAD';
		objProduct2.Breville_US_Product__c = true;
		insert objProduct2;
		
		
		Account objAccount = new Account();
		objAccount.Name ='Test Account';
		insert objAccount;
		
		Case objCase =  new case();
		objCase.RecordTypeId = objRecordType.Id;
		objCase.Order_Type__c = 'ACCOMMODATION';
		objCase.Item_1__c = objProduct2.id;
		objCase.Item_2__c = objProduct2.id;
		objCase.Item_3__c = objProduct2.id;
		objCase.Item_4__c = objProduct2.id;
		objCase.Item_5__c = objProduct2.id;
		
		objCase.AccountId = objAccount.Id;
		objCase.Product__c = objProduct2.id;
		//objCase.Item_1__c = objProduct2.Id;
		objCase.Status = 'Open';
		objCase.Origin = 'Email';
		objCase.Type = 'Feedback';
		objCase.Complaint_Code__c = 'Dented';
		objCase.Sub_Complaint_Code__c = 'ERROR 1';
		objCase.Subject = 'Test Subject';
		objCase.Item_1_Qty__c = 2;
		objCase.Item_2_Qty__c = 2;
		objCase.Item_3_Qty__c = 2;
		objCase.Item_4_Qty__c = 2;
		objCase.Item_5_Qty__c = 2;
		insert objCase; 
		
		/*TestObjects to = new TestObjects();
		Account acct = to.getAccount(true);
		Product2 prod = to.getProduct(true);
		Case c = to.getCase2(acct.Id, prod.id, true);
		c.Item_2__c = prod.id;
		c.Item_3__c = prod.id;
		c.Item_4__c = prod.id;
				
		c.Order_Type__c = 'New_Case';//'ACCOMMODATION';
		update c;
		Case cse = [SELECT Id, Item_1_Cost__c, CC_Authorization_Amount__c
					FROM Case
					WHERE Id = :c.id];
	*/
//		system.assert(cse.CC_Authorization_Amount__c == 40.0);
		
	/*}*/
}