global with sharing class S3FileUploadCtrl {
    public Knowledge_Base__c KB {get;set;}
    public String ctrlRegion {get;
                                set{ ctrlRegion = value.toUpperCase();}
                            }
    public String ctrlKey {get;
                                set{ctrlKey = value != null ? EncodingUtil.urlEncode(value, 'UTF-8') :value;}
                            }
     
    
    @RemoteAction
    global static Boolean createKnowledgeBase(Knowledge_Base__c KB,String bucket,String key,String etag){
        //try{
            if(KB.Id == null){
	            KB.Region__c = bucket;
	            KB.RecordtypeId = Schema.SObjectType.Knowledge_Base__c.getRecordTypeInfosByName().get(Label.KBRecordTypeCaseAtttachment).getRecordTypeId();
	            KB.Title__c = key.substring(key.lastIndexOf('/')+1);
            }
            KB.Etag__c = etag;
            KB.FileKey__c = key;
            upsert KB;
            return true;
        //}catch(Exception ex){
            //system.debug('Exception'+ex);
            return false;
        //}
        return false;
        
    }
}