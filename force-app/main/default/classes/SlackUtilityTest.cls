@isTest
public with sharing class SlackUtilityTest {
    
    @isTest
    private static void PositiveTest() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new SlackUtilityMock(true));
        SlackUtility.SlackPost post = new SlackUtility.SlackPost(true);
        post.isSuccess = false;
        post.text = 'New From Salesforce';
        post.fields = new List<SlackUtility.SlackField> {
            new SlackUtility.SlackField('Field 1', 'Value1'),
            new SlackUtility.SlackField('Field 2', 'Value2')
        };
        System.debug(post);
        SlackUtility.postToSlack('X810', post);
        
        Test.stopTest();
    }
    
    @isTest
    private static void NegativeTest() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new SlackUtilityMock(false));
        SlackUtility.SlackPost post = new SlackUtility.SlackPost(true);
        post.isSuccess = false;
        post.text = 'New From Salesforce';
        System.debug(post);
        SlackUtility.postToSlack('X810', post);
        
        Test.stopTest();
    }
    
    public class SlackUtilityMock implements HttpCalloutMock {
        String response;
        Integer statusCode;
        
        public SlackUtilityMock(Boolean isSuccess) {
            if (isSuccess) {
                response = 'ok';
                statusCode = 200;
            } else {
                response = 'invalid_payload';
                statusCode = 400;
            }
        }
    
        public HTTPResponse respond(HTTPRequest req) {
          HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/html');
            res.setStatusCode(this.statusCode);
            res.setStatus('Complete');
            res.setBody(this.response);
            return res; 
        }
    }
}