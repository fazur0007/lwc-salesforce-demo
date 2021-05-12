public with sharing class AWS_Upload_Controller {

public String fileNameInput{get;set;}

    public AWS_Upload_Controller(ApexPages.StandardController controller) {

    }

 
   public string AwsSecretKey{get;set;}
   public string AWSAccessKey{get;set;}
   public string ForRedirect{get;set;}  
   public static string appParentId{get;set;}
   public string Content_Type {get;set;}  
   Public String acessType{get;set;}
   
   public AWS_Upload_Controller(){
    
        AwsSecretKey= 'iaJ5w7vBiZAmj492qtEUokKB/Mmnzb2kRHWNq4++';
        AWSAccessKey='AKIAIRMTARNK43JY5YHA';
        appParentId = ApexPages.currentPage().getParameters().get('parentIdForRedirect');
        ForRedirect = URL.getSalesforceBaseUrl().toExternalForm()+'/'+'apex/AWS_SucessRedirectPage?parentIdForRedirect='+appParentId;
        Content_Type ='multipart/form-data';
        acessType ='private';
      
       //system.debug('awsKeySet'+awsKeySet); 
        system.debug('policy'+policy);
   }
       
       
       Datetime expire = system.now().addDays(1);
       String formattedexpire = expire.formatGmt('yyyy-MM-dd')+'T'+ expire.formatGmt('HH:mm:ss')+'.'+expire.formatGMT('SSS')+'Z';           
          
      string policy { get {return 
        '{ "expiration": "'+formattedexpire+'","conditions": [ {"bucket": "testtapan" } ,{ "acl": "'+acessType+'" },'+
        '{"content-type":"'+Content_Type+'"},'+
        '{"success_action_redirect": "'+ForRedirect+'"},' +
        '["starts-with", "$key", ""] ]}';   } } 
    
    public String getPolicy() {
        return EncodingUtil.base64Encode(Blob.valueOf(policy));
    }
    
    public String getSignedPolicy() {    
        return make_sig(EncodingUtil.base64Encode(Blob.valueOf(policy)));        
    }
    
    
    //method that will sign
    private String make_sig(string canonicalBuffer) {        
        String macUrl ;
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(AwsSecretKey)); 
        macUrl = EncodingUtil.base64Encode(mac);                
        return macUrl;
    }
       
     public void uploadDocument() {   
    
    system.debug('File To Upload in Method:'+fileNameInput);  
     
     
     
    }
    
}