@isTest
public with sharing class WarrantyIndiocatorExtensiontest {
    
    static testMethod void testMethodWarrantyIndicatorExtension(){
        
        Test.Starttest();
            Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
            Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, false);
            productRecord.Finished_Good__c = true;
            productRecord.Spare_Part__c = false;
            productRecord.CurrencyIsoCode = 'USD';
            insert productRecord;
            Case caseRecord2 = TestDataFactory.createCase(accountRecord.id,'Phone','Open','Test Case without asset','USD', 
            												productRecord.id, 'Support & Service','Circulation','1130', Date.today(),'', true);
            ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord2);
            WarrantyIndicatorExtension warrantyExtension= new WarrantyIndicatorExtension(sc);
        Test.Stoptest();
    }
    
}