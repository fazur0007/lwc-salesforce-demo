/*
    @Author  : Fazurulla Ganganapalli
    @Handler : ContactPointAddressHandler
    @Purpose : This class is responsible for swapping the address between parent and child records.
    @Date    : 30-10-2020
    @History : Added new logic to turn off idDefault checkbox for all records.
*/
public class ContactPointAddressHandler {
    public static boolean isExecuted = True;
    /*Method : This method will update child record with parent info*/
    public static void doUpdateContactPointAddressWithPrentObject(List < ContactPointAddress > ContactPointAddressList, Map < Id, Account > mapOfAccounts) {
        List < ContactPointAddress > listOfContactPointAddress = new List < ContactPointAddress > ();
        for (ContactPointAddress contactPointAddressObj: ContactPointAddressList) {
            if (mapOfAccounts.containsKey(contactPointAddressObj.ParentId) && contactPointAddressObj.IsDefault) {
                ContactPointAddress contactPointAddrss = new ContactPointAddress(
                    Id = contactPointAddressObj.Id,
                    ParentId = mapOfAccounts.get(contactPointAddressObj.ParentId).Id,
                    Name = String.isNotBlank(contactPointAddressObj.Name) ? contactPointAddressObj.Name : doCheckNulls(mapOfAccounts.get(contactPointAddressObj.ParentId).Name),
                    AddressType = 'Shipping',
                    Street = doCheckNulls(mapOfAccounts.get(contactPointAddressObj.ParentId).ShippingStreet),
                    City = doCheckNulls(mapOfAccounts.get(contactPointAddressObj.ParentId).ShippingCity),
                    PostalCode = doCheckNulls(mapOfAccounts.get(contactPointAddressObj.ParentId).ShippingPostalCode),
                    State = doCheckNulls(mapOfAccounts.get(contactPointAddressObj.ParentId).ShippingState),                    
                    Country = doCheckNulls(mapOfAccounts.get(contactPointAddressObj.ParentId).ShippingCountry),
                    Shipping_Street_Line_1__c = doCheckNulls(mapOfAccounts.get(contactPointAddressObj.ParentId).Shipping_Street_Line_1__c),
                    Shipping_Street_Line_2__c = doCheckNulls(mapofAccounts.get(contactPointAddressObj.ParentId).Shipping_Street_Line_2__c)
                );
                listOfContactPointAddress.add(contactPointAddrss);
            }
        }
        if (isExecuted) {
            isExecuted = False;
            system.debug('***listOfContactPointAddress**'+listOfContactPointAddress);
            if (listOfContactPointAddress.size() > 0) {
                Update listOfContactPointAddress;
            }
        }

    }
    public static string doCheckNulls(String addressString){
        return String.isNotBlank(addressString) ? addressString : null;
    }
    public static void doUpdateSelectedRecordDefault(Set < Id > setOfContactPointAddressIds, Map < Id, Account > mapOfAccounts) {
        List < ContactPointAddress > listOfParentRelatedRecordsToUpdate = new List < ContactPointAddress > ();
        for (Account acct: mapOfAccounts.values()) {
            List < ContactPointAddress > listOfParentRelatedRecords = acct.ContactPointAddresses;
            if (listOfParentRelatedRecords.size() > 0) {
                for (ContactPointAddress contactPointAddressObj: listOfParentRelatedRecords) {
                    //if (!setOfContactPointAddressIds.contains(contactPointAddressObj.Id)) {
                        listOfParentRelatedRecordsToUpdate.add(
                            new ContactPointAddress(
                                Id = contactPointAddressObj.Id,
                                IsDefault = false
                            )
                        );
                    //}
                }
            }
        }
        if (listOfParentRelatedRecordsToUpdate.size() > 0) {
            update listOfParentRelatedRecordsToUpdate;
        }
    }
    /*Method : This method will update parent record with child info*/
    public static void doUpdateAccountAddressWithChildObject(List < ContactPointAddress > ContactPointAddressList, Map < Id, Account > mapOfAccounts) {
        List < Account > acctListToUpdate = new List < Account > ();
        for (ContactPointAddress contactPointAddressObj: ContactPointAddressList) {
            if (contactPointAddressObj.IsDefault) {
                if (mapOfAccounts.containsKey(contactPointAddressObj.ParentId)) {
                    Account acctObj = new Account();
                    acctObj.Id = mapOfAccounts.get(contactPointAddressObj.ParentId).Id;
                    acctObj.ShippingStreet = doCheckNulls(contactPointAddressObj.Street);
                    acctObj.ShippingCity = doCheckNulls(contactPointAddressObj.City);
                    acctObj.ShippingPostalCode = doCheckNulls(contactPointAddressObj.PostalCode);
                    acctObj.ShippingState = doCheckNulls(contactPointAddressObj.State);
                    acctObj.ShippingCountry = doCheckNulls(contactPointAddressObj.Country);
                    acctObj.Shipping_Street_Line_1__c = doCheckNulls(contactPointAddressObj.Shipping_Street_Line_1__c);
                    acctObj.Shipping_Street_Line_2__c = doCheckNulls(contactPointAddressObj.Shipping_Street_Line_2__c);
                    acctListToUpdate.add(acctObj);
                }
            }
        }
        system.debug('*****'+acctListToUpdate);
        if (acctListToUpdate.size() > 0) {
            update acctListToUpdate;
        }
    }
    /*Method : This method will collect account records*/
    public static Map < Id, Account > doGetAccountsandRelatedContactPointAddresses(Set < Id > setOfAccountIds) {
        return new Map < Id, Account > ([
            Select Id, Name, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingCountryCode, ShippingState, ShippingCountry,
            Shipping_Street_Line_1__c,Shipping_Street_Line_2__c,
            (Select Id, ParentId, Name, Street, City, PostalCode, State, Country, IsDefault,
             Shipping_Street_Line_1__c,Shipping_Street_Line_2__c From ContactPointAddresses)
            From Account Where Id IN: setOfAccountIds
        ]);
    }
    /*Method : Main method to call from trigger*/
    public static void doUpdateCreateAccountContactPointAddress(List < ContactPointAddress > ContactPointAddressList) {
        Set < Id > setOfAccountIds = new Set < Id > ();
        Set < Id > setOfContactPointAddressIds = new Set < Id > ();
        for (ContactPointAddress contactPointAddressObj: ContactPointAddressList) {
            if (contactPointAddressObj.IsDefault) {
                setOfAccountIds.add(contactPointAddressObj.ParentId);
                setOfContactPointAddressIds.add(contactPointAddressObj.Id);
            }
        }
        if (setOfAccountIds.size() > 0 && setOfContactPointAddressIds.size() > 0) {
            Map < Id, Account > mapOfAccounts = doGetAccountsandRelatedContactPointAddresses(setOfAccountIds);
            //Swapping logic would be executed here            
            doUpdateContactPointAddressWithPrentObject(ContactPointAddressList, mapOfAccounts);
            doUpdateAccountAddressWithChildObject(ContactPointAddressList, mapOfAccounts);
            doUpdateSelectedRecordDefault(setOfContactPointAddressIds, mapOfAccounts);
        }
    }
}