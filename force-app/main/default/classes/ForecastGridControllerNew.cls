/*
ForecastGridControllerNew is a controller for ForecastGridNew page.
To show the opportunity schedule fore 'Forecast' and 'budget' record type.
*/
public with sharing class ForecastGridControllerNew{
    
    public static string strAccName{get;set;}
    public static string strJson{get;set;}
    public static list<String> lstString1{get;set;}
    public Date dtFrom{get;set;}
    public Date dtTo{get;set;}
    public Date dtFromPY{get;set;}
    public Date dtToPY{get;set;}
    public String dtFromStr{get;set;}
    public String dtToStr{get;set;}
    public static Id AccountId{get;set;}
    public static string strBlankData='',idOLISchedule='';
    public static list<OpportunityLineItem> lstOppLineItem;
    public static map<string,boolean> mapProdId_BudgetRecType;
    public static map<string,boolean> mapProdId_ForecastRecType;
    public static map<string,boolean> mapProdId_PriorYearRecType;
    public list<string> monthList {get;set;}
    public list<string> fullMonthList {get;set;}
    static integer cnt=1;
    static integer intCurrentYearCol=date.today().year();
    
    public String cellWidths {get;set;}
    public String colHeaders {get;set;}
    public String colAlignments {get;set;}
    public String colTypes {get;set;}
    public String resizeHeaders {get;set;}
    
    public integer recColumn {get;set;}
    public integer accColumn {get;set;}
    public integer oliColumn {get;set;}
    public integer oliScheduleCol {get;set;}
    public integer colVariance {get;set;}
    public integer productId {get;set;}
    
    public integer cellCount{get;set;}
    public integer initialColumns = 6; //No. of columns before monthly data, starting from 1
    public integer indexOfEditableColumns {get;set;}
    
    public integer fromDateMonth {get;set;}
    public integer fromDateYear {get;set;}
    public integer toDateMonth {get;set;}
    public integer toDateYear {get;set;}
    public Map<String,String> columnWidthMap = new Map<String,String>();
    
    public ForecastGridControllerNew(ApexPages.StandardController controller) {
        list<ForeCastGrid__mdt> literalRec = [SELECT Value__c, DeveloperName FROM ForeCastGrid__mdt];
         if(literalRec != null && literalRec.size() > 0){
             for(ForeCastGrid__mdt metaDataRecord:literalRec)
    			columnWidthMap.put(String.valueOf(metaDataRecord.DeveloperName),String.valueOf(metaDataRecord.Value__c));
 		  } 
        AccountId = ApexPages.currentPage().getParameters().get('id');
         cellCount =0;
         setValues();
         setDateVals(Date.today());
         dtFromStr = fullMonthList.get(dtFrom.month()-1) + '-'+dtFrom.year();
         dtToStr = fullMonthList.get(dtTo.month()-1) + '-'+dtTo.year();
         getOpportunityData();
    }
    
    private void setValues(){
        monthList = new List<String>{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
        fullMonthList = new List<String> {'January','February','March','April','May','June','July','August','September','October','November','December'};
    }

    public void loadData(){
        cellCount = 0;
        intCurrentYearCol= date.today().year();
        AccountId = ApexPages.currentPage().getParameters().get('id');
         
        Account objAcc= new Account();
        if(AccountId <> NULL){
            objAcc= [select Name
                       from Account where Id =: AccountId];
            strAccName= objAcc.Name;
        }// end if
        
        lstString1 = new list<String>();
        lstString1.clear();
        Date dateVal = dtFrom.toStartOfMonth();
        Date todaysDate =  Date.today().toStartOfMonth();
        indexOfEditableColumns = initialColumns-1;//since we want index
        while(dateVal <= dtTo){
            lstString1.add(monthList[dateVal.month()-1] + ' '+dateVal.year());
            cellCount++;
            if(dateVal <= todaysDate){
                indexOfEditableColumns++;
            }
            dateVal = dateVal.addMonths(1);
        }
        configureGridProperties(cellCount);
        accColumn = initialColumns+cellCount+1;
        oliColumn = accColumn +1;
        oliScheduleCol = accColumn + 2;
        recColumn = accColumn + 3;
        productId = accColumn + 4;
        colVariance = accColumn +5;
    }
    
    public void fetchData(){   
        if(isDataValid()){
            loadData();
            getOpportunityData();
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select proper date range.'));
        }
    }
    
    public boolean isDataValid(){
        boolean isValid = true;
        if(dtFrom.daysBetween(dtTo) >= 0){
            isValid = true;
        }
        else{
            isValid = false;
        }
        return isValid;
    }
    
    public void getOpportunityData(){
        AccountId = ApexPages.currentPage().getParameters().get('id');
        mapProdId_BudgetRecType= new map<string,boolean>();
        mapProdId_ForecastRecType= new map<string,boolean>();
        mapProdId_PriorYearRecType= new map<string,boolean>();
        strJson= '""';
        cnt=1;
        strBlankData= getBlanKData(dtFrom, dtTo);
        Id idUser=UserInfo.getUserId();
        lstOppLineItem=[SELECT Opportunity.RecordType.Name, Product2.Id, Product2.Name, Product2.Description,
                               Opportunity.Account.Id, Opportunity.Account.Name, PricebookEntryId, Product2.Product_Sub_Family__c,
                       (SELECT ScheduleDate, Quantity
                          FROM OpportunityLineItemSchedules
                          WHERE ScheduleDate >=: dtFromPY  AND ScheduleDate <=: dtTo
                          AND OpportunityLineItem.Opportunity.OwnerId=:idUser
                          AND OpportunityLineItem.Opportunity.Account.Id <> NULL
                          AND OpportunityLineItem.Opportunity.Account.Id =: AccountId
                          AND (OpportunityLineItem.Opportunity.RecordType.Name =:system.label.Label_Forecast
                           OR OpportunityLineItem.Opportunity.RecordType.Name =:system.label.Label_Budget
                           OR OpportunityLineItem.Opportunity.RecordType.Name =:system.label.Label_Prior_Sales_Year)
                      order by ScheduleDate ASC)
                         FROM OpportunityLineItem
                        WHERE Opportunity.OwnerId=:idUser
                          AND Opportunity.Account.Id <> NULL
                          AND Opportunity.Account.Id =: AccountId
                         AND (Opportunity.RecordType.Name =:system.label.Label_Forecast
                           OR Opportunity.RecordType.Name =:system.label.Label_Budget
                           OR OpportunityLineItem.Opportunity.RecordType.Name =:system.label.Label_Prior_Sales_Year)
                    ORDER By Opportunity.Account.Name Asc,Product2.Name Asc, Opportunity.RecordType.DeveloperName DESC];
        if(lstOppLineItem <> NULL && !lstOppLineItem.isEmpty()){
            for(OpportunityLineItem objLineItem : lstOppLineItem){
                 if(objLineItem.Opportunity.RecordType.Name.equalsIgnoreCase(system.label.Label_Budget)){
                        mapProdId_BudgetRecType.put(objLineItem.Opportunity.Account.Id+'+'+objLineItem.Product2.Id, true);
                 }
                 if(objLineItem.Opportunity.RecordType.Name.equalsIgnoreCase(system.label.Label_Forecast)){
                       mapProdId_ForecastRecType.put(objLineItem.Opportunity.Account.Id+'+'+objLineItem.Product2.Id, true);
                 }// end forecast if
                 if(objLineItem.Opportunity.RecordType.Name.equalsIgnoreCase(system.label.Label_Prior_Sales_Year)){
                       mapProdId_PriorYearRecType.put(objLineItem.Opportunity.Account.Id+'+'+objLineItem.Product2.Id, true);
                 }// end if PY sales
            }// end for
            if(lstOppLineItem <> NULL && !lstOppLineItem.isEmpty()){
                strJson= '{rows:[';
                getOLI(mapProdId_ForecastRecType,mapProdId_BudgetRecType,lstOppLineItem);
            }//end if
        }// end if

    }// end method
    // method to get grouped forecast and budget products with OLI schedules
    public void getOLI(map<string,boolean> mapProduId_Forecast, map<string,boolean> mapProdId_Budget, list<OpportunityLineItem> lstOLI){
       Integer intTotalQLI =0,donePrior=0,intMonth=12,intCnt=1,done=0;
       Integer doneBudget=0, intForecastTotal=0, intBudgetTotal=0, intPriorTotal=0,intForecastTotalPY=0;
       map<String,Integer> mapMonth_Qty = new map<String,Integer>();
       Decimal dlPerChange=0.0, dlPerChangePrior=0.0, dlPerChangeActual=0.0;
       String actualJson= '';
       map<String,Integer> mapMonth_Qty_act = new map<String,Integer>(); // to be used for actual
       Integer intTotalQLI_act = 0;
        Integer abbreviationLength;
       String abbreviationLengthString = fetchValueFromMetadata('ForeCastGridAbbreviationLength');
        if(abbreviationLengthString != null){
            abbreviationLength = Integer.valueOf(abbreviationLengthString);
        }else{
            abbreviationLength = 25;
        }
       for(OpportunityLineItem objOLI: lstOLI){
             mapMonth_Qty = new map<String,Integer>();
            intTotalQLI=0;
            if(mapProdId_BudgetRecType.get(objOLI.Opportunity.Account.Id+'+'+objOLI.Product2.Id)== true
            && done==0 && objOLI.Opportunity.RecordType.Name <> system.label.Label_Prior_Sales_Year){
            	strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","'+ string.valueof(objOLI.Product2.Name).remove('"')+'","';
            	
                if(string.isNotBlank(objOLI.Product2.Product_Sub_Family__c) && objOLI.Product2.Product_Sub_Family__c <> NULL){
                    strJson+= objOLI.Product2.Product_Sub_Family__c.remove('"')+'","'+ string.valueof(objOLI.Product2.Product_Sub_Family__c).remove('"').abbreviate(abbreviationLength)+'","';
                }
                else{
                	strJson+= '","","';
                }
                if(string.isNotBlank(objOLI.Product2.Description) && objOLI.Product2.Description <> NULL){
                    strJson+= objOLI.Product2.Description.remove('"').abbreviate(abbreviationLength)+'",';
                }
                else{
                	strJson+= '",';
                }
                strJson+= '"'+objOLI.Opportunity.RecordType.Name+'",';
                if(objOLI.OpportunityLineItemSchedules<> NULL && !objOLI.OpportunityLineItemSchedules.isEmpty()){
                    for(OpportunityLineItemSchedule  objSchedule :objOLI.OpportunityLineItemSchedules){
                    	if(objSchedule.ScheduleDate >= dtFrom && objSchedule.ScheduleDate <= dtTo){
	                        idOLISchedule = objSchedule.Id;
	                        mapMonth_Qty.put(objSchedule.ScheduleDate.month()+'_'+objSchedule.ScheduleDate.year(),Integer.valueof(objSchedule.Quantity));
	                        intTotalQLI += integer.valueof(objSchedule.Quantity);
                    	}
                    }// end for
                }
                strJson += getJsonFromMapMonthQty(mapMonth_Qty, dtFrom, dtTo);
                intBudgetTotal +=intTotalQLI;
                if(mapMonth_Qty <> NULL && !mapMonth_Qty.isEmpty() && intTotalQLI<> 0){
                    strJson+='"'+intTotalQLI+'","","'+objOLI.Id+'","'+idOLISchedule+'","'+system.label.Label_Forecast+'"]},';   
                }
                else{
                    strJson+='"","","'+objOLI.Id+'","","'+system.label.Label_Forecast+'"]},';
                }
                intTotalQLI=0;
                mapMonth_Qty.clear();
                cnt++;
                done=0;
                doneBudget=1;
                donePrior=0;
            }
             if(mapProdId_ForecastRecType.get(objOLI.Opportunity.Account.Id+'+'+objOLI.Product2.Id) == true
             && objOLI.Opportunity.RecordType.Name <> system.label.Label_Prior_Sales_Year){
                if(mapProdId_Budget.get(objOLI.Opportunity.Account.Id+'+'+objOLI.Product2.Id) == true && done==0){
                     done=1;
                }// end if budget
                else{
                    if(doneBudget==0 || done==0){
                    
                    strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","'+ string.valueof(objOLI.Product2.Name).remove('"')+'","';
            	
	                if(string.isNotBlank(objOLI.Product2.Product_Sub_Family__c) && objOLI.Product2.Product_Sub_Family__c <> NULL){
	                    strJson+= objOLI.Product2.Product_Sub_Family__c.remove('"')+'","'+ string.valueof(objOLI.Product2.Product_Sub_Family__c).remove('"').abbreviate(abbreviationLength)+'","';
	                }
	                else{
	                	strJson+= '","","';
	                }
	                if(string.isNotBlank(objOLI.Product2.Description) && objOLI.Product2.Description <> NULL){
	                    strJson+= objOLI.Product2.Description.remove('"').abbreviate(abbreviationLength)+'",';
	                }
	                else{
	                	strJson+= '",';
	                }	
					
                    /*if(string.isNotBlank(objOLI.Product2.Description)
                    && objOLI.Product2.Description <> NULL){
                        strJson+= '{id:'+cnt+', data:'+'["'+objOLI.Product2.Name+'","'+ string.valueof(objOLI.Product2.Name)+'","'+objOLI.Product2.Product_Sub_Family__c.remove('"')+'","'+ string.valueof(objOLI.Product2.Product_Sub_Family__c).remove('"')+'","'+objOLI.Product2.Description.remove('"')+'",';
                    }
                    else{
                       strJson+= '{id:'+cnt+', data:'+'["'+objOLI.Product2.Name+'","'+ string.valueof(objOLI.Product2.Name)+'","'+objOLI.Product2.Product_Sub_Family__c.remove('"')+'","'+ string.valueof(objOLI.Product2.Product_Sub_Family__c).remove('"')+'","'+objOLI.Product2.Description+'",';
                    }*/
                    strJson+= '"'+system.label.Label_Budget+'",'+strBlankData+',"'+objOLI.Opportunity.Account.Id+'","","","","'+objOLI.PriceBookEntryId+'"]},';
                    cnt++;
                    }
                    doneBudget=1;
                    donePrior=1;
                    if(string.isNotBlank(objOLI.Product2.Product_Sub_Family__c) && objOLI.Product2.Product_Sub_Family__c <> NULL){
	                    strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","'+objOLI.Product2.Product_Sub_Family__c.remove('"')+'","","",';
	                }
	                else
                    	strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","","","",';
                    strJson+= '"'+objOLI.Opportunity.RecordType.Name+'",';
                    if(objOLI.OpportunityLineItemSchedules<> NULL && !objOLI.OpportunityLineItemSchedules.isEmpty()){
                    for(OpportunityLineItemSchedule  objSchedule :objOLI.OpportunityLineItemSchedules){
                    	if(objSchedule.ScheduleDate >= dtFrom && objSchedule.ScheduleDate <= dtTo){
	                        idOLISchedule = objSchedule.Id;
	                        mapMonth_Qty.put(objSchedule.ScheduleDate.month()+'_'+objSchedule.ScheduleDate.year(),Integer.valueof(objSchedule.Quantity));
	                        intTotalQLI += integer.valueof(objSchedule.Quantity);
                        }
                    }
                    }// end for
                    
                    strJson += getJsonFromMapMonthQty(mapMonth_Qty, dtFrom, dtTo);
                    
                    intForecastTotal+=intTotalQLI;
                     if(intBudgetTotal <> 0  && intForecastTotal <> 0 && string.valueof(intForecastTotal)  <> ''
                        && string.valueof(intForecastTotal )<> NULL   && string.valueof(intBudgetTotal ) <> ''
                        && string.valueof (intBudgetTotal) <> NULL){
                         dlPerChange= ((decimal.valueof(intForecastTotal) - decimal.valueof(intBudgetTotal))/decimal.valueof(intBudgetTotal))*100;
                         strJson+='"'+intTotalQLI+'","","'+objOLI.Id+'","'+idOLISchedule+'","'+system.label.Label_Forecast+'","","'+dlPerChange.setScale(2)+' %"]},';
                    }
                    else if(mapMonth_Qty <> NULL && !mapMonth_Qty.isEmpty() && intTotalQLI<> 0){
                         strJson+='"'+intTotalQLI+'","","'+objOLI.Id+'","'+idOLISchedule+'","'+system.label.Label_Forecast+'"]},';
                    }
                    else{
                        strJson+='"","","'+objOLI.Id+'","","'+system.label.Label_Forecast+'"]},';
                    }
                    intTotalQLI=0;
                    mapMonth_Qty.clear();
                    intBudgetTotal =0;
                    intForecastTotalPY=intForecastTotal ;
                    intForecastTotal =0; 
                    cnt++;
                }
            }
            else{
               if(mapProdId_Budget.get(objOLI.Opportunity.Account.Id+'+'+objOLI.Product2.Id) <> true && (done==0
               && doneBudget== 0)){
                    intBudgetTotal =0;
                    intForecastTotal =0;
                    doneBudget=1;
                    done=1;
                    strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","'+ string.valueof(objOLI.Product2.Name).remove('"')+'","';
            	
	                if(string.isNotBlank(objOLI.Product2.Product_Sub_Family__c) && objOLI.Product2.Product_Sub_Family__c <> NULL){
	                    strJson+= objOLI.Product2.Product_Sub_Family__c.remove('"')+'","'+ string.valueof(objOLI.Product2.Product_Sub_Family__c).remove('"').abbreviate(abbreviationLength)+'","';
	                }
	                else{
	                	strJson+= '","","';
	                }
	                if(string.isNotBlank(objOLI.Product2.Description) && objOLI.Product2.Description <> NULL){
	                    strJson+= objOLI.Product2.Description.remove('"').abbreviate(abbreviationLength)+'",';
	                }
	                else{
	                	strJson+= '",';
	                }	
                    /*if(string.isNotBlank(objOLI.Product2.Description)
                    && objOLI.Product2.Description <> NULL){
                        strJson+= '{id:'+cnt+', data:'+'["'+objOLI.Product2.Name+'","'+ string.valueof(objOLI.Product2.Name)+'","'+objOLI.Product2.Product_Sub_Family__c.remove('"')+'","'+ string.valueof(objOLI.Product2.Product_Sub_Family__c).remove('"')+'","'+objOLI.Product2.Description.remove('"')+'",';
                    }
                    else{
                        strJson+= '{id:'+cnt+', data:'+'["'+objOLI.Product2.Name+'","'+ string.valueof(objOLI.Product2.Name)+'","'+objOLI.Product2.Product_Sub_Family__c.remove('"')+'","'+ string.valueof(objOLI.Product2.Product_Sub_Family__c).remove('"')+'","'+objOLI.Product2.Description+'",';
                    }*/
                    strJson+= '"'+system.label.Label_Budget+'",'+strBlankData+',"'+objOLI.Opportunity.Account.Id+'","","","","'+objOLI.PriceBookEntryId+'"]},';
                    cnt++;
                }
                if(mapProduId_Forecast.get(objOLI.Opportunity.Account.Id+'+'+objOLI.Product2.Id) <> true
                	&& doneBudget==1){
	                intBudgetTotal =0;
	                intForecastTotal =0;
	                done=0;
	                donePrior=1;
	                if(string.isNotBlank(objOLI.Product2.Product_Sub_Family__c) && objOLI.Product2.Product_Sub_Family__c <> NULL)
	                	strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","'+objOLI.Product2.Product_Sub_Family__c.remove('"')+'","","",';
	                else
	                	strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","","","",';
	                strJson+= '"'+system.label.Label_Forecast+'",'+strBlankData+',"'+objOLI.Opportunity.Account.Id+'","","","","'+objOLI.PriceBookEntryId+'"]},';
	                doneBudget=0;
	                cnt++;
                }
            }
            if(mapProdId_PriorYearRecType.get(objOLI.Opportunity.Account.Id+'+'+objOLI.Product2.Id) == true
                && donePrior==1 && objOLI.Opportunity.RecordType.Name == system.label.Label_Prior_Sales_Year
                && objOLI.Opportunity.RecordType.Name <> system.label.Label_Forecast){
            		done=0;donePrior=0;doneBudget=0;
            		if(string.isNotBlank(objOLI.Product2.Product_Sub_Family__c) && objOLI.Product2.Product_Sub_Family__c <> NULL){
                    	strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","'+objOLI.Product2.Product_Sub_Family__c.remove('"')+'","","",';
                    	actualJson+= '{id:'+(cnt+1)+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","'+objOLI.Product2.Product_Sub_Family__c.remove('"')+'","","",';
            		}
                    else{
                    	strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","","","",';
                    	actualJson+= '{id:'+(cnt+1)+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","","","",';
                    }
                    strJson+= '"'+objOLI.Opportunity.RecordType.Name+'",';
                    actualJson+= '"'+system.label.Label_Actual+'",';
                    if(objOLI.OpportunityLineItemSchedules<> NULL && !objOLI.OpportunityLineItemSchedules.isEmpty()){
                        mapMonth_Qty.clear();
                        for(OpportunityLineItemSchedule  objSchedule :objOLI.OpportunityLineItemSchedules){
                        	if(objSchedule.ScheduleDate >= dtFromPY && objSchedule.ScheduleDate <= dtToPY){
		                        idOLISchedule = objSchedule.Id;
		                        mapMonth_Qty.put(objSchedule.ScheduleDate.month()+'_'+objSchedule.ScheduleDate.year(),Integer.valueof(objSchedule.Quantity));
		                        intTotalQLI += integer.valueof(objSchedule.Quantity);
                    		}
                    		
                    		if(objSchedule.ScheduleDate >= dtFrom && objSchedule.ScheduleDate <= dtTo){
		                        idOLISchedule = objSchedule.Id;
		                        mapMonth_Qty_act.put(objSchedule.ScheduleDate.month()+'_'+objSchedule.ScheduleDate.year(),Integer.valueof(objSchedule.Quantity));
		                        intTotalQLI_act += integer.valueof(objSchedule.Quantity);
                    		}
                   		}// end for
                    }
                    strJson += getJsonFromMapMonthQty(mapMonth_Qty, dtFromPY, dtToPY);
                    actualJson+= getJsonFromMapMonthQty(mapMonth_Qty_act, dtFrom, dtTo);
                    
                    intPriorTotal+=intTotalQLI;
                    if(intPriorTotal <> 0  && intForecastTotalPY <> 0  && string.valueof(intForecastTotalPY )  <> ''
                        && string.valueof(intForecastTotalPY )<> NULL  && string.valueof(intPriorTotal ) <> ''
                        && string.valueof (intPriorTotal) <> NULL){
                            dlPerChangePrior= ((decimal.valueof(intForecastTotalPY) - decimal.valueof(intPriorTotal))/decimal.valueof(intPriorTotal))*100;
                            strJson+='"'+intTotalQLI+'","","","","","","'+dlPerChangePrior.setScale(2)+' %"]},';
                    }
                    else  if(mapMonth_Qty <> NULL && !mapMonth_Qty.isEmpty() && intTotalQLI<> 0){
                    	strJson+='"'+intTotalQLI+'"]},';
                    }
                    else {
                    	strJson+='""]},';
                    }
                    
                    if(intTotalQLI_act <> 0  && intForecastTotalPY <> 0  && string.valueof(intForecastTotalPY )  <> ''
                        && string.valueof(intForecastTotalPY )<> NULL  && string.valueof(intTotalQLI_act ) <> ''
                        && string.valueof (intTotalQLI_act) <> NULL){
                            dlPerChangeActual= ((decimal.valueof(intTotalQLI_act) - decimal.valueof(intForecastTotalPY))/decimal.valueof(intForecastTotalPY))*100;
                            actualJson+='"'+intTotalQLI_act+'","","","","","","'+dlPerChangeActual.setScale(2)+' %"]},';
                    }
                    else  if(mapMonth_Qty_act <> NULL && !mapMonth_Qty_act.isEmpty() && intTotalQLI_act<> 0){
                    	actualJson+='"'+intTotalQLI_act+'"]},';
                    }
                    else {
                    	actualJson+='""]},';
                    }
                    mapMonth_Qty.clear();
                    intTotalQLI=0;
                    intBudgetTotal =0;
                    intForecastTotal =0;
                    intForecastTotalPY=0;
                    intPriorTotal=0;
                    cnt++;
                    
                    strJson+=actualJson;
                    cnt++;
                    actualJson = '';
                    intTotalQLI_act  =0;
                    mapMonth_Qty_act.clear();
                }// end else if
                else{
                  if(mapProdId_PriorYearRecType.get(objOLI.Opportunity.Account.Id+'+'+objOLI.Product2.Id) <> true
                  && donePrior==1){
                  	actualJson = '';
                    done=0;
                    donePrior=0;doneBudget=0;
                    intBudgetTotal =0;
                    intForecastTotal =0;
                    intForecastTotalPY=0;
                    intPriorTotal=0;
                    if(string.isNotBlank(objOLI.Product2.Product_Sub_Family__c) && objOLI.Product2.Product_Sub_Family__c <> NULL){
                    	strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","'+objOLI.Product2.Product_Sub_Family__c.remove('"')+'","","",';
                    	actualJson+= '{id:'+(cnt+1)+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","'+objOLI.Product2.Product_Sub_Family__c.remove('"')+'","","",';
                    }
                    else{
                    	strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","","","",';
                    	actualJson+= '{id:'+(cnt+1)+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","","","",';
                    }
                    strJson+= '"'+system.label.Label_Prior_Sales_Year+'",'+strBlankData+']},';
                    actualJson+= '"'+system.label.Label_Actual+'",'+strBlankData+']},';
                    cnt++;
                    strJson+=actualJson;
                    cnt++;
                    actualJson = '';
                  }
                }
        }//END for
        strJson= strJson.removeEnd(',');
        strJson+=']};';
    }// end method

    private String getJsonFromMapMonthQty(map<string,integer> mapMonthQty, Date dtFrom, Date dtTo)
    {
        String monthJson = '';
        Date dateVal = dtFrom.toStartOfMonth();
        while(dateVal <= dtTo){
            if(mapMonthQty.containsKey(dateVal.month()+'_'+dateVal.year())){
                monthJson+='"'+mapMonthQty.get(dateVal.month()+'_'+dateVal.year())+'",';
            }
            else{
                monthJson+='"",';
            }
            dateVal = dateVal.addMonths(1);
        }
        return monthJson;
    }
    
    private String getBlankData(Date dtFrom, Date dtTo)
    {
        String blankJson = '';
        Date dateVal = dtFrom.toStartOfMonth();
        while(dateVal <= dtTo){
            blankJson+='"",';
            dateVal = dateVal.addMonths(1);
        }
        blankJson+='""';
        return blankJson;
    }
    // to update the opportunity line item Schedule
    @RemoteAction
    public static void saveOLIQTY(String strMonName,
                                  map<string ,list<string>> mapOLI_Qty,
                                  map<string,list<string>> mapOLI_OLISchedule,
                                  map<string,list<string>> mapOLIS_Qty,
                                  map<string,list<string>> mapAccId_ProdId,
                                  map<string,list<string>> mapProdId_Month_Qty) {
        string strMonth='';
        integer intMonth=0;
        map<String,list<string>> mapOLIid_Mont_Qty= new map<String,list<string>>();
        list<OpportunityLineItemSchedule> lstUpdateOLIS =new list<OpportunityLineItemSchedule>();
        list<OpportunityLineItemSchedule> lstScheduleUpdate = new list<OpportunityLineItemSchedule>();
        map<string,list<string>> mapOLI_Not_Year_and_Month= new map<string,list<string>>();
        list<string> lstString = new list<string>();
        if(mapOLI_OLISchedule.values() <> NULL && !mapOLI_OLISchedule.values().isEmpty()){
            for(OpportunityLineItemSchedule objSchedule: [SELECT Id, OpportunityLineItemId, ScheduleDate, Quantity FROM OpportunityLineItemSchedule
                                                          WHERE OpportunityLineItemId IN:mapOLI_OLISchedule.keySet()]){
                if(objSchedule <> NULL){
                    if(objSchedule.ScheduleDate.year() >= date.today().year()){
                        for(String strQty_Month: mapOLI_Qty.get(objSchedule.OpportunityLineItemId )){
                            strMonth = strQty_Month.split('-')[1].substring(0,3);
                            integer intYearCol = integer.valueof(strQty_Month.split('-')[1].substring(4,8));
                            intMonth= getMonthFromLabel(strMonth);
                            if(intMonth != -1)  {
                                if(objSchedule.ScheduleDate.month() == intMonth && objSchedule.ScheduleDate.year()== intYearCol){
                                    objSchedule.ScheduleDate= date.newInstance(intYearCol,intMonth,28);
                                    objSchedule.Quantity=0;
                                    objSchedule.Quantity =decimal.valueof(strQty_Month.split('-')[0]);
                                    lstScheduleUpdate.add(objSchedule);
                            	}// end if
                            }
                            else{
                                mapOLI_Not_Year_and_Month.putAll(mapOLI_Qty);
                            }
                        }
                    }
                    else{
                        mapOLI_Not_Year_and_Month.putAll(mapOLI_Qty);
                    }
                }
                else{
                    mapOLI_Not_Year_and_Month.putAll(mapOLI_Qty);
                }
           }
        }
        else {
            insertOLISchedule(mapOLI_Qty);
        }
        if(lstScheduleUpdate<> NULL && !lstScheduleUpdate.isEmpty()){
	        set<OpportunityLineItemSchedule> setUpdateOLIS  =new set<OpportunityLineItemSchedule>();
	        setUpdateOLIS.addAll(lstScheduleUpdate);
	        lstUpdateOLIS.addAll(setUpdateOLIS);
	        update lstUpdateOLIS;
        }
        //insert OLIs newly which does not have single record
        if(mapOLIS_Qty <> NULL && !mapOLIS_Qty.isEmpty()){
            insertOLISchedule(mapOLIS_Qty);                
        }
        if(mapOLI_Not_Year_and_Month.size() >0 && lstUpdateOLIS.size() == 0 && (mapOLIS_Qty.size () ==0 || lstUpdateOLIS.size() > 0)){
            insertOLISchedule(mapOLI_Not_Year_and_Month);
        }
        if(mapAccId_ProdId <> NULL && !mapAccId_ProdId.isEmpty() && mapProdId_Month_Qty <> NULL && !mapProdId_Month_Qty.isEmpty()){
            createOLIForecastOpportunity(mapAccId_ProdId,mapProdId_Month_Qty);
        }// end if
    }// end method

    // insert opportunity line item schedule
    public static void insertOLISchedule(map<string ,list<string>> mapOLI_QtyInsert) {
    string strMonth='';
    integer intMonth=0;
    OpportunityLineItemSchedule objSchedule;
    list<OpportunityLineItemSchedule> lstSchedule = new list<OpportunityLineItemSchedule>();
    if(mapOLI_QtyInsert<> NULL && !mapOLI_QtyInsert.isEmpty() && mapOLI_QtyInsert.keyset() <> NULL && !mapOLI_QtyInsert.keySet().isEmpty()){
        for(String idOppLine: mapOLI_QtyInsert.keySet()){
            if(idOppLine <> NULL && string.isNotBlank(idOppLine)){
                for(String strQty_Month: mapOLI_QtyInsert.get(idOppLine)){
                    objSchedule= new OpportunityLineItemSchedule ();
                    objSchedule.OpportunityLineItemId = idOppLine;
                    objSchedule.Type= 'Quantity';
                    objSchedule.Quantity =decimal.valueof(strQty_Month.split('-')[0]);
                    strMonth= strQty_Month.split('-')[1].substring(0,3);
                    integer intYearCol = integer.valueof(strQty_Month.split('-')[1].substring(4,8));
                    intMonth= getMonthFromLabel(strMonth);
                    objSchedule.ScheduleDate= date.newInstance(intYearCol,intMonth,28);
                    lstSchedule.add(objSchedule);
                    }// end for
                }// end if
            }// end for
            insert lstSchedule;
        }
    }// end method
    
    public static integer getMonthFromLabel(String strMonth)
    {
        List<String> monthList = new List<String>{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
        for(integer i=0; i< monthList.size();i++){
            if(monthList.get(i) == strMonth){
                return i+1;
            }
        }
        return -1;
    }
    // create Opportunity Line Item for Forecast opportunity
    public static void createOLIForecastOpportunity(map<string,list<string>> mapAcc_Prod,
                                                    map<string,list<string>> mapProd_Month_Qty){
        map<string,list<string>> mapOLI_month_Qty = new map<string,list<string>>();
        set<OpportunityLineItem> setOLI= new set<OpportunityLineItem>();
        list<OpportunityLineItem> lstOLIInsert= new list<OpportunityLineItem>();
        OpportunityLineItem objOppOli;
        for(Opportunity objOpp: [SELECT Id,AccountId
                                   FROM Opportunity
                                   WHERE AccountId IN:mapAcc_Prod.keySet()
                                   AND RecordType.Name =:system.label.Label_Forecast]){
            for(string pricebkEntry: mapAcc_Prod.get(objOpp.AccountId)){
                objOppOli= new OpportunityLineItem();
                objOppOli.PricebookEntryId = pricebkEntry;
                objOppOli.OpportunityId= objOpp.Id;
                objOppOli.Quantity=1;
                objOppOli.UnitPrice=0.00;
                setOLI.add(objOppOli);
            }// end for

        }// end if
        if(setOLI <> NULL && !setOLI.isEmpty()){
            lstOLIInsert.addAll(setOLI);
            insert lstOLIInsert;
            for(OpportunityLineItem objOLI: lstOLIInsert){
                if(mapOLI_month_Qty.containsKey(string.valueof(objOLI.Id))){
                    mapOLI_month_Qty.get(string.valueof(objOLI.Id)).addAll(mapProd_Month_Qty.get(objOLI.PriceBookEntryId));
                }// end if
                else{
                    //list<string> lststr= ;
                    mapOLI_month_Qty.put(string.valueof(objOLI.Id),mapProd_Month_Qty.get(objOLI.PriceBookEntryId));
                    //lststr.clear();
                }
            }// end for
        }// end if
        if(mapOLI_month_Qty <> NULL && !mapOLI_month_Qty.isEmpty()){
            insertOLISchedule(mapOLI_month_Qty);
        }
    }// end method
    
    public void configureGridProperties(integer count)
    {
        //cellWidths = '120,100,120,100,150,100,';
        String ForecastGridWidth = fetchValueFromMetadata('ForeCastGridColumnWidth');
        if(ForecastGridWidth == null){
            ForecastGridWidth = '120,150,120,175,175,100,';
        }
        cellWidths = ForecastGridWidth;
        colHeaders = 'Hidden Item Name,Item Number,Hidden Product Category,Product Category, Item Description, Type,';
        colAlignments = 'center,center,center,center,center,center,';
        colTypes = 'ro,ro,ro,ro,ro,ro,';
        resizeHeaders = 'false,false,false,false,false,false,';
        String columnWidthMonths = fetchValueFromMetadata('cellWidthMonths');
        if(columnWidthMonths == null){
            columnWidthMonths ='50,';
        }
        for(integer i=0; i<count; i++){
            cellWidths += columnWidthMonths;
            colHeaders += lstString1[i]+',';
            colAlignments += 'center,'; 
            colTypes += 'edn,';
            resizeHeaders += 'false,';
        }
        String totalVarianceWidth = fetchValueFromMetadata('total_variance_width');
        if(totalVarianceWidth == null){
            totalVarianceWidth = '70';
        }
        cellWidths += totalVarianceWidth+',,,,,,'+totalVarianceWidth;
        colHeaders += 'Total,AccId,OLIId,ScheduleId,RrcordType,ProductId, % Variance';
        colAlignments +='center,center,center';
        colTypes += 'ro,ro,ro,ro,ro,ro,ro';
        resizeHeaders += 'false,false,false,false,false,false,false';
    }
   
    public void setFromDate(){
        dtFrom = Date.newInstance(fromDateYear, fromDateMonth+1, 1);
        dtFromPY = Date.newInstance(fromDateYear-1, fromDateMonth+1,1);
        dtFromStr = fullMonthList.get(dtFrom.month()-1) + '-'+dtFrom.year();
    }
    
    public void setToDate(){
        dtTo = Date.newInstance(toDateYear, toDateMonth+1,1);
        dtToPY = Date.newInstance(toDateYear-1, toDateMonth+1,1);
        dtTo = dtTo.addMonths(1).addDays(-1); 
        dtToPY = dtToPY.addMonths(1).addDays(-1);       
        dtToStr = fullMonthList.get(dtTo.month()-1) + '-'+dtTo.year();
    }
    
    public void setDateVals(Date fromDate){
        integer fDMonth = (Math.floor(fromDate.month()/4)).intValue();
        List<Integer> quarterMonths = new List<Integer>{1,4,7,10};
        dtFrom = Date.newInstance(fromDate.year(),quarterMonths.get(fDMonth),1);
        dtFromPY = Date.newInstance(fromDate.year()-1,quarterMonths.get(fDMonth),1);
        dtTo = dtFrom.addMonths(18).addDays(-1);
        dtToPY = dtFromPY.addMonths(18).addDays(-1);
    }
    
    public String fetchValueFromMetadata(String key){
        String value = columnWidthMap.get(key); 
        if(value == null ||value ==''){
            return null;
        }
        return value;
    }
}// end class