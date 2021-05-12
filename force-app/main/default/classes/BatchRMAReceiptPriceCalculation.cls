global class BatchRMAReceiptPriceCalculation implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful{
    
    private String currencyISOCode;
    private Integer maxAttempts;
    
    public BatchRMAReceiptPriceCalculation(String currencyISOCode) {
        this.currencyISOCode = currencyISOCode;
    }

    global static void schduleBatch() {
        String jobname =  'BatchRMAReceiptPriceCalculation ';
        
        if (Test.isRunningTest()) {
            jobname += Datetime.now().format();    
        }
        
        String schUSA =  '0 0 * * * ?';
        BatchRMAReceiptPriceCalculation priceBatchForUSA = new BatchRMAReceiptPriceCalculation('USD');
        String jobIDForUSA = system.schedule(jobName + 'JobUSA',schUSA, priceBatchForUSA);
        System.debug('### usa : ' +jobIDForUSA);
        
        String schCAN =  '0 15 * * * ?';
        BatchRMAReceiptPriceCalculation priceBatchForCAN = new BatchRMAReceiptPriceCalculation('CAD');
        String jobIDForCAN = system.schedule(jobName + 'JobCAN',schCAN, priceBatchForCAN);
        System.debug('### can : ' +jobIDForCAN);
        
        String schAUD =  '0 30 * * * ?';
        BatchRMAReceiptPriceCalculation priceBatchForAUS = new BatchRMAReceiptPriceCalculation('AUD');
        String jobIDForAUS = system.schedule(jobName + 'JobAUS',schAUD, priceBatchForAUS);
        System.debug('### aus : ' +jobIDForAUS);
        
        String schNZD =  '0 45 * * * ?';
        BatchRMAReceiptPriceCalculation priceBatchForNZ = new BatchRMAReceiptPriceCalculation('NZD');
        String jobIDForNZ = system.schedule(jobName + 'JobNZ',schNZD, priceBatchForNZ);
        System.debug('### nz : ' +jobIDForNZ);
        
        String schGBP =  '0 0 * * * ?';
        BatchRMAReceiptPriceCalculation priceBatchForUK = new BatchRMAReceiptPriceCalculation('GBP');
        String jobIDForUK = system.schedule(jobName + 'JobUK',schGBP, priceBatchForUK);
        System.debug('### uk : ' +jobIDForUK);
        
        String schEUR =  '0 50 * * * ?';
        BatchRMAReceiptPriceCalculation priceBatchForDE = new BatchRMAReceiptPriceCalculation('EUR');
        String jobIDForDE = system.schedule(jobName + 'JobDE', schEUR, priceBatchForDE);
        System.debug('### de : ' +jobIDForDE);
        
    }
    
    global void execute(SchedulableContext sc) {
        //check if already one batch is runnning then return this batch from execution
        //if (!Utility.isBatchRunning('BatchRMAReceiptPriceCalculation')) {
            //we can set chunk size to only 1 as depending on chargent api
            list<All_Literal__mdt> batchRmaPriceChunk = [Select Value__c from All_Literal__mdt where DeveloperName='BATCHRMARECEIPTCHUNK'];
            Database.executeBatch(this, Integer.valueOf(batchRmaPriceChunk[0].Value__c));
        //}
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String receviedDateDuration = '';
        String priceError = '';
        list<All_Literal__mdt> RMAReceivedDate = [Select Value__c from All_Literal__mdt where DeveloperName='RMAReceivedDate'];
        list<All_Literal__mdt> RMAPriceError = [Select Value__c from All_Literal__mdt where DeveloperName='RMAPriceErrorOccurred'];
        Map<String, PriceAPI__c> settings = PriceAPI__c.getAll();
        maxAttempts = Integer.valueOf(settings.get('PriceCalculationMaxAttempts').Value__c);
        
        //System.debug('RMAReceivedDate' + RMAReceivedDate);
        if (RMAReceivedDate != null && RMAReceivedDate.size() > 0) {
            receviedDateDuration = RMAReceivedDate[0].Value__c;
        }
        if (RMAPriceError != null && RMAPriceError.size() > 0) {
            priceError = RMAPriceError[0].Value__c;
        }
        
        
        String query = 'SELECT ID, RMACalculatedUnitPrice__c,RMACalculatedTotalPrice__c,IsPriceCalculated__c,Case__r.Account.IsWarrantyAccount__c,Case__r.RMA_Status__c,Case__r.Account.IsPersonAccount,Case__r.Account.DataAreaID__c,Case__r.CaseNumber,RMAProduct__c,RMAProduct__r.CalculatedUnitPrice__c, Case__r.Id,Case__r.Account.BusinessUnitFormula__c,'+
                        'ErrorOccurredWhileCalculatingPrice__c, Case__r.CurrencyIsoCode, Case__r.CreatedDate, '+
                        'Case__r.Refund_Amount__c, ' +
                        'Case__r.FG_Refund_Amount__c, ' +
                        'Received_Product__r.AX_Item_Number__c, Case__r.Purchase_Invoice_No__c, AXAccountNumber__c, Received_Qty__c, PriceCalculationAttempts__c, Received_AX_Item_Number__c '+
                        'FROM Receiving__c WHERE Case__c != null '+
                        'AND CurrencyIsoCode=:CurrencyIsoCode AND IsPriceCalculated__c = false '+ (priceError != null && priceError != '' ? ' AND ' + priceError : '') +
                        ( receviedDateDuration != '' && receviedDateDuration != null ? ' AND ('+receviedDateDuration +')':'') +'AND(PriceCalculationAttempts__c = null OR PriceCalculationAttempts__c < ' +maxAttempts  +')' 
                        +'ORDER BY Case__r.CaseNumber' ;
        
        System.debug('### query');
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Receiving__c> receivingList) {
        
        if (receivingList != null && receivingList.size() > 0) {
            map<Id,Case> RMAForUpdate = new map<Id,Case>();
            populateRMAProduct(receivingList);
            list<Receiving__c> receivingListWithoutCalculatedPrice = new list<Receiving__c>();
            list<Receiving__c> receivingListWithoutCalculatedPriceD365 = new list<Receiving__c>();
            list<Receiving__c> receivingListPersonAccount = new list<Receiving__c>();
            for (Receiving__c receiving : receivingList) {
                if (!receiving.IsPriceCalculated__c && receiving.Received_Product__c != null && receiving.Received_Product__r.AX_Item_Number__c != null 
                            && !receiving.Case__r.Account.IsPersonAccount && !receiving.Case__r.Account.IsWarrantyAccount__c) {
                    if (Utility.isD365Enabled(receiving.Case__r)) {
                        receivingListWithoutCalculatedPriceD365.add(receiving);
                    } else {
                        receivingListWithoutCalculatedPrice.add(receiving);
                    }
                }
                if (receiving.Case__r.Account.IsPersonAccount || receiving.Case__r.Account.IsWarrantyAccount__c) {
                    if (Utility.isD365Enabled(receiving.Case__r)) {
                        receiving.RMACalculatedUnitPrice__c = receiving.Case__r.FG_Refund_Amount__c;
                    } else {
                        receiving.RMACalculatedUnitPrice__c = 0;
                    }
                    
                    receiving.IsPriceCalculated__c = true;
                }
            }

            map<String, AXPriceUtility.PriceWrapper> idToPricewrapperMap = new map<String, AXPriceUtility.PriceWrapper>();
            if (receivingListWithoutCalculatedPrice.size() > 0 ) {
                idToPricewrapperMap = AXPriceUtility.getXmlResponse(receivingListWithoutCalculatedPrice, null);
            }

            Map<String, D365APIUtility.TradeAgreementPriceResponse> idToTradeAgreementResponseMap = new Map<String, D365APIUtility.TradeAgreementPriceResponse>();
            if (receivingListWithoutCalculatedPriceD365.size() > 0) {
                idToTradeAgreementResponseMap = D365APIUtility.getTradeAgreementPrice(receivingListWithoutCalculatedPriceD365, null);
            }
            
            map<Id, list<Receiving__c>> rmaReceiptToReceivingMap = new map<Id, list<Receiving__c>>();
            map<Id, Double> idToQuantityMap = new map<Id, Double>();
            map<Id, Double> idToPrice = new map<Id, Double>();
            list<RMA__c> updatedRMAReceiptList = new list<RMA__C>();
            //populate RMA product for Receiving
            //populateRMAProduct(receivingList);
            
            if (idToPricewrapperMap != null && idToPricewrapperMap.size() > 0) {
                for (Receiving__c record : receivingListWithoutCalculatedPrice) {
                    
                    if (idToPricewrapperMap.containsKey(record.Id)) {
                    
                        AXPriceUtility.PriceWrapper wrapper = idToPricewrapperMap.get(record.Id);
                        if (wrapper.SalesPrice != null) {
                            record.RMACalculatedUnitPrice__c = wrapper.SalesPrice;
                        }
                        record.IsPriceCalculated__c = true;
                    }
                           
                }
            } else {
                /* if price is not calculated successfully then price error counter is increased by 1 or set to 1*/
                for (Receiving__c record : receivingListWithoutCalculatedPrice) {
                    if (record.PriceCalculationAttempts__c != null) {
                        record.PriceCalculationAttempts__c = record.PriceCalculationAttempts__c + 1;
                        if (record.PriceCalculationAttempts__c == maxAttempts) {
                            record.ErrorOccurredWhileCalculatingPrice__c = true;
                        }			
                    } else {
                        record.PriceCalculationAttempts__c = 1;	
                    }
                }
            }

            if (idToTradeAgreementResponseMap != null && idToTradeAgreementResponseMap.size() > 0) {
                for (Receiving__c record : receivingListWithoutCalculatedPriceD365) {
                    if (idToTradeAgreementResponseMap.containsKey(record.Received_AX_Item_Number__c)) {
                        D365APIUtility.TradeAgreementPriceResponse wrapper = idToTradeAgreementResponseMap.get(record.Received_AX_Item_Number__c);
                        if (wrapper.Price != null) {
                            record.RMACalculatedUnitPrice__c = wrapper.Price;
                        }
                        record.IsPriceCalculated__c = true;
                    }
                }
            } else {
                /* if price is not calculated successfully then price error counter is increased by 1 or set to 1*/
                for (Receiving__c record : receivingListWithoutCalculatedPriceD365) {
                    if (record.PriceCalculationAttempts__c != null) {
                        record.PriceCalculationAttempts__c = record.PriceCalculationAttempts__c + 1;
                        if (record.PriceCalculationAttempts__c == maxAttempts) {
                            record.ErrorOccurredWhileCalculatingPrice__c = true;
                        }			
                    } else {
                        record.PriceCalculationAttempts__c = 1;	
                    }
                }
            }
                        
            for (Receiving__c record : receivingList) {
                if (record.Case__r.RMA_Status__c != 'Credit Complete' && !RMAForUpdate.containsKey(record.Case__r.Id)) {
                    RMAForUpdate.put(record.Case__r.Id,new Case(Id=record.Case__r.Id,RMA_Status__c = 'Credit Pending'));
                } 
            }
            if (receivingList != null && receivingList.size() > 0) {
                Database.SaveResult[] saveresult = Database.update(receivingList);
                system.debug('###saveresult'+saveresult );
            }
            
            update RMAForUpdate.values();
           
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
       
    } 
    
    private void populateRMAProduct(List<Receiving__c> receivingList) {
        
        set<Id> caseids = new set<Id>();
        map<Id, map<String, RMA_Product__c>> RMAProductByCaseId = new map<Id, map<String, RMA_Product__c>>();
        for (Receiving__c receiving : receivingList) {
            caseids.add(receiving.Case__r.Id);
        }
        for (RMA_Product__c rmaPro : [select Id,Case__c,Product__r.AX_Item_Number__c,RMACreditValue__c from RMA_Product__c where Case__c IN:caseids]) {
            if (!RMAProductByCaseId.containsKey(rmaPro.Case__c)) {
                RMAProductByCaseId.put(rmaPro.Case__c,new map<String,RMA_Product__c>{rmaPro.Product__r.AX_Item_Number__c=>rmaPro});
            } else {
                RMAProductByCaseId.get(rmaPro.Case__c).put(rmaPro.Product__r.AX_Item_Number__c,rmaPro);
            }
        }
        
        for (Receiving__c receiving : receivingList) {
            if (RMAProductByCaseId.containsKey(receiving.Case__r.Id) && RMAProductByCaseId.get(receiving.Case__r.Id) != null
                             && RMAProductByCaseId.get(receiving.Case__r.Id).containsKey(receiving.Received_Product__r.AX_Item_Number__c)) {
                                
                receiving.RMAProduct__c = RMAProductByCaseId.get(receiving.Case__r.Id).get(receiving.Received_Product__r.AX_Item_Number__c).id;
                if (RMAProductByCaseId.get(receiving.Case__r.Id).get(receiving.Received_Product__r.AX_Item_Number__c).RMACreditValue__c != null) {
                    receiving.RMACalculatedUnitPrice__c = RMAProductByCaseId.get(receiving.Case__r.Id).get(receiving.Received_Product__r.AX_Item_Number__c).RMACreditValue__c;
                    /*if (receiving.Received_Qty__c != null) {
                        receiving.RMACalculatedTotalPrice__c = receiving.RMACalculatedUnitPrice__c * receiving.Received_Qty__c;
                    }*/
                    receiving.IsPriceCalculated__c = true;
                }
                
            }
            
        }
        
        
    }
}