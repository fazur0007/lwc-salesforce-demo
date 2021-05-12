public with sharing class NewOrderHelper {
  Boolean isPortalUser;
    User currentUser;
    private String idParam = null;
    private String accountId = null;
    private String currencyCode;
    private String objectType='';
    private String returnURL = '';
    public Boolean isError {get; set;}
    
  public NewOrderHelper(ApexPages.StandardController controller){
        isError = False;
        currentUser = [select id, IsPortalEnabled, AccountID, Account.RecordType.DeveloperName, Account.Phone, Account.PersonEmail, Account.Business_Email__c, Account.CurrencyIsoCode, DefaultCurrencyIsoCode from User where Id =: UserInfo.getUserId()];
        isPortalUser = currentUser.IsPortalEnabled;
        
        /*SF-746: Changes to make Phone and Email mandatory*/
        /*String excludedCurrencies = System.Label.Excluded_Currencies_for_required_Email_and_Phone;
        if(currentUser.AccountId != Null && currentUser.Account.RecordType.DeveloperName == 'PersonAccount' && (String.isBlank(currentUser.Account.PersonEmail) || String.isBlank(currentUser.Account.Phone))
        && !excludedCurrencies.containsIgnoreCase(';'+ currentUser.Account.CurrencyIsoCode +';')){
            isError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Email_and_Phone_Number_Required));
        }*/
    //caseRec = new Case();
    idParam = ApexPages.currentPage().getParameters().get('recordId');
    returnURL = ApexPages.currentPage().getParameters().get('retURL');
    
    if(idParam != null && idParam != ''){
      objectType = Id.valueOf(idParam).getSObjectType().getDescribe().getName();
    }
    currencyCode = currentUser.DefaultCurrencyIsoCode;  
  }
  
    public PageReference getRedirect(){
        PageReference newPage = new PageReference('/apex/NewOrder');    
        if(!isPortalUser && (idParam==null || idParam=='')){
            return null;
        }
        if(!(idParam != null && idParam != '')){
            idParam = currentUser.AccountID;
        }
        newPage.getParameters().put('recordId', idParam);
        newPage.getParameters().put('retURL', returnURL);
        newPage.getParameters().put('currencyISOCode', currencyCode);
        return newPage.setRedirect(true);
    }
}