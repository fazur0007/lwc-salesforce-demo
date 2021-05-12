public with sharing class GoogleReCaptchaCtrl {
    
    public String googleSiteKey 					{get;set;}
    private String googleSecretKey 					{get;set;}
    private String googleRecaptchaVerifyEndpoint 	{get;set;}
    
    public GoogleReCaptchaCtrl(){
    	
    	//read site key, secret and endpoint from Custom metadata
    	for(All_Literal__mdt appliteral : [Select DeveloperName,Value__c from All_Literal__mdt 
    										where DeveloperName IN ('GoogleReCaptchaEndPoint', 'GoogleSecretkey','GoogleSitekey') ]){
    											
    		if(appliteral.DeveloperName == 'GoogleSitekey'){
    			googleSiteKey = appliteral.Value__c;
    		}else if(appliteral.DeveloperName == 'GoogleSecretkey'){
    			googleSecretKey = appliteral.Value__c;
    		}else if(appliteral.DeveloperName == 'GoogleReCaptchaEndPoint'){
    			googleRecaptchaVerifyEndpoint = appliteral.Value__c;
    		}
    	}
    	
    }
    
    public Boolean validateRecaptchaResponse(String response){
    	
    	Boolean success = false;
    	HttpRequest req = new HttpRequest(); 
 		//Set HTTPRequest Method
  		req.setMethod('POST');
		String endpoint = googleRecaptchaVerifyEndpoint +'?secret='
							+googleSecretKey
							+'&response='+response;
  		req.setEndpoint(endpoint);
		
		//req.se
  		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
  		req.setHeader('Content-Length', String.valueOf(req.getBody().length()));
  		//Set the HTTPRequest body	
  		//req.setBody(body); 	
  		Http http = new Http();
        //Execute web service call here		
        HTTPResponse res = http.send(req);	
        Map<String, Object> responseParsedObject = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        success = (Boolean)responseParsedObject.get('success');
        return success;
				
    }
    
    
}