@isTest
public class NotifyMeAPITest {
    private static testMethod void testExistingEmail(){
        Account acc = createAccount();
        NotifyMeAPI.RequestWrapper requestWrap= new NotifyMeAPI.RequestWrapper();
        requestWrap.email='abcd@xyz.com';
        requestWrap.AX_Item_Number='123456';
        requestWrap.firstName = 'Fname';
        requestWrap.lastName = 'lname';
        requestWrap.Region='UK';
        requestWrap.language='EN';
        requestWrap.PDPUrl='www.google.com';
        requestWrap.SubscribeToNewsletter = true;
        createProduct(requestWrap);
        NotifyMeAPI.ResponseWrapper responseWrap= NotifyMeAPI.doPost(requestWrap);
        System.assertEquals(true, responseWrap.success);
        
    }
    
    
    private static testMethod void testValidEmail(){
        NotifyMeAPI.RequestWrapper requestWrap= new NotifyMeAPI.RequestWrapper();
        requestWrap.email='abcd@xyz.com';
        requestWrap.lastName='testLastName';
        requestWrap.AX_Item_Number='123456';
        requestWrap.Region='AU';
        requestWrap.language='FR';
        requestWrap.PDPUrl='www.google.com';
        requestWrap.SubscribeToNewsletter = true;
        createProduct(requestWrap);
        NotifyMeAPI.ResponseWrapper responseWrap= NotifyMeAPI.doPost(requestWrap);
        NotifyMeAPI.ResponseWrapper responseWrap2= NotifyMeAPI.doPost(requestWrap);
        System.assertEquals(true, responseWrap2.success);
        
    }
    
    private static testMethod void testNullLanguagePreference(){
        NotifyMeAPI.RequestWrapper requestWrap= new NotifyMeAPI.RequestWrapper();
        requestWrap.email='abcd@xyz.com';
        requestWrap.lastName='testLastName';
        requestWrap.AX_Item_Number='123456';
        requestWrap.Region='AU';
        createProduct(requestWrap);
        NotifyMeAPI.ResponseWrapper responseWrap= NotifyMeAPI.doPost(requestWrap);
        NotifyMeAPI.ResponseWrapper responseWrap2= NotifyMeAPI.doPost(requestWrap);
        System.assertEquals(false, responseWrap2.success);
        
    }
    private static testMethod void testNullPDPUrl(){
        NotifyMeAPI.RequestWrapper requestWrap= new NotifyMeAPI.RequestWrapper();
        requestWrap.email='abcd@xyz.com';
        requestWrap.lastName='testLastName';
        requestWrap.AX_Item_Number='123456';
        requestWrap.Region='AU';
        requestWrap.language='FR';
        NotifyMeAPI.ResponseWrapper responseWrap= NotifyMeAPI.doPost(requestWrap);
        NotifyMeAPI.ResponseWrapper responseWrap2= NotifyMeAPI.doPost(requestWrap);
        System.assertEquals(false, responseWrap2.success);
        
    }
    
    private static testMethod void testInvalidLanguagePreference(){
        NotifyMeAPI.RequestWrapper requestWrap= new NotifyMeAPI.RequestWrapper();
        requestWrap.email='abcd@xyz.com';
        requestWrap.lastName='testLastName';
        requestWrap.AX_Item_Number='123456';
        requestWrap.Region='AU';
        requestWrap.language='abcdefghi';
        createProduct(requestWrap);
        NotifyMeAPI.ResponseWrapper responseWrap= NotifyMeAPI.doPost(requestWrap);
        NotifyMeAPI.ResponseWrapper responseWrap2= NotifyMeAPI.doPost(requestWrap);
        System.assertEquals(false, responseWrap2.success);
        
    }
    private static testMethod void testInvalidProduct(){
        Account acc = createAccount();
        NotifyMeAPI.RequestWrapper requestWrap= new NotifyMeAPI.RequestWrapper();
        requestWrap.email='abcd@xyz.com';
        requestWrap.AX_Item_Number='123456';
        requestWrap.lastName='testLastName';
        requestWrap.Region='UK';
        requestWrap.language='DE';
        requestWrap.PDPUrl='www.google.com';
        NotifyMeAPI.ResponseWrapper responseWrap= NotifyMeAPI.doPost(requestWrap);
        System.assertEquals(false, responseWrap.success);
    }  
    
