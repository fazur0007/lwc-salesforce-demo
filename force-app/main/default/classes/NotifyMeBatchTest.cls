@isTest
public class NotifyMeBatchTest {
    
    @testsetup
    static void setup(){
        List<Product_Preference__c> productPreferenceList = new List<Product_Preference__c>();
        Product2 prod1 = createProduct('CA');
        Product2 prod2 = createProduct('AU');
        Account account1 = createAccount('ABC', 'abc@example.com');
        Account account2 = createAccount('XYZ', 'xyz@example.com');
        List<Product2> productList = new List<Product2>();
        for(Integer i=0;i<100;i++){
            	Product_Preference__c productPreference = new Product_Preference__c();
            	Product_Preference__c productPreference1 = new Product_Preference__c();
            	
            	if(math.mod(i, 2)==0) {
                	productPreference.Channel__c ='CCC';
            		productPreference.ProductID__c = prod2.id;
            		productPreference.Account__c = account1.id;
            		productPreference.currencyIsoCode = 'AUD';
                    productPreference.Country_code__c = 'AUS';
            	} else {
                	productPreference.Channel__c='ECOMM';
                	productPreference.ProductID__c = prod1.id;
            		productPreference.Account__c = account2.id;
            		productPreference.currencyIsoCode = 'CAD';
                    productPreference.Country_code__c = 'CAN';
            	}
            productPreferenceList.add(productPreference);
           	//productPreferenceList.add(productPreference1);
        }
        
        //productList.add(new Product2(name='testProduct',CurrencyIsoCode = 'GBP',AX_Item_Number__c='SP0010165',Quantity_Available__c=199,Quantity_Available_Web__c=199,AX_Unique_ID__c='BAUSP0010165',Available_To_Sell__c=true));
       	//productList.add(new Product2(name='testProduct1',CurrencyIsoCode = 'CAD',AX_Item_Number__c='SP0010166',Quantity_Available__c=199,Quantity_Available_Web__c=199,AX_Unique_ID__c='BCASP0010166',Available_To_Sell__c=true));

        
        insert productPreferenceList;
       // insert productList;
        //Product2 prod = new Product2(Name = 'BEM800XL-99',AX_Item_Number__c='SP0010165',Quantity_Available__c='20',Quantity_Available_Web__c='13',AX_Unique_ID__c='');
    }
    
    /*static testMethod void NotifyBatch(){
        Test.startTest();
        NotifyMeBatch.schduleBatch();
        //NotifyMeBatch nmb = new NotifyMeBatch();
        //Id batchId = Database.executeBatch(nmb);
        Test.stopTest();
        List<Product_Preference__c> productPreferenceList = [Select id,Product_Available__c,AX_item_number__c, Country_code__c from Product_Preference__c];
        for(Product_Preference__c pr:productPreferenceList)
        {
            System.debug('Product: ' + pr.AX_item_number__c + pr.Product_Available__c);
			//System.assertEquals(true, pr.Product_Available__c);
        }
    }*/
    
    static testMethod void testSchedulable(){
        Test.startTest();
        String jobId = System.schedule('Test', '0 0 15 * * ?', new NotifyMeBatch('AUD'));
        // Get the information from the CronTrigger API object
        CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered
                          FROM CronTrigger 
                          WHERE id = :jobId ];
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        String jobId1 = System.schedule('Testing', '0 0 14 * * ?', new NotifyMeBatch('CAD'));
        // Get the information from the CronTrigger API object
        CronTrigger ct1 = [ SELECT Id, CronExpression, TimesTriggered
                          FROM CronTrigger 
                          WHERE id = :jobId1 ];
        // Verify the job has not run
        System.assertEquals(0, ct1.TimesTriggered);
        Test.stopTest();
    }
    
    public static Account createAccount(String lname, String email){
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account record = new Account();
        record.lastName = lname;
        record.firstName = 'firstName';
        record.RecordTypeId = accountRecordTypeId;
        record.PersonEmail = email;
        record.TerritoryAssigned__c = false;
        insert record;        
        return record;
    }
    public static Product2 createProduct(String region){
        Product2 prod = new Product2(name='testProduct',AX_Item_Number__c='123456',IsActive=true,Country_Code__c= region);
        prod.AX_Unique_ID__c = 'B'+ region + '123456';
        prod.Quantity_Available__c = 40;
        prod.Quantity_Available_Web__c = 40;
        insert prod;
        return prod;
    }

}