public class CWSIdentityTokenRepository {

    private static final CWSIdentityTokenRepository INSTANCE = new CWSIdentityTokenRepository();
    
    public static CWSIdentityTokenRepository getInstance(){
       return INSTANCE;
    }
    
    private Identity_Service_Token__c tokenOrNullRaw(List<Identity_Service_Token__c> tokens) {
         return tokens != null && tokens.size() == 1 ? tokens[0] : null;
    }
    
    private CWSIdentityToken tokenOrNull(List<Identity_Service_Token__c> tokens) {
         return tokens != null && tokens.size() == 1 ? new CWSIdentityToken(tokens[0]) : null;
    }
    
    public void redeemAndSave(CWSIdentityToken token) {
    
        if (!token.isRedeemable()) return;
    
        List<Identity_Service_Token__c> tokens = [
            SELECT Id, Redeemed__c
            FROM Identity_Service_Token__c 
            WHERE Token__c = :token.value
            LIMIT 1 
            FOR UPDATE]; 
            
        Identity_Service_Token__c aToken = tokenOrNullRaw(tokens);
         if (aToken != null) {
             aToken.Redeemed__c = true;
             update aToken;
             token.setRedeemed(true); // points to the same record as aToken so keep it in sync with the database
         }
    }
    
     public CWSIdentityToken findOneByValueAndRedeemed(String tokenValue, boolean redeemed) {
        System.debug(String.format('Locating an Identity_Service_Token__c record with token value = {0} and redeemed = {1}',
            new List<Object>{tokenValue,redeemed}));
          
        List<Identity_Service_Token__c> tokens = [
            SELECT Id, Expires_On__c, Redeemed__c, Subject__c,Token_Type__c,Token__c,Client__c
            FROM Identity_Service_Token__c 
            WHERE Token__c = :tokenValue AND Redeemed__c = :redeemed 
            LIMIT 1];
        return tokenOrNull(tokens);
    }
    
    public CWSIdentityToken findOneByValue(String tokenValue) {
        System.debug(String.format('Locating an Identity_Service_Token__c record with token value = {0}',
            new List<Object>{tokenValue}));
          
        List<Identity_Service_Token__c> tokens = [
            SELECT Id, Expires_On__c, Redeemed__c, Subject__c,Token_Type__c,Token__c,Client__c
            FROM Identity_Service_Token__c 
            WHERE Token__c = :tokenValue 
            LIMIT 1];
        return tokenOrNull(tokens);
    }
    
    @TestVisible private List<Identity_Service_Token__c> findAllByUsageAndIssuedTo(String tokenType, Id issuedTo) {
         return [
            SELECT Id, Expires_On__c, Redeemed__c, Subject__c,Token_Type__c,Token__c,Client__c
            FROM Identity_Service_Token__c 
            WHERE Token_Type__c = :tokenType AND Subject__c = :issuedTo];
    }
    
}