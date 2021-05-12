@isTest
public with sharing class AWS_Upload_ControllerTest {
    
     static testMethod void testAWS_Upload(){
     	
     	AWS_Upload_Controller ctrl = new AWS_Upload_Controller();
     	
     	String getPolicy = ctrl.getPolicy();
     	String getSignedPolicy = ctrl.getSignedPolicy();
     	ctrl.uploadDocument();
     	
     }
    
}