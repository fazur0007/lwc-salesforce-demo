@isTest(SeeAllData=false)
public class CaseTriggerHandlerTest {

    /*static testMethod void testMethod1(){
        
            Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
            Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, false);
            productRecord.CurrencyIsoCode = 'USD';
            insert productRecord;
            //productRecord.Always_in_Warranty__c = true;
            //productRecord.Extended_Warranty_in_months__c = 10;
            //upsert productRecord;
            
            Asset assetRecord = TestDataFactory.createAsset('Test Asset',null,'1230',productRecord.Id,accountRecord.Id,15,true);
            QCAlert__c qcAlertRecord = TestDataFactory.createQCAlert('details of qc alert','test review','USD',productRecord.id,'Circulation','Call Center',true);
            //qcAlertRecord.Complaint_Code__c = 'Circulation';
            QCLocation__c qcLocationRecord = TestDataFactory.createQCLocation(accountRecord.id,'USA',qcAlertRecord.id,productRecord.id,true,accountRecord.id,'1230',true);
            //qcLocationRecord.IsActive__c = true;
            
            ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
            
            Case caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open','Test Case','USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
            caseRecord.Warranty__c ='In Warranty';
            caseRecord.RecordTypeId=recordTypeRecord;
            caseRecord.RA_Delivered__c = true;
            caseRecord.Country__c = 'USA';
            //insert caseRecord;
            
            Case caseRecord1 = TestDataFactory.createCase(accountRecord.id,'Chat','Open','Test Case','USD', productRecord.id, 'Support & Service','Circulation',null, Date.today(),'Out of Warranty', false);
            caseRecord1.Warranty__c ='In Warranty';
            caseRecord1.RecordTypeId=recordTypeRecord;
            caseRecord1.RA_Delivered__c = true;
            caseRecord1.Country__c = 'USA';
            //insert caseRecord1;
            
            Case caseRecord2 = TestDataFactory.createCase(accountRecord.id,'Email','Open','Test Case without asset','USD', productRecord.id, 'Support & Service','Circulation','1130', Date.today(),'', false);
            caseRecord2.RecordTypeId=recordTypeRecord;
            caseRecord2.RA_Delivered__c = true;
            caseRecord2.Country__c = 'USA';
            insert caseRecord2;
            
            Case caseRecord3 = TestDataFactory.createCase(accountRecord.id,'Email CAN Lid Gasket','Open','Test Case with cad','CAD', productRecord.id, 'Support & Service','Circulation','1130', Date.today(),'', false);
            caseRecord3.RecordTypeId=recordTypeRecord;
            caseRecord3.RA_Delivered__c = true;
            caseRecord3.Country__c = 'CAN';
            //insert caseRecord3;
            
            List<Case> lstcase=new List<Case>();  
            lstcase.add(caseRecord);
            lstcase.add(caseRecord1);
            insert lstcase;
            
            CaseTriggerHandler.afterTriggerRun = true;
            lstcase.add(caseRecord2);
            //lstcase.add(caseRecord3);
            update lstcase;
          
          	
            Test.Starttest();
            CaseTriggerHandler.populateContactForChatTypeCase(lstcase);
        	
        	Case cRecord = [SELECT Id, ContactId FROM Case WHERE Id = :lstcase[0].Id];
        	System.assertEquals(true, lstcase[0].ContactId != null);	
        
            CaseTriggerHandler.updateCaseWhenNoAssetFound(caseRecord2, Date.today(), 3, 0);
            CaseTriggerHandler.updateCaseWhenRegisteredAssetFound(assetRecord,caseRecord,2,Date.today(),0);
            CaseTriggerHandler.getCaseCurrencyCode(lstcase);
            //CaseTriggerHandler.updateCaseIfWarrantyStatusChanged(lstcase,caseRecord1.id);
            //CaseTriggerHandler.checkForAdvanceShippingRAReturned(lstcase,caseMap);
            
            ID groupId = [select id from Group where Type = 'Organization'].id;
            CaseShare caseShare = CaseTriggerHandler.createCaseShare(caseRecord.id, groupId);
            Test.Stoptest();
    }
*/    
    /*static testMethod void testMethod2(){
        
            Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
            Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, false);
            productRecord.CurrencyIsoCode = 'USD';
            insert productRecord;
            //productRecord.Always_in_Warranty__c = true;
            //productRecord.Extended_Warranty_in_months__c = 10;
            //upsert productRecord;
            
            Asset assetRecord = TestDataFactory.createAsset('Test Asset',null,'1230',productRecord.Id,accountRecord.Id,15,true);
            QCAlert__c qcAlertRecord = TestDataFactory.createQCAlert('details of qc alert','test review','USD',productRecord.id,'Circulation','Call Center',true);
            //qcAlertRecord.Complaint_Code__c = 'Circulation';
            QCLocation__c qcLocationRecord = TestDataFactory.createQCLocation(accountRecord.id,'USA',qcAlertRecord.id,productRecord.id,true,accountRecord.id,'1230',true);
            //qcLocationRecord.IsActive__c = true;
            
            ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
            
              Pricebook2 objPricebook2 = new Pricebook2();
             objPricebook2 = [select id from Pricebook2 where IsStandard=true];
           
            Case caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open','Test Case','USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
            caseRecord.Warranty__c ='In Warranty';
            caseRecord.RecordTypeId=recordTypeRecord;
            caseRecord.RA_Delivered__c = false;
            caseRecord.Country__c = 'USA';
            //insert caseRecord;
            
            Case caseRecord1 = TestDataFactory.createCase(accountRecord.id,'Chat','Open','Test Case','USD', productRecord.id, 'Support & Service','Circulation',null, Date.today(),'Out of Warranty', false);
            caseRecord1.Warranty__c ='In Warranty';
            caseRecord1.RecordTypeId=recordTypeRecord;
            caseRecord1.RA_Delivered__c = false;
            caseRecord1.Country__c = 'USA';
            //insert caseRecord1;
            
            Case caseRecord2 = TestDataFactory.createCase(accountRecord.id,'Email','Open','Test Case without asset','USD', productRecord.id, 'Support & Service','Circulation','1130', Date.today(),'', false);
            caseRecord2.RecordTypeId=recordTypeRecord;
            caseRecord2.RA_Delivered__c = false;
            caseRecord2.Country__c = 'USA';
            insert caseRecord2;
            
            Case caseRecord3 = TestDataFactory.createCase(accountRecord.id,'Email CAN Lid Gasket','Open','Test Case with cad','CAD', productRecord.id, 'Support & Service','Circulation','1130', Date.today(),'', false);
            caseRecord3.RecordTypeId=recordTypeRecord;
            caseRecord3.RA_Delivered__c = false;
            caseRecord3.Country__c = 'CAN';
            //insert caseRecord3;
            
             //Insert Order    		
			Order orderObj = new Order(AccountId=accountRecord.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2.Id); 
			orderObj.Type = 'Accommodation';
			orderObj.CC_Authorization_ID__c = '1324';
		    orderObj.AdvanceShippingStatus__c = null;
		    orderObj.Case__c = caseRecord2.id;
			insert orderObj; 
            
            List<Case> lstcase=new List<Case>();  
            lstcase.add(caseRecord);
            lstcase.add(caseRecord1);
            insert lstcase;
            
            CaseTriggerHandler.afterTriggerRun = true;
            caseRecord3.RA_Delivered__c = true;
            lstcase.add(caseRecord2);
            //lstcase.add(caseRecord3);
            update lstcase;
            Test.Starttest();
            CaseTriggerHandler.populateContactForChatTypeCase(lstcase);
            CaseTriggerHandler.updateCaseWhenNoAssetFound(caseRecord2, Date.today(), 3, 0);
            CaseTriggerHandler.updateCaseWhenRegisteredAssetFound(assetRecord,caseRecord,2,Date.today(),0);
            CaseTriggerHandler.getCaseCurrencyCode(lstcase);
            //CaseTriggerHandler.updateCaseIfWarrantyStatusChanged(lstcase,caseRecord1.id);
            //CaseTriggerHandler.checkForAdvanceShippingRAReturned(lstcase,caseMap);
            
            assetRecord.PurchaseDate = Date.today();
            upsert assetRecord;
            caseRecord.Purchase_Date__c = Date.today().addDays(-1);
            upsert caseRecord;
            CaseTriggerHandler.updateCaseWhenRegisteredAssetFound(assetRecord,caseRecord,2,Date.today(),0);
            
            
            assetRecord.Warranty_In_Months__c =null;
            upsert assetRecord;
            CaseTriggerHandler.updateCaseWhenRegisteredAssetFound(assetRecord,caseRecord,2,Date.today(),0);
            
            ID groupId = [select id from Group where Type = 'Organization'].id;
            CaseShare caseShare = CaseTriggerHandler.createCaseShare(caseRecord.id, groupId);
            Test.Stoptest();
    }*/
    /* static testMethod void testMethod3(){
        
            Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
            Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, true);
         	Product2 productRecord1 = TestDataFactory.createProduct('Product2','BES920XL',true,false,false,15,true, true);
            //productRecord.Always_in_Warranty__c = true;
            //productRecord.Extended_Warranty_in_months__c = 10;
            //upsert productRecord;
            
            Asset assetRecord = TestDataFactory.createAsset('Test Asset',null,'1230',productRecord.Id,accountRecord.Id,15,true);
            QCAlert__c qcAlertRecord = TestDataFactory.createQCAlert('details of qc alert','test review','USD',productRecord.id,'Circulation','Call Center',true);
            //qcAlertRecord.Complaint_Code__c = 'Circulation';
            QCLocation__c qcLocationRecord = TestDataFactory.createQCLocation(accountRecord.id,'USA',qcAlertRecord.id,productRecord.id,true,accountRecord.id,'1230',true);
            //qcLocationRecord.IsActive__c = true;
            
            ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
            
              Pricebook2 objPricebook2 = new Pricebook2();
             objPricebook2 = [select id from Pricebook2 where IsStandard=true];
           
            Case caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open','Test Case','USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
            caseRecord.Warranty__c ='In Warranty';
            caseRecord.RecordTypeId=recordTypeRecord;
            caseRecord.RA_Delivered__c = false;
            caseRecord.Country__c = 'USA';
            insert caseRecord;
            
           List<Case> lstcase=new List<Case>();  
            lstcase.add(caseRecord);
                       
             //Insert Order    		
			Order orderObj = new Order(AccountId=accountRecord.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2.Id); 
			orderObj.Type = 'Accommodation';
			orderObj.CC_Authorization_ID__c = '1324';
		    orderObj.AdvanceShippingStatus__c = null;
		    orderObj.Case__c = caseRecord.id;
			insert orderObj; 
            
            CaseTriggerHandler.afterTriggerRun = true;
            caseRecord.RA_Delivered__c = true;
           caseRecord.Product__c = productRecord1.Id; 
            update caseRecord;
            Test.Starttest();
            CaseTriggerHandler.populateContactForChatTypeCase(lstcase);
            CaseTriggerHandler.updateCaseWhenNoAssetFound(caseRecord, Date.today(), 3, 0);
            CaseTriggerHandler.updateCaseWhenRegisteredAssetFound(assetRecord,caseRecord,2,Date.today(),0);
            CaseTriggerHandler.getCaseCurrencyCode(lstcase);
            //CaseTriggerHandler.updateCaseIfWarrantyStatusChanged(lstcase,caseRecord1.id);
            //CaseTriggerHandler.checkForAdvanceShippingRAReturned(lstcase,caseMap);
            
            assetRecord.PurchaseDate = Date.today();
            upsert assetRecord;
            caseRecord.Purchase_Date__c = Date.today().addDays(-1);
            upsert caseRecord;
            CaseTriggerHandler.updateCaseWhenRegisteredAssetFound(assetRecord,caseRecord,2,Date.today(),0);
            
            
            assetRecord.Warranty_In_Months__c =null;
            upsert assetRecord;
            CaseTriggerHandler.updateCaseWhenRegisteredAssetFound(assetRecord,caseRecord,2,Date.today(),0);
            
            ID groupId = [select id from Group where Type = 'Organization'].id;
            CaseShare caseShare = CaseTriggerHandler.createCaseShare(caseRecord.id, groupId);
            Test.Stoptest();
    }*/

