/**
 * This is the controller class for the ProductRegistrationForJoeJuicer visual force page.
 * This class takes the data from the visual force page and inserts if necessary
 * an account, and a Warranty__c object from the data supplied on the page.
 *
 * Revision History: 
 *
 * Version       Author             Date          Description 
 *  1.0        Yogesh Sharma      09/23/2015     Initial Draft 
*/
public class ProductRegistrationForJoeJuicer {

    public String selectedSubCategory { get; set; }
    public Account acct { get; set; }
    public String confirmEmail { get; set; }
    public String personBillingStreet2 { get; set; }
    public Warranty__c warranty { get; set; }
    public Boolean isSuccess;
    public String fieldErrors;
    //public boolean blnEnglish {get; set;}
    //public boolean blnFrench {get; set;}
    //public String URL {get; set;}
    public string code {get; set;}
    //public boolean isCanada {get; set;}
    public string whereDidYouPurchase {get; set;}
    public string hearAboutUs{get; set;}
    private static Map<String, ProductSubCategory__c> productsubCateg = ProductSubCategory__c.getAll();
    
    public ProductRegistrationForJoeJuicer() {
        acct = new Account();
        isSuccess = false;
        warranty = new Warranty__c();
        /*blnEnglish = true;
        blnFrench = false;
        URL = ApexPages.currentPage().getParameters().get('param');
        
        if(URL == 'US')
        {
            isCanada = false;
            //acct.BillingCountry = 'USA';
        }
        else if(URL == 'CA')
        {
            isCanada = true;
            //acct.BillingCountry = 'CAN';
        }*/
    }

    public List<String> requiredSerials {
        get {
            //if(URL == 'US')
            //{
                List<Product2> products =
                    [SELECT Id
                     FROM Product2
                     WHERE (Serial_Required_for_Registration__c = true AND
                            Finished_Good__c = true AND
                            // Product_Classification__c IN ('C', 'D', 'E', 'F', 'R', 'S') AND
                            Accessory__c = false AND
                            Joe_Product__c = true AND
                            // Spare_Part__c = false AND
                            IsActive = true)];
                List<String> result = new List<String>();
                system.debug('@products@@' + products);
                for (Product2 product : products)
                {
                    result.add(product.Id); //Name + ' - ' + product.Description);
                }
                return result;
            /*}
            else if(URL == 'CA')
            {
                List<Product2> products =
                    [SELECT Id
                     FROM Product2
                     WHERE (Serial_Required_for_Registration__c = true AND
                            Finished_Good__c = true AND
                            Product_Classification__c IN ('C', 'D', 'E', 'F', 'R', 'S') AND
                            Country_Code__c = 'CAN' AND
                            IsActive = true)];
                List<String> result = new List<String>();
                for (Product2 product : products) 
                {
                    result.add(product.Id); //Name + ' - ' + product.Description);
                }
                return result;
            }*/
        //return null;
        }
    }
    
