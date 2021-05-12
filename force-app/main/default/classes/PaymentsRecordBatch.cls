public with sharing class PaymentsRecordBatch implements Database.Batchable<SObject>, Database.Stateful{


    public Database.QueryLocator start(Database.BatchableContext context) {

    //Describe call for all fields
         Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
         Map <String, Schema.SObjectField> fieldMap = schemaMap.get('pymt__PaymentX__c').getDescribe().fields.getMap();
         String queryString = '';
         for(Schema.SObjectField schemafield : fieldMap.Values()) {
             schema.describefieldresult dynamicfields = schemafield.getDescribe();
             if(queryString=='')
                 queryString+= string.valueOf(dynamicfields.getname());
             else
                 queryString+= ','+string.valueOf(dynamicfields.getname());
         }//End for

         string finalQuery='select Order__r.Source__c, Order__r.AccountId,'+
                           ' Order__r.Payment_Occurrence__c, Order__r.EndDate, '+queryString+' from'+
                           ' pymt__PaymentX__c where (Order__r.Source__c = \'Argo\'' +
                           ' or Order__r.Source__c = \'Mojo\') and Order__r.IsProcessed__c = false'+
                           ' and Order__r.EndDate!=null and (Order__r.Payment_Occurrence__c!=null and Order__r.Payment_Occurrence__c > 1)' ;

        // Return list of Order records
        return Database.getQueryLocator(finalQuery);
     }//End start

    public void execute(Database.BatchableContext context, 
                            list<pymt__PaymentX__c> lstpymtPaymentX) {

        set<Id> setAccountId = new set<Id>(); 
        map<Id, Id> mapAccountIdContactId = new map<Id, Id>();
        map<Id,Id> mapContactIdPaymentMethodId = new map<Id, Id>();
        list<pymt__PaymentX__c> lstPrepymtPayment = new list<pymt__PaymentX__c>();
        list<pymt__Payment_Method__c> lstpymtPaymentMethod = 
                                            new list<pymt__Payment_Method__c>();
        set<Id> setAccId = new set<Id>();
        set<Id> setOrderId = new set<Id>();
        list<pymt__PaymentX__c> lstPymtRecord = new list<pymt__PaymentX__c>();
        list<Order> lstOrder = new list<Order>();
        map<Id, string> mapAccountIdContactName = new map<Id, string>();

        for(pymt__PaymentX__c objpymtPaymentX : lstpymtPaymentX){
            if(!String.isEmpty(objpymtPaymentX.Order__r.AccountId)){
                setAccountId.add(objpymtPaymentX.Order__r.AccountId);
                setOrderId.add(objpymtPaymentX.Order__c);
              }//End if
        }//End for

        for(Account objAcc : [select Id,
                                     Name,
                                     PersonContactId 
                                from Account
                               where Id IN : setAccountId]){
               mapAccountIdContactId.put(objAcc.Id, objAcc.PersonContactId);
               mapAccountIdContactName.put(objAcc.Id, objAcc.Name);
         }//End for

        RecordType paymentMethodRtype = [Select Id
                                           from RecordType 
                                          where DeveloperName = 'PayPal_Transaction_Reference' 
                                            and SobjectType = 'pymt__Payment_Method__c'];

        list<Order> lstO = [select Id,
                                       AccountId,
                                           (Select Id, 
                                                  pymt__Transaction_Id__c,
                                                  pymt__Amount__c,
                                                  pymt__Scheduled_Payment_Date__c,
                                                  CurrencyIsoCode,
                                                  pymt__Contact__c,
                                                  pymt__Date__c,
                                                  pymt__Processor_Connection__c,
                                                  pymt__Payment_Processor__c,
                                                  pymt__Card_Type__c,
                                                  pymt__Last_4_Digits__c,
                                                  pymt__Billing_Postal_Code__c,
                                                  pymt__Billing_First_Name__c,
                                                  pymt__Billing_Last_Name__c,
                                                  pymt__Billing_Street__c,
                                                  pymt__Billing_City__c,
                                                  pymt__Billing_State__c,
                                                  pymt__Billing_Country__c,
                                                  pymt__Billing_Email__c,
                                                  pymt__Billing_Phone__c,
                                                  Order__r.AccountId
                                             from Payments__r
                                            where (pymt__Transaction_Type__c = 'Payment' and pymt__Status__c = 'Completed')
                                              and (pymt__Date__c = LAST_N_DAYS:730 or pymt__Date__c = TODAY) 
                                              and pymt__Processor_Connection__r.Name = 'PayPal 3' 
                                              and pymt__Transaction_Id__c!=null order by pymt__Date__c DESC limit 1)
                                              from Order
                                             where Id IN : setOrderId];


        if(lstO!=null && lstO.size()>0){
            for(Order objOrder : lstO){
                if(mapAccountIdContactId.containsKey(objOrder.AccountId) && objOrder.Payments__r!=null && objOrder.Payments__r.size()>0){
                     lstPrepymtPayment.addAll(objOrder.Payments__r);
                     setAccId.add(objOrder.AccountId);
                }//End if
            }//End for
        }//End if

        set<string> setTransactionId = new set<string>();
        set<string> setProfileId = new set<string>();

         if(lstPrepymtPayment!=null && lstPrepymtPayment.size()>0){
              for(pymt__PaymentX__c objpymtPaymentX : lstPrepymtPayment){
                setTransactionId.add(objpymtPaymentX.pymt__Transaction_Id__c);
              }//End for
         }//End if

        for(pymt__Payment_Method__c objpymtPaymentMethod : [select Id,
                                                                   Name,
                                                                   pymt__Profile_Id__c,
                                                                   pymt__Contact__c
                                                              from pymt__Payment_Method__c
                                                             where pymt__Contact__c IN :mapAccountIdContactId.values()]){
               if(setTransactionId.contains(objpymtPaymentMethod.pymt__Profile_Id__c)){
                setProfileId.add(objpymtPaymentMethod.pymt__Profile_Id__c);
               }//End if
         }//End for

    if(lstPrepymtPayment!=null && lstPrepymtPayment.size()>0){
      for(pymt__PaymentX__c objpymtPaymentX : lstPrepymtPayment){

            String expMonth = String.valueOf(objpymtPaymentX.pymt__Date__c.addDays(720).month());
                   expMonth = expMonth.leftPad(2).replaceAll(' ','0');
            String expYear = String.valueOf(objpymtPaymentX.pymt__Date__c.addDays(720).year());
            String methodName ;

        if (!String.isEmpty(objpymtPaymentX.pymt__Card_Type__c)) {
            methodName = objpymtPaymentX.pymt__Card_Type__c;
            methodName += ' ('+objpymtPaymentX.pymt__Last_4_Digits__c+')';
        }else{
            methodName = 'Transaction Reference';
        }//End if-else

        if(!setProfileId.contains(objpymtPaymentX.pymt__Transaction_Id__c)){
            // Create payment method
            pymt__Payment_Method__c objPymtMethod = new pymt__Payment_Method__c(
              name = methodName + mapAccountIdContactName.get(objpymtPaymentX.Order__r.AccountId),
              RecordTypeId = paymentMethodRtype.Id,
              pymt__Profile_Id__c = objpymtPaymentX.pymt__Transaction_Id__c,
              pymt__Contact__c = mapAccountIdContactId.get(objpymtPaymentX.Order__r.AccountId),
              pymt__Default__c = false,
              pymt__Expiration_Month__c = expMonth,
              pymt__Expiration_Year__c = expYear,
              pymt__Processor_Connection__c = objpymtPaymentX.pymt__Processor_Connection__c,
              pymt__Card_Type__c = objpymtPaymentX.pymt__Card_Type__c,
              pymt__Last_4_Digits__c = objpymtPaymentX.pymt__Last_4_Digits__c,
              pymt__Billing_Postal_Code__c = objpymtPaymentX.pymt__Billing_Postal_Code__c, 
              pymt__Billing_First_Name__c = objpymtPaymentX.pymt__Billing_First_Name__c, 
              pymt__Billing_Last_Name__c = objpymtPaymentX.pymt__Billing_Last_Name__c, 
              pymt__Billing_Street__c = objpymtPaymentX.pymt__Billing_Street__c, 
              pymt__Billing_City__c = objpymtPaymentX.pymt__Billing_City__c, 
              pymt__Billing_State__c = objpymtPaymentX.pymt__Billing_State__c, 
              pymt__Billing_Country__c = objpymtPaymentX.pymt__Billing_Country__c, 
              pymt__Billing_Email__c = objpymtPaymentX.pymt__Billing_Email__c, 
              pymt__Billing_Phone__c = objpymtPaymentX.pymt__Billing_Phone__c 
             );
            lstpymtPaymentMethod.add(objPymtMethod);
        }//End if
      }//End for
    }//End if

        //Insert Payment Method records
        if(lstpymtPaymentMethod!=null && lstpymtPaymentMethod.size()>0){
            try{
                insert lstpymtPaymentMethod;
            }catch(DMLException errorMessage){
                system.debug('-errorMessage-' + errorMessage);
            }//End try-catch
        }//End if

        
    pymt__Processor_Connection__c objpymtProcessorConnection = [select Id
                                                                  from pymt__Processor_Connection__c
                                                                 where Name =: 'PayPal 3'
                                                                   and IsDeleted = false LIMIT 1];

    for(pymt__Payment_Method__c objpymtPaymentMethodc : [SELECT Id,
                                                                pymt__Profile_Id__c,
                                                                pymt__Contact__c
                                                           FROM pymt__Payment_Method__c
                                                          WHERE pymt__Contact__c IN : mapAccountIdContactId.values()]){
         if(setTransactionId.contains(objpymtPaymentMethodc.pymt__Profile_Id__c))
          mapContactIdPaymentMethodId.put(objpymtPaymentMethodc.pymt__Contact__c, objpymtPaymentMethodc.Id);
     }//End for

    //system.debug('--objpymtPaymentMethodc-' + objpymtPaymentMethodc);

        //Create Payment record
        for(Order objOrder : [select Id,
                                     Name,
                                     IsProcessed__c,
                                     EndDate,
                                     Recurring_Amount__c,
                                     AccountId,
                                     BillToContactId,
                                     CurrencyIsoCode,
                                     BillToContact.FirstName,
                                     BillToContact.LastName,
                                     Payment_Occurrence__c,
                                     BillToContact.MailingStreet,
                                     BillToContact.MailingCity,
                                     BillToContact.MailingStateCode,
                                     BillToContact.MailingPostalCode,
                                     BillToContact.MailingCountryCode
                                from Order
                               where AccountId IN : setAccId
                                 and Id IN :setOrderId]){
           for(integer i=1; i<objOrder.Payment_Occurrence__c; i++){
              pymt__PaymentX__c payment = new pymt__PaymentX__c(
                Name = 'Scheduled Payment',
                pymt__Transaction_Type__c = 'Payment',
                pymt__Status__c = 'Scheduled',
                pymt__Amount__c = objOrder.Recurring_Amount__c,
                pymt__Shipping__c = 0, // optional
                pymt__Currency_ISO_Code__c = objOrder.CurrencyIsoCode, 
                pymt__Scheduled_Payment_Date__c = objOrder.EndDate.addMonths(i),
                pymt__Account__c = objOrder.AccountId,
                pymt__Processor_Connection__c = objpymtProcessorConnection.Id,
                pymt__Payment_Method__c = mapContactIdPaymentMethodId.get(mapAccountIdContactId.get(objOrder.AccountId)),
                pymt__Payment_Processor__c = 'PayPal',
                Order__c = objOrder.Id, 
                pymt__Opportunity__c = null,
                pymt__Batch_Processing_Action__c = 'Process using assigned Payment Method',//'Process using default Payment Method on Contact',
                pymt__Billing_First_Name__c = objOrder.BillToContact.FirstName, 
                pymt__Billing_Last_Name__c = objOrder.BillToContact.LastName,
                pymt__Billing_Street__c = objOrder.BillToContact.MailingStreet,
                pymt__Billing_City__c = objOrder.BillToContact.MailingCity,
                pymt__Billing_State__c = objOrder.BillToContact.MailingStateCode,
                pymt__Billing_Country__c = objOrder.BillToContact.MailingCountryCode,
                pymt__Billing_Postal_Code__c = objOrder.BillToContact.MailingPostalCode,
                pymt__Contact__c = mapAccountIdContactId.get(objOrder.AccountId)); 
               lstPymtRecord.add(payment);
           }//End for
            objOrder.IsProcessed__c = true;
           lstOrder.add(objOrder);
         }//End for

        //Insert Payment records
        if(lstPymtRecord!=null && lstPymtRecord.size()>0){
            try{
                insert lstPymtRecord;
            }catch(DMLException errorMessage){
                system.debug('-errorMessage-' + errorMessage);
            }//End try-catch
        }//End if

        //Update Order Records
        if(lstOrder!=null && lstOrder.size()>0){
            try{
                update lstOrder;
            }catch(DMLException errorMessage){
                system.debug('-errorMessage-' + errorMessage);
            }//End try-catch
        }//End if


    }//End execute

    public void finish(Database.BatchableContext context) {
       
    }//End finish

}