@isTest public class DeleteContactPointAddressAPI_Test {

    @testSetup static void dataSetup() {
        ContactPointAddress contactPointAddressObj = new ContactPointAddress (Name = 'Testing');
        insert contactPointAddressObj;
    }
    @isTest public static void testDeleteNegitive() {
        ContactPointAddress ContactPointAddressObj = [ SELECT Id FROM ContactPointAddress LIMIT 1 ];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/ContactPointAddress/'+ContactPointAddressObj.Id;
        req.httpMethod = 'DELETE';
        RestContext.request = req;
        RestContext.response= res;
        DeleteContactPointAddressAPI.doDelete();
        DeleteContactPointAddressAPI.doDelete();
        system.assertEquals( [ SELECT COUNT() FROM ContactPointAddress], 0);
    }
    
}