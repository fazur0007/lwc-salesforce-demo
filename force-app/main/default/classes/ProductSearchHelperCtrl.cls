public with sharing class ProductSearchHelperCtrl {
	
	  /**
       * searchTagsLibrary
       * This method will used to find matching template on the basis of user keyword
       * @return void
       */
     public String productReultsStr {get;set;}
     
     public void searchProduct(){ 
        productReultsStr='';
        String searchString=Apexpages.currentPage().getParameters().get('q');
        string q=+ '%'+searchString + '%';
         
        list<Product2> productList = [select Id,Name, Country_code__c from Product2 
                                                where IsActive = true
                                                and Finished_Good__c = true
                                                AND Exclude_from_Sync__c = false
                                                //and CurrencyIsoCode =:Userinfo.getDefaultCurrency()
                                                and (
	                                                	Product_Sub_Family__c like:q
	                                                		or 
	                                                	Name like :q 
                                                ) 
                                                limit 100];

        if(productList != null && productList.size() > 0){
            //searilize to json
            productReultsStr = Json.serializePretty(productList);

        }else{
            //set to blank array to avoid runtime exception in javascript
            productReultsStr='[]';
        }
      
    }
    
}