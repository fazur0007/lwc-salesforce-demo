public class EventTriggerHandler{
    public static void populateLocation(list<Event> eventList){
        map<Id, Id> siteVisitIdToAccountId = new map<Id, Id>();
        map<Id, Account> siteVisitIdToAccount = new map<Id, Account>(); 
        for(Event record : eventList){
            if(record.WhatId != null && record.WhatId.getSObjectType().getDescribe().getName() == 'Site_Visit__c'){
                siteVisitIdToAccount.put(record.WhatId, null);
            }
        }
        for(Site_Visit__c record : [SELECT Id, Account__c, Account__r.ShippingStreet, Account__r.ShippingCity, 
                                   Account__r.ShippingState, Account__r.ShippingPostalCode, Account__r.ShippingCountry 
                                   FROM Site_Visit__c WHERE ID IN :siteVisitIdToAccount.keySet()]){
            siteVisitIdToAccount.put(record.Id, record.Account__r);
        }
        for(Event record : eventList){
            if(record.Location == null || record.Location == ''){
                if(record.WhatId != null && record.WhatId.getSObjectType().getDescribe().getName() == 'Site_Visit__c'){
                    if(siteVisitIdToAccount != null && siteVisitIdToAccount.size() > 0 && siteVisitIdToAccount.get(record.WhatId) != null){
                        Account accountRecord = siteVisitIdToAccount.get(record.WhatId);
                        String location = '';
                        if(accountRecord.ShippingStreet != null && accountRecord.ShippingStreet != ''){
                            location += accountRecord.ShippingStreet +', ';
                        }
                        if(accountRecord.ShippingCity != null && accountRecord.ShippingCity != ''){
                            location += accountRecord.ShippingCity +', ';
                        }
                        if(accountRecord.ShippingState != null && accountRecord.ShippingState != ''){
                            location += accountRecord.ShippingState +', ';
                        }
                        if(accountRecord.ShippingPostalCode != null && accountRecord.ShippingPostalCode != ''){
                            location += accountRecord.ShippingPostalCode +', ';
                        }
                        if(accountRecord.ShippingCountry != null && accountRecord.ShippingCountry != ''){
                            location += accountRecord.ShippingCountry;
                        }
                        if(location != '' && location.substring(location.length()-1).equals(',')){
                            location = location.subString(0, location.length()-1);
                        }
                        record.Location = location;
                    }
                }
            }
        }
    }
}