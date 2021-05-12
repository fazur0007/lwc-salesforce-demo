@isTest
public class TroubleshootHelperTest {
@isTest
    public static void testNoFlow()
    {
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount','Palekar99', false);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NY';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'Us';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NY';
        accountRecord.ShippingStreet = 'ghi';
        accountRecord.recordtypeid = [select id from recordtype where name='Person Account'].Id;
        insert accountRecord;
        
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,false);
        productRecord.Quantity_Available__c =25;
        productRecord.Isactive = true;
        productRecord.Product_Type__c = 'FG';
        productRecord.Finished_Good__c = True;
        productRecord.Spare_Part__c = False; 
        productRecord.Accessory__c = False;
        insert productRecord;
        
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', false);
        caseRecord.Product__c = productRecord.Id;
        caseRecord.Type='Support & Service';
        insert caseRecord;
        TroubleshootHelper.GetFlowName(caseRecord.Id);
    }
    
    @isTest
    public static void testNoFlow_withoutProduct()
    {
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount','Palekar99', false);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NY';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'Us';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NY';
        accountRecord.ShippingStreet = 'ghi';
        accountRecord.recordtypeid = [select id from recordtype where name='Person Account'].Id;
        insert accountRecord;
        
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,false);
        productRecord.Quantity_Available__c =25;
        productRecord.Isactive = true;
        productRecord.Product_Type__c = 'FG';
        productRecord.Finished_Good__c = True;
        productRecord.Spare_Part__c = False; 
        productRecord.Accessory__c = False;
        insert productRecord;
        
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', false);
        //seRecord.Product__c = productRecord.Id;
        caseRecord.Type='Support & Service';
        insert caseRecord;
        TroubleshootHelper.GetFlowName(caseRecord.Id);
    }
    
    @isTest
    public static void testNoFlow_withoutType()
    {
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount','Palekar99', false);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NY';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'Us';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NY';
        accountRecord.ShippingStreet = 'ghi';
        accountRecord.recordtypeid = [select id from recordtype where name='Person Account'].Id;
        insert accountRecord;
        
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,false);
        productRecord.Quantity_Available__c =25;
        productRecord.Isactive = true;
        productRecord.Product_Type__c = 'FG';
        productRecord.Finished_Good__c = True;
        productRecord.Spare_Part__c = False; 
        productRecord.Accessory__c = False;
        insert productRecord;
        
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', false);
        caseRecord.Product__c = productRecord.Id;
        caseRecord.Type='Order Issue';
        insert caseRecord;
        TroubleshootHelper.GetFlowName(caseRecord.Id);
    }
    
    @isTest
    public static void testWithFlow()
    {
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount','Palekar99', false);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NY';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'Us';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NY';
        accountRecord.ShippingStreet = 'ghi';
        accountRecord.recordtypeid = [select id from recordtype where name='Person Account'].Id;
        insert accountRecord;
        
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,false);
        productRecord.Quantity_Available__c =25;
        productRecord.Isactive = true;
        productRecord.Product_Type__c = 'FG';
        productRecord.Finished_Good__c = True;
        productRecord.Spare_Part__c = False; 
        productRecord.Accessory__c = False;
        //Product_Category__c, Product_Sub_Category__c
        productRecord.Family = 'BEVERAGE & TOAST';
        productRecord.Product_Sub_Family__c = 'Coffee Makers';
        insert productRecord;
        //SELECT Flow_Name__c, Product__c, Product_Category__c, Product_Sub_Category__c, Complaint_Code__c from Trouble_Shoot_Flow_Mapping__c
        Trouble_Shoot_Flow_Mapping__c objTb = new Trouble_Shoot_Flow_Mapping__c(Flow_Name__c='Espresso_With_Grinder_Troubleshoot_Flow',Product__c=productRecord.Id,Product_Category__c='BEVERAGE & TOAST',Product_Sub_Category__c='Coffee Makers',Complaint_Code__c='Alignment / Fit');
        insert objTb;
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', false);
        caseRecord.Product__c = productRecord.Id;
        caseRecord.Type='Support & Service';
        caseRecord.Complaint_Category__c='Coffee & Toast';
        caseRecord.Complaint_Code__c='Alignment / Fit';
        insert caseRecord;
        TroubleshootHelper.GetFlowName(caseRecord.Id);
    }
    
     @isTest
    public static void testWithoutFlow_diffProd()
    {
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount','Palekar99', false);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NY';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'Us';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NY';
        accountRecord.ShippingStreet = 'ghi';
        accountRecord.recordtypeid = [select id from recordtype where name='Person Account'].Id;
        insert accountRecord;
        
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,false);
        productRecord.Quantity_Available__c =25;
        productRecord.Isactive = true;
        productRecord.Product_Type__c = 'FG';
        productRecord.Finished_Good__c = True;
        productRecord.Spare_Part__c = False; 
        productRecord.Accessory__c = False;
        //Product_Category__c, Product_Sub_Category__c
        productRecord.Family = 'BEVERAGE & TOAST';
        productRecord.Product_Sub_Family__c = 'Coffee Makers';
        insert productRecord;
        
        Product2 productRecord1 = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,false);
        productRecord1.Quantity_Available__c =25;
        productRecord1.Isactive = true;
        productRecord1.Product_Type__c = 'FG';
        productRecord1.Finished_Good__c = True;
        productRecord1.Spare_Part__c = False; 
        productRecord1.Accessory__c = False;
        //Product_Category__c, Product_Sub_Category__c
        productRecord1.Family = 'BEVERAGE & TOAST';
        productRecord1.Product_Sub_Family__c = 'Coffee Makers';
        insert productRecord1;
        //SELECT Flow_Name__c, Product__c, Product_Category__c, Product_Sub_Category__c, Complaint_Code__c from Trouble_Shoot_Flow_Mapping__c
        Trouble_Shoot_Flow_Mapping__c objTb = new Trouble_Shoot_Flow_Mapping__c(Flow_Name__c='Espresso_With_Grinder_Troubleshoot_Flow',Product__c=productRecord.Id,Product_Category__c='BEVERAGE & TOAST',Product_Sub_Category__c='Coffee Makers',Complaint_Code__c='Alignment / Fit');
        insert objTb;
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', false);
        caseRecord.Product__c = productRecord1.Id;
        caseRecord.Type='Support & Service';
        caseRecord.Complaint_Category__c='Coffee & Toast';
        caseRecord.Complaint_Code__c='Alignment / Fit';
        insert caseRecord;
        TroubleshootHelper.GetFlowName(caseRecord.Id);
    }
    
    @isTest
    public static void testWithFlow_withoutCategory()
    {
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount','Palekar99', false);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NY';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'Us';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NY';
        accountRecord.ShippingStreet = 'ghi';
        accountRecord.recordtypeid = [select id from recordtype where name='Person Account'].Id;
        insert accountRecord;
        
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,false);
        productRecord.Quantity_Available__c =25;
        productRecord.Isactive = true;
        productRecord.Product_Type__c = 'FG';
        productRecord.Finished_Good__c = True;
        productRecord.Spare_Part__c = False; 
        productRecord.Accessory__c = False;
        //Product_Category__c, Product_Sub_Category__c
        productRecord.Family = 'BEVERAGE & TOAST';
        productRecord.Product_Sub_Family__c = 'Coffee Makers';
        insert productRecord;
        //SELECT Flow_Name__c, Product__c, Product_Category__c, Product_Sub_Category__c, Complaint_Code__c from Trouble_Shoot_Flow_Mapping__c
        Trouble_Shoot_Flow_Mapping__c objTb = new Trouble_Shoot_Flow_Mapping__c(Flow_Name__c='Espresso_With_Grinder_Troubleshoot_Flow',Product__c=productRecord.Id,Product_Sub_Category__c='Coffee Makers',Complaint_Code__c='Alignment / Fit');
        insert objTb;
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', false);
        caseRecord.Product__c = productRecord.Id;
        caseRecord.Type='Support & Service';
        caseRecord.Complaint_Category__c='Coffee & Toast';
        caseRecord.Complaint_Code__c='Alignment / Fit';
        insert caseRecord;
        TroubleshootHelper.GetFlowName(caseRecord.Id);
    }
    
    public static void testWithFlow_withoutcomplaintcode()
    {
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount','Palekar99', false);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NY';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'Us';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NY';
        accountRecord.ShippingStreet = 'ghi';
        accountRecord.recordtypeid = [select id from recordtype where name='Person Account'].Id;
        insert accountRecord;
        
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,false);
        productRecord.Quantity_Available__c =25;
        productRecord.Isactive = true;
        productRecord.Product_Type__c = 'FG';
        productRecord.Finished_Good__c = True;
        productRecord.Spare_Part__c = False; 
        productRecord.Accessory__c = False;
        //Product_Category__c, Product_Sub_Category__c
        productRecord.Family = 'BEVERAGE & TOAST';
        productRecord.Product_Sub_Family__c = 'Coffee Makers';
        insert productRecord;
        //SELECT Flow_Name__c, Product__c, Product_Category__c, Product_Sub_Category__c, Complaint_Code__c from Trouble_Shoot_Flow_Mapping__c
        Trouble_Shoot_Flow_Mapping__c objTb = new Trouble_Shoot_Flow_Mapping__c(Flow_Name__c='Espresso_With_Grinder_Troubleshoot_Flow',Product__c=productRecord.Id,Product_Category__c='BEVERAGE & TOAST',Product_Sub_Category__c='Coffee Makers');
        insert objTb;
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', false);
        caseRecord.Product__c = productRecord.Id;
        caseRecord.Type='Support & Service';
        caseRecord.Complaint_Category__c='Coffee & Toast';
        caseRecord.Complaint_Code__c='Alignment / Fit';
        insert caseRecord;
        TroubleshootHelper.GetFlowName(caseRecord.Id);
    }
    
    
    @isTest
    public static void testWithFlow_withoutProdcut()
    {
        Account accountRecord = TestDataFactory.createAccountRecord('NikhilAccount','Palekar99', false);
        accountRecord.BillingCity = 'def';
        accountRecord.BillingCountryCode = 'US';
        accountRecord.BillingPostalCode = '440022';
        accountRecord.BillingStateCode = 'NY';
        accountRecord.BillingStreet = 'abc';
        accountRecord.ShippingCountryCode = 'Us';
        accountRecord.ShippingCity = 'def';
        accountRecord.ShippingPostalCode = '440022';
        accountRecord.ShippingStateCode = 'NY';
        accountRecord.ShippingStreet = 'ghi';
        accountRecord.recordtypeid = [select id from recordtype where name='Person Account'].Id;
        insert accountRecord;
        
        Product2 productRecord = TestDataFactory.createProduct('Product Name 1', 'PN1', '9999',true,false);
        productRecord.Quantity_Available__c =25;
        productRecord.Isactive = true;
        productRecord.Product_Type__c = 'FG';
        productRecord.Finished_Good__c = True;
        productRecord.Spare_Part__c = False; 
        productRecord.Accessory__c = False;
        //Product_Category__c, Product_Sub_Category__c
        productRecord.Family = 'BEVERAGE & TOAST';
        productRecord.Product_Sub_Family__c = 'Coffee Makers';
        insert productRecord;
        //SELECT Flow_Name__c, Product__c, Product_Category__c, Product_Sub_Category__c, Complaint_Code__c from Trouble_Shoot_Flow_Mapping__c
        Trouble_Shoot_Flow_Mapping__c objTb = new Trouble_Shoot_Flow_Mapping__c(Flow_Name__c='Espresso_With_Grinder_Troubleshoot_Flow',Product_Category__c='BEVERAGE & TOAST',Product_Sub_Category__c='Coffee Makers',Complaint_Code__c='Alignment / Fit');
        insert objTb;
        Case caseRecord = TestDataFactory.createCase(accountRecord.Id, 'Email','Open','Subject 99', 'USD', false);
        caseRecord.Product__c = productRecord.Id;
        caseRecord.Type='Support & Service';
        caseRecord.Complaint_Category__c='Coffee & Toast';
        caseRecord.Complaint_Code__c='Alignment / Fit';
        insert caseRecord;
        TroubleshootHelper.GetFlowName(caseRecord.Id);
    }
}