    private static testMethod void testInValidEmail(){
        NotifyMeAPI.RequestWrapper requestWrap= new NotifyMeAPI.RequestWrapper();
        requestWrap.email='incorrectEmail';
        requestWrap.lastName='testLastName';
        requestWrap.AX_Item_Number='123456';
        requestWrap.Region='CA';
        NotifyMeAPI.ResponseWrapper responseWrap= NotifyMeAPI.doPost(requestWrap);
        System.assertEquals(faLse, responseWrap.success);
        //System.assertEquals(new List<String>{'Please provide a valid email address'}, responseWrap.errors);
    }
    private static testMethod void testNoEmail(){
        NotifyMeAPI.RequestWrapper requestWrap= new NotifyMeAPI.RequestWrapper();
        requestWrap.email='';
        requestWrap.lastName='testLastName';
        requestWrap.AX_Item_Number='123456';
        requestWrap.Region='NZ';
        NotifyMeAPI.ResponseWrapper responseWrap= NotifyMeAPI.doPost(requestWrap);
        System.assertEquals(faLse, responseWrap.success);
        //System.assertEquals(new List<String>{'Insufficient data: Email field is required'}, responseWrap.errors);
    }
    
    
    private static testMethod void testInvalidLastName(){
        NotifyMeAPI.RequestWrapper requestWrap= new NotifyMeAPI.RequestWrapper();
        requestWrap.email='abcd@xyz.com';
        requestWrap.lastName='';
        requestWrap.AX_Item_Number='123456';
        requestWrap.Region='AU';
        createProduct(requestWrap);
        NotifyMeAPI.ResponseWrapper responseWrap= NotifyMeAPI.doPost(requestWrap);
        System.assertEquals(false, responseWrap.success);
        //System.assertEquals(new List<String>{'Insufficient data: LastName field is required'}, responseWrap.errors);
    }
    
    private static testMethod void testInvalidRegion(){
        NotifyMeAPI.RequestWrapper requestWrap= new NotifyMeAPI.RequestWrapper();
        requestWrap.email='abcd@xyz.com';
        requestWrap.lastName='testLastName';
        requestWrap.AX_Item_Number='1234';
        requestWrap.Region='region';
        NotifyMeAPI.ResponseWrapper responseWrap= NotifyMeAPI.doPost(requestWrap);
        System.assertEquals(false, responseWrap.success);
        
    }
    
    private static testMethod void testInvalidAXNumber(){
        NotifyMeAPI.RequestWrapper requestWrap= new NotifyMeAPI.RequestWrapper();
        requestWrap.email='abcd@xyz.com';
        requestWrap.lastName='testLastName';
        requestWrap.AX_Item_Number='';
        requestWrap.Region='US';
        NotifyMeAPI.ResponseWrapper responseWrap= NotifyMeAPI.doPost(requestWrap);
        System.assertEquals(false, responseWrap.success);
        
    }
    private static testMethod void testSubscribeToNewsletter(){
        Account acc = createAccount();
        NotifyMeAPI.RequestWrapper requestWrap= new NotifyMeAPI.RequestWrapper();
        requestWrap.email='abcd@xyz.com';
        requestWrap.AX_Item_Number='123456';
        requestWrap.lastName='testLastName';
        requestWrap.Region='UK';
        requestWrap.language='EN';
        requestWrap.SubscribeToNewsletter=true;
        createProduct(requestWrap);
        requestWrap.PDPUrl='www.google.com';
        requestWrap.SubscribeToNewsletter = true;
        NotifyMeAPI.ResponseWrapper responseWrap= NotifyMeAPI.doPost(requestWrap);
        System.assertEquals(true, responseWrap.success);
    }  
    public static Account createAccount(){
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account record = new Account();
        record.lastName = 'lastName';
        record.firstName = 'firstName';
        record.RecordTypeId = accountRecordTypeId;
        record.PersonEmail = 'abcd@xyz.com';
        record.TerritoryAssigned__c = false;
        insert record;        
        return record;
    }
    public static Product2 createProduct(NotifyMeAPI.RequestWrapper request){
        String countryCode = Utility.fetchRegionCodeFromEPRegionAPI(request.region);
        Product2 prod = new Product2(name='testProduct',AX_Item_Number__c='123456',IsActive=true,Country_Code__c=countryCode);
        prod.AX_Unique_ID__c = Utility.fetchBusinessUnitEPRegionAPI(request.region)+''+request.AX_Item_Number;
        insert prod;
        return prod;
    }
    
}