public with sharing class S3FileUploadHelperCtrl {
    
    public String formattedDateString {get;set;}
    public String objectname {get;set;}
    public String accessType {get;set;}
    public String content_Type {get;set;}
    public String forRedirect {get;set;}
    public String credential {get;set;}
    private String secretKey;
    Datetime currenttime;
    private String region = null;
    public String s3ServerSideEncryp {get;set;}
    public String s3Algorithm {get;set;}
    private String strpolicy {get;set;}
    public String formAction {get;set;}
    public AWSS3Setting__mdt s3stng {get;set;}
    public S3FileUploadHelperCtrl(){
        
         region = ApexPages.currentPage().getParameters().get('region');
         objectname = ApexPages.currentPage().getParameters().get('key');
         objectname = objectname != null && objectname != '' ? EncodingUtil.urlDecode(objectname, 'UTF-8') : objectname;
         
         initFileUpload();

    }
    private void initFileUpload(){
        System.debug('region ::::: '+region);
        if(region != null && region != ''){
           s3stng = [SELECT DeveloperName,S3BucketName__c, 
                                            S3Region__c, SecretAccessKey__c, AccessKeyID__c,RequestType__c,
                                            DataTimeFormat__c, TimeZone__c ,Service__c,FormPostRegion__c,meta_uuid__c
                                        FROM AWSS3Setting__mdt 
                                        WHERE DeveloperName =:region ];
                                    
            secretKey = s3stng.SecretAccessKey__c;
            currenttime = DateTime.now(); 
            Datetime expirydate = currenttime.addDays(1);
            formattedDateString = currenttime.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
            accessType = ApplicationLiterals.ACCESSTYPE;
            content_Type = ApplicationLiterals.CONTENTTYPE;
            formAction = 'https://'+s3stng.S3BucketName__c+'.s3.amazonaws.com/';
            forRedirect =  URL.getSalesforceBaseUrl().toExternalForm()+Page.s3fileuploadHelper.getUrl();
            credential = s3stng.AccessKeyID__c+'/'+currenttime.formatGmt('yyyyMMdd')+'/'+s3stng.FormPostRegion__c+'/'+s3stng.Service__c+'/'+s3stng.RequestType__c;
            s3ServerSideEncryp = ApplicationLiterals.S3SERVERSIDEENCRYP;
            s3Algorithm = ApplicationLiterals.S3ALGORITHM;
            strpolicy = '{ "expiration": "'+expirydate.formatGmt('yyyy-MM-dd')+'T'+ expirydate.formatGmt('HH:mm:ss')+'.'+expirydate.formatGMT('SSS')+'Z'
                    +'","conditions": [ {"bucket": "'+ s3stng.S3BucketName__c +'" } ,'
                     +'["starts-with", "$key", "'+objectname+'"],'
                     +'{ "acl": "'+accessType+'" },'
                     +'{"success_action_redirect": "'+ForRedirect+'"},' 
                    + '["starts-with", "$Content-Type", ""],'
                    + '{"x-amz-meta-uuid": "'+s3stng.meta_uuid__c+'"},'
                    +'{"x-amz-server-side-encryption": "'+ s3ServerSideEncryp +'"},'
                    +'["starts-with", "$x-amz-meta-tag", ""],'
                    +'{"x-amz-credential": "'+credential+'"},'
                    +'{"x-amz-algorithm": "'+s3Algorithm+'"},'
                    +'{"x-amz-date": "'+formattedDateString+'" }'
                    +' ]}';
           
        }
       
    }
    public String getPolicy() {
        return EncodingUtil.base64Encode(Blob.valueOf(strpolicy));
    }
    
    public String getSignedPolicy() {    
        return make_sig(EncodingUtil.base64Encode(Blob.valueOf(strpolicy)));        
    }
    
    
    //method that will sign
    public String make_sig(string canonicalBuffer) { 
        Blob signingKey = createSigningKey(secretKey);       
        String macUrl ;
      
        macUrl= EncodingUtil.convertToHex(Crypto.generateMac(ApplicationLiterals.HMACSHA256, Blob.valueOf(canonicalBuffer), signingKey));              
        return macUrl;
    }
    
    public Blob createSigningKey(String secretKey) {
        Blob signingKey = Crypto.generateMac(ApplicationLiterals.HMACSHA256, Blob.valueOf(s3stng.RequestType__c),
            Crypto.generateMac(ApplicationLiterals.HMACSHA256, Blob.valueOf(s3stng.Service__c),
                Crypto.generateMac(ApplicationLiterals.HMACSHA256, Blob.valueOf(s3stng.FormPostRegion__c),
                    Crypto.generateMac(ApplicationLiterals.HMACSHA256, Blob.valueOf(currenttime.formatGMT('YYYYMMdd')), Blob.valueOf('AWS4'+secretKey))
                )
            )
        );
        return signingKey;
    }
    
    
    
}