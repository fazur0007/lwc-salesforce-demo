@isTest
private class MonitoringApiUtilityTest {
    @isTest
    public static void callMonitoringAPISyncTest() {
        
        Test.setMock(HttpCalloutMock.class, new MonitoringApiMock());
        
        test.startTest();
        
        MonitoringApiUtility.callMonitoringApi('1223', 'Endpoint', Datetime.now().addMinutes(-1), Datetime.now(), 'Success', new Map<String, String> ());

        test.stopTest();
        
    }
    
    @isTest
    public static void callMonitoringAPIAsSyncTest() {
        
        Test.setMock(HttpCalloutMock.class, new MonitoringApiMock());
        
        test.startTest();
        
        MonitoringApiUtility.callMonitorApiAsync('1223', 'Endpoint', Datetime.now().addMinutes(-1), Datetime.now(), 'Success', new Map<String, String> {'a' => '1', 'b' => '2'});

        test.stopTest();
        
    }
    
    class MonitoringApiMock implements HttpCalloutMock {
        String jsonResponse =  '{' +
            '"SendMessageResponse": {' +
                '"ResponseMetadata": {' +
                    '"RequestId": "bc6c1e28-2847-5664-86f4-4986c62148e5"' +
                '},' +
                '"SendMessageResult": {' +
                    '"MD5OfMessageAttributes": null,' +
                    '"MD5OfMessageBody": "d751713988987e9331980363e24189ce",' +
                    '"MD5OfMessageSystemAttributes": null,' +
                    '"MessageId": "7bdc1792-a67e-49c8-bf93-b551fd285338",' +
                    '"SequenceNumber": null' +
                '}' +
            '}' +
        '}';
   
 

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setStatusCode(200);
            res.setStatus('Complete');
            res.setBody(jsonResponse);
            return res; 
        }
    }
}