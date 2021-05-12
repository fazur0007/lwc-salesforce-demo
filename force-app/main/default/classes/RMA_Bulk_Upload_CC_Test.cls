@isTest
public class RMA_Bulk_Upload_CC_Test {
    
    static testMethod void readFileTest(){
        Account objAcc = new Account();
        objAcc.Name = 'Account1';
        objAcc.DataAreaID__c='BUS';
        insert objAcc;
        
        //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1',AX_Unique_ID__c='BUSZBBL800BSS1BCA1'); 
        insert objProd;  
        
        //Insert Case  
        Case caseObj = new Case(AccountId=objAcc.Id,PriceCalculationRequired__c=false,CurrencyIsoCode='USD');  
        insert caseObj;
        caseObj=[Select AccountId,PriceCalculationRequired__c,CaseNumber from Case where id=: caseObj.Id];
        
        //Insert RMA Product
        RMA_Product__c rmaObj = new RMA_Product__c(Quantity__c=10,Case__c=caseObj.Id,Price__c = 100, Product__c = objProd.Id);
        insert rmaObj;
        Test.StartTest(); 
       // ApexPages.StandardSetController sc = new ApexPages.StandardSetController(rmaObj);
        RMA_Bulk_Upload_CC obj=new RMA_Bulk_Upload_CC();
        obj.FileContent=Blob.valueOf('a,b,c,d \n'+objProd.AX_Item_Number__c+',123,122,'+caseObj.CaseNumber);
        obj.readFile();
        obj.done();
        obj.download();
        obj.upload();
        Test.stopTest();
    }

}