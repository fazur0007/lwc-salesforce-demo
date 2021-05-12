@isTest(SeeAllData = true)
public with sharing class OrderExtTest 
{
	 static testMethod void testMethodOrderExt(){
		
        //Insert Account    		
	 	Account objAcc = new Account();
        objAcc.Name = 'test Account';
        objAcc.DataAreaID__c='BUS';
        insert objAcc;
        
        //Insert Pricebook2   
        Pricebook2 objPricebook2 = new Pricebook2();
        objPricebook2 = [select id from Pricebook2 where IsStandard=true];
        
         //Insert Order    		
		Order orderObj = new Order(AccountId=objAcc.Id,CurrencyIsoCode='USD',Status='Open',EffectiveDate=system.today(),Pricebook2Id = objPricebook2.Id); 
		orderObj.Type = 'Sale';
		insert orderObj;  
         
         //Insert Product2
        Product2 objProd = new Product2(Name= 'Test Product',AX_Item_Number__c='ZBBL800BSS1BCA1'); 
        insert objProd;   
        					
        //Insert PricebookEntry
        PricebookEntry pricebookEntryObj = new PricebookEntry(Pricebook2Id=objPricebook2.Id, Product2Id=objProd.Id, UnitPrice=99, isActive=true);
        insert pricebookEntryObj;  
        
        //Insert OrderItem
     	OrderItem orderItemObj = new OrderItem(Description='Test Description',PriceBookEntryId =pricebookEntryObj.Id, OrderId=orderObj.Id,Quantity= 400,UnitPrice =20 );
     	insert orderItemObj;
     	
		Test.starttest();
	
	     ApexPages.StandardController sc = new ApexPages.StandardController(orderObj);
	     OrderExt orderExtObj = new OrderExt(sc);
	     
		Test.stoptest();
	
	}
	
        }