/**
 * This is the controller for the WebToCaseForBrevilleMicroSite VisualForce page.
 * It takes necessary data from the page, validates it, and saves to Account (if new),
 * and Case for the product code "BPR600XL".
 *
 * Revision History:
 *
 * Version        Author        Last Modified Date (MM/DD/YYYY)          Description
 *  1.0        Yogesh Sharma           12/09/2015                       Initial Draft
 **/
public with sharing class WebToCaseForBrevilleMicroSiteController {
    
    public Account acct { get; set; }
    public Case objCase { get; set;}
    private Boolean isSuccess;
    private String fieldErrors;
    public String comments{ get; set;}
    public String confirmEmail { get; set; }
    
    public WebToCaseForBrevilleMicroSiteController(){
        acct = new Account();
        isSuccess = false; 
        objCase = new Case();
        fieldErrors = '';
    }//End Constructor

    /* Picklist of products related to product SubCategory from Product */
  /*  public List<SelectOption> products {
        get {
                List<SelectOption> result = new List<SelectOption>();

                result.add(new SelectOption('', '-- None --'));

                List<Product2> products = [SELECT Id, Name, Description, US_SKU__c
                                           FROM Product2
                                           WHERE (Finished_Good__c = true AND
                                                  Product_Classification__c IN ('C', 'D', 'F', 'R', 'S') AND
                                                  IsActive = true AND 
                                                  Spare_Part__c = false 
                                                  AND Espresso_Microsite__c = true)
                                           ORDER BY Name ASC];

                for (Product2 product : products) {
                    if(product.US_SKU__c == null )
                    product.US_SKU__c = '';
                    result.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description));
                    
                }
                return result;
        }
    }

   /* Picklist to get the Picklist of Inquiry Types from the Case object */ 
  /*  public List<SelectOption> getCaseTypes(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- None --'));
        List<String> uniqueCustomObjectList = new List<String>();

            uniqueCustomObjectList.add('Sales & Product Information');

        for(integer i=0; i<uniqueCustomObjectList.size(); i++){
            options.add(new SelectOption(uniqueCustomObjectList[i],uniqueCustomObjectList[i]));
        }

        return options;
    }

     /**
     * This method is the save method it validates all the fields. Queries for
     * Accounts and creates Case objects.
     */
 /*   public pageReference registrationSave() {
        fieldErrors ='';
        checkFields();

        if(fieldErrors != ''){
                createErrorMessage(Label.Following_Fields_are_Required + ' ' + fieldErrors + Label.Please_make_the_necessary_corrections);
            return null;
        }//End if

        if(!validateEmail()){
            return null;
        }

        Account[] accts = findExistingAccount();
        Account account = createUpdateAccount(accts);

        try{
            upsert account;
            Case objCaseToInsert = new Case();

            RecordType newCasePS = [SELECT Id,
                                           Name 
                                      From RecordType 
                                     Where SobjectType = 'Case' 
                                       And DeveloperName = 'New_Case' 
                                       And IsActive = true];
			objCase.RecordTypeId = Utility.fetchRecordTypeId('Case', 'New_Case');
            objCase.Origin = 'Web Inquiry';
            objCase.AccountId = acct.Id;
            objCase.Complaint_Code__c = 'Questions & Feedback';
            objCase.Description =  comments;
	            
	            
            //objCaseToInsert.Complaint_Code__c = 'Questions & Feedback';
            if(comments != Null){
                if(comments.length()>30)
                objCaseToInsert.Subject =  comments.substring(0, 30);
                else objCaseToInsert.Subject =  comments;
            }//End if
            objCase.Type = 'Sales & Product Information';
            objCase.Product__c = objCase.Product__c;
            objCase.Case_Sub__c = 'Espresso Microsite';
            
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule= true;
            objCase.setOptions(dmlOpts);
            
            
            insert objCase;
            isSuccess = true;
        }catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }

        
        return null; // Added for testing form submission
    }//End registrationSave

     /**
     * Creates an error messge based on the data sent in.
     */
   /* private void createErrorMessage(String err){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, err));
    }//End createErrorMessage

    public Boolean getIsSuccess(){
        return this.isSuccess;
    }//End getIsSuccess

     /**
     * This method updates the inputed account data or updates the queried
     * account object and returns it for upsert in save method.
     */
   /*private Account createUpdateAccount(Account[] accounts){

        if(accounts != null){
            accounts[0].FirstName = acct.firstName;
            accounts[0].LastName = acct.LastName;
            accounts[0].PersonEmail = acct.PersonEmail;
            accounts[0].Phone = acct.Phone;
            return accounts[0];
        }//End if

        acct.RecordTypeId = [SELECT Id
                             FROM RecordType
                             WHERE sObjectType = 'Account'
                             AND Name = 'Person Account' 
                             AND IsActive = true].Id;
        return acct;
    }//End createUpdateAccount

     /**
     * Queries for accounts based on email inputted in vf page.
     */
   /* private Account[] queryOnEmail(){
        return [SELECT Id
                FROM Account
                WHERE PersonEmail = :acct.PersonEmail];
    }//End queryOnEmail

    /**
     * Queries to find any existing accounts. Returns existing or null if none
     * exist.
     */
   /* private Account[] findExistingAccount(){
        List<Account> accounts = queryOnEmail();
        if(accounts.size() > 0){
            return accounts;
        }
      return null;
    }//End findExistingAccount

    /**
     * Verifies that the two email inputted in the vf page match and that the
     * format for the email is correct.
     */
   /* private boolean validateEmail(){
        if(acct.PersonEmail == confirmEmail){
            if(Utility.isValidEmail(acct.PersonEmail)){
                return true;
            }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Email_Invalid));
            }
        }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Email_Dont_Match));
        }
        return false;
    }//End validateEmail

     /**
     * Verifies a string is valid and is not null or an empty string.
     */
  /*  private Boolean isValid(String value){
        if(value == null || value == ''){
            return false;
        }//End if
        return true;
    }//End isValid

    private Boolean isValid(Date inDate){
        if(inDate ==  null){
            return false;
        }
        return true;
    }//End isValid
    
     /**
     * Adds fields to the fielderror string passed in from the checkfields
     * method.
     */
   /* private void addField(String label){
        if(fieldErrors == ''){
            fielderrors = fielderrors + label;
        }//End if

        if(!fieldErrors.contains(label)){
            fieldErrors = fielderrors + ', ' + label;
        }//End if
    }//End addField

    /**
     * Verifies all required fields have been populated on vf page.
     */
   /* public void checkFields(){

            if(!isValid(acct.FirstName)){
                addfield('First Name');
            }

            if(!isValid(acct.LastName)){
                addfield('Last Name');
            }

            if(!isValid(acct.PersonEmail)){
                addfield('Email');
            }

            if(!isValid(confirmEmail)){
                addfield('Confirm Email');
            }

            /*if(!isValid(objCase.Type)){
                addfield('Inquiry Type');
            }

            if(!isValid(comments)){
                addfield('Comments');
            }*/
/*    }//End checkFields*/

}//End WebToCaseForBrevilleMicroSiteController