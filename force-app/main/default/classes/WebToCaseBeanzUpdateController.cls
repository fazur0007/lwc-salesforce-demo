public without sharing class WebToCaseBeanzUpdateController
{

    public String caseNumber{get;set;}
    public string strAccountId {get;set;}
    public string strProduct{get;set;}
    public string strCaseNumber{get;set;}
    public string strSubject{get;set;}
    public string strComment{get;set;}
    public boolean blnIsShow{get;set;}
    public string code {get; set;}
    public transient Boolean blnIsSucess{get;set;}
    public transient Boolean blnIsAttach{get;set;}
    public Attachment objAttach {get;set;}
    private CaseComment objCaseComment;
    private string strStoreCaseNumber;
    private Case objectCase1;
    public boolean blnSubmit;
    public boolean showButtons{get;set;}
    public Integer osize{get;set;}
    public Integer resultFileSize{get;set;}
    public transient Blob Attachbody{get;set;}
    public transient String Attachname{get;set;}
    public String brand{get;set;}
    public String region{get;set;}
    public String phoneNumber{get;set;}
    final private String defaultBrand = 'Breville';
    final private String defaultRegion = 'US';
    public String lang;
    
    public String googleSiteKey           {get;set;}
    private String googleSecretKey           {get;set;}
    private String googleRecaptchaVerifyEndpoint   {get;set;}
    private Decimal googleRecaptchaMinScore   {get;set;}

    public WebToCaseBeanzUpdateController()
    {
        objectCase1 = new Case();
        showButtons = false;
        blnIsShow = false;
        blnIsSucess = false;
        blnIsAttach = true;
        blnSubmit = false;
        objAttach = new Attachment();
        resultFileSize = 135000;

        brand = ApexPages.currentPage().getParameters().get('brand');
        if (brand == null || brand == '')
        {
            brand = defaultBrand;
        }

        region = ApexPages.currentPage().getParameters().get('param');
        lang = ApexPages.currentPage().getParameters().get('language');
        if (region == null || region == '')
        {
            region = defaultregion;
        }
        phoneNumber = 'CaseNumber_' + region;

        Region_Specific__mdt regionSpecific = [select MasterLabel, LanguageCode__c, EPParameter__c From Region_Specific__mdt Where EPParameter__c =: region];

        if (lang != null && lang != '')
        {
            code = lang;
            if (lang.equalsIgnoreCase('fr'))
            {
                if (region == 'CA')
                {
                    code = 'fr_CA';
                }
            }
        }
        else
        {
            code = regionSpecific.LanguageCode__c;
        }

        //read site key, secret and endpoint from Custom metadata
        for (All_Literal__mdt appliteral: [Select Id,DeveloperName,Value__c from All_Literal__mdt 
                        where DeveloperName IN ('GoogleReCaptchaEndPointBeanz', 'GoogleSecretkeyBeanz','GoogleSitekeyBeanz','Google_Recaptcha_Min_Score_Beanz')
            ])
        {

            if (appliteral.DeveloperName == 'GoogleSitekeyBeanz')
            {
                googleSiteKey = appliteral.Value__c;
            }
            else if (appliteral.DeveloperName == 'GoogleSecretkeyBeanz')
            {
                googleSecretKey = appliteral.Value__c;
            }
            else if (appliteral.DeveloperName == 'GoogleReCaptchaEndPointBeanz')
            {
                googleRecaptchaVerifyEndpoint = appliteral.Value__c;
            }
            else if (appliteral.DeveloperName == 'Google_Recaptcha_Min_Score_Beanz')
            {
                googleRecaptchaMinScore = Decimal.valueOf(appliteral.Value__c);
            }
        }
    }

    //Method for Autopopulating Case related information when CaseNumber is entered. 
    public pageReference searchCase()
    {

        blnIsAttach = true;
        showButtons = true;
        if (caseNumber != null && caseNumber != '')
        {

            String caseNumberString;
            caseNumber = caseNumber.toUpperCase();
            if (caseNumber.contains('BVL-') || caseNumber.startsWith('R'))
            {
                caseNumberString = caseNumber;
            }
            else
            {
                Integer caseNumberLength = caseNumber.length();
                Integer caseNumberLengthMinus8;
                Integer caseNumberLengthMinus9;
                if (caseNumberLength <= 8)
                {

                    caseNumberLengthMinus8 = 8 - caseNumberLength;
                    caseNumberString = caseNumber;
                    if (caseNumberLengthMinus8 != 0)
                    {
                        for (Integer i = 0; i < caseNumberLengthMinus8; i++)
                        {
                            caseNumberString = '0' + caseNumberString;
                        } //end for
                    } //end if
                    caseNumberString = 'BVL-' + caseNumberString;
                    caseNumberString = caseNumberString.replaceAll('\\s+', '');
                }
                else
                {
                    showButtons = false;
                    blnIsShow = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.LimitExceed));
                }
            }

            if (caseNumberString != null && caseNumberString != '')
            {
                list < Case > caseList = [SELECT Subject, Product__r.Description, CaseNumber, Account.Name, AccountId FROM Case WHERE CaseNumber =: caseNumberString];

                if (caseList != null && caseList.size() > 0)
                {
                    objectCase1 = caseList[0];
                    blnIsShow = true;

                    strAccountId = objectCase1.Account.Name;
                    strProduct = objectCase1.Product__r.Description;
                    strCaseNumber = objectCase1.CaseNumber;
                    strSubject = objectCase1.Subject;
                }
                else
                {
                    showButtons = false;
                    blnIsShow = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.DataNotAvailable));
                }
            }
        }
        else
        {
            showButtons = false;
            blnIsShow = false;

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.FieldMissing));
        }
        return null;
    } //end of method Search Case.

    //Method for Submitting Case related information to Case Comment.
    public pageReference submitCase()
    {
        blnIsAttach = true;
        //list<CaseComment> lstCaseComment = new list<CaseComment>();
        if (caseNumber != null && caseNumber != '' && blnIsShow == false)
        {
            //blnIsAttach= true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.GoButton));
        }
        else if (blnIsShow == false)
        {
            //blnIsAttach= true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.FieldMissing));
        } //end else if
        Boolean recaptchaValidation;
        //check for recaptcha
        if (Test.isRunningTest())
        {
            recaptchaValidation = true;
        }
        else
        {
            String response = ApexPages.currentPage().getParameters().get('response');
            system.debug('******'+response);
            recaptchaValidation = validateRecaptchaResponse(response);
            system.debug('recaptchaValidation ******'+recaptchaValidation);
        }
        if (!recaptchaValidation)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.Invalid_Captcha_Response));
            return null;
        }
        if (blnIsShow == true && strComment == '')
        {
            //blnIsAttach= true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                System.Label.RequiredFieldComment));
        }
        else if (objectCase1.id != null)
        {
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail = true;
            CaseComment objCaseComment = new CaseComment();
            objCaseComment.CommentBody = strComment;
            objCaseComment.ParentId = objectCase1.Id;
            objCaseComment.IsPublished = true;
            //lstCaseComment.add(objCaseComment);
            //insert objCaseComment;
            database.insert(objCaseComment, dlo);
            // }//end for

            //if(lstCaseComment.size()>0 && lstCaseComment!=null)
            // {
            // insert lstCaseComment;
            blnIsSucess = true;
            if (blnSubmit == false)
            {
                if (blnIsSucess)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,
                        System.Label.SuccessMessage + ' ' + brand + '. ' + System.Label.in_touch_message));
                } //end if
            } //end if
            //}//end if
        } //end else if
        return null;
    } //end of method submitCase

    //Method for Submitting Case related information to Case Comment and adding Attachment.
    public pageReference submitSaveAndAddAttachment()
    {
        blnSubmit = true;
        //blnIsAttach = true;
        blnIsSucess = false;
        submitCase();
        blnSubmit = false;
        //blnIsSucess=true;
        if (blnIsSucess)
            blnIsAttach = false;
        return null;
    }

    //Method for Uploading file. 
    public void Upload()
    {

        blnIsSucess = false;
        if (Attachbody != null && Attachname != null)
        {
            try
            {
                objAttach = new Attachment();
                objAttach.Body = Attachbody;
                objAttach.Name = Attachname;
                objAttach.ParentId = objectCase1.id;
                insert objAttach;
                blnIsSucess = true;
                objAttach = null;
            }
            catch (Exception e)
            {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }

        if (blnIsSucess)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, System.Label.SubmittingInquiry));
            blnIsAttach = true;
            blnIsSucess = true;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.ChooseFile));
            blnIsAttach = false;
            blnIsSucess = true;
        }

    }


    /*
            try{
                if(Attachbody != null && Attachname != null){
                    objAttach = new Attachment();
                    objAttach.Body = Attachbody;
                    objAttach.Name = Attachname;
                    objAttach.ParentId = objectCase1.id;
                    insert objAttach;
                    
                    objAttach = null;
                }
            }catch(Exception e){
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
            
            blnIsAttach = true;
            blnIsSucess = true;
            if(blnIsSucess){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,
                                                           System.Label.SubmittingInquiry));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                                                           System.Label.ChooseFile));
            }//end else
            //return null;
        }//end of method for uploading file 
        
     */
    public Boolean validateRecaptchaResponse(String response)
    {
        system.debug('googleRecaptchaVerifyEndpoint *****'+googleRecaptchaVerifyEndpoint );
        
        system.debug('googleSecretKey *****'+googleSecretKey);
        system.debug('response*****'+response);
        
        Boolean success = false;
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        String endpoint = googleRecaptchaVerifyEndpoint + '?secret=' + googleSecretKey + '&response=' + response;
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Content-Length', String.valueOf(req.getBody().length()));
        Http http = new Http();
        HTTPResponse res = http.send(req);
        Map < String, Object > responseParsedObject = (Map < String, Object > ) JSON.deserializeUntyped(res.getBody());
        system.debug('responseParsedObject:' + responseParsedObject );
        Decimal score = (Decimal) responseParsedObject.get('score');
        
        if(score != null && score > googleRecaptchaMinScore){
            success = (Boolean) responseParsedObject.get('success');
        }
        return success;
    }

}