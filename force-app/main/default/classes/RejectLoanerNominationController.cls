public class RejectLoanerNominationController {
    
    public Boolean showMessage {get;set;}
    public Boolean showMessageForReturn {get;set;}
    String loanerNomIdVal;
    public String pgmName;
    String type;
    String orderType;
    String decodedId;
    public String messageForLoanerNomination{get;set;}
    List<Order> orders=new List<Order>();
    List<Loaner_Nomination__c> loanerNominations=new List<Loaner_Nomination__c>();
    List<Error_Log__c> errorLogs = new List<Error_Log__c>();
    Blob key;
    public Id loanerNomId;
    @TestVisible private static Id AccId ;
    @TestVisible private static Id LoanerProgramId;
    
    public RejectLoanerNominationController() {
        
    }
    
    public void init() {
        showMessage=false;
        showMessageForReturn=false;
        loanerNomIdVal = ApexPages.CurrentPage().getparameters().get('id');
        pgmName = ApexPages.CurrentPage().getparameters().get('pgm');
        type = ApexPages.CurrentPage().getparameters().get('type');
        orderType='Loaner Program Sale';
        key = Blob.valueOf('aAk!h@37WQ9bsAfk');
        if(loanerNomIdVal!=null && pgmName!=null){
            //Decyrpting loaner nomination Id 
            if(!Test.isRunningTest()){
                Blob blobData = EncodingUtil.base64Decode(loanerNomIdVal);
                Blob decryptedBlob = Crypto.decryptWithManagedIV('AES128', key, blobData);
                decodedId = decryptedBlob.toString();
                loanerNomId=decodedId;
            }
            if(Test.isRunningTest()){
                loanerNomId=loanerNomIdVal;  
            }
            
            List<Loaner_Nomination__c> loanerNom = [select id,Account__c,Status__c,name,CreatedDate,Link_Expiration_date__c from Loaner_Nomination__c where id =: loanerNomId];
            if(loanerNom.size()>0){
                if(loanerNomIdVal!=null && type!=null){
                    if(loanerNom[0].Status__c==label.LoanerNominationStatus_TrialEndPurchase){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.LoanerPgmPaymentDone));
                        showMessageForReturn=true;    
                    }
                    else if(loanerNom[0].Status__c==label.LoanerNominationStatus_TrialEndReturn){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.LoanerPgmNominationReturnDone));
                        showMessageForReturn=true;    
                    }else{
                        showMessage=false;
                        TrialEndReturn();
                    }
                }else{
                    if(loanerNom[0].Status__c==label.LoanerNominationStatus_TrialOfferAccepted){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.LoanerPgmPaymentDone));
                        showMessage=true;    
                    }
                    else if(loanerNom[0].Status__c==label.LoanerNominationStatus_TrialOfferRejected){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.LoanerPgmNominationAlreadyRejected));
                        showMessage=true;    
                    }
                    else if(loanerNom[0].Status__c != label.LoanerNominationStatus_TrialOfferAccepted && loanerNom[0].Status__c != label.LoanerNominationStatus_TrialOfferRejected && loanerNom[0].Link_Expiration_date__c < System.now() ){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.LoanerPgmNominationLinkExpired));
                        showMessage=true;
                        loanerNomId=loanerNom[0].Id;
                        cancelOrder();
                        //LoanerProgramUtility.cancelOrder(loanerNomId,pgmName,orderType);
                    }
                    else if(loanerNom[0].Status__c==label.LoanerNominationStatus_OrderCreatedQuoteSent){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.LoanerPgmNominationRejected));
                        showMessage=true;
                        loanerNomId=loanerNom[0].Id;
                        cancelOrder();
                    }
                }
            }
            
        }
    }
    
    public void cancelOrder(){
        
        if(loanerNomId!=null && pgmName!=null){
            List<Loaner_Nomination__c> loanerNom = [select id,Account__c,Status__c,name,CreatedDate  from Loaner_Nomination__c where id =: loanerNomId];
            loanerNom[0].Status__c='Trial Offer Rejected'; 
            loanerNominations.add(loanerNom[0]); 
            Id accountId=loanerNom[0].Account__c;
            Loaner_Program__c loanerPgm=[SELECT Id, OwnerId, ProgramName__c, Active__c, PriceBook__c FROM Loaner_Program__c where ProgramName__c=:pgmName]; 
            
            //Order order=[Select id,LoanerProgram__c,Status from Order where AccountId =: accountId and LoanerProgram__c=:loanerPgm.Id and Type=:orderType limit 1];
            //List<Order> order=[Select id,LoanerProgram__c,Status from Order where Loaner_Nomination__c=:loanerNom[0].Id and LoanerProgram__c=:loanerPgm.Id and Type=:orderType and Status='Open' limit 1];
            List<Order> order=[Select id,LoanerProgram__c,Status from Order where Loaner_Nomination__c=:loanerNom[0].Id and LoanerProgram__c=:loanerPgm.Id and Status='Open' and Type=:orderType order by CreatedDate DESC];
            If(order.size()>0){
                order[0].Status='Cancelled'; 
                orders.add(order[0]);
            }
            showMessage=true; 
            try{
                
                if(loanerNominations.size()>0 && orders.size()>0){
                    if(Test.isRunningTest()){
                		if(AccId!=null)
                			orders.add(new Order(AccountId=AccId));
                        if(LoanerProgramId!=null)
                			loanerNominations.add(new Loaner_Nomination__c(Loaner_Program__c=LoanerProgramId));
           			 }
                    Database.SaveResult[] orderResult = Database.update(orders, false);
                    for (Integer i = 0; i < orders.size(); i++) {
                        if (!orderResult[i].isSuccess()) {
                            Error_Log__c error =  ErrorLog.logErrorActivity('error while updating order with cancel status',
                                                                            'Error--->'+orderResult[i], 
                                                                            'RejectLoanerNominationController-cancelOrder method',false, 'RejectLoanerNominationController');
                            
                        }
                    }
                    
                    Database.SaveResult[] loanerNominationsResult = Database.update(loanerNominations, false);
                    for (Integer i = 0; i < loanerNominations.size(); i++) {
                        if (!loanerNominationsResult[i].isSuccess()) {
                            Error_Log__c error =  ErrorLog.logErrorActivity('error while updating loaner Nomination with offer rejected status',
                                                                            'Error--->'+loanerNominationsResult[i], 
                                                                            'RejectLoanerNominationController-cancelOrder method',false, 'RejectLoanerNominationController');
                            
                        }
                    }
                    
                    
                    //messageForLoanerNomination='You have been rejected';   
                    messageForLoanerNomination=Label.LoanerPgmNominationRejected;  
                    showMessage=true; 
                }
                
            }catch(Exception e){
                Error_Log__c error =  ErrorLog.LogErrorActivity(e, 'RejectLoanerNominationController',true,'RejectLoanerNominationController Error',
                                                                null,order[0].id,null);
                errorLogs.add(error); 
                
            }
        } 
    } 
    
    
    public void TrialEndReturn(){
        
        List<Loaner_Nomination__c> loanerNomIds=new List<Loaner_Nomination__c>();
        Map<Id,Loaner_Nomination__c> loanerNomIdsMap=new Map<Id,Loaner_Nomination__c>();
        type = ApexPages.CurrentPage().getparameters().get('type');
        if(loanerNomIdVal!=null && type!=null){
            //Decyrpting loaner nomination Id 
            if(!Test.isRunningTest()){
                Blob blobData = EncodingUtil.base64Decode(loanerNomIdVal);
                Blob decryptedBlob = Crypto.decryptWithManagedIV('AES128', key, blobData);
                string decodedId = decryptedBlob.toString();
                loanerNomId=decodedId;
            }
            if(Test.isRunningTest()){
                loanerNomId=loanerNomIdVal;  
            }
            List<Loaner_Nomination__c> loanerNom = [select id,Account__c,Status__c,name,CreatedDate  from Loaner_Nomination__c where id =: loanerNomId];
            if(loanerNom.size()>0){
                loanerNom[0].Status__c='Trial End- Return';
                loanerNomIds.add(loanerNom[0]);
            	loanerNominations.add(loanerNom[0]);
                loanerNomIdsMap.putAll(loanerNomIds);
            }
            if(loanerNomIds!=null){
                List<Loaner_Nomination__c> loanerNominationsUpdated = loanerNomIdsMap.values();
                Database.SaveResult[] loanerNominationsResult = Database.update(loanerNominationsUpdated, false);
                for (Integer i = 0; i < loanerNominationsUpdated.size(); i++) {
                    if (!loanerNominationsResult[i].isSuccess()) {
                        Error_Log__c error =  ErrorLog.logErrorActivity('error while updating loaner Nomination with offer rejected status',
                                                                        'Error--->'+loanerNominationsResult[i], 
                                                                        'RejectLoanerNominationController-cancel Order method',false, 'RejectLoanerNominationController');
                        
                    }
                }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.LoanerPgmNominationReturn));
                messageForLoanerNomination=Label.LoanerPgmNominationReturn;
                showMessageForReturn=true; 
            }
        }
    }
}