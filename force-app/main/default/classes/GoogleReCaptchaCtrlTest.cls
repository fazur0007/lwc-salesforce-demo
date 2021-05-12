@isTest
global with sharing class GoogleReCaptchaCtrlTest 
{
	global class ExampleCalloutMock implements HttpCalloutMock{
  	global HttpResponse respond(HTTPRequest req){
    		HttpResponse res = new HttpResponse();
    		// Create a fake response
	        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
			res.setBody('{ "success": true, "hostname": "salesforce.com" }');
	        res.setStatusCode(200);
	        return res;
	 }
	}
	 static testMethod void testMethodGoogleReCaptchaCtrl(){
		Test.starttest();
			Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
			GoogleReCaptchaCtrl googleReCaptchaCtrlObj = new GoogleReCaptchaCtrl();
			Boolean success = googleReCaptchaCtrlObj.validateRecaptchaResponse('abcdefxyz');
		Test.stoptest();
		System.assertEquals(true, success);
	}
}