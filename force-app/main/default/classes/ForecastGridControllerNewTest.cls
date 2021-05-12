@isTest
public class ForecastGridControllerNewTest {
	static testMethod void testMethod1()
    {
        RecordType objRecBudget= [SELECT Id FROM RecordType Where Name=:system.label.Label_Budget limit 1];
        RecordType objRecForecast= [SELECT Id FROM RecordType Where Name=:system.label.Label_Forecast limit 1];
        // Insert Account
        List<Account> lstAcc=TestDataFactory.createAccount('Test', 100);
        insert lstAcc;

        //Insert Opportunity
        list<Opportunity> lstOpp = new list<Opportunity>();
        Opportunity objOpp= new Opportunity();
        objOpp.Name='Opp1';
        objOpp.AccountId = lstAcc[0].Id;
        objOpp.RecordTypeId=objRecForecast.Id;
        objOpp.CloseDate= date.today();
        objOpp.StageName='Forecast';
        
        lstOpp.add(objOpp);
        
        objOpp= new Opportunity();
        objOpp.Name='Opp2';
        objOpp.AccountId = lstAcc[0].Id;
        objOpp.RecordTypeId=objRecBudget.Id;
        objOpp.CloseDate= date.today();
        objOpp.StageName='Budget';
        
        lstOpp.add(objOpp);
        insert lstOpp;
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, false);
        lstProd[0].CanUseQuantitySchedule = true;
        lstProd[0].Description = 'Test Product';
        lstProd[0].Product_Sub_Family__c = 'Test';
        insert lstProd;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe; 

        //Insert Opportunity Line Items
        List<OpportunityLineItem> lstOI = TestDataFactory.createOLItem(pbe.Id, lstOpp[0].id, 400, 20, 200);
        insert lstOI;