    public List<SelectOption> productSubCategories {
        get {
            //if(URL == 'US')
            //{ 
                List<AggregateResult> ars =
                    [SELECT Product_Sub_Family__c subCategory
                     FROM Product2
                     WHERE (Finished_Good__c = true AND
                            // Product_Classification__c IN ('C', 'D', 'E', 'F', 'R', 'S') AND
                            Accessory__c = false AND
                            Joe_Product__c = true AND
                            // Spare_Part__c = false AND
                            IsActive = true)
                     GROUP BY Product_Sub_Family__c];
                     system.debug('!!!!!!!!ars!!!' + ars);
                List<SelectOption> result = new List<SelectOption>();
                result.add(new SelectOption('', '-- None --'));
                for (AggregateResult ar : ars) {
                    if(ar!= Null && ar.get('subCategory') != Null)
                    result.add(new SelectOption((string) ar.get('subCategory'), (string) ar.get('subCategory')));
                }
                return result;
            /*}
            else if(URL == 'CA')
            {
                  if(blnEnglish)
                    { 
                        List<AggregateResult> ars = [SELECT Product_Sub_Family__c subCategory
                                             FROM Product2
                                             WHERE (Finished_Good__c = true AND
                                                    Product_Classification__c IN ('C', 'D', 'E', 'F', 'R', 'S') AND
                                                    Country_Code__c = 'CAN' AND
                                                    IsActive = true AND Spare_Part__c = false)
                                             GROUP BY Product_Sub_Family__c];
                        //system.debug('!!!!!!!!!!ars'+ars);
                        List<SelectOption> result = new List<SelectOption>();
                        //system.debug('^^^^^^^^result'+result);
                   
                        result.add(new SelectOption('', '-- None --'));
           
                        for (AggregateResult ar : ars) 
                        {
                            if(ar!= Null && ar.get('subCategory') != Null)
                            result.add(new SelectOption((string) ar.get('subCategory'), (string) ar.get('subCategory')));
                        }
                        return result;
                    }
                    else if(blnFrench)
                    {
                        List<AggregateResult> ars = [SELECT Product_Sub_Family__c subCategory
                                             FROM Product2
                                             WHERE (Finished_Good__c = true AND
                                                    Product_Classification__c IN ('C', 'D', 'E', 'F', 'R', 'S') AND
                                                    Country_Code__c = 'CAN' AND
                                                    IsActive = true AND Spare_Part__c = false )
                                             GROUP BY Product_Sub_Family__c];
                       List<SelectOption> result = new List<SelectOption>();
                       result.add(new SelectOption('', '- Aucun -'));
                      
                       for(AggregateResult ar : ars)
                       {
                            if(ar!= Null && ar.get('subCategory') != Null)
                            {
                                if(productsubCateg.get((string) ar.get('subCategory'))!=null)
                                { 
                                    //system.debug('(string) '+productsubCateg.get((string) ar.get('subCategory')));
                                    ProductSubCategory__c ProdCatg = productsubCateg.get((string) ar.get('subCategory'));
                                    //system.debug('ProdCatg*******'+ProdCatg);
                                    result.add(new selectOption(ProdCatg.Name,ProdCatg.CategoryNameFrench__c));
                                    //mapProdCatgFrenchEng.put(ProdCatg.CategoryNameFrench__c,ProdCatg.Name);
                                }
                            }
                       }
                       return result;
                   }
                }*/
                //return null;
            }
        }
    