     static testMethod void testMethod4(){
        
            Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
            Account accountRecord2 = TestDataFactory.createAccountRecord('Return Locarion','USD','California',false);
            accountRecord2.Type = 'Return Center';
            insert accountRecord2;
            Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, true);
         	Product2 productRecord1 = TestDataFactory.createProduct('Product2','BES920XL',true,false,false,15,true, true);
            //productRecord.Always_in_Warranty__c = true;
            //productRecord.Extended_Warranty_in_months__c = 10;
            //upsert productRecord;
            
            Asset assetRecord = TestDataFactory.createAsset('Test Asset',null,'1230',productRecord.Id,accountRecord.Id,15,true);
            QCAlert__c qcAlertRecord = TestDataFactory.createQCAlert('details of qc alert','test review','USD',productRecord.id,'Circulation','Call Center',true);
            QCAlert__c qcAlertRecord2 = TestDataFactory.createQCAlert('details of qc alert','test review','USD',productRecord.id,'Circulation','Call Center',true);
            //qcAlertRecord.Complaint_Code__c = 'Circulation';
            QCLocation__c qcLocationRecord = TestDataFactory.createQCLocation(accountRecord.id,'USA',qcAlertRecord.id,productRecord.id,true,accountRecord.id,'1230',true);
            QCLocation__c qcLocationRecord2 = TestDataFactory.createQCLocation(accountRecord2.id,'USA',qcAlertRecord2.id,productRecord1.id,true,accountRecord2.id,'1230',true);
            //qcLocationRecord.IsActive__c = true;
            
            ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
            ID recordTypeRecord2 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Case').getRecordTypeId();
            
