@isTest
private class SignUpForNewsLetterRestTest {
    
    private static testMethod void testExistingEmail(){
        SignUpForNewsLetterRest.RequestWrapper requestWr= new SignUpForNewsLetterRest.RequestWrapper();
        Account acc = createAccount();
        requestWr.firstName = '';
        requestWr.lastName = 'testLastName';
        requestWr.email='kanika.choubey1@gmail.com';
        requestWr.hasSubscribed = true;
        requestWr.Region='UK';
        requestWr.language='FR';
        String JsonRequest=JSON.serialize(requestWr);
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'https://psldevint-brevilleusa.cs19.force.com/eComm/services/apexrest/SignUpForNewsLetter';//url 
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueOf(JsonRequest);
        RestContext.request = req;
        RestContext.response= res;
        SignUpForNewsLetterRest.ResponseWrapper responseWr = SignUpForNewsLetterRest.createNewCase(requestWr);
        acc=[Select id,Agreed_for_Opt_in__c  from account where id=:acc.id];  
    }
    private static testMethod void testNewEmail(){
        SignUpForNewsLetterRest.RequestWrapper requestWr= new SignUpForNewsLetterRest.RequestWrapper();
        //Account acc = createAccount();
        //requestWr.firstName = '';
        requestWr.lastName = 'testLastName';
        requestWr.email='kanika.choubey1@gmail.com';
        requestWr.hasSubscribed = true;
        requestWr.Region='AU';
        requestWr.language='EN';
        String JsonRequest=JSON.serialize(requestWr);
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'https://psldevint-brevilleusa.cs19.force.com/eComm/services/apexrest/SignUpForNewsLetter';//url 
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueOf(JsonRequest);
        RestContext.request = req;
        RestContext.response= res;
        SignUpForNewsLetterRest.ResponseWrapper responseWr = SignUpForNewsLetterRest.createNewCase(requestWr);
        Account acc = [Select id,Agreed_for_Opt_in__c from account where id = :responseWr.ID];
    }
    
    private static testMethod void testNullLanguagePreference(){
        SignUpForNewsLetterRest.RequestWrapper requestWr= new SignUpForNewsLetterRest.RequestWrapper();
        Account acc = createAccount();
        requestWr.firstName = '';
        requestWr.lastName = 'testLastName';
        requestWr.email='kanika.choubey1@gmail.com';
        requestWr.hasSubscribed = true;
        requestWr.Region='UK';
        String JsonRequest=JSON.serialize(requestWr);
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'https://psldevint-brevilleusa.cs19.force.com/eComm/services/apexrest/SignUpForNewsLetter';//url 
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueOf(JsonRequest);
        RestContext.request = req;
        RestContext.response= res;
        SignUpForNewsLetterRest.ResponseWrapper responseWr = SignUpForNewsLetterRest.createNewCase(requestWr);
    }
    
    private static testMethod void testIncorrectLanguagePreference(){
        SignUpForNewsLetterRest.RequestWrapper requestWr= new SignUpForNewsLetterRest.RequestWrapper();
        Account acc = createAccount();
        requestWr.firstName = '';
        requestWr.lastName = 'testLastName';
        requestWr.email='kanika.choubey1@gmail.com';
        requestWr.hasSubscribed = true;
        requestWr.Region='UK';
        requestWr.language='abcdef';
        String JsonRequest=JSON.serialize(requestWr);
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'https://psldevint-brevilleusa.cs19.force.com/eComm/services/apexrest/SignUpForNewsLetter';//url 
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueOf(JsonRequest);
        RestContext.request = req;
        RestContext.response= res;
        SignUpForNewsLetterRest.ResponseWrapper responseWr = SignUpForNewsLetterRest.createNewCase(requestWr);
    }

    private static testMethod void testInvalidEmail(){
        SignUpForNewsLetterRest.RequestWrapper requestWr= new SignUpForNewsLetterRest.RequestWrapper();
        //Account acc = createAccount();
        requestWr.firstName = '';
        requestWr.lastName = 'testLastName';
        requestWr.email='testEmail';
        requestWr.hasSubscribed = true;
        requestWr.Region='US';
        String JsonRequest=JSON.serialize(requestWr);
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'https://psldevint-brevilleusa.cs19.force.com/eComm/services/apexrest/SignUpForNewsLetter';//url 
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueOf(JsonRequest);
        RestContext.request = req;
        RestContext.response= res;
        SignUpForNewsLetterRest.ResponseWrapper responseWr = SignUpForNewsLetterRest.createNewCase(requestWr);
    }
    
    
    
    
    private static testMethod void testNullEmail(){
        SignUpForNewsLetterRest.RequestWrapper requestWr= new SignUpForNewsLetterRest.RequestWrapper();
        //Account acc = createAccount();
        requestWr.firstName = '';
        requestWr.lastName = 'testLastName';
        requestWr.email='';
        requestWr.hasSubscribed = true;
        requestWr.Region='CA';
        String JsonRequest=JSON.serialize(requestWr);
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'https://psldevint-brevilleusa.cs19.force.com/eComm/services/apexrest/SignUpForNewsLetter';//url 
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueOf(JsonRequest);
        RestContext.request = req;
        RestContext.response= res;
        SignUpForNewsLetterRest.ResponseWrapper responseWr = SignUpForNewsLetterRest.createNewCase(requestWr);
    }
    
