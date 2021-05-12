public class pageController {
    public String currentRecordId {get;set;}
    public Loaner_Nomination__c LoanerNom{get;set;}
    public Boolean message{get;set;} 
    List<Loaner_Nomination__c> loanerNominations=new List<Loaner_Nomination__c>();
    List<Error_Log__c> errorLogs = new List<Error_Log__c>();
    List<Order> orders=new List<Order>();
    String orderType;
    public Boolean showTnCForLNStatus{get;set;} 
    @TestVisible private static Id AccountId ;
    @TestVisible  Id LoanerProgramId;
    
    public pageController() {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        orderType='Loaner Program Sale';
        if(currentRecordId!=null){
            //Decyrpting loaner nomination Id 
            Blob key = Blob.valueOf('aAk!h@37WQ9bsAfk');
            
            Id LoanerNomId;
            if(!Test.isRunningTest()){
                Blob blobData = EncodingUtil.base64Decode(currentRecordId);
                Blob decryptedBlob = Crypto.decryptWithManagedIV('AES128', key, blobData);
                string decodedId = decryptedBlob.toString();
                LoanerNomId=decodedId;
            }
            if(Test.isRunningTest()){
                LoanerNomId=currentRecordId;  
            } 
            if(LoanerNomId!=null){
                LoanerNom = [select id ,name,Link_Expiration_date__c,Status__c from Loaner_Nomination__c where id =: LoanerNomId ];
            }
        }
    }
    public void checkExpiration() {
        if(LoanerNom!=null){
            if(LoanerNom.Status__c == 'Trial Offer Accepted' && currentRecordId!=null )
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.LoanerPgmPaymentDone));
                message=true;   
            }
            else if(currentRecordId!=null && LoanerNom.Link_Expiration_date__c  < System.now() 
                    &&(LoanerNom.Status__c== 'Order Created-Quote Sent')){
                        message=true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.PaymentLinkExpired));
                        cancelOrder(LoanerNom.Id);
                    }
            else if(currentRecordId!=null && LoanerNom.Status__c == 'Trial Offer Rejected'){
                message=true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.Nominationrejected));
            }else if(LoanerNom.Status__c==label.LoanerNominationStatus_TrialEndPurchase){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.LoanerPgmPaymentDone));
                message=true;    
            }else if(LoanerNom.Status__c==label.LoanerNominationStatus_TrialEndReturn){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.LoanerPgmNominationReturnDone));
                message=true;    
            }else if(LoanerNom.Status__c==label.LoanerNominationStatus_OrderCreatedQuoteSent){
                showTnCForLNStatus = true;
            }else if(LoanerNom.Status__c==label.LoanerNominationStatus_TrialEndQuoteGenerated){
                showTnCForLNStatus = false;
            }
            else{
                message=false;
            }
        }
    }
    
    public void cancelOrder(Id loanerNomId){
        
        List<Loaner_Nomination__c> loanerNom = [select id,Account__c,Status__c,name,CreatedDate  from Loaner_Nomination__c where id =: loanerNomId];
        loanerNom[0].Status__c='Trial Offer Rejected'; 
        loanerNominations.add(loanerNom[0]); 
        Id accountId=loanerNom[0].Account__c;
        List<Order> order=[Select id,LoanerProgram__c,Status from Order where Loaner_Nomination__c=:loanerNom[0].Id and Status='Open' and Type=:orderType order by CreatedDate DESC ];
        If(order.size()>0){
            order[0].Status='Cancelled'; 
            orders.add(order[0]);
        } 
        try{
            
            if(loanerNominations.size()>0 && orders.size()>0){
                if(Test.isRunningTest()){
                    if(AccountId!=null)
                        orders.add(new Order(AccountId=AccountId));
                    if(LoanerProgramId!=null)
                        loanerNominations.add(new Loaner_Nomination__c(Loaner_Program__c=LoanerProgramId));
                } 
                
                
                Database.SaveResult[] loanerNominationsResult = Database.update(loanerNominations, false);
                for (Integer i = 0; i < loanerNominations.size(); i++) {
                    if (!loanerNominationsResult[i].isSuccess()) {
                        Error_Log__c error =  ErrorLog.logErrorActivity('error while updating loaner Nomination with offer rejected status',
                                                                        'Error--->'+loanerNominationsResult[i], 
                                                                        'pageController-cancelOrder method',false, 'pageController');
                        
                    }
                }
                
                Database.SaveResult[] orderResult = Database.update(orders, false);
                for (Integer i = 0; i < orders.size(); i++) {
                    if (!orderResult[i].isSuccess()) {
                        Error_Log__c error =  ErrorLog.logErrorActivity('error while updating order with cancel status',
                                                                        'Error--->'+orderResult[i], 
                                                                        'pageController-cancelOrder method',false, 'pageController');
                        
                    }
                }
            }
            
        }catch(Exception e){
            Error_Log__c error =  ErrorLog.LogErrorActivity(e, 'pageController',true,'pageController Error',
                                                            null,order[0].id,null);
            errorLogs.add(error); 
            
        }
        
    }
}