        //Insert Opportunity Line Item Schedule
        List<OpportunityLineItemSchedule> lstOppSch = new List<OpportunityLineItemSchedule>();
        OpportunityLineItemSchedule objSc= new OpportunityLineItemSchedule();
        objSc.ScheduleDate= date.today();
        objSc.Quantity= 2;
        objSc.Type= 'Quantity';
        objSc.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc);
        insert lstOppSch;
        PageReference pgRef = Page.ForecastGrid;
        pgRef.getParameters().put('Id',lstAcc[0].Id);
        Test.setCurrentPage(pgRef);
        //ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(lstAcc[0]);
        ForecastGridControllerNew cntr= new ForecastGridControllerNew(new ApexPages.Standardcontroller(lstAcc[0]));
        cntr.loadData();
        system.assertEquals(ForecastGridControllerNew.mapProdId_ForecastRecType.size(),1);
    }
    static testMethod void testSaveQty(){
        map<string,list<string>> mapOLI_MonthQty= new map<string,list<string>>();
        map<string,list<string>> mapOLI_OLIS= new map<string,list<string>>();
        map<string,list<string>> mapOLIS_Qty= new map<string,list<string>>();
        map<string,list<string>> mapAccId_ProdId= new map<string,list<string>>();
        map<string,list<string>> mapProdId_Month_Qty= new map<string,list<string>>();
        RecordType objRecBudget= [SELECT Id FROM RecordType Where Name=:system.label.Label_Budget limit 1];
        RecordType objRecForecast= [SELECT Id FROM RecordType Where Name=:system.label.Label_Forecast limit 1];
        // Insert Account
        List<Account> lstAcc=TestDataFactory.createAccount('Test', 100);
        insert lstAcc;

        //Insert Opportunity
        list<Opportunity> lstOpp = new list<Opportunity>();
        Opportunity objOpp= new Opportunity();
        objOpp.Name='Opp1';
        objOpp.AccountId = lstAcc[0].Id;
        objOpp.RecordTypeId=objRecForecast.Id;
        objOpp.CloseDate= date.today();
        objOpp.StageName='Forecast';

        lstOpp.add(objOpp);
        insert lstOpp;
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, false);
        lstProd[0].CanUseQuantitySchedule = true;
        lstProd[0].Description = 'Test';
        insert lstProd;
        
        List<Product2> lstProd1 =TestDataFactory.createProductList('TestProd', 200, false);
        lstProd1[0].CanUseQuantitySchedule = true;
        lstProd1[0].Description = 'Test';
        insert lstProd1;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd1[0].Id, UnitPrice=99, isActive=true);
        insert pbe1;
        
        //Insert Opportunity Line Items
        List<OpportunityLineItem> lstOI = TestDataFactory.createOLItem(pbe.Id, lstOpp[0].id, 400, 20, 200);
        insert lstOI;

        List<OpportunityLineItemSchedule> lstOppSch = new List<OpportunityLineItemSchedule>();
        OpportunityLineItemSchedule objSc= new OpportunityLineItemSchedule();
        OpportunityLineItemSchedule objSc2= new OpportunityLineItemSchedule();
        OpportunityLineItemSchedule objSc1= new OpportunityLineItemSchedule();
        OpportunityLineItemSchedule objSc3= new OpportunityLineItemSchedule();
        objSc.ScheduleDate= date.newInstance(2018,1,15);
        objSc.Quantity= 2;
        objSc.Type= 'Quantity';
        objSc.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc);

        objSc1.ScheduleDate= date.newInstance(2018,2,15);
        objSc1.Quantity= 2;
        objSc1.Type= 'Quantity';
        objSc1.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc1);

        objSc2.ScheduleDate= date.newInstance(2018,3,15);
        objSc2.Quantity= 2;
        objSc2.Type= 'Quantity';
        objSc2.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc2);

        objSc3.ScheduleDate= date.newInstance(2018,4,15);
        objSc3.Quantity= 2;
        objSc3.Type= 'Quantity';
        objSc3.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc3);
        insert lstOppSch;
        PageReference pgRef = Page.ForecastGrid;
        pgRef.getParameters().put('Id',lstAcc[0].Id);
        Test.setCurrentPage(pgRef);

        for(OpportunityLineItem objOLI:[SELECT Id,PricebookEntryId,
                                               Opportunity.Account.Id,
                                        (SELECT Id
                                        FROM OpportunityLineItemSchedules
                                        WHERE OpportunityLineItemId IN:lstOI)
                                          FROM OpportunityLineItem
                                          WHERE Id IN: lstOI]){
            mapOLI_MonthQty.put(string.valueof(objOLI.Id),new list<string>{'6-Oct 2016','7-Nov 2016','2-Dec 2016','6-Mar 2016'});

            mapOLI_OLIS.put(string.valueof(objOLI.Id),new list<string>{string.valueof(lstOppSch[0].Id)});
            mapOLIS_Qty.put('',new list<string>{'6-Jan 2016','7-Mar 2016','2-Apr 2016'});
            mapOLIS_Qty.put('',new list<string>{'11-Jul 2016','10-Dec 2016','9-Sep 2016'});
            mapAccId_ProdId.put(objOLI.Opportunity.Account.Id, new list<string>{pbe1.Id});
            mapProdId_Month_Qty.put(pbe1.Id,new list<string>{'1-May 2016','2-Jun 2016','3-Jul 2016','6-Mar 2016'});
        }
        String str ='Jul 2016';
        ForecastGridControllerNew.saveOLIQTY(str,mapOLI_MonthQty, mapOLI_OLIS, mapOLIS_Qty, mapAccId_ProdId, mapProdId_Month_Qty);
        OpportunityLineItemSchedule objSch= [SELECT Id,ScheduleDate,Quantity
                                            FROM OpportunityLineItemSchedule
                                            WHERE Id In:lstOppSch limit 1];
        system.assertEquals(objSch.ScheduleDate.Month(),1);

    }
    
    static testMethod void testPreviousYearBudget(){
        RecordType objRecBudget= [SELECT Id FROM RecordType Where Name=:system.label.Label_Budget limit 1];
        RecordType objRecForecast= [SELECT Id FROM RecordType Where Name=:system.label.Label_Forecast limit 1];
        RecordType objRecSales= [SELECT Id FROM RecordType Where Name=:system.label.Label_Prior_Sales_Year limit 1];
        // Insert Account
        List<Account> lstAcc=TestDataFactory.createAccount('Test', 100);
        insert lstAcc;

        //Insert Opportunity
        list<Opportunity> lstOpp = new list<Opportunity>();
        Opportunity objOpp= new Opportunity();
        objOpp.Name='Opp1';
        objOpp.AccountId = lstAcc[0].Id;
        objOpp.RecordTypeId=objRecBudget.Id;
        objOpp.CloseDate= date.today();
        objOpp.StageName='Budget';

        lstOpp.add(objOpp);
        insert lstOpp;
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, false);
        lstProd[0].CanUseQuantitySchedule = true;
        lstProd[0].Description = 'Test';
        lstProd[0].Product_Sub_Family__c = 'Test';
        insert lstProd;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe;

        //Insert Opportunity Line Items
        List<OpportunityLineItem> lstOI = TestDataFactory.createOLItem(pbe.Id, lstOpp[0].id, 400, 20, 200);
        insert lstOI;

        //Insert Opportunity Line Item Schedule
        List<OpportunityLineItemSchedule> lstOppSch = new List<OpportunityLineItemSchedule>();
        OpportunityLineItemSchedule objSc= new OpportunityLineItemSchedule();
        objSc.ScheduleDate= date.newInstance(2018,3,15);
        objSc.Quantity= 2;
        objSc.Type= 'Quantity';
        objSc.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc);
        insert lstOppSch;
        PageReference pgRef = Page.ForecastGrid;
        pgRef.getParameters().put('Id',lstAcc[0].Id);
        Test.setCurrentPage(pgRef);
        
        lstOpp = new list<Opportunity>();
        objOpp= new Opportunity();
        objOpp.Name='Opp1';
        objOpp.AccountId = lstAcc[0].Id;
        objOpp.RecordTypeId=objRecSales.Id;
        objOpp.CloseDate= date.today();
        objOpp.StageName='Sales';

        lstOpp.add(objOpp);
        insert lstOpp;
        
        standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product
        lstProd =TestDataFactory.createProductList('Prod', 200, false);
        lstProd[0].CanUseQuantitySchedule = true;
        lstProd[0].Description = 'Test';
        lstProd[0].Product_Sub_Family__c = 'Test';
        insert lstProd;
        
        pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe;
        
        lstOI = TestDataFactory.createOLItem(pbe.Id, lstOpp[0].id, 400, 20, 200);
        insert lstOI;
        
        lstOppSch = new List<OpportunityLineItemSchedule>();
        objSc= new OpportunityLineItemSchedule();
        objSc.ScheduleDate= date.newInstance(2018,4,15);
        objSc.Quantity= 2;
        objSc.Type= 'Quantity';
        objSc.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc);
        insert lstOppSch;
        
        ForecastGridControllerNew cntr= new ForecastGridControllerNew(new ApexPages.Standardcontroller(lstAcc[0]));
        cntr.loadData();
        system.assertEquals(cntr.cellCount,18);
    }
    
    static testMethod void testUtilMethods()
    {
    	// Insert Account
        List<Account> lstAcc=TestDataFactory.createAccount('Test', 100);
        insert lstAcc;
    	ForecastGridControllerNew cntr = new ForecastGridControllerNew(new ApexPages.Standardcontroller(lstAcc[0]));
    	cntr.fromDateYear = 2017;
    	cntr.fromDateMonth = 3;
    	cntr.setFromDate();
    	System.assertEquals(cntr.dtFromStr, 'April-2017');
    	
    	cntr.toDateYear = 2017;
    	cntr.toDateMonth = 7;
    	cntr.setToDate();
    	System.assertEquals(cntr.dtToStr, 'August-2017');
    	
    	System.assertEquals(cntr.isDataValid(), true);
        cntr.fetchData();
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        System.assertEquals(0, msgs.size());
    	    	
    }
    static testMethod void testInvalidData(){
         List<Account> lstAcc=TestDataFactory.createAccount('Test', 100);
        insert lstAcc;
    	ForecastGridControllerNew cntr = new ForecastGridControllerNew(new ApexPages.Standardcontroller(lstAcc[0]));
    	cntr.fromDateYear = 2017;
    	cntr.fromDateMonth = 3;
    	cntr.setFromDate();
    	
    	cntr.toDateYear = 2017;
    	cntr.toDateMonth = 2;
    	cntr.setToDate();

        cntr.fetchData();
       	List<Apexpages.Message> msgs = ApexPages.getMessages();
		boolean b = false;
		for(Apexpages.Message msg:msgs){
   			 if (msg.getDetail().contains('Please select proper date range.')) 
   			 	b = true;
		}
		system.assert(b);
    }
}