            Id pbId = Test.getStandardPricebookId();
           
            Case caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open',null,'USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
            caseRecord.Warranty__c ='In Warranty';
            caseRecord.RecordTypeId=recordTypeRecord;
            caseRecord.RA_Delivered__c = false;
            caseRecord.Country__c = 'USA';
         	caseRecord.Description = 'This is test desctiption';
            insert caseRecord;
            
            Case caseRecord2 = TestDataFactory.createCase(accountRecord.id,'Chat','Open',null,'USD', productRecord1.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
            caseRecord2.Warranty__c ='In Warranty';
            caseRecord2.RecordTypeId=recordTypeRecord2;
            caseRecord2.RA_Delivered__c = false;
            caseRecord2.Country__c = 'USA';
            caseRecord2.ReturnLocation__c = accountRecord2.Id;
         	caseRecord2.Description = 'This is test desctiption';
            insert caseRecord2;
            
           List<Case> lstcase=new List<Case>();  
            lstcase.add(caseRecord);
                       
             //Insert Order    		
			Order orderObj = new Order(AccountId=accountRecord.Id,CurrencyIsoCode='USD',PODate=Date.today(),Status='Open',EffectiveDate=system.today(),Pricebook2Id = pbId); 
			orderObj.Type = 'Accommodation';
			orderObj.CC_Authorization_ID__c = '1324';
		    orderObj.AdvanceShippingStatus__c = null;
		    orderObj.Case__c = caseRecord.id;
			insert orderObj; 
            
            CaseTriggerHandler.afterTriggerRun = true;
            caseRecord.RA_Delivered__c = true;
           caseRecord.Product__c = productRecord1.Id; 
            update caseRecord;
            
            CaseTriggerHandler.afterTriggerRun = true;
            caseRecord2.RA_Delivered__c = true;
            update caseRecord2;
            
            Test.Starttest();
            CaseTriggerHandler.populateContactForChatTypeCase(lstcase);
            CaseTriggerHandler.updateCaseWhenNoAssetFound(caseRecord, Date.today(), 3, 0);
            CaseTriggerHandler.updateCaseWhenRegisteredAssetFound(assetRecord,caseRecord,2,Date.today(),0);
            CaseTriggerHandler.getCaseCurrencyCode(lstcase);
            
            System.assertEquals(true, lstcase[0].Description != null);
            
            //CaseTriggerHandler.updateCaseIfWarrantyStatusChanged(lstcase,caseRecord1.id);
            //CaseTriggerHandler.checkForAdvanceShippingRAReturned(lstcase,caseMap);
            
            assetRecord.PurchaseDate = Date.today();
            upsert assetRecord;
            caseRecord.Purchase_Date__c = Date.today().addDays(-1);
            upsert caseRecord;
            CaseTriggerHandler.updateCaseWhenRegisteredAssetFound(assetRecord,caseRecord,2,Date.today(),0);
            
            
            assetRecord.Warranty_In_Months__c =null;
            upsert assetRecord;
            CaseTriggerHandler.updateCaseWhenRegisteredAssetFound(assetRecord,caseRecord,2,Date.today(),0);
            
            ID groupId = [select id from Group where Type = 'Organization'].id;
            CaseShare caseShare = CaseTriggerHandler.createCaseShare(caseRecord.id, groupId);
            Test.Stoptest();
    }
    
