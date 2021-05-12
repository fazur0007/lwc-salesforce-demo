public with sharing class CaseS3FileUploadExtn {
    
    Public Knowledge_Base__c knowledgeBase {get;set;}
    Public static Case caseObj{get;set;}  
	Public static String region{get;set;}     
    Public static All_Literal__mdt literalMetadata{get;set;}

    public CaseS3FileUploadExtn(ApexPages.StandardController stdController) {
     
         if (!Test.isRunningTest()) {
		        stdController.addFields(new List<String>{'CurrencyIsoCode'});  
		    }       
         caseObj = (Case)stdController.getRecord();                                      
         knowledgeBase = new Knowledge_Base__c();
         knowledgeBase.Case__c=caseObj.id;     
	     if(caseObj.CurrencyIsoCode != null )
	     {
	     	region=Utility.regionBased(caseObj.CurrencyIsoCode);
	     	knowledgeBase.Region__c=region;
	     	knowledgeBase.Bucket__c=region;
	     }
         system.debug('Region : '+region); 
        literalMetadata= [SELECT DeveloperName, Value__c FROM All_Literal__mdt where DeveloperName='CaseAttachments' LIMIT 1  ];
         system.debug('Object Prefix key: '+literalMetadata);       
    }       
}