    public List<SelectOption> products {
        get {
            //if(URL == 'US')
            //{
                List<SelectOption> result = new List<SelectOption>();
                result.add(new SelectOption('', '-- None --'));
    
                if (selectedSubCategory == null) {
                    return result;
                }
    
                List<Product2> products =
                    [SELECT Id, Name, Description, US_SKU__c
                     FROM Product2
                     WHERE (Product_Sub_Family__c = :selectedSubCategory AND
                            Finished_Good__c = true AND
                            // Product_Classification__c IN ('C', 'D', 'E', 'F', 'R', 'S') AND
                            Accessory__c = false AND
                            Joe_Product__c = true AND
                            // Spare_Part__c = false AND
                            IsActive = true)
                     ORDER BY Name ASC];
                system.debug('@!@!@!@!@Products' + products);
                for (Product2 product : products) {
                    if(product.US_SKU__c == null )
                        product.US_SKU__c = '';
                        result.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description));
                }
                return result;
            /*}
            else if (URL == 'CA')
            {
                List<SelectOption> result = new List<SelectOption>();
            
                if(blnEnglish == true)
                result.add(new SelectOption('', '-- None --'));
                else if(blnFrench == true)
                result.add(new SelectOption('', '- Aucun -'));

                if (selectedSubCategory == null) 
                {
                    return result;
                }
            
                List<Product2> products = [SELECT Id, Name, Description, US_SKU__c,SKU__c
                                           FROM Product2
                                           WHERE (Product_Sub_Family__c = :selectedSubCategory AND
                                                  Finished_Good__c = true AND
                                                  Product_Classification__c IN ('C', 'D', 'E', 'F', 'R', 'S') AND
                                                  Country_Code__c = 'CAN' AND
                                                  IsActive = true AND Spare_Part__c = false )
                                           ORDER BY Name ASC];

                for (Product2 product : products) 
                {
                    if(product.US_SKU__c == null )//US_SKU__c
                        product.US_SKU__c = '';//US_SKU__c
                        //Remove US_SKU__c and added product name : 08/05/2015
                        result.add(new SelectOption(product.Id, product.Name + ' - ' + product.Description));
                       // result.add(new SelectOption(product.Id, product.SKU__c + ' - ' + product.Description));//US_SKU__c
                        
                }
                return result;
            }*/
            //return null;
        }
    }
    
    public List<SelectOption> howDidYouHearAboutUs{
        get
            {
            List<SelectOption> options = new List<SelectOption>();
             options.add(new SelectOption('', '-- None --'));
            Schema.DescribeFieldResult fieldResult = Warranty__c.How_did_you_hear_of_us__c.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            for(Schema.Picklistentry pickValues: picklistValues){
                if(pickValues.getValue() != 'Retail in-store'){
                        options.add(new SelectOption(pickValues.getLabel(), pickValues.getValue()));
                        options.sort();
                  }//End if
            }//End for
            return options;  
            }
    }//End howDidYouHearAboutUs

    public List<SelectOption> whereDidYouPurchaseFrom
    {
        get
            {
            List<SelectOption> options = new List<SelectOption>();
             options.add(new SelectOption('', '-- None --'));
            //Schema.DescribeFieldResult fieldResult = Warranty__c.Where_did_you_purchase__c.getDescribe();
            //system.debug('!!!!!!fieldResult'+fieldResult);
            //List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            //for(Schema.Picklistentry pickValues: picklistValues)
            //{
                //f(pickValues.getValue() != 'PolyScience' && pickValues.getValue() != 'Distributor')
                  //  {
                        //options.add(new SelectOption(pickValues.getLabel(), pickValues.getValue()));
                        //system.debug('!!!!!!!!!!options'+options);
                        options.add(new SelectOption('Website', 'Website'));
                        options.add(new SelectOption('TV', 'TV'));
                        options.sort();
                    //}
            //}
            return options;  
            }
    }

    public Boolean getIsSuccess() {
        return this.isSuccess;
    }

    /**
     * This method is the save method it validates all the fields. Queries for
     * Accounts and creates warranty objects.
     */
    public pageReference registrationSave() {

        warranty.Warranty_Product_Sub_Category__c = selectedSubCategory;

        fieldErrors = '';
        checkFields();
        if(fieldErrors != ''){
            //system.debug('********fieldErrors'+fieldErrors);
            //if(blnEnglish == true)
            //{
                System.debug('\n\n***********fieldErrors***********\n\n' + fieldErrors);
                createErrorMessage('The following required field(s) are required and missing: '
                                   + fieldErrors + '. Please make the necessary corrections.');
            //}
            /*else if(blnFrench == true)
            {
                createErrorMessage('Les champs suivants obligatoires(s) sont requises et manquante: '
                                    + fieldErrors + '. Veuillez effectuer les corrections nécessaires.');
            }*/
            return null;
        }
        if(!validateEmail()){
            return null;
        }
        if(!validatePostalCode(acct.BillingPostalCode))
        {
            return null;
        }
        if(!validateBillingStreet(acct.BillingStreet))
        {
            return null;
        }
        if(!validateBillingState(acct.BillingStateCode))
        {
            return null;
        }
        
        Account[] accts = findExistingAccount();
        Account account = createUpdateAccount(accts);
        SavePoint sp = Database.setSavepoint();
        try{
            upsert account;

            warranty.Warranty_Owner__c = account.id;
            warranty.Where_did_you_purchase__c = whereDidYouPurchase;
            insert warranty;
            isSuccess = true;
        }
        catch (Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }

        if(isSuccess){
            //if(blnEnglish == true)
            //{
                ApexPages.addMessage
                    (new ApexPages.Message
                     (ApexPages.Severity.Info,
                      'Thank you, your warranty registration has been submitted!'));
            /*}
            else if(blnFrench == true)
            {
                ApexPages.addMessage
                    (new ApexPages.Message
                     (ApexPages.Severity.Info,
                      'Merci, votre enregistrement de garantie a été soumis!'));
            }*/
        }
        return null; // Added for testing form submission
    }

    /**
     * This method updates the inputed account data or updates the queried
     * account object and returns it for upsert in save method.
     */
    private Account createUpdateAccount(Account[] accounts){
        acct.BillingStreet += personBillingStreet2 != null ? '\n '+personBillingStreet2 : '';
        acct.BillingCountryCode = acct.BillingCountryCode;
        //acct.PolySci_Account__c = true;
        if(accounts != null){
            accounts[0].FirstName = acct.firstName;
            accounts[0].LastName = acct.LastName;
            accounts[0].BillingStreet = acct.BillingStreet;
            accounts[0].BillingCountryCode = acct.BillingCountryCode;
            accounts[0].BillingPostalCode = acct.BillingPostalCode;
            accounts[0].BillingStateCode = acct.BillingStateCode;
            accounts[0].BillingCity = acct.BillingCity;
            accounts[0].PersonEmail = acct.PersonEmail;
            accounts[0].Phone = acct.Phone;
            accounts[0].PersonBirthdate = acct.PersonBirthdate;
            accounts[0].Gender__c = acct.Gender__c;
            accounts[0].Subscribe_to_our_newsletter__c = acct.Subscribe_to_our_newsletter__c;
            //accounts[0].PolySci_Account__c = true;
            return accounts[0];
        }

        acct.RecordTypeId =
            [SELECT Id
             FROM RecordType
             WHERE sObjectType = 'Account' AND Name = 'Person Account' AND IsActive = true].Id;

        return acct;
    }
    
    /* Method to set the English as the language of the Page 
    public PageReference enableEnglish()
    {
        blnEnglish = true;
        blnFrench = false;
        if(blnEnglish == true)
        code = 'En-Us';
        if(blnFrench == true)
        code = 'fr';
        return null;
    }
    
    /* Method to set the French as the language of the Page 
    public PageReference enableFrench()
    {
        blnEnglish = false;
        blnFrench = true;
        if(blnEnglish == true)
        code = 'En-Us';
        if(blnFrench == true)
        code = 'fr';
        return null;
    }*/ 
    /**
     * Queries to find any existing accounts. Returns existing or null if none
     * exist.
     */
    private Account[] findExistingAccount(){

        List<Account> accounts = queryOnEmail();
        system.debug('!!!!!!!!!!!!!accounts'+accounts);
        if(accounts.size() > 0){
            return accounts;
        }

        if ((! String.isEmpty(acct.Phone)) && acct.Phone.trim().length() >= 7) {
            accounts = queryOnPhone();
            if(accounts != null){
                return accounts;
            }
        }

        return null;
    }

    /**
     * Queries for accounts based on email inputted in vf page.
     */
    private Account[] queryOnEmail(){
        return [SELECT Id
                FROM Account
                WHERE PersonEmail = :acct.PersonEmail];
    }

    /**
     * Queries for accounts based on inputted phone.
     */
    private Account[] queryOnPhone(){
        List<List<sObject>> searchList = [FIND :acct.Phone IN PHONE FIELDS RETURNING Account];
        Account[] accounts = ((List<Account>)searchList[0]);
        if(accounts.size() < 0){
            return [SELECT Id
                    FROM Account
                    WHERE Id = :accounts[0].id];
        }
        return null;
    }

    /**
     * Creates an error messge based on the data sent in.
     */
    private void createErrorMessage(String err){
        ApexPages.addMessage
            (new ApexPages.Message
             (ApexPages.Severity.Error, err));
    }

    /**
     * Adds fields to the fielderror string passed in from the checkfields
     * method.
     */
    private void addField(String label){
        if(fieldErrors == ''){
            fielderrors = fielderrors + label;
        }
        if(!fieldErrors.contains(label)){
            fieldErrors = fielderrors + ', ' + label;
        }
    }

    /**
     * Verifies a string is valid and is not null or an empty string.
     */
    private Boolean isValid(String value){
        if(value == null || value == ''){
            return false;
        }
        return true;
    }

    /**
     * Verifies a Date field is populated
     */
    private Boolean isValid(Date inDate){
        if(inDate ==  null){
            return false;
        }
        return true;
    }

    /**
     * Verifies all required fields have been populated on vf page.
     */
    public void checkFields(){
    //if(blnEnglish == true)
        //{
        if (String.isBlank(warranty.Warranty_Product_Sub_Category__c)) {
            addField('Product Sub Category');
        }

        if (String.isBlank(warranty.Product__c)) {
            addField('Product');
        } else {

            Product2 product =
                [SELECT Id, Serial_Required_for_Registration__c
                 FROM Product2
                 WHERE id = : warranty.Product__c];
                //system.debug('!!!!!!!!product'+product);
            if (product.Serial_Required_for_Registration__c == true && String.isBlank(warranty.Serial__c)) {
                //system.debug('!!!!!!!!warranty.Serial__c'+warranty.Serial__c);
                addfield('Serial #');
            }
        }

       /* if (String.isBlank(warranty.Product_Date_Code__c)) {
            addField ('Product Batch Code');
        }*/

        if(String.isBlank(whereDidYouPurchase)){
            addField('Where did you purchase?');
        }

        if(!isValid(warranty.Web_Purchase_Date__c)){
            addfield('Date of Purchase');
        } else if (warranty.Web_Purchase_Date__c > Date.today()) {
            addfield('Web Purchase Date');
        }

        if(!isValid(acct.FirstName)){
            addfield('First Name');
        }

        if(!isValid(acct.LastName)){
            addfield('Last Name');
        }

        if(!isValid(acct.BillingStreet)){
            addfield('Street(1)');
        }

        if(!isValid(acct.BillingCity)){
            addfield('City');
        }

        if(!isValid(acct.BillingStateCode)){
            addField('State/Province');
        }

        if(!isValid(acct.BillingPostalCode)){
            addfield('Zip/Postal Code');
        }
        if(!isValid(acct.BillingCountryCode)){
            addfield('Country');
        }
        if(!isValid(acct.PersonEmail)){
            addfield('Email');
        }

        if(!isValid(confirmEmail)){
            addfield('Confirm Email');
        }
    /*}
    else if (blnFrench == true)
    {
        if (String.isBlank(warranty.Warranty_Product_Sub_Category__c)) {
            addField('Sous-catégorie de produits');
        }

        if (String.isBlank(warranty.Product__c)) {
            addField('Produit');
        } else {

            Product2 product =
                [SELECT Id, Serial_Required_for_Registration__c
                 FROM Product2
                 WHERE id = : warranty.Product__c];

            if (product.Serial_Required_for_Registration__c == true && String.isBlank(warranty.Serial__c)) {
                addfield('Série #');
            }
        }
        if (String.isBlank(warranty.Product_Date_Code__c)) {
            addField (system.Label.Product_Batch_Code);
        }

        if(!isValid(whereDidYouPurchase)){
            addField(system.Label.Where_did_you_purchase);
        }

        if(!isValid(warranty.Web_Purchase_Date__c)){
            addfield(system.Label.Date_of_Purchase);
        } else if (warranty.Web_Purchase_Date__c > Date.today()) {
            addfield('Web Date d\'achat');
        }

        if(!isValid(acct.FirstName)){
            addfield('Prénom');
        }

        if(!isValid(acct.LastName)){
            addfield('Nom');
        }

        if(!isValid(acct.BillingStreet)){
            addfield('Rue(1)');
        }

        if(!isValid(acct.BillingCity)){
            addfield('Ville');
        }

        if(!isValid(acct.BillingState)){
            addField(system.Label.State);
        }

        if(!isValid(acct.BillingPostalCode)){
            addfield(system.Label.Postal_Code);
        }
        
        if(!isValid(acct.BillingCountry)){
            addfield(system.Label.Country);
        }

        if(!isValid(acct.PersonEmail)){
            addfield(system.Label.Email);
        }

        if(!isValid(confirmEmail)){
            addfield('Confirmer le courriel');
        }
    }*/
    }
    
    //Validation rule for BillingPostalCode on Account
    public Boolean validatePostalCode(String strPostalCode)
    {
        //system.debug('***********strPostalCode'+strPostalCode);
        //system.debug('***********strPostalCode'+acct.BillingCountry);
        
        if(strPostalCode!= null && acct.BillingCountryCode == 'CA' && (strPostalCode.contains(' ') || strPostalCode.length() != 6))
        {
            system.debug('!!!!!!Insered');
            //if(blnEnglish == true)
                //{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                        'Postal code must be 6 characters and no spaces.'));
                //}
                /*else if(blnFrench == true)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                        'Code postal doit être de 6 caractères, sans espaces.'));
                }*/
                return false;
        }
        
        else
        return true;
    }
    
    /**
     * Verifies that the two email inputted in the vf page match and that the
     * format for the email is correct.
     */
    private boolean validateEmail(){
        if(acct.PersonEmail == confirmEmail){
            if(Utility.isValidEmail(acct.PersonEmail)){
                return true;
            }
            //if(blnEnglish == true)
                //{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                        'The email entered is invalid, please re-enter.'));
                //}
            /*else if(blnFrench == true)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                        'L\'e-mail saisie est incorrecte, veuillez la saisir de nouveau.'));
                }*/

        }
        else {
                //if(blnEnglish == true)
                //{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                  'The Email and Confirm Email do not match. Please verify your answers.'));
                //}
                /*else if(blnFrench == true)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                        'L\'e-mail et l\'e-mail de confirmation ne correspondent pas. Veuillez vérifier vos réponses.'));
                }*/
                
        }
        return false;
    }
    
    //Validation rule for BillingStreet on Account
    public Boolean validateBillingStreet(String strBillingStreet)
    {
        if(strBillingStreet != null && strBillingStreet.length() > 30)
        {
            //if(blnEnglish == true)
                //{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                        'Length of address cannot be greater than 30 characters or 2 lines.'));
                //}
                /*else if(blnFrench == true)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                        'Longueur de l\'adresse ne peut être supérieure à 30 caractères ou 2 lignes.'));
                }*/
                return false;
        }
        
        else
        return true;
        
    }
    
    User objUser = [ Select u.UserType From User u WHERE u.id =: UserInfo.getUserId()];
    
    Set<String> statesofUSA = new Set<String>{'AL','AK','AZ','AR','CA','CO','CT','DE','DC','FL','GA','HI','ID','IL','IN','IA',
        'KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI',
        'SC','SD','TN','TX','UT','VT','VA','WA','WV', 'WI','WY','AA','AE','AP','AS','FM','GU','MH','MP','PR','PW','VI'};
    
    Set<String> statesofCanada = new Set<String>{'AB','BC','MB','NB','NL','NT','NS','NU','ON','PE','QC','SK','YT'};
    
    //Validation rule for BillingState on Account
    public Boolean validateBillingState(String strBillingState)
    {    
        /*system.debug('!!!!!!!!!!strBillingState'+strBillingState);
        system.debug('!!!!!!!!!!!acct.BillingCountry'+acct.BillingCountry);
        system.debug('!!!!!!!!objUser.UserType'+objUser.UserType);
        system.debug('!!!!!!!!!!!!!new'+!statesofCanada.contains(strBillingState));
        system.debug('!!!!!!!!!!newUSa'+!statesofUSA.contains(strBillingState));
        */
        
        /*(if(strBillingState == null  && objUser.UserType != 'Guest')
        {
            system.debug('$$$$Inserted');
            if(blnEnglish == true)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                        'Invalid Billing State - please provide a valid two letter abbreviation.'));
                }
                else if(blnFrench == true)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                        'Non valide état de facturation - veuillez fournir un valide abréviation à deux lettres.'));
                }   
                return false; 
        }*/
         if ((strBillingState != null  && objUser.UserType != 'Guest' && acct.BillingCountryCode == 'CA' && strBillingState.length() <= 2 && !statesofCanada.contains(strBillingState)))
        {
            //system.debug('!!!!!!!!!!Inserted');
        //if(blnEnglish == true)
                //{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                        'Invalid Billing State - please provide a valid two letter abbreviation.'));
                //}
                /*else if(blnFrench == true)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                        'Non valide état de facturation - veuillez fournir un valide abréviation à deux lettres.'));
                } */  
                return false;             
        }
        else if (strBillingState != null  && objUser.UserType != 'Guest' && acct.BillingCountryCode == 'US' && strBillingState.length() <= 2 && !statesofUSA.contains(strBillingState))
        {
            //system.debug('Inserted Here');
            //if(blnEnglish == true)
                //{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                        'Invalid Billing State - please provide a valid two letter abbreviation.'));
                //}
                /*else if(blnFrench == true)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                        'Non valide état de facturation - veuillez fournir un valide abréviation à deux lettres.'));
                }*/
                return false; 
        }
        else
        return true;
        }
}
   /* @isTest(SeeAllData=true)
        static void testAll(){
        TestObjects to = new TestObjects();
        Account acct = to.getPersonAccount(true);
        ProductRegistrationController prc = new ProductRegistrationController();
        prc.acct.FirstName = 'Joe';
        prc.acct.LastName = 'Bob';
        prc.acct.BillingStreet = '123 test st';
        prc.acct.BillingCity = 'Denver';
        prc.acct.BillingState = 'CO';
        prc.acct.BillingPostalCode = '80002';
        prc.acct.PersonEmail = 'm@test.org';
        prc.confirmEmail = 'm@test.org';
        prc.warranty.Product_Category__c = 'I dont see my product';
        prc.warranty.Serial__c = '123';
        prc.warranty.Where_did_you_purchase__c = 'test';
        prc.warranty.Web_Purchase_Date__c = date.today();
        prc.acct.Phone = '234-234-1123';
        prc.registrationSave();
    }*/