    private static testMethod void testNullSubscription(){
        SignUpForNewsLetterRest.RequestWrapper requestWr= new SignUpForNewsLetterRest.RequestWrapper();
        //Account acc = createAccount();
        requestWr.firstName = '';
        requestWr.lastName = 'testLastName';
        requestWr.email='';
        requestWr.Region='NZ';
        String JsonRequest=JSON.serialize(requestWr);
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'https://psldevint-brevilleusa.cs19.force.com/eComm/services/apexrest/SignUpForNewsLetter';//url 
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueOf(JsonRequest);
        RestContext.request = req;
        RestContext.response= res;
        SignUpForNewsLetterRest.ResponseWrapper responseWr = SignUpForNewsLetterRest.createNewCase(requestWr);
    }
    
    private static testMethod void testInvalidLastName(){
        SignUpForNewsLetterRest.RequestWrapper requestWr= new SignUpForNewsLetterRest.RequestWrapper();
        //Account acc = createAccount();
        requestWr.firstName = '';
        requestWr.lastName = '';
        requestWr.email='testEmail@mail.com';
        requestWr.hasSubscribed = true;
        requestWr.Region='US';
        String JsonRequest=JSON.serialize(requestWr);
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'https://psldevint-brevilleusa.cs19.force.com/eComm/services/apexrest/SignUpForNewsLetter';//url 
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueOf(JsonRequest);
        RestContext.request = req;
        RestContext.response= res;
        SignUpForNewsLetterRest.ResponseWrapper responseWr = SignUpForNewsLetterRest.createNewCase(requestWr);
    }
    
    private static testMethod void testInvalidRegion(){
        SignUpForNewsLetterRest.RequestWrapper requestWr= new SignUpForNewsLetterRest.RequestWrapper();
        //Account acc = createAccount();
        requestWr.firstName = '';
        requestWr.lastName = '';
        requestWr.email='testEmail@mail.com';
        requestWr.hasSubscribed = true;
        String JsonRequest=JSON.serialize(requestWr);
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'https://psldevint-brevilleusa.cs19.force.com/eComm/services/apexrest/SignUpForNewsLetter';//url 
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueOf(JsonRequest);
        RestContext.request = req;
        RestContext.response= res;
        SignUpForNewsLetterRest.ResponseWrapper responseWr = SignUpForNewsLetterRest.createNewCase(requestWr);
    }
    
    
    
    
    
    public static Account createAccount(){
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account record = new Account();
        record.lastName = 'lastName';
        record.firstName = 'firstName';
        record.RecordTypeId = accountRecordTypeId;
        record.PersonEmail = 'kanika.choubey1@gmail.com';
        record.TerritoryAssigned__c = false;
        insert record;        
        return record;
    }
    
    
     private static testMethod void testMarketingZipCode(){
        SignUpForNewsLetterRest.RequestWrapper requestWrZip= new SignUpForNewsLetterRest.RequestWrapper();
        //Account acc = createAccount();
        requestWrZip.firstName = 'TestfirstName';
        requestWrZip.lastName = 'TestlastName';
        requestWrZip.email='testEmail@mail.com';
        requestWrZip.hasSubscribed = true;
        requestWrZip.MarketingZipCode = 'Post123';
        requestWrZip.Region='DE';
        requestWrZip.language='EN';
        String JsonRequest=JSON.serialize(requestWrZip);
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'https://psldevint-brevilleusa.cs19.force.com/eComm/services/apexrest/SignUpForNewsLetter';//url 
        req.httpMethod = 'Post';
        req.requestBody = Blob.valueOf(JsonRequest);
        RestContext.request = req;
        RestContext.response= res;
        SignUpForNewsLetterRest.ResponseWrapper responseWr = SignUpForNewsLetterRest.createNewCase(requestWrZip);
        Account acc = [Select id,Marketing_Zip_Code__c from account where id = :responseWr.ID];
    }    
}