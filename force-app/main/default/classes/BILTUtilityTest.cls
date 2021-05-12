@isTest
public class BILTUtilityTest {
    
    @isTest
    private static void testGetProductRegistrations() {
        Test.setMock(HttpCalloutMock.class, new BILTApiMock(API.Registrations));
        Test.startTest();
        BILT.ProductRegistrationResponse response = BILTUtility.getProductRegistrations();
        System.assertNotEquals(null, response);
        System.assertEquals(1, response.data.size());
        System.assertEquals(2, response.data[0].registrations.size());
        System.assertEquals('Breville', response.data[0].manufacturerName);
        System.assertEquals('BES450', response.data[0].modelNumber);
        System.assertEquals('the Bambino™', response.data[0].productName);
        System.assertEquals(true, response.context.withSubsidiaries);
        System.assertNotEquals(null, response.context.startTimestamp);
        System.assertEquals('US', response.data[0].registrations[0].notClassifiedAttributes.APP_COUNTRY);
        System.assertEquals(null, response.data[0].registrations[0].notClassifiedAttributes.serialNum);
        System.assertEquals('BES450', response.data[0].registrations[0].attributes.product_info.MODEL_NUMBER);
        System.assertEquals('Bed Bath & Beyond', response.data[0].registrations[0].attributes.product_info.placeOfPurchase);
        System.assertEquals('A1BUAESA203601066', response.data[0].registrations[0].attributes.product_info.DATE_CODE);
        Test.stopTest();
    }
    
    @isTest
    private static void testGetProducts() {
        Test.setMock(HttpCalloutMock.class, new BILTApiMock(API.Products));
        Test.startTest();
        BILT.ProductIntegrationResponse response = BILTUtility.getProducts();
        System.assertNotEquals(null, response);
        System.assertEquals(1, response.available.size());
        System.assertEquals('Breville', response.available[0].brand.name);
        System.assertEquals('the Bambino™', response.available[0].name);
        System.assertNotEquals(null, response.available[0].skuNumbers);
        System.assertNotEquals(null, response.available[0].languages);
        System.assertEquals('BES450', response.available[0].model[0]);
        System.assertEquals(4, response.available[0].countries.size());
        System.assertEquals('Australia', response.available[0].countries[0].name);
        System.assertEquals('AU', response.available[0].countries[0].code);
        Test.stopTest();
    }
    
    @isTest
    private static void testUpdateTimeStamp() {
        Test.startTest();
        System.enqueueJob(new BILTUtility.UpdateTimeStamp('1611813852731'));
        Test.stopTest();
    }
    
    
    public enum API {
        Products,
        Registrations
    }
    
    private static Map<API, String> API_RESPONSE = new Map<API, String> {
        API.Products => '[{"available":[{"id":"m-c9b697c81fe891d6","name":"the Bambino™","model":["BES450"],"languages":["EN_US"],"skuNumbers":[],"brand":{"id":"co-3625f95663a3c13e","name":"Breville"},"countries":[{"name":"Australia","code":"AU"},{"name":"Brazil","code":"BR"},{"name":"Japan","code":"JP"},{"name":"New Zealand","code":"NZ"}]}]},{"not-available":["m-af242445eee7909a","m-a23f875703ff3e6f","m-365b10cb102cd9e0","m-b413a2d73bf5f9ee","m-700d0a42be653a4c"]}]',
        API.Registrations => '{"context":{"startTimestamp":-2208988800000,"endTimestamp":1611813852731,"withSubsidiaries":true},"data":[{"manufacturerName":"Breville","modelNumber":"BES450","productName":"the Bambino™","registrations":[{"purchaseDate":"2020-11-20T00:00:00","registered":"2020-12-26T05:55:02.031","notClassifiedAttributes":{"APP_COUNTRY":"US","serialNum":null},"attributes":{"user_info":{"firstName":"Test","lastName":"abc","ADDRESS_LINE1":"456456 4gdfg Ave #7","COUNTRY":"United States","CITY":"Gardena","ZIP_CODE":"90247-4766","PHONE":"Gardena","OPT_IN_MARKETINGEMAILS":"YES","STATE":"California","confimrEmail":"test@test.com","email":"test@test.com"},"product_info":{"DATE_CODE":"A1BUAESA203601066","MODEL_NUMBER":"BES450","placeOfPurchase":"Bed Bath & Beyond"}}},{"purchaseDate":"2020-12-22T00:00:00","registered":"2020-12-26T23:28:11.825","notClassifiedAttributes":{"APP_COUNTRY":"US","serialNum":null},"attributes":{"user_info":{"firstName":"Test","lastName":"dsdfsdf","ADDRESS_LINE1":"sdf sdf Rd","CITY":"Irvine","COUNTRY":"United States","ZIP_CODE":"92604","PHONE":"9492950969","STATE":"CA","OPT_IN_MARKETINGEMAILS":"YES","confimrEmail":"test2@test.com","email":"test2@test.com"},"product_info":{"DATE_CODE":"A1buaesa202904186","MODEL_NUMBER":"BES450","placeOfPurchase":"Bed Bath & Beyond"}}}]}]}'
    };
     
    public class BILTApiMock implements HttpCalloutMock {
        String response;
        public BILTApiMock(API apiType) {
            this.response = API_RESPONSE.get(apiType);
        }
            
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setStatusCode(200);
            res.setStatus('Complete');
            res.setBody(this.response);
            return res; 
        }
    }
}