    static testMethod void testNoReturnLocation(){
        
        D365Setting__c D365Setting = new D365Setting__c();
        D365Setting.ValidCurrencies__c = 'USD';
        insert D365Setting;
        
        Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
        Account accountRecord2 = TestDataFactory.createAccountRecord('Return Locarion','USD','California',false);
        accountRecord2.Type = 'Return Center';
        insert accountRecord2;
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, true);
        
        ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
        
        Id pbId = Test.getStandardPricebookId();
       
        Case caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open',null,'USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord.RA_Delivered__c = false;
        caseRecord.Country__c = 'USA';
        caseRecord.Description = 'This is test desctiption';
        
        Test.startTest();
        try {
            insert caseRecord;
        } catch (Exception e) {
            system.assert(e.getMessage().contains('Return location cannot be empty.'));
        }
        
        Test.stopTest();
    }
    
    static testMethod void testReturnLocationValidationOnDIF(){
        
        D365Setting__c D365Setting = new D365Setting__c();
        D365Setting.ValidCurrencies__c = 'USD';
        insert D365Setting;
        
        Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
        Account accountRecord2 = TestDataFactory.createAccountRecord('Return Locarion','USD','California',false);
        accountRecord2.Type = 'Return Center';
        insert accountRecord2;
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, true);
        
        ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
        
        Id pbId = Test.getStandardPricebookId();
       
        Case caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open',null,'USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord.RA_Delivered__c = false;
        caseRecord.Country__c = 'USA';
        caseRecord.Description = 'This is test desctiption';
        caseRecord.RMA_Type__c = 'Destroy in Field';
        caseRecord.ReturnLocation__c = accountRecord2.Id;
        Test.startTest();
        try {
            insert caseRecord;
        } catch (Exception e) {
            system.assert(e.getMessage().contains('Return location is not needed for Destroy in Field RMA type'));
        }
        
        Test.stopTest();
    }
    
    static testMethod void testNoReturnLocationFound(){
        
        D365Setting__c D365Setting = new D365Setting__c();
        D365Setting.ValidCurrencies__c = 'USD';
        insert D365Setting;
        
        Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
        Account accountRecord2 = TestDataFactory.createAccountRecord('Return Locarion','USD','California',false);
        accountRecord2.Type = 'Return Center';
        insert accountRecord2;
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, true);
        
        ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
        
        Id pbId = Test.getStandardPricebookId();
       
        Case caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open',null,'USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord.RA_Delivered__c = false;
        caseRecord.Country__c = 'USA';
        caseRecord.Description = 'This is test desctiption';
        caseRecord.RMA_Type__c = 'Goods to be return (First quality)';
        caseRecord.ReturnLocation__c = accountRecord2.Id;
        Test.startTest();
        try {
            insert caseRecord;
        } catch (Exception e) {
            system.assert(e.getMessage().contains('A matching return location for this region was not found.'));
        }
        
        Test.stopTest();
    }
    
    static testMethod void testInvalidReturnLocationFound(){
        
        D365Setting__c D365Setting = new D365Setting__c();
        D365Setting.ValidCurrencies__c = 'USD';
        insert D365Setting;
        
        Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
        
        Account accountRecord2 = TestDataFactory.createAccountRecord('Return Locarion','USD','California',false);
        accountRecord2.Type = 'Return Center';
        accountRecord2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        accountRecord2.Stock_Return_Type__c = 'Good Stock Return';
        accountRecord2.DataAreaID__c = 'BUK';
        insert accountRecord2;
        
        Account accountRecord3 = TestDataFactory.createAccountRecord('Return Locarion','USD','California',false);
        accountRecord3.Type = 'Return Center';
        accountRecord3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        accountRecord3.Stock_Return_Type__c = 'Good Stock Return';
        accountRecord3.DataAreaID__c = 'BUS';
        insert accountRecord3;
        
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, true);
        
        ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
        
        Id pbId = Test.getStandardPricebookId();
       
        Case caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open',null,'USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord.RA_Delivered__c = false;
        caseRecord.Country__c = 'USA';
        caseRecord.Description = 'This is test desctiption';
        caseRecord.RMA_Type__c = 'Goods to be return (First quality)';
        caseRecord.ReturnLocation__c = accountRecord2.Id;
        Test.startTest();
        try {
            insert caseRecord;
        } catch (Exception e) {
            system.assert(e.getMessage().contains('Invalid return location for the region and RMA type.'));
        }
        
        Test.stopTest();
    }
    
    static testMethod void testCreateReceivingOnDIF(){
        
        D365Setting__c D365Setting = new D365Setting__c();
        D365Setting.ValidCurrencies__c = 'USD';
        insert D365Setting;
        
        Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
        
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, true);
        
        ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
        
        Id pbId = Test.getStandardPricebookId();
       
        Case caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open',null,'USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord.RA_Delivered__c = false;
        caseRecord.Country__c = 'USA';
        caseRecord.Description = 'This is test desctiption';
        caseRecord.RMA_Type__c = 'Destroy in Field';
        insert caseRecord;
        
        RMA_Product__c rm = new RMA_Product__c(Case__c = caseRecord.Id , Quantity__c=2, CurrencyIsoCode='USD');
        rm.Product__c=productRecord.Id;
        insert rm;
        Test.setMock(HttpCalloutMock.class, new D365APIUtilityMock.ProcessRMAMock());
        Test.startTest();
        CaseTriggerHandler.afterTriggerRun = true;
        CaseTriggerHandler.beforeTriggerRun = true;
        caseRecord.RMAStatus__c = 'RMA Approved';
        update caseRecord;
        Test.stopTest();
        System.assertEquals(2, [SELECT count() FROM Receiving__c]);
    }
    
    static testMethod void testReceivingComplete(){
        
        D365Setting__c D365Setting = new D365Setting__c();
        D365Setting.ValidCurrencies__c = 'USD';
        insert D365Setting;
        
        Account accountRecord = TestDataFactory.createAccountRecord('Abc Ventures','USD','California',true);
        Account accountRecord2 = TestDataFactory.createAccountRecord('Return Locarion','USD','California',false);
        accountRecord2.Type = 'Return Center';
        accountRecord2.Stock_Return_Type__c = 'Good Stock Return';
        accountRecord2.DataAreaID__c = 'BUS';
        insert accountRecord2;
        Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, true);
        
        ID recordTypeRecord = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRecordTypeRMA).getRecordTypeId();
        
        Id pbId = Test.getStandardPricebookId();
       
        Case caseRecord = TestDataFactory.createCase(accountRecord.id,'Chat','Open',null,'USD', productRecord.id, 'Support & Service','Circulation','1230', Date.today(), 'Out of Warranty' ,false);
        caseRecord.Warranty__c ='In Warranty';
        caseRecord.RecordTypeId=recordTypeRecord;
        caseRecord.RA_Delivered__c = false;
        caseRecord.Country__c = 'USA';
        caseRecord.Description = 'This is test desctiption';
        caseRecord.RMA_Type__c = 'Goods to be return (First quality)';
        caseRecord.ReturnLocation__c = accountRecord2.Id;
        insert caseRecord;
        
        RMA_Product__c rm = new RMA_Product__c(Case__c = caseRecord.Id , Quantity__c=2, CurrencyIsoCode='USD');
        rm.Product__c=productRecord.Id;
        insert rm;
        Test.setMock(HttpCalloutMock.class, new D365APIUtilityMock.ProcessRMAMock());
        Test.startTest();
        CaseTriggerHandler.afterTriggerRun = true;
        CaseTriggerHandler.beforeTriggerRun = true;
        caseRecord.ReceivingComplete__c = true;
        update caseRecord;
        Test.stopTest();
    }
}