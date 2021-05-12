public with sharing class S3FileDownloaderHelperExtn {
    
    private Knowledge_Base__c KB ;
    public String downloadLInk {get;set;}
    public S3FileDownloaderHelperExtn(ApexPages.StandardController stdController) {
    	
    	if (!Test.isRunningTest()) {
        stdController.addFields(new list<string>{'Bucket__c','FileKey__c'});
    }
        this.KB = (Knowledge_Base__c)stdController.getRecord();
    }
    public void generateDownloadLink(){
        downloadLInk = new AWSS3Connector(KB.Bucket__c).amazonS3Utility().bucket().content(KB.FileKey__c).presign().getEndpoint();
    }
    
}