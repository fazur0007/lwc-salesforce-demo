public with sharing class AwsS3SearchArticlesController{
    
    public String searchStr                             {get;set;}
    public Boolean showSearcResultsBlock                {get;set;}
    public Integer size                                 {get;set;} 
    public Integer noOfRecords                          {get; set;} 
    public ApexPages.StandardSetController setCon       {get;set;}
    private String knowledgeBaseRecordId                {get;set;}
    public String businessUnit {get; set;}
    public String docType {get; set;}
    
    public AwsS3SearchArticlesController(){
        
        showSearcResultsBlock = false;
        knowledgeBaseRecordId = Schema.SObjectType.Knowledge_Base__c.getRecordTypeInfosByName().get(Label.KBRecordTypeKnowledgeRepo).getRecordTypeId();
        
    }
    
    /*Changes made for W-000310 (Improve Knowledge Base record search process and versioning of KB Records)
    Added Doctype filter in the search criteria, Introduced new field New_Knowledge_Base__c to track recent KBs*/
    public void searchKnowledgeBase(){
        
        try{
            setCon = null;
            size = 10;
            noOfRecords = 0;
            showSearcResultsBlock = true;
            list<String> productList = new list<String>();
            String selectedProducts =   Apexpages.currentPage().getParameters().get('products');
            String KBQueryFields = System.Label.Knowledgebase_Column_Fields;
            
            if(selectedProducts != null && selectedProducts != '' ){
            	selectedProducts = EncodingUtil.urlDecode(selectedProducts,'UTF-8') ;
                productList = selectedProducts.split(',');
            }
            if( searchStr!= null && searchStr.length() < 3 ){
            	
            }
            
            if( searchStr!= null && searchStr.length() > 1 ){
                List<List<SObject>> searchList;
                
                if(productList != null && productList.size() > 0){
                    if(businessUnit != System.Label.Select2 && docType != System.Label.Select2){
                        searchList = [FIND :searchStr IN ALL FIELDS RETURNING Knowledge_Base__c (Id,Name,Title__c,Description__c,DocType__c,Region__c,Product__c,DownloadLink__c,isOutOfDate__c,New_Knowledge_Base__c
                                                     WHERE Product__r.Name IN :productList 
                                                     AND Region__c INCLUDES (:businessUnit) 
                                                     AND DocType__c = : docType                                            
                                                     AND RecordTypeId =:knowledgeBaseRecordId
                                                     Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                
                	}else if(businessUnit != System.Label.Select2){
                		searchList = [FIND :searchStr IN ALL FIELDS RETURNING Knowledge_Base__c (Id,Name,Title__c,Description__c,DocType__c,Region__c,Product__c,DownloadLink__c,isOutOfDate__c,New_Knowledge_Base__c
                                                     WHERE Product__r.Name IN :productList 
                                                     AND Region__c INCLUDES (:businessUnit) 
                                                     AND RecordTypeId =:knowledgeBaseRecordId
                                                     Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                	}else if(docType != System.Label.Select2){
                		searchList = [FIND :searchStr IN ALL FIELDS RETURNING Knowledge_Base__c (Id,Name,Title__c,Description__c,DocType__c,Region__c,Product__c,DownloadLink__c,isOutOfDate__c,New_Knowledge_Base__c
                                                     WHERE Product__r.Name IN :productList 
                                                     AND DocType__c = : docType  
                                                     AND RecordTypeId =:knowledgeBaseRecordId 
                                                     Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                	}else{
                		searchList = [FIND :searchStr IN ALL FIELDS RETURNING Knowledge_Base__c (Id,Name,Title__c,Description__c,DocType__c,Region__c,Product__c,DownloadLink__c,isOutOfDate__c,New_Knowledge_Base__c
                                                     WHERE Product__r.Name IN :productList AND RecordTypeId =:knowledgeBaseRecordId 
                                                     Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                	}
                }else{
                    
                    if(businessUnit != System.Label.Select2 && docType != System.Label.Select2){
                        searchList = [FIND :searchStr IN ALL FIELDS RETURNING Knowledge_Base__c 
                    										(Id,Name,Title__c,Description__c,DocType__c,Region__c,Product__c,DownloadLink__c,isOutOfDate__c,New_Knowledge_Base__c
                                                    WHERE RecordTypeId =:knowledgeBaseRecordId 
                                                    AND Region__c INCLUDES (:businessUnit)
                                     				AND DocType__c = : docType 
                                                    Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                    
                	}else if(businessUnit != System.Label.Select2){
                		searchList = [FIND :searchStr IN ALL FIELDS RETURNING Knowledge_Base__c 
                    										(Id,Name,Title__c,Description__c,DocType__c,Region__c,Product__c,DownloadLink__c,isOutOfDate__c,New_Knowledge_Base__c
                                                    WHERE RecordTypeId =:knowledgeBaseRecordId 
                                                    AND Region__c INCLUDES (:businessUnit) 
                                                    Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                        
                	}else if(docType != System.Label.Select2){
                		searchList = [FIND :searchStr IN ALL FIELDS RETURNING Knowledge_Base__c 
                    										(Id,Name,Title__c,Description__c,DocType__c,Region__c,Product__c,DownloadLink__c,isOutOfDate__c,New_Knowledge_Base__c
                                                    WHERE RecordTypeId =:knowledgeBaseRecordId 
                                                    AND DocType__c = : docType 
                                                    Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                        
                    }else{
                		searchList = [FIND :searchStr IN ALL FIELDS RETURNING Knowledge_Base__c
                    										(Id,Name,Title__c,Description__c,DocType__c,Region__c,Product__c,DownloadLink__c,isOutOfDate__c,New_Knowledge_Base__c
                                                    WHERE RecordTypeId =:knowledgeBaseRecordId
                                                    Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                        
                	}
                    
                }
                if(searchList != null && searchList.size() > 0 ){
                    
                    setCon = new ApexPages.StandardSetController(((List<Knowledge_Base__c>)searchList[0]));
                    setCon.setPageSize(size);  
                    noOfRecords = setCon.getResultSize();
                }
            }else if(productList != null && productList.size() > 0 ){
                if(businessUnit != System.Label.Select2 && docType != System.Label.Select2){
                	setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                                                                [SELECT Id,Name,Title__c,Description__c,DocType__c,Region__c,Product__c,DownloadLink__c,isOutOfDate__c,New_Knowledge_Base__c
                                                                    FROM Knowledge_Base__c 
                                                                    WHERE Product__r.Name IN:productList 
                                                                    AND RecordTypeId =:knowledgeBaseRecordId 
                                                                 	AND Region__c INCLUDES (:businessUnit)
                                                                	AND DocType__c = : docType
                                                                	Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc]));	
                  
            	}else if(businessUnit != System.Label.Select2){
                	setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                                                                [SELECT Id,Name,Title__c,Description__c,DocType__c,Region__c,Product__c,DownloadLink__c,isOutOfDate__c,New_Knowledge_Base__c
                                                                    FROM Knowledge_Base__c 
                                                                    WHERE Product__r.Name IN:productList 
                                                                    AND RecordTypeId =:knowledgeBaseRecordId 
                                                                 	AND Region__c INCLUDES (:businessUnit)
                                                                	Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc]));		
            	}else if(docType != System.Label.Select2){
                	setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                                                                [SELECT Id,Name,Title__c,Description__c,DocType__c,Region__c,Product__c,DownloadLink__c,isOutOfDate__c,New_Knowledge_Base__c
                                                                    FROM Knowledge_Base__c 
                                                                    WHERE Product__r.Name IN:productList 
                                                                    AND RecordTypeId =:knowledgeBaseRecordId 
                                                                 	AND DocType__c = : docType
                                                                	Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc]));		
            	}else{
            		setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                                                                [SELECT Id,Name,Title__c,Description__c,DocType__c,Region__c,Product__c,DownloadLink__c,isOutOfDate__c,New_Knowledge_Base__c
                                                                    FROM Knowledge_Base__c 
                                                                    WHERE Product__r.Name IN:productList 
                                                                    AND RecordTypeId =:knowledgeBaseRecordId
                                                                	Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc]));
            	}
                setCon.setPageSize(size);  
                noOfRecords = setCon.getResultSize();
            }else{
                
                showSearcResultsBlock = false;
            }
          }
          catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error:'+ex.getMessage()));
        }
    } 
  
       
    //Changes the size of pagination
    public PageReference refreshPageSize() {
         setCon.setPageSize(size);
         return null;
    }
 
    // Initialize setCon and return a list of record    
     
    public list<Knowledge_Base__c> getKnowledgeBaseList() {
        if(setCon != null){
            return (list<Knowledge_Base__c>) setCon.getRecords();
        }else{
            return new list<Knowledge_Base__c>();
        }
    }
    @RemoteAction
    public static Case getCaseDetails(String caseId){
        list<Case> caseList = [select id,Product__c,Product__r.Name from Case where Id =: caseId limit 1];
        if(caseList != null && caseList.size() > 0){
            return caseList[0];
        }
        return null;
    }
    public List<SelectOption> getBusinessUnits() {
 	 	return Utility.getBusinessUnits();
  	}
    
    /*Changes made for W-000310 (Improve Knowledge Base record search process and versioning of KB Records)
	Added a new Search Filter for Doc Type*/
    public List<SelectOption> getDocTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(System.Label.Select2, System.Label.Select2));

		Schema.DescribeFieldResult fieldResult = Knowledge_Base__c.DocType__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			options.add(new SelectOption(pickListVal.getLabel(), pickListVal.getLabel()));
		}             
        return options;
    }
}