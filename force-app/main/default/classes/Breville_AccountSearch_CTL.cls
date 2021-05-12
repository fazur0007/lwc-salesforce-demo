public with sharing class Breville_AccountSearch_CTL {
    static String sanitizeQueryString(String aQuery) {
        if (aQuery == null) return '%';

        String trimmedQuery = aQuery.trim();
        if (trimmedQuery.length() == 0) return '%';
        return '%' + trimmedQuery.replaceAll('\\W+', '%') + '%';
    }
    @AuraEnabled
    public static List < Account > searchAllAccounts (String nameFilterString) {
        String composedFilter = sanitizeQueryString(nameFilterString);
        return [
            SELECT Id, Name, Email_External_ID__c,Phone,BillingAddress,ShippingAddress 
            FROM Account
            WHERE Email_External_ID__c LIKE: composedFilter
            ORDER BY Name ASC Limit 100
        ];
    }
}