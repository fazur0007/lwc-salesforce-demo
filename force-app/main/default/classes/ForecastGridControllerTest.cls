/*
ForecastGridControllerTest is a testclass to be used in test class name 'ForecastGridController'
* Version       Author             Date                  Description
*  1.0        Yogesh Sharma      10/28/2016             Initial Draft
*/
@isTest
private class ForecastGridControllerTest {

    static testMethod void testPositive() {
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
        objOpp.StageName='Authorization Successful';

        lstOpp.add(objOpp);
        insert lstOpp;
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, false);
        lstProd[0].CanUseQuantitySchedule = true;
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
        ForecastGridController cntr= new ForecastGridController(new ApexPages.Standardcontroller(lstAcc[0]));
        ForecastGridController.setMonths3();
        ForecastGridController.setMonths();
        system.assertEquals(ForecastGridController.mapProdId_ForecastRecType.size(),1);
    }

    static testMethod void testPositiveBudget() {
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
        objOpp.RecordTypeId=objRecBudget.Id;
        objOpp.CloseDate= date.today();
        objOpp.StageName='Authorization Successful';

        lstOpp.add(objOpp);
        insert lstOpp;
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, false);
        lstProd[0].CanUseQuantitySchedule = true;
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
        ForecastGridController.setMonths();

    }

    static testMethod void testPreviousYearForecast(){
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
        objOpp.StageName='Authorization Successful';

        lstOpp.add(objOpp);
        insert lstOpp;
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, false);
        lstProd[0].CanUseQuantitySchedule = true;
        insert lstProd;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe;

        //Insert Opportunity Line Items
        List<OpportunityLineItem> lstOI = TestDataFactory.createOLItem(pbe.Id, lstOpp[0].id, 400, 20, 200);
        insert lstOI;

        //Insert Opportunity Line Item Schedule
        List<OpportunityLineItemSchedule> lstOppSch = new List<OpportunityLineItemSchedule>();
        OpportunityLineItemSchedule objSc= new OpportunityLineItemSchedule();
        objSc.ScheduleDate= date.newInstance(date.today().year()-1,date.today().month()-1,date.today().day());
        objSc.Quantity= 2;
        objSc.Type= 'Quantity';
        objSc.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc);
        insert lstOppSch;
        PageReference pgRef = Page.ForecastGrid;
        pgRef.getParameters().put('Id',lstAcc[0].Id);
        Test.setCurrentPage(pgRef);
        ForecastGridController cntr= new ForecastGridController(new ApexPages.Standardcontroller(lstAcc[0]));
        ForecastGridController.setMonths();
        system.assertEquals(ForecastGridController.mapProdId_ForecastRecType.size(),1);
    }
    static testMethod void testPreviousYearBudget(){
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
        objOpp.RecordTypeId=objRecBudget.Id;
        objOpp.CloseDate= date.today();
        objOpp.StageName='Authorization Successful';

        lstOpp.add(objOpp);
        insert lstOpp;
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, false);
        lstProd[0].CanUseQuantitySchedule = true;
        insert lstProd;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe;

        //Insert Opportunity Line Items
        List<OpportunityLineItem> lstOI = TestDataFactory.createOLItem(pbe.Id, lstOpp[0].id, 400, 20, 200);
        insert lstOI;

        //Insert Opportunity Line Item Schedule
        List<OpportunityLineItemSchedule> lstOppSch = new List<OpportunityLineItemSchedule>();
        OpportunityLineItemSchedule objSc= new OpportunityLineItemSchedule();
        objSc.ScheduleDate= date.newInstance(date.today().year()-1,3,date.today().day());
        objSc.Quantity= 2;
        objSc.Type= 'Quantity';
        objSc.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc);
        insert lstOppSch;
        PageReference pgRef = Page.ForecastGrid;
        pgRef.getParameters().put('Id',lstAcc[0].Id);
        Test.setCurrentPage(pgRef);
        ForecastGridController cntr= new ForecastGridController(new ApexPages.Standardcontroller(lstAcc[0]));
        ForecastGridController.setMonths();
        system.assertEquals(ForecastGridController.mapProdId_BudgetRecType.size(),1);
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
        objOpp.StageName='Authorization Successful';

        lstOpp.add(objOpp);
        insert lstOpp;
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, false);
        lstProd[0].CanUseQuantitySchedule = true;
        insert lstProd;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe;

        //Insert Opportunity Line Items
        List<OpportunityLineItem> lstOI = TestDataFactory.createOLItem(pbe.Id, lstOpp[0].id, 400, 20, 200);
        insert lstOI;

        List<OpportunityLineItemSchedule> lstOppSch = new List<OpportunityLineItemSchedule>();
        OpportunityLineItemSchedule objSc= new OpportunityLineItemSchedule();
        OpportunityLineItemSchedule objSc2= new OpportunityLineItemSchedule();
        OpportunityLineItemSchedule objSc1= new OpportunityLineItemSchedule();
        OpportunityLineItemSchedule objSc3= new OpportunityLineItemSchedule();
        objSc.ScheduleDate= date.today();
        objSc.Quantity= 2;
        objSc.Type= 'Quantity';
        objSc.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc);

        objSc1.ScheduleDate= date.newInstance(date.today().year(),11,date.today().day());
        objSc1.Quantity= 2;
        objSc1.Type= 'Quantity';
        objSc1.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc1);

        objSc2.ScheduleDate= date.newInstance(date.today().year(),12,date.today().day());
        objSc2.Quantity= 2;
        objSc2.Type= 'Quantity';
        objSc2.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc2);

        objSc3.ScheduleDate= date.newInstance(date.today().year(),3,date.today().day());
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
            mapAccId_ProdId.put(objOLI.Opportunity.Account.Id, new list<string>{objOLI.PricebookEntryId});
            mapProdId_Month_Qty.put(objOLI.PricebookEntryId,new list<string>{'1-May 2016','2-Jun 2016','3-Jul 2016','6-Mar 2016'});
        }
        String str ='Jul 2016';
        ForecastGridController.saveOLIQTY(str,mapOLI_MonthQty, mapOLI_OLIS, mapOLIS_Qty, mapAccId_ProdId, mapProdId_Month_Qty);
        OpportunityLineItemSchedule objSch= [SELECT Id,ScheduleDate,Quantity
                                            FROM OpportunityLineItemSchedule
                                            WHERE Id In:lstOppSch limit 1];
        //system.assertEquals(objSch.ScheduleDate.Month(),1);

    }
    //for month jan, feb,march,
    static testMethod void testSaveQty2(){
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
        objOpp.StageName='Authorization Successful';

        lstOpp.add(objOpp);
        insert lstOpp;
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, false);
        lstProd[0].CanUseQuantitySchedule = true;
        insert lstProd;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe;

        //Insert Opportunity Line Items
        List<OpportunityLineItem> lstOI = TestDataFactory.createOLItem(pbe.Id, lstOpp[0].id, 400, 20, 200);
        insert lstOI;

        List<OpportunityLineItemSchedule> lstOppSch = new List<OpportunityLineItemSchedule>();
        OpportunityLineItemSchedule objSc= new OpportunityLineItemSchedule();
        OpportunityLineItemSchedule objSc2= new OpportunityLineItemSchedule();
        OpportunityLineItemSchedule objSc1= new OpportunityLineItemSchedule();
        objSc.ScheduleDate= date.newInstance(date.today().year(),3,date.today().day());
        objSc.Quantity= 2;
        objSc.Type= 'Quantity';
        objSc.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc);

        objSc1.ScheduleDate= date.newInstance(date.today().year(),1,date.today().day());
        objSc1.Quantity= 2;
        objSc1.Type= 'Quantity';
        objSc1.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc1);

        objSc2.ScheduleDate= date.newInstance(date.today().year(),2,date.today().day());
        objSc2.Quantity= 2;
        objSc2.Type= 'Quantity';
        objSc2.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc2);
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
            mapOLI_MonthQty.put(string.valueof(objOLI.Id),new list<string>{'6-Mar 2016','7-Jan 2016','2-Feb 2016'});

            mapOLI_OLIS.put(string.valueof(objOLI.Id),new list<string>{string.valueof(lstOppSch[0].Id)});
            mapOLIS_Qty.put('',new list<string>{'6-Jul 2016','7-Aug 2016','2-Sep 2016'});
           // mapOLIS_Qty.put('',new list<string>{'11-Jul','10-Aug','9-Dec'});
            mapAccId_ProdId.put(objOLI.Opportunity.Account.Id, new list<string>{objOLI.PricebookEntryId});
            mapProdId_Month_Qty.put(objOLI.PricebookEntryId,new list<string>{'1-Dec 2016','2-Nov 2016','3-Apr 2016'});
        }
        String str ='Jul 2016';
        ForecastGridController.saveOLIQTY(str,mapOLI_MonthQty, mapOLI_OLIS, mapOLIS_Qty, mapAccId_ProdId, mapProdId_Month_Qty);
        OpportunityLineItemSchedule objSch= [SELECT Id,ScheduleDate,Quantity
                                            FROM OpportunityLineItemSchedule
                                            WHERE Id In:lstOppSch limit 1];
        system.assertEquals(objSch.ScheduleDate.Month(),3);

    }
    //Apr,May,Jun,July,Aug,sep
    static testMethod void testSaveQty3(){
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
        objOpp.StageName='Authorization Successful';

        lstOpp.add(objOpp);
        insert lstOpp;
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, false);
        lstProd[0].CanUseQuantitySchedule = true;
        insert lstProd;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe;

        //Insert Opportunity Line Items
        List<OpportunityLineItem> lstOI = TestDataFactory.createOLItem(pbe.Id, lstOpp[0].id, 400, 20, 200);
        insert lstOI;

        List<OpportunityLineItemSchedule> lstOppSch = new List<OpportunityLineItemSchedule>();
        OpportunityLineItemSchedule objSc= new OpportunityLineItemSchedule();
        OpportunityLineItemSchedule objSc2= new OpportunityLineItemSchedule();
        OpportunityLineItemSchedule objSc1= new OpportunityLineItemSchedule();
        objSc.ScheduleDate= date.newInstance(date.today().year(),4,date.today().day());
        objSc.Quantity= 2;
        objSc.Type= 'Quantity';
        objSc.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc);

        objSc1.ScheduleDate= date.newInstance(date.today().year(),5,date.today().day());
        objSc1.Quantity= 2;
        objSc1.Type= 'Quantity';
        objSc1.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc1);

        objSc2.ScheduleDate= date.newInstance(date.today().year(),6,date.today().day());
        objSc2.Quantity= 2;
        objSc2.Type= 'Quantity';
        objSc2.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc2);
        insert lstOppSch;
        PageReference pgRef = Page.ForecastGrid;
        pgRef.getParameters().put('Id',lstAcc[0].Id);
        Test.setCurrentPage(pgRef);
        for(OpportunityLineItem objOLI:[SELECT Id,PricebookEntryId,
                                               Opportunity.Account.Id,
                                        (SELECT Id
                                        FROM OpportunityLineItemSchedules
                                        WHERE Id IN:lstOppSch)
                                          FROM OpportunityLineItem
                                          WHERE Id IN: lstOI]){
            mapOLI_MonthQty.put(string.valueof(objOLI.Id),new list<string>{'6-Apr 2016','7-May 2016','2-Jun 2016'});

            mapOLI_OLIS.put(string.valueof(objOLI.Id),new list<string>{string.valueof(lstOppSch[0].Id)});
            mapOLIS_Qty.put('',new list<string>{'1-Jul 2016','2-Aug 2016','3-Sep 2016'});
            //mapOLIS_Qty.put('',new list<string>{'11-Feb','10-Dec','9-Sep'});
            mapAccId_ProdId.put(objOLI.Opportunity.Account.Id, new list<string>{objOLI.PricebookEntryId});
            mapProdId_Month_Qty.put(objOLI.PricebookEntryId,new list<string>{'1-Jul 2016','2-Aug 2016','3-Sep 2016'});
        }
        String str = 'Jul 2016';
        ForecastGridController.saveOLIQTY(str,mapOLI_MonthQty, mapOLI_OLIS, mapOLIS_Qty, mapAccId_ProdId, mapProdId_Month_Qty);
        OpportunityLineItemSchedule objSch= [SELECT Id,ScheduleDate,Quantity
                                            FROM OpportunityLineItemSchedule
                                            WHERE Id In:lstOppSch limit 1];
        //system.assertEquals(objSch.ScheduleDate.Month(),4);

    }
        static testMethod void testSaveQty5(){
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
        objOpp.StageName='Authorization Successful';

        lstOpp.add(objOpp);
        insert lstOpp;
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, false);
        lstProd[0].CanUseQuantitySchedule = true;
        insert lstProd;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe;

        //Insert Opportunity Line Items
        List<OpportunityLineItem> lstOI = TestDataFactory.createOLItem(pbe.Id, lstOpp[0].id, 400, 20, 200);
        insert lstOI;

        List<OpportunityLineItemSchedule> lstOppSch = new List<OpportunityLineItemSchedule>();
        OpportunityLineItemSchedule objSc= new OpportunityLineItemSchedule();
        OpportunityLineItemSchedule objSc2= new OpportunityLineItemSchedule();
        OpportunityLineItemSchedule objSc1= new OpportunityLineItemSchedule();
        objSc.ScheduleDate= date.newInstance(date.today().year(),1,date.today().day());
        objSc.Quantity= 2;
        objSc.Type= 'Quantity';
        objSc.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc);

        objSc1.ScheduleDate= date.newInstance(date.today().year(),2,date.today().day());
        objSc1.Quantity= 2;
        objSc1.Type= 'Quantity';
        objSc1.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc1);

        objSc2.ScheduleDate= date.newInstance(date.today().year(),3,date.today().day());
        objSc2.Quantity= 2;
        objSc2.Type= 'Quantity';
        objSc2.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc2);
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
            mapOLI_MonthQty.put(string.valueof(objOLI.Id),new list<string>{'6-Jan 2016','7-Feb 2016','2-Feb 2016'});
            for(OpportunityLineItemSchedule objSch:lstOppSch){
                //mapOLI_OLIS.put(string.valueof(objOLI.Id),new list<string>{string.valueof(objSch.Id)});
            }

        }
            String str ='Jul 2016';
            ForecastGridController.saveOLIQTY(str,mapOLI_MonthQty, mapOLI_OLIS, mapOLIS_Qty, mapAccId_ProdId, mapProdId_Month_Qty);
            ForecastGridController.setMonths2();
            ForecastGridController.setMonths();

    }

    static testMethod void testSaveQty6(){
        map<string,list<string>> mapOLI_MonthQty= new map<string,list<string>>();
        map<string,list<string>> mapOLI_OLIS= new map<string,list<string>>();
        map<string,list<string>> mapOLIS_Qty= new map<string,list<string>>();
        map<string,list<string>> mapAccId_ProdId= new map<string,list<string>>();
        map<string,list<string>> mapProdId_Month_Qty= new map<string,list<string>>();
        RecordType objRecBudget= [SELECT Id FROM RecordType Where Name=:system.label.Label_Budget limit 1];
        RecordType objRecPy= [SELECT Id FROM RecordType Where Name=:system.label.Label_Prior_Sales_Year limit 1];
        // Insert Account
        List<Account> lstAcc=TestDataFactory.createAccount('Test', 100);
        insert lstAcc;

        //Insert Opportunity
        list<Opportunity> lstOpp = new list<Opportunity>();
        Opportunity objOpp= new Opportunity();
        objOpp.Name='Opp1';
        objOpp.AccountId = lstAcc[0].Id;
        objOpp.RecordTypeId=objRecPy.Id;
        objOpp.CloseDate= date.today();
        objOpp.StageName='Authorization Successful';

        lstOpp.add(objOpp);
        insert lstOpp;
        Id standardPriceBookId = Test.getStandardPricebookId();
        //Insert Product
        List<Product2> lstProd =TestDataFactory.createProductList('Prod', 200, false);
        lstProd[0].CanUseQuantitySchedule = true;
        insert lstProd;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=lstProd[0].Id, UnitPrice=99, isActive=true);
        insert pbe;

        //Insert Opportunity Line Items
        List<OpportunityLineItem> lstOI = TestDataFactory.createOLItem(pbe.Id, lstOpp[0].id, 400, 20, 200);
        insert lstOI;

        List<OpportunityLineItemSchedule> lstOppSch = new List<OpportunityLineItemSchedule>();
        OpportunityLineItemSchedule objSc= new OpportunityLineItemSchedule();
        OpportunityLineItemSchedule objSc2= new OpportunityLineItemSchedule();
        OpportunityLineItemSchedule objSc1= new OpportunityLineItemSchedule();
        objSc.ScheduleDate= date.newInstance(date.today().year()-1,7,date.today().day());
        objSc.Quantity= 2;
        objSc.Type= 'Quantity';
        objSc.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc);

        objSc1.ScheduleDate= date.newInstance(date.today().year()-1,8,date.today().day());
        objSc1.Quantity= 2;
        objSc1.Type= 'Quantity';
        objSc1.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc1);

        objSc2.ScheduleDate= date.newInstance(date.today().year()-1,9,date.today().day());
        objSc2.Quantity= 2;
        objSc2.Type= 'Quantity';
        objSc2.OpportunityLineItemId = lstOI[0].Id;
        lstOppSch.add(objSc2);
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
            mapOLI_MonthQty.put(string.valueof(objOLI.Id),new list<string>{'6-Jul 2015','7-Aug 2015','2-Sep 2015'});
            for(OpportunityLineItemSchedule objSch:lstOppSch){
                //mapOLI_OLIS.put(string.valueof(objOLI.Id),new list<string>{string.valueof(objSch.Id)});
            }

        }
            String str ='Jul 2016';
            ForecastGridController.saveOLIQTY(str,mapOLI_MonthQty, mapOLI_OLIS, mapOLIS_Qty, mapAccId_ProdId, mapProdId_Month_Qty);
            ForecastGridController.setMonths2();
            ForecastGridController.setMonths();

    }
}