public with sharing class KnowledgeBaseS3FileUploadExtn {
     
     public String knowledgeBaseMainFolderPath					{get;set;}
     public String caseAttachmentsMainFolderPath				{get;set;}

     public KnowledgeBaseS3FileUploadExtn(ApexPages.StandardController stdController) { 
        
        for(All_Literal__mdt literal :  [SELECT DeveloperName, Value__c FROM All_Literal__mdt 
        					where DeveloperName='KnowledgeBase' or DeveloperName='CaseAttachments' ]){
        	if(literal.DeveloperName == 'KnowledgeBase' ){
        		knowledgeBaseMainFolderPath = literal.Value__c;
        	}else if(literal.DeveloperName == 'CaseAttachments'){
        		caseAttachmentsMainFolderPath = literal.Value__c;
        	}				
        						
        }
                
    }        
}