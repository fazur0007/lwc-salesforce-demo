@isTest
private class CWSIdentityUtilsTest {

    @isTest static void testGenericServiceEndpoint() {
       String endpoint = CWSIdentityUtils.isSandbox() ? 'https://test.salesforce.com' : 'https://login.salesforce.com';
       System.assertEquals(new URL(endpoint).toExternalForm(),
           CWSIdentityUtils.genericServiceEndpoint().toExternalForm());
    }
    
    @isTest static void testOAuthTokenEndpoint() {
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm() + '/services/oauth2/token';
        System.assertEquals(new URL(endpoint).toExternalForm(),CWSIdentityUtils.oAuthTokenEndpoint().toExternalForm());
    }
    
     @isTest static void testUsernameWithSuffix() {
         String username = 'foo';
         String suffix = [SELECT Value__c FROM Customer_Community_Settings__mdt 
            WHERE DeveloperName = :CWSIdentityUtils.USERNAME_SUFFIX_METADATA_INSTANCE_NAME ]?.Value__c;
        String expected = String.isBlank(suffix) ? username : (username.endsWith(suffix) ? username : username + suffix);
        System.assertEquals(expected,CWSIdentityUtils.usernameWithSuffix(username));
    }
}