public class CWSIdentityUtils {

    @TestVisible  private final static String USERNAME_SUFFIX_METADATA_INSTANCE_NAME = 'User_Prefix';

    @TestVisible private static boolean isSandbox() {
        return [SELECT IsSandbox FROM Organization WHERE Id =:UserInfo.getOrganizationId()].IsSandbox;
    }
    
    public static URL genericServiceEndpoint() {
       String endpoint = String.format('https://{0}.salesforce.com', 
           new List<Object>{isSandbox() ? 'test' : 'login'});
       return new URL(endpoint);

    }
    
    public static URL oAuthTokenEndpoint() {
        return new URL(URL.getSalesforceBaseUrl().toExternalForm() + '/services/oauth2/token');
    }
    
    public static String usernameWithSuffix(String username) {
        String suffix = [SELECT Value__c FROM Customer_Community_Settings__mdt 
            WHERE DeveloperName = :USERNAME_SUFFIX_METADATA_INSTANCE_NAME ]?.Value__c;
        return String.isBlank(suffix) ? username : (username.endsWith(suffix) ? username : username + suffix);
    }
}