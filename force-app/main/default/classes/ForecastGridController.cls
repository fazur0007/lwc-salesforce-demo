/*
ForecastGridController is a controller for ForecastGrid page.
To show the opportunity schedule fore 'Forecast' and 'budget' record type.
* Version       Author             Date                   Description
*  1.0        Yogesh Sharma      10/18/2016             Initial Draft
*  1.1        Yogesh Sharma      10/26/2016             Grouping of OLIS by Customer Name
*  1.2        Yogesh Sharma      10/27/2016             Create new OLI for Forecast opportunity
*/
public with sharing class ForecastGridController{

    public static string strAccName{get;set;}
    public static string strJson{get;set;}
    public static integer getMonth{get;set;}
    public static list<String> lstString1{get;set;}
    public static list<OpportunityLineItem> lstOppLineItem;
    public static map<string,boolean> mapProdId_BudgetRecType;
    public static map<string,boolean> mapProdId_ForecastRecType;
    static integer cnt=1;
    static string strBlankData='',idOLISchedule='';
    public static Id AccountId;
    static date dtFrom;
    static date dtTo;
    static integer intStartMonth;
    static integer intEndMonth;
    static integer intCurYear=date.today().year();
    public static integer intCurrentYearCol{get;set;}
    public static integer intEditableYearCol{get;set;}
    public static map<string,boolean> mapProdId_PriorYearRecType;
    static integer prevYear=0,currentYear=0;

    public ForecastGridController(ApexPages.StandardController controller) {
         AccountId = ApexPages.currentPage().getParameters().get('id');
    }

    public static void setMonths(){
        AccountId = ApexPages.currentPage().getParameters().get('id');
         if(date.today().month() < 7){
             intCurrentYearCol= date.today().year();
             intEditableYearCol= date.today().year();
         }
         else{
             intCurrentYearCol= date.today().year();
             intEditableYearCol= date.today().year();
         }

        Account objAcc= new Account();
        if(AccountId <> NULL){
            objAcc= [select Name,
                            Grid_Counter__c
                       from Account where Id =: AccountId];
            if(objAcc.Grid_Counter__c == NULL){
                objAcc.Grid_Counter__c =0;
            }
            objAcc.Grid_Counter__c= 0;
            update objAcc;
            strAccName= objAcc.Name;
        }// end if
        intCurYear = date.today().year();
        lstString1 = new list<String>();
        lstString1.clear();
        String strYear ='',strNextYr ='';
        if(date.today().month()< 7){
          strYear =  String.valueOf(intCurYear-1);
          strNextYr = String.valueOf(intCurYear);
        }
        else{
            strYear = String.valueOf(date.today().year());
            strYear = strYear;
            strNextYr = String.valueOf((date.today().year())+1);
            strNextYr = strNextYr;
        }
        lstString1.add('Jul '+strYear);
        lstString1.add('Aug '+strYear);
        lstString1.add('Sep '+strYear);
        lstString1.add('Oct '+strYear);
        lstString1.add('Nov '+strYear);
        lstString1.add('Dec '+strYear);
        lstString1.add('Jan '+strNextYr);
        lstString1.add('Feb '+strNextYr);
        lstString1.add('Mar '+strNextYr);
        lstString1.add('Apr '+strNextYr);
        lstString1.add('May '+strNextYr);
        lstString1.add('Jun '+strNextYr);
        if(date.today().month()< 7){
            dtFrom= date.newInstance(intCurYear-2,7,1);//2016 july 1
            dtTo= date.newInstance(intCurYear,6,30); // 2017 Jun 30
            getMonth=date.today().month()+8;
            intStartMonth = 6;
            prevYear=intCurYear-1;
            currentYear = intCurYear;
            getOpportunityData();
            
        }
        else{
            dtFrom= date.newInstance(date.today().year()-1,7,1);
            dtTo= date.newInstance(date.today().year()+1,6,30);
            getMonth=date.today().month()-3;
            intStartMonth = 6;
            prevYear=date.today().year()-1;
            currentYear = date.today().year()+1;
            getOpportunityData();
        }
    }

    public static void setMonths2(){
        if(date.today().month()< 7){
          intCurrentYearCol=date.today().year();
          intEditableYearCol= date.today().year()-1;
        }
        else{
            intCurrentYearCol=date.today().year();
            intEditableYearCol= date.today().year();
        }     
        AccountId = ApexPages.currentPage().getParameters().get('id');
        integer intCurYearDup=0;
        Account objAcc= new Account();
        if(AccountId <> NULL){
        objAcc= [select Name, Grid_Counter__c from Account where Id =: AccountId];
            if(objAcc.Grid_Counter__c == NULL){
                objAcc.Grid_Counter__c =0;
            }
            objAcc.Grid_Counter__c-= 1;
            update objAcc;
            intCurYear = date.today().year() + integer.valueof(objAcc.Grid_Counter__c);
            intCurYearDup=intCurYear;
            strAccName= objAcc.Name;
        }
        intEditableYearCol= intCurYear;
        lstString1 = new list<String>();
        lstString1.clear();
            
       String strYear ='',strNextYr ='';
        
        if(date.today().month()< 7){
          strYear = String.valueOf(intCurYear-1);
          strNextYr =  String.valueOf(intCurYear);
        }
        else{
            strYear = String.valueOf(intCurYear);
            strYear = strYear;
            strNextYr = String.valueOf(intCurYear+1);
            strNextYr = strNextYr;
        }

        lstString1.add('Jul '+strYear);
        lstString1.add('Aug '+strYear);
        lstString1.add('Sep '+strYear);
        lstString1.add('Oct '+strYear);
        lstString1.add('Nov '+strYear);
        lstString1.add('Dec '+strYear);
        lstString1.add('Jan '+strNextYr);
        lstString1.add('Feb '+strNextYr);
        lstString1.add('Mar '+strNextYr);
        lstString1.add('Apr '+strNextYr);
        lstString1.add('May '+strNextYr);
        lstString1.add('Jun '+strNextYr);
        
        if(date.today().month()< 7){
            dtFrom= date.newInstance(intCurYear-2,7,1);
            dtTo= date.newInstance(intCurYear ,6,30);
            getMonth=date.today().month()+8;
            intStartMonth = 6;
            prevYear=intCurYear-1;
            currentYear = intCurYear;
            getOpportunityData();
        }
        else{
            dtFrom= date.newInstance(intCurYear-1 ,7,1);
            dtTo= date.newInstance(intCurYear + 1,6,30);
            intCurYear=intCurYearDup;
            getMonth=date.today().month()-3;
            intStartMonth = 6;
            prevYear=intCurYear-1;
            currentYear = intCurYear+1;
            getOpportunityData();
        }
    }// end setMonths2

    public static void setMonths3(){
      integer intCurYearDup=0;
      if(date.today().month()< 7){
          intCurrentYearCol=date.today().year();
          intEditableYearCol= date.today().year();
      }
      else{
        intCurrentYearCol=date.today().year();
        intEditableYearCol= date.today().year();
       }
        intCurrentYearCol= date.today().year();
        AccountId = ApexPages.currentPage().getParameters().get('id');
        Account objAcc= new Account();
        if(AccountId <> NULL){
            objAcc= [select Name, Grid_Counter__c from Account where Id =: AccountId];
            if(objAcc.Grid_Counter__c == NULL){
                objAcc.Grid_Counter__c =0;
            }
            objAcc.Grid_Counter__c+= 1;
            update objAcc;
            
            intCurYear = date.today().year() + integer.valueof(objAcc.Grid_Counter__c);
            intCurYearDup=intCurYear;
            strAccName= objAcc.Name;
        }
        lstString1 = new list<String>();
        lstString1.clear();
        
        
        intEditableYearCol= intCurYear;
        String strYear ='',strNextYr ='';
        
        if(date.today().month()< 7){
          strYear = String.valueOf(intCurYear-1);
          strNextYr =  String.valueOf(intCurYear);
        }
        else{
            strYear = String.valueOf(intCurYear);
            strYear = strYear;
            strNextYr = String.valueOf(intCurYear+1);
            strNextYr = strNextYr;
        }

        lstString1.add('Jul '+strYear);
        lstString1.add('Aug '+strYear);
        lstString1.add('Sep '+strYear);
        lstString1.add('Oct '+strYear);
        lstString1.add('Nov '+strYear);
        lstString1.add('Dec '+strYear);
        lstString1.add('Jan '+strNextYr);
        lstString1.add('Feb '+strNextYr);
        lstString1.add('Mar '+strNextYr);
        lstString1.add('Apr '+strNextYr);
        lstString1.add('May '+strNextYr);
        lstString1.add('Jun '+strNextYr);

        if(date.today().month()< 7){
            dtFrom= date.newInstance(intCurYear-2,7,1);
            dtTo= date.newInstance(intCurYear,6,30);
            getMonth=date.today().month()+8;
            intStartMonth = 6;
            prevYear=intCurYear-1;
            currentYear = intCurYear;
            getOpportunityData();
        }
        else{
            dtFrom= date.newInstance(intCurYear-1 ,7,1);
            dtTo= date.newInstance(intCurYear + 1,6,30);
            intCurYear=intCurYearDup;
            getMonth=date.today().month()-3;
            prevYear=intCurYear-1;
            currentYear = intCurYear +1;
            intStartMonth = 6;
            getOpportunityData();
        }
    }

    public static void getOpportunityData(){
        AccountId = ApexPages.currentPage().getParameters().get('id');
        mapProdId_BudgetRecType= new map<string,boolean>();
        mapProdId_ForecastRecType= new map<string,boolean>();
        mapProdId_PriorYearRecType= new map<string,boolean>();
        strJson= '""';
        cnt=1;
        strBlankData= '"","","","","","","","","","","","",""';
        Id idUser=UserInfo.getUserId();
        lstOppLineItem=[SELECT Opportunity.RecordType.Name,
                               Product2.Id, Product2.Name,
                               Product2.Description,
                               Opportunity.Account.Id,
                               Opportunity.Account.Name,
                               PricebookEntryId,
                       (SELECT ScheduleDate, Quantity
                          FROM OpportunityLineItemSchedules
                          WHERE ScheduleDate >=: dtFrom
                          AND ScheduleDate <=: dtTo
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
    public static void getOLI(map<string,boolean> mapProduId_Forecast,
                              map<string,boolean> mapProdId_Budget,
                              list<OpportunityLineItem> lstOLI){
       Integer intTotalQLI =0,donePrior=0,intMonth=12,intCnt=1,done=0;
       Integer doneBudget=0, intForecastTotal=0, intBudgetTotal=0, intPriorTotal=0,intForecastTotalPY=0;
       map<Integer,Integer> mapMonth_Qty = new map<Integer,Integer>();
       map<Integer,Integer> mapMonth_Yr = new map<Integer,Integer>();
       Decimal dlPerChange=0.0, dlPerChangePrior=0.0;
       string strBlank;
       strBlank='"","","","",""';
       for(OpportunityLineItem objOLI: lstOLI){
             mapMonth_Qty = new map<Integer,Integer>();
             mapMonth_Yr = new map<Integer,Integer>();
            intTotalQLI=0;
            if(mapProdId_BudgetRecType.get(objOLI.Opportunity.Account.Id+'+'+objOLI.Product2.Id)== true
            && done==0 && objOLI.Opportunity.RecordType.Name <> system.label.Label_Prior_Sales_Year){
                if(string.isNotBlank(objOLI.Product2.Description)
                && objOLI.Product2.Description <> NULL){
                    strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","'+ string.valueof(objOLI.Product2.Name).remove('"')+'","'+objOLI.Product2.Description.remove('"')+'",';
                }
                else{
                   strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","'+ string.valueof(objOLI.Product2.Name).remove('"')+'","'+objOLI.Product2.Description+'",';
                }
                strJson+= '"'+objOLI.Opportunity.RecordType.Name+'",';
                if(objOLI.OpportunityLineItemSchedules<> NULL && !objOLI.OpportunityLineItemSchedules.isEmpty()){
                    for(OpportunityLineItemSchedule  objSchedule :objOLI.OpportunityLineItemSchedules){
                         idOLISchedule = objSchedule.Id;
                         if(objSchedule.ScheduleDate.year() == prevYear||
                           objSchedule.ScheduleDate.year() == currentYear ){
                            mapMonth_Qty.put(objSchedule.ScheduleDate.month(),Integer.valueof(objSchedule.Quantity));
                            mapMonth_Yr.put(objSchedule.ScheduleDate.month(), objSchedule.ScheduleDate.year());
                            if((objSchedule.ScheduleDate.month()>intStartMonth   && objSchedule.ScheduleDate.year()==prevYear)
                                || (objSchedule.ScheduleDate.month()<=intStartMonth   && objSchedule.ScheduleDate.year()==currentYear))
                            intTotalQLI += integer.valueof(objSchedule.Quantity);
                        }// end if
                    }// end for
                    if(mapMonth_Qty <> NULL && !mapMonth_Qty.isEmpty() && intTotalQLI<> 0){
                        for(integer i=(intStartMonth+1);i<=12;i++){
                            if(mapMonth_Qty.containsKey(i) && mapMonth_Yr.get(i)==prevYear){
                                 strJson+='"'+mapMonth_Qty.get(i)+'",';
                            }
                            else{
                                strJson+='"",';
                            }
                        }
                        for(integer i=1;i<=intStartMonth;i++){
                            if(mapMonth_Qty.containsKey(i) && mapMonth_Yr.get(i)==currentYear){
                                 strJson+='"'+mapMonth_Qty.get(i)+'",';
                            }
                            else{
                                strJson+='"",';
                            }
                        }
                        mapMonth_Qty.clear();
                        mapMonth_Yr.clear();
                        intBudgetTotal +=intTotalQLI;
                        //intForecastTotal+=intTotalQLI;
                        strJson+='"'+intTotalQLI+'","","'+objOLI.Id+'","'+idOLISchedule+'","'+system.label.Label_Forecast+'"]},';
                        intTotalQLI=0;
                    }// END IF
                    else{
                       strJson+=+strBlankData+',"","'+objOLI.Id+'","","'+system.label.Label_Forecast+'"]},';
                     }// end else
                }//END IF
                else{
                   strJson+=+strBlankData+',"","'+objOLI.Id+'","","'+system.label.Label_Forecast+'"]},';
                 }// end else
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

                    if(string.isNotBlank(objOLI.Product2.Description)
                    && objOLI.Product2.Description <> NULL){
                        strJson+= '{id:'+cnt+', data:'+'["'+objOLI.Product2.Name+'","'+ string.valueof(objOLI.Product2.Name)+'","'+objOLI.Product2.Description.remove('"')+'",';
                    }
                    else{
                        strJson+= '{id:'+cnt+', data:'+'["'+objOLI.Product2.Name+'","'+ string.valueof(objOLI.Product2.Name)+'","'+objOLI.Product2.Description+'",';
                    }
                    strJson+= '"'+system.label.Label_Budget+'",'+strBlankData+',"'+objOLI.Opportunity.Account.Id+'","","","","'+objOLI.PriceBookEntryId+'"]},';
                    cnt++;
                   }

                   doneBudget=1;
                   donePrior=1;
                    strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","",';
                    strJson+= '"'+objOLI.Opportunity.RecordType.Name+'",';
                    if(objOLI.OpportunityLineItemSchedules<> NULL && !objOLI.OpportunityLineItemSchedules.isEmpty()){
                    for(OpportunityLineItemSchedule  objSchedule :objOLI.OpportunityLineItemSchedules){
                        if(objSchedule.ScheduleDate.year() == prevYear ||
                           objSchedule.ScheduleDate.year() == currentYear){
                            mapMonth_Qty.put(objSchedule.ScheduleDate.month(),Integer.valueof(objSchedule.Quantity));
                            mapMonth_Yr.put(objSchedule.ScheduleDate.month(), objSchedule.ScheduleDate.year());
                            if((objSchedule.ScheduleDate.month()>intStartMonth   && objSchedule.ScheduleDate.year()==prevYear)
                                || (objSchedule.ScheduleDate.month()<=intStartMonth   && objSchedule.ScheduleDate.year()==currentYear))
                            intTotalQLI += integer.valueof(objSchedule.Quantity);
                        }// end if
                    }// end for
                    if(mapMonth_Qty <> NULL && !mapMonth_Qty.isEmpty() && intTotalQLI<> 0){
                        for(integer i=(intStartMonth+1);i<=12;i++){
                            if(mapMonth_Qty.containsKey(i) && mapMonth_Yr.get(i)==prevYear){
                                 strJson+='"'+mapMonth_Qty.get(i)+'",';
                            }
                            else{
                                strJson+='"",';
                            }
                        }
                        for(integer i=1;i<=intStartMonth;i++){
                            if(mapMonth_Qty.containsKey(i) && mapMonth_Yr.get(i)==currentYear){
                                 strJson+='"'+mapMonth_Qty.get(i)+'",';
                            }
                            else{
                                strJson+='"",';
                            }
                        }
                        mapMonth_Qty.clear();
                        mapMonth_Yr.clear();
                        intForecastTotal+=intTotalQLI;
                        //intBudgetTotal+=intTotalQLI;
                        if(intBudgetTotal <> 0
                        && string.valueof(intForecastTotal)  <> ''
                        && string.valueof(intForecastTotal )<> NULL
                        && string.valueof(intBudgetTotal ) <> ''
                        && string.valueof (intBudgetTotal) <> NULL){
                            dlPerChange= ((decimal.valueof(intForecastTotal) - decimal.valueof(intBudgetTotal))/decimal.valueof(intBudgetTotal))*100;
                            strJson+='"'+intTotalQLI+'","","'+objOLI.Id+'","'+idOLISchedule+'","'+system.label.Label_Forecast+'","","'+dlPerChange.setScale(2)+' %"]},';
                        }
                        else {
                            strJson+='"'+intTotalQLI+'","","'+objOLI.Id+'","'+idOLISchedule+'","'+system.label.Label_Forecast+'"]},';
                        }
                        intTotalQLI=0;
                        intBudgetTotal =0;
                        intForecastTotalPY=intForecastTotal ;
                        intForecastTotal =0;
                    }// END IF
                    else{
                        strJson+=+strBlankData+',"","'+objOLI.Id+'","","'+system.label.Label_Forecast+'","",""]},';
                    }
                    }// end if sCHEDULE
                    else{
                        strJson+=+strBlankData+',"","'+objOLI.Id+'","","'+system.label.Label_Forecast+'","",""]},';
                    }
                    intBudgetTotal =0;
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
                    if(string.isNotBlank(objOLI.Product2.Description)
                    && objOLI.Product2.Description <> NULL){
                        strJson+= '{id:'+cnt+', data:'+'["'+objOLI.Product2.Name+'","'+ string.valueof(objOLI.Product2.Name)+'","'+objOLI.Product2.Description.remove('"')+'",';
                    }
                    else{
                        strJson+= '{id:'+cnt+', data:'+'["'+objOLI.Product2.Name+'","'+ string.valueof(objOLI.Product2.Name)+'","'+objOLI.Product2.Description+'",';
                    }
                    strJson+= '"'+system.label.Label_Budget+'",'+strBlankData+',"'+objOLI.Opportunity.Account.Id+'","","","","'+objOLI.PriceBookEntryId+'"]},';
                    cnt++;
                }
                if(mapProduId_Forecast.get(objOLI.Opportunity.Account.Id+'+'+objOLI.Product2.Id) <> true
                && doneBudget==1){
                intBudgetTotal =0;
                intForecastTotal =0;
                done=0;
                donePrior=1;
                strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","",';
                strJson+= '"'+system.label.Label_Forecast+'",'+strBlankData+',"'+objOLI.Opportunity.Account.Id+'","","","","'+objOLI.PriceBookEntryId+'"]},';
                doneBudget=0;
                cnt++;
                }
            }
            if(mapProdId_PriorYearRecType.get(objOLI.Opportunity.Account.Id+'+'+objOLI.Product2.Id) == true
                 && donePrior==1 && objOLI.Opportunity.RecordType.Name == system.label.Label_Prior_Sales_Year
                 && objOLI.Opportunity.RecordType.Name <> system.label.Label_Forecast){
                   done=0;donePrior=0;doneBudget=0;
                    strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","",';
                    strJson+= '"'+objOLI.Opportunity.RecordType.Name+'",';
                    if(objOLI.OpportunityLineItemSchedules<> NULL
                    && !objOLI.OpportunityLineItemSchedules.isEmpty()){
                        mapMonth_Qty.clear();
                        mapMonth_Yr.clear();
                        for(OpportunityLineItemSchedule  objSchedule :objOLI.OpportunityLineItemSchedules){
                        if(objSchedule.ScheduleDate.year() == prevYear-1 ||
                           objSchedule.ScheduleDate.year() == currentYear-1){
                            mapMonth_Qty.put(objSchedule.ScheduleDate.month(),Integer.valueof(objSchedule.Quantity));
                            mapMonth_Yr.put(objSchedule.ScheduleDate.month(), objSchedule.ScheduleDate.year());
                            if((objSchedule.ScheduleDate.month()>intStartMonth   && objSchedule.ScheduleDate.year()==prevYear-1)
                                || objSchedule.ScheduleDate.month()<=intStartMonth   && objSchedule.ScheduleDate.year()==currentYear-1)
                            intTotalQLI += integer.valueof(objSchedule.Quantity);
                        }// end if
                    }// end for

                    if(mapMonth_Qty <> NULL && !mapMonth_Qty.isEmpty() && intTotalQLI<> 0 ){
                        for(integer i=(intStartMonth+1);i<=12;i++){
                            if(mapMonth_Qty.containsKey(i) && mapMonth_Yr.get(i)==prevYear-1){
                                 strJson+='"'+mapMonth_Qty.get(i)+'",';
                            }
                            else{
                                strJson+='"",';
                            }
                        }
                        for(integer i=1;i<=intStartMonth;i++){
                            if(mapMonth_Qty.containsKey(i) && mapMonth_Yr.get(i)==currentYear-1){
                                 strJson+='"'+mapMonth_Qty.get(i)+'",';
                            }
                            else{
                                strJson+='"",';
                            }
                        }
                        mapMonth_Qty.clear();
                        mapMonth_Yr.clear();
                        intPriorTotal+=intTotalQLI;
                        if(intPriorTotal <> 0 
                        && intForecastTotalPY <> 0
                        && string.valueof(intForecastTotalPY )  <> ''
                        && string.valueof(intForecastTotalPY )<> NULL
                        && string.valueof(intPriorTotal ) <> ''
                        && string.valueof (intPriorTotal) <> NULL){
                            dlPerChangePrior= ((decimal.valueof(intForecastTotalPY) - decimal.valueof(intPriorTotal))/decimal.valueof(intPriorTotal))*100;
                            strJson+='"'+intTotalQLI+'",'+strBlank+',"'+dlPerChangePrior.setScale(2)+' %"]},';
                        }
                        else {
                            strJson+='"'+intTotalQLI+'"]},';
                        }
                        intTotalQLI=0;
                        intBudgetTotal =0;
                        intForecastTotal =0;
                        intForecastTotalPY=0;
                        intPriorTotal=0;
                    }// END IF
                    else{
                        strJson+=+strBlankData+',"",'+strBlank+',""]},';
                    }
                    }// end if sCHEDULE
                    else{
                        strJson+=+strBlankData+',"",'+strBlank+',""]},';
                    }
                    intTotalQLI=0;
                    intBudgetTotal =0;
                    intForecastTotal =0;
                    intForecastTotalPY=0;
                    intPriorTotal=0;
                    cnt++;
                }// end else if
                else{
                  if(mapProdId_PriorYearRecType.get(objOLI.Opportunity.Account.Id+'+'+objOLI.Product2.Id) <> true
                  && donePrior==1){
                    done=0;
                    donePrior=0;doneBudget=0;
                    intBudgetTotal =0;
                    intForecastTotal =0;
                    intForecastTotalPY=0;
                    intPriorTotal=0;
                        strJson+= '{id:'+cnt+', data:'+ '["'+objOLI.Product2.Name.remove('"')+'","","",';
                        strJson+= '"'+system.label.Label_Prior_Sales_Year+'",'+strBlankData+']},';
                        cnt++;
                  }
                }
               
        }//END for
        strJson= strJson.removeEnd(',');
        strJson+=']};';
    }// end method

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
            for(OpportunityLineItemSchedule objSchedule: [SELECT Id,
                                                                 OpportunityLineItemId,
                                                                 ScheduleDate,
                                                                 Quantity
                                                            FROM OpportunityLineItemSchedule
                                                            WHERE OpportunityLineItemId
                                                            IN:mapOLI_OLISchedule.keySet()]){
                if(objSchedule <> NULL){
                    if(objSchedule.ScheduleDate.year() >= date.today().year()){
                        for(String strQty_Month: mapOLI_Qty.get(objSchedule.OpportunityLineItemId )){
                            strMonth = strQty_Month.split('-')[1].substring(0,3);
                            integer intYearCol = integer.valueof(strQty_Month.split('-')[1].substring(4,8));
                        if(system.label.Label_Jan.equalsIgnoreCase(strMonth)){
                          intMonth= 1;
                          if(objSchedule.ScheduleDate.month() == intMonth
                          && objSchedule.ScheduleDate.year()== intYearCol){
                             objSchedule.ScheduleDate= date.newInstance(intYearCol,intMonth,28);
                              objSchedule.Quantity=0;
                              objSchedule.Quantity =decimal.valueof(strQty_Month.split('-')[0]);
                              lstScheduleUpdate.add(objSchedule);
                          }// end if
                        }
                        else if(system.label.Label_Feb.equalsIgnoreCase(strMonth)){
                          intMonth= 2;
                          if(objSchedule.ScheduleDate.month() == intMonth
                          && objSchedule.ScheduleDate.year()== intYearCol){
                              objSchedule.ScheduleDate= date.newInstance(intYearCol,intMonth,28);
                              objSchedule.Quantity=0;
                              objSchedule.Quantity =decimal.valueof(strQty_Month.split('-')[0]);
                              lstScheduleUpdate.add(objSchedule);
                          }// end if
                        }
                        else if(system.label.Label_Mar.equalsIgnoreCase(strMonth)){
                            intMonth= 3;
                            if(objSchedule.ScheduleDate.month() == intMonth
                            && objSchedule.ScheduleDate.year()== intYearCol){
                               objSchedule.ScheduleDate= date.newInstance(intYearCol,intMonth,28);
                                objSchedule.Quantity=0;
                                objSchedule.Quantity =decimal.valueof(strQty_Month.split('-')[0]);
                                lstScheduleUpdate.add(objSchedule);
                            }// end if
                        }
                        else if(system.label.Label_Apr.equalsIgnoreCase(strMonth)){
                            intMonth= 4;
                            if(objSchedule.ScheduleDate.month() == intMonth
                            && objSchedule.ScheduleDate.year()== intYearCol){
                                objSchedule.ScheduleDate= date.newInstance(intYearCol,intMonth,28);
                                objSchedule.Quantity=0;
                                objSchedule.Quantity =decimal.valueof(strQty_Month.split('-')[0]);
                                lstScheduleUpdate.add(objSchedule);

                            }// end if
                        }
                        else if(system.label.Label_May.equalsIgnoreCase(strMonth)){
                            intMonth= 5;
                            if(objSchedule.ScheduleDate.month() == intMonth
                            && objSchedule.ScheduleDate.year()== intYearCol){
                                objSchedule.ScheduleDate= date.newInstance(intYearCol,intMonth,28);
                                objSchedule.Quantity=0;
                                objSchedule.Quantity =decimal.valueof(strQty_Month.split('-')[0]);
                                lstScheduleUpdate.add(objSchedule);
                            }// end if
                        }
                        else if(system.label.Label_Jun.equalsIgnoreCase(strMonth)){
                            intMonth= 6;
                            if(objSchedule.ScheduleDate.month() == intMonth
                            && objSchedule.ScheduleDate.year()== intYearCol){
                                objSchedule.ScheduleDate= date.newInstance(intYearCol,intMonth,28);
                                objSchedule.Quantity=0;
                                objSchedule.Quantity =decimal.valueof(strQty_Month.split('-')[0]);
                                lstScheduleUpdate.add(objSchedule);
                            }// end if
                        }
                        else if(system.label.Label_July.equalsIgnoreCase(strMonth)){
                            intMonth= 7;
                            if(objSchedule.ScheduleDate.month() == intMonth
                            && objSchedule.ScheduleDate.year()== intYearCol){
                                objSchedule.ScheduleDate= date.newInstance(intYearCol,intMonth,28);
                                objSchedule.Quantity=0;
                                objSchedule.Quantity =decimal.valueof(strQty_Month.split('-')[0]);
                                lstScheduleUpdate.add(objSchedule);
                                }
                        }
                        else if(system.label.Label_Aug.equalsIgnoreCase(strMonth)){
                            intMonth= 8;
                            if(objSchedule.ScheduleDate.month() == intMonth
                            && objSchedule.ScheduleDate.year()== intYearCol){
                                objSchedule.ScheduleDate= date.newInstance(intYearCol,intMonth,28);
                                objSchedule.Quantity=0;
                                objSchedule.Quantity =decimal.valueof(strQty_Month.split('-')[0]);
                                lstScheduleUpdate.add(objSchedule);
                            }// end if
                        }
                        else if(system.label.Label_Sep.equalsIgnoreCase(strMonth)){
                            intMonth= 9;
                            if(objSchedule.ScheduleDate.month() == intMonth
                            && objSchedule.ScheduleDate.year()== intYearCol){
                                objSchedule.ScheduleDate= date.newInstance(intYearCol,intMonth,28);
                                objSchedule.Quantity=0;
                                objSchedule.Quantity =decimal.valueof(strQty_Month.split('-')[0]);
                                lstScheduleUpdate.add(objSchedule);
                            }// end if
                        }
                        else if(system.label.Label_Oct.equalsIgnoreCase(strMonth)){
                            intMonth= 10;
                            if(objSchedule.ScheduleDate.month() == intMonth
                            && objSchedule.ScheduleDate.year()== intYearCol){
                                objSchedule.ScheduleDate= date.newInstance(intYearCol,intMonth,28);
                                objSchedule.Quantity=0;
                                objSchedule.Quantity =decimal.valueof(strQty_Month.split('-')[0]);
                                lstScheduleUpdate.add(objSchedule);
                            }// end if
                        }
                        else if(system.label.Label_Nov.equalsIgnoreCase(strMonth)){
                            intMonth= 11;
                            if(objSchedule.ScheduleDate.month() == intMonth
                            && objSchedule.ScheduleDate.year()== intYearCol){
                                objSchedule.ScheduleDate= date.newInstance(intYearCol,intMonth,28);
                                objSchedule.Quantity=0;
                                objSchedule.Quantity =decimal.valueof(strQty_Month.split('-')[0]);
                                lstScheduleUpdate.add(objSchedule);
                            }// end if
                        }
                        else if(system.label.Label_Dec.equalsIgnoreCase(strMonth)){
                            intMonth= 12;
                            if(objSchedule.ScheduleDate.month() == intMonth
                            && objSchedule.ScheduleDate.year()== intYearCol){
                                objSchedule.ScheduleDate= date.newInstance(intYearCol,intMonth,28);
                                objSchedule.Quantity=0;
                                objSchedule.Quantity =decimal.valueof(strQty_Month.split('-')[0]);
                                lstScheduleUpdate.add(objSchedule);
                            }// end if
                        }
                        else {
                         mapOLI_Not_Year_and_Month.putAll(mapOLI_Qty);
                        }

                        }// end for
                    }// end if
                    else{
                        mapOLI_Not_Year_and_Month.putAll(mapOLI_Qty);
                    }
                }// end if
                else{
                    mapOLI_Not_Year_and_Month.putAll(mapOLI_Qty);
                }
            }// end for
        }// end if
        else {
            insertOLISchedule(mapOLI_Qty);
        }
        Savepoint sp = Database.setSavepoint();
            if(lstScheduleUpdate<> NULL && !lstScheduleUpdate.isEmpty()){
               set<OpportunityLineItemSchedule> setUpdateOLIS  =new set<OpportunityLineItemSchedule>();
               setUpdateOLIS.addAll(lstScheduleUpdate);
               lstUpdateOLIS.addAll(setUpdateOLIS);
                    try{
                        update lstUpdateOLIS;
                    }
                    catch(DMLException de){
                         system.debug('de------'+lstScheduleUpdate);
                          Database.rollback(sp);
                    }
                }// end if
                //insert OLIs newly which does not have single record
                if(mapOLIS_Qty <> NULL && !mapOLIS_Qty.isEmpty()
                ){
                    insertOLISchedule(mapOLIS_Qty);
                }

                if(mapOLI_Not_Year_and_Month.size() >0 && lstUpdateOLIS.size() == 0
                && (mapOLIS_Qty.size () ==0 || lstUpdateOLIS.size() > 0)){
                   insertOLISchedule(mapOLI_Not_Year_and_Month);
                }
                if(mapAccId_ProdId <> NULL && !mapAccId_ProdId.isEmpty() &&
                   mapProdId_Month_Qty <> NULL && !mapProdId_Month_Qty.isEmpty()){
                    createOLIForecastOpportunity(mapAccId_ProdId,mapProdId_Month_Qty);
                }// end if
        }// end method

    // insert opportunity line item schedule
        public static void insertOLISchedule(map<string ,list<string>> mapOLI_QtyInsert) {
            string strMonth='';
            integer intMonth=0;
            OpportunityLineItemSchedule objSchedule;
            list<OpportunityLineItemSchedule> lstSchedule = new list<OpportunityLineItemSchedule>();
            if(mapOLI_QtyInsert<> NULL && !mapOLI_QtyInsert.isEmpty()
            && mapOLI_QtyInsert.keyset() <> NULL && !mapOLI_QtyInsert.keySet().isEmpty()){
            for(String idOppLine: mapOLI_QtyInsert.keySet()){
                if(idOppLine <> NULL && string.isNotBlank(idOppLine)){
                    for(String strQty_Month: mapOLI_QtyInsert.get(idOppLine)){
                    objSchedule= new OpportunityLineItemSchedule ();
                    objSchedule.OpportunityLineItemId = idOppLine;
                    objSchedule.Type= 'Quantity';
                        objSchedule.Quantity =decimal.valueof(strQty_Month.split('-')[0]);
                        strMonth= strQty_Month.split('-')[1].substring(0,3);
                        integer intYearCol = integer.valueof(strQty_Month.split('-')[1].substring(4,8));
                        if(system.label.Label_Jan.equalsIgnoreCase(strMonth)){
                            intMonth= 1;
                        }
                        else if(system.label.Label_Feb.equalsIgnoreCase(strMonth)){
                            intMonth= 2;
                        }
                        else if(system.label.Label_Mar.equalsIgnoreCase(strMonth)){
                            intMonth= 3;
                        }
                        else if(system.label.Label_Apr.equalsIgnoreCase(strMonth)){
                            intMonth= 4;
                        }
                        else if(system.label.Label_May.equalsIgnoreCase(strMonth)){
                            intMonth= 5;
                        }
                        else if(system.label.Label_Jun.equalsIgnoreCase(strMonth)){
                            intMonth= 6;
                        }
                        else if(system.label.Label_July.equalsIgnoreCase(strMonth)){
                            intMonth= 7;
                        }
                        else if(system.label.Label_Aug.equalsIgnoreCase(strMonth)){
                            intMonth= 8;
                        }
                        else if(system.label.Label_Sep.equalsIgnoreCase(strMonth)){
                            intMonth= 9;
                        }
                        else if(system.label.Label_Oct.equalsIgnoreCase(strMonth)){
                            intMonth= 10;
                        }
                        else if(system.label.Label_Nov.equalsIgnoreCase(strMonth)){
                            intMonth= 11;
                        }
                        else if(system.label.Label_Dec.equalsIgnoreCase(strMonth)){
                            intMonth= 12;
                        }
                        objSchedule.ScheduleDate= date.newInstance(intYearCol,intMonth,28);
                       lstSchedule.add(objSchedule);
                    }// end for
                }// end if
            }// end for
            Savepoint sp = Database.setSavepoint();
            if(lstSchedule <> NULL && !lstSchedule.isEmpty()){
                    try{
                        insert lstSchedule;
                    }
                    catch(DMLException de){
                    	Database.rollback(sp);
                    	System.debug('Error while saving: ' + de);
                    	ErrorLog.logErrorActivity(de, 'Saving Forecast', true);
                    }
            }// end if
        }

    }// end method

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
            try{
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
            }// end try
            catch(DMLException de){
              //  system.debug('de----'+de);
            }// end catch
        }// end if
        if(mapOLI_month_Qty <> NULL && !mapOLI_month_Qty.isEmpty()){
            insertOLISchedule(mapOLI_month_Qty);
        }
    }// end method
}// end class