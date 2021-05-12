/*
 * CreateShipmentHandler is class which operate from create shipping label button on Case
 *
 * Functionality :
 * (1) Creates the shipping label for canada post service using rest callout.
 * (2) Send email template with shipping label attachment to the customer.
 * (3) Create CanadaPostWebServiceHelp record with pdf link attached.
 * (4) Send different email template to the customer based on DRP account.
 * (5) Added logic to insert tracking label and its status
 * Version       Author             Date                  Description
 *  1.0        Yogesh Sharma      09/23/2015             Initial Draft
 *  1.1        Yogesh Sharma      09/29/2015            Functionality(4)
 *  1.2        Yogesh Sharma      06/24/2016            Functionality(5)
 */
public with sharing class CreateShipmentHandler {

    public static List<Case> lstobjCase;
    public static String strPDFLink , strRequestErr , strTrackingPin , strWt , strDimensions, intHeight= '', intWidth='', intLength='' ;
    public static double intWt;
    public static Id strCaseId;
    public static Http objhttp;
    public static HttpRequest req ;
    public static HttpResponse res ;
    public static boolean blnProcessing {get;set;}
    public String strError{get;set;}
    public static integer calloutcnt ;
    public static boolean blnNonDRP;

    //Constructor
    public CreateShipmentHandler(ApexPages.standardController controller){
        blnNonDRP = false;
        blnProcessing = true;
        strError ='';
    }//End CreateShipmentHandler

    /*** Queries for the case data necessary to create
     * shipping label on canada post.
     */
    public void getQueryResult(Id pstrCaseId){
        String fieldnames = ' ';
        String strSelectQuery ;
        Map<String, Schema.SObjectField> M = Schema.SObjectType.Case.fields.getMap();

        for(Schema.SObjectField s:m.values()){
            Schema.DescribeFieldResult sfield=s.getDescribe();
            fieldnames += s + ',';
        }//End for

        fieldnames = fieldnames.substring(0,fieldnames.length()-1);
        strSelectQuery = 'select '+ fieldnames + ',Contact.Id , Account.Name, Account.PersonEmail ,'+
            'Account.ShippingStreet, Account.ShippingStateCode, Account.ShippingPostalCode,'+
            'Account.ShippingCountryCode, Account.ShippingCity, Account.LastName, ' +
            'Account.FirstName , Product__r.Dimensions__c,Product__r.Weight__c ,'+
            'Product__r.Width__c, Product__r.Height__c,Product__r.Length__c,' +
            'Product__r.Name, Service_Center__r.Name, Service_Center__r.ShippingStreet,'+
            'Service_Center__r.ShippingStateCode, Service_Center__r.ShippingPostalCode,' +
            'Service_Center__r.ShippingCountryCode, Service_Center__r.ShippingCity, ' +
            'Service_Center__r.Business_Email__c'+
            ' from Case where Id = \''+ pstrCaseId +'\' LIMIT 1';

        lstobjCase = Database.query(strSelectQuery);
    }//End getQueryResult

    public pagereference init(){
        blnProcessing = true;
        calloutcnt = 0;
        strError ='';

        if(ApexPages.currentPage().getParameters().get('pdflink') != null){
            getQueryResult(ApexPages.currentPage().getParameters().get('id'));
            getShipmentPDfFromLink(ApexPages.currentPage().getParameters().get('pdflink'),ApexPages.currentPage().getParameters().get('id'));
            if(blnProcessing){
                pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+lstobjCase[0].Id);
                newpg.setRedirect(true);
                return newpg;
            }
            else{return null;}
        }else{
            CreateShipment(ApexPages.currentPage().getParameters().get('id'));
            if(blnProcessing){
                pagereference newpg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+lstobjCase[0].Id);
                newpg.setRedirect(true);
                return newpg;
            }
            else{return null;}
        }//End if-else
    }//End init

    public void CreateShipment(Id caseId){
        strCaseId = caseId;
        strRequestErr = ''; strTrackingPin = ''; strWt =''; strDimensions= '';
        intWt = 0.00;
        getQueryResult(caseId);
        if(lstobjCase !=null && lstobjCase.size() > 0 ){

            if(lstobjCase[0].Product__r.Dimensions__c !=null)
                strDimensions = String.valueof(lstobjCase[0].Product__r.Dimensions__c);
            else
                strDimensions = '';

            if(lstobjCase[0].Product__r.Weight__c !=null)
                intWt = lstobjCase[0].Product__r.Weight__c;
            else
                intWt = 001.00;

            if(lstobjCase[0].Product__r.Width__c !=null) intWidth = '';
            if(lstobjCase[0].Product__r.Height__c !=null) intHeight = '';
            if(lstobjCase[0].Product__r.Length__c !=null) intLength = '' ;
        }//End if

        CreateAuthorizeReturn();
        if(strPDFLink !=null && strPDFLink !=''){
            getShipmentPDF(strPDFLink ,strCaseId );
        }//End if
    }//End CreateShipment

    //Method to Make CreateAuthorizeReturn Rest Callout
    public void CreateAuthorizeReturn(){
        objhttp = new Http();
        req = new HttpRequest();
        res = new HttpResponse();
        String strName = '';
        String strAddressLine ='';
        String strCity = '';
        String strPostalCode = '';
        String strEmail = '';
        String strShippingState = '';
        String strReceiverName = '';
        String strRecAddressLine = '';
        String strRecCity = '';
        String strRecPostalcode = '';
        String strRecShippingstate = '';

        if(lstobjCase[0].Account.PersonEmail != null )
            strEmail = lstobjCase[0].Account.PersonEmail;
        else
            strEmail = System.label.DefaultEmail;

        if(lstobjCase[0].Account.FirstName !=null )
            strName = lstobjCase[0].Account.FirstName;
        else
            strName = System.label.DefaultAccName;

        if(lstobjCase[0].Account.LastName !=null )
            strName = strName + lstobjCase[0].Account.LastName;

        if(lstobjCase[0].Account.ShippingStreet != null)
            strAddressLine = lstobjCase[0].Account.ShippingStreet;
        else
            strAddressLine = System.label.DefaultAddressLine;

        if(lstobjCase[0].Account.ShippingCity != null)
            strCity = lstobjCase[0].Account.ShippingCity;
        else
            strCity = System.label.DefaultCity;

        if(lstobjCase[0].Account.ShippingPostalCode!= null)
            strPostalCode = String.valueof(lstobjCase[0].Account.ShippingPostalCode );
        else
            strPostalCode = System.Label.PostalCode;

        if(lstobjCase[0].Account.ShippingStateCode != null)
            strShippingState = lstobjCase[0].Account.ShippingStateCode;
        else
            strShippingState = System.Label.DefaultState;

        if(lstobjCase[0].Service_Center__r.Name !=null )
            strReceiverName = lstobjCase[0].Service_Center__r.Name;
        else
            strReceiverName = System.Label.ReceiverName;

        if(lstobjCase[0].Service_Center__r.ShippingStreet != null)
            strRecAddressLine = lstobjCase[0].Service_Center__r.ShippingStreet;
        else
            strRecAddressLine = System.Label.AddressLine;

        if(lstobjCase[0].Service_Center__r.ShippingCity != null)
            strRecCity = lstobjCase[0].Service_Center__r.ShippingCity;
        else
            strRecCity = System.Label.City;

        if(lstobjCase[0].Service_Center__r.ShippingPostalCode!= null)
            strRecPostalcode = String.valueof(lstobjCase[0].Service_Center__r.ShippingPostalCode);
        else
            strRecPostalcode = System.Label.PostalCode;

        if(lstobjCase[0].Service_Center__r.ShippingStateCode != null)
            strRecShippingstate = lstobjCase[0].Service_Center__r.ShippingStateCode;
        else
            strRecShippingstate = System.Label.DefaultState;
        system.debug('strName*******'+strName);
        system.debug('strAddressLine*******'+strAddressLine);
        system.debug('strCity*******'+strCity);
        system.debug('strShippingState*****'+strShippingState);
        system.debug('strPostalCode.trim()*****'+strPostalCode.trim());

        system.debug('strReceiverName*******'+strReceiverName);
        system.debug('strRecAddressLine*******'+strRecAddressLine);
        system.debug('strRecCity*******'+strRecCity);
        system.debug('strRecShippingState*****'+strRecShippingState);
        system.debug('strRecPostalcode.trim()*****'+strRecPostalcode.trim());
        String reqBody ='<authorized-return xmlns="http://www.canadapost.ca/ws/authreturn">'+
            '<service-code>'+ System.Label.service_code +'</service-code>'+
            '<returner>'+
            '<name>'+ strName +'</name>'+
            '<domestic-address>'+
            '<address-line-1>'+ strAddressLine +'</address-line-1>'+
            '<city>'+ strCity +'</city>'+
            '<province>'+ strShippingState +'</province>'+
            '<postal-code>'+ strPostalCode.trim() +'</postal-code>'+
            '</domestic-address>'+
            '</returner>'+
            '<receiver>'+
            '<name>'+ strReceiverName + '</name>'+
            '<domestic-address>'+
            '<address-line-1>'+ strRecAddressLine + '</address-line-1>'+
            '<city>'+ strRecCity + '</city>'+
            '<province>'+ strRecShippingState + '</province>'+
            '<postal-code>'+ strRecPostalcode.trim() + '</postal-code>'+
            '</domestic-address>'+
            '</receiver>'+
            '<parcel-characteristics>'+
            '<weight>'+ intWt +'</weight>';

        /*if((intLength !=null && intWidth !=null && intHeight !=null) ||
           (intLength ==null && intWidth !=null && intHeight !=null) ||
           (intLength !=null && intWidth ==null && intHeight !=null) ||
           (intLength !=null && intWidth ==null && intHeight ==null)
           ){
            if (intLength == null) intLength = '';
            if (intWidth == null) intWidth = '';
            if (intHeight == null) intHeight = '';
            
            reqBody = reqBody +
                '<dimensions>'+
                '<length>'+ intLength +'</length>'+
                '<width>'+ intWidth +'</width>'+
                '<height>'+ intHeight +'</height>'+
                '</dimensions>';
        system.debug('**********0'+reqBody);
        }else{
            reqBody = reqBody;
        }//End if-else*/

     //if((intLength !=null && intWidth !=null && intHeight !=null)){
        /*    intLength = '';
            intWidth = '';
            intHeight = '';
            
            reqBody = reqBody +
                '<dimensions>'+
                '<length>'+ intLength +'</length>'+
                '<width>'+ intWidth +'</width>'+
                '<height>'+ intHeight +'</height>'+
                '</dimensions>';
        system.debug('**********0'+reqBody);
        //}else{*/
            reqBody = reqBody;
       // }//End if-else

        reqBody =  reqBody + '</parcel-characteristics>'+
            '<print-preferences>'+
            '<output-format>8.5x11</output-format>'+
            '<encoding>PDF</encoding>'+
            '<show-packing-instructions>true</show-packing-instructions>'+
            '</print-preferences>'+
            '<settlement-info>'+
            '<paid-by-customer>'+ System.Label.CustomerNumber.trim() +'</paid-by-customer>'+
            '<contract-id>'+ System.Label.ContractID.trim() +'</contract-id>'+
            '</settlement-info>'+
            '<references><customer-ref-1>'+ lstobjCase[0].Id +'</customer-ref-1>'+
            '<customer-ref-2>'+ lstobjCase[0].CaseNumber +'</customer-ref-2></references>'+
            '<notifications>'+
            '<notification>'+
            '<email>'+ strEmail +'</email>'+
            '<on-shipment>true</on-shipment>'+
            '<on-exception>true</on-exception>'+
            '<on-delivery>true</on-delivery>'+
            '</notification>'+
            '</notifications>'+
            '</authorized-return>';
        system.debug('reqBody****'+reqBody);
        req.setMethod('POST');
        req.setEndpoint(System.Label.AUTHORIZERETURNENDPOINT.trim()+System.Label.CustomerNumber.trim() +'/' +
                        System.Label.CustomerNumber.trim() +'/'+ System.Label.AUTHORIZERETURNName.trim());
        string endpoint=System.Label.AUTHORIZERETURNENDPOINT.trim()+System.Label.CustomerNumber.trim() +'/' +System.Label.CustomerNumber.trim() +'/'+ System.Label.AUTHORIZERETURNName.trim();
        system.debug('************'+endpoint);
        Blob headerValue = Blob.valueOf(System.Label.UserName.trim() + ':' + System.Label.Password.trim());
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Accept','application/vnd.cpc.authreturn+xml');
        req.setHeader('Content-type','application/vnd.cpc.authreturn+xml; charset=UTF-8');
        req.setHeader('Accept-Language', 'en-CA');
        req.setTimeout(120000);
        req.setBody(reqBody);
        system.debug('----Request--' + req);
        system.debug('--Req Body--' + reqBody);
        if (!Test.isRunningTest()){
            try{
                res = objhttp.send(req);
                calloutcnt++;
            }catch(System.CalloutException e){
                strError = e.getMessage();
                blnProcessing = false;
            }//End try-catch
        }else{
            res.setStatus('OK');
            res.setStatusCode(200);
            String strResponse = '<authorized-return-info>'+
                '<tracking-pin>12345678901234</tracking-pin>'+
                '<links>'+
                '<link href="https://ct.soa-gw.canadapost.ca/ers/artifact/76108cb5192002d5/21238/0" rel="returnLabel" media-type="application/pdf" index="0"></link>'+
                '</links>'+
                '</authorized-return-info>';
            res.setHeader('Content-Type', 'application/vnd.cpc.shipment-v4+xml; charset=UTF-8');
            res.setBody(strResponse);
        }//End if-else

        if(res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200){
            parseXMLReturnResponse(res.getBody());
        }else{
            strError = system.label.Error400;
            //strError = strError +  res.toString();
            System.debug(res.toString());
            System.debug(res.getBody());
            blnProcessing = false;
        }//End if-else
    }//End CreateAuthorizeReturn

    // Method to parse the XML response of GetAuthorize Return Api Call
    public void parseXMLReturnResponse(String strResponse){
        XmlStreamReader reader = new XmlStreamReader(strResponse);
        while(reader.hasNext()){
            if('links' == reader.getLocalName() && reader.getEventType() == XmlTag.END_ELEMENT){
                break;
            }//End if

            if('tracking-pin' == reader.getLocalName()){
                reader.next();
                if(reader.getEventType() == XmlTag.CHARACTERS){
                    strTrackingPin = reader.getText();
                }//End if
            }//End if

            if('link' == reader.getLocalName() && reader.getEventType() == XmlTag.START_ELEMENT){
                String strLabel = reader.getAttributeValue(null, 'rel');
                if(strLabel =='returnLabel'){
                    strPDFLink = reader.getAttributeValue(null, 'href');
                }//End if
            }//End if
            reader.next();
        }//End while
        if(strPDFLink == null ) strPDFLink = '';
    }//parseXMLReturnResponse

    public void getShipmentPDfFromLink(String pLink , Id pstrCaseId){

        if(pLink != '' || pLink !=null){
            objhttp = new Http();
            req = new HttpRequest();
            res = new HttpResponse();
            req.setMethod('GET');
            req.setEndpoint(pLink );
            Blob headerValue = Blob.valueOf(System.Label.UserName + ':' + System.Label.Password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Accept','application/pdf');
            req.setHeader('Accept-Language', 'en-CA');
            req.setTimeout(120000);
            try{
                if(!Test.isRunningTest()){
                    res = objhttp.send(req);
                }else{
                    res.setHeader('Content-Type', 'application/pdf');
                    res.setBody('TEST PDF');
                    res.setStatusCode(200);
                    res.setStatus('OK');
                }//End if-else
                calloutcnt++;
                if(res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200){
                    Blob beforeBlob = res.getBodyAsBlob();
                    Attachment objAttachmnt = new Attachment(parentId = pstrCaseId ,
                                                             name= System.label.AttachmentName, body = beforeBlob);
                    insert objAttachmnt;
                    if(objAttachmnt.Id != null){
                        CanadaPostWebServiceHelp__c objHelper = [select Name ,
                                                                 Is_Shipping_Label_Created__c ,
                                                                 PDFLink__c
                                                                 from CanadaPostWebServiceHelp__c
                                                                 where Name = :lstobjCase[0].CaseNumber LIMIT 1 ];
                        objHelper.Is_Shipping_Label_Created__c = true ;
                        objHelper.PDFLink__c = pLink;
                        update objHelper;
                        sendemailToCustomer(beforeBlob);
                    }else{
                        blnProcessing = false;
                    }
                }else if(res.getStatus().equalsIgnoreCase('Accepted') && res.getStatusCode() == 202){
                    if(calloutcnt >= 9 ){
                        blnProcessing = false;
                        CanadaPostWebServiceHelp__c objHelper = [select Name ,
                                                                 Is_Shipping_Label_Created__c ,
                                                                 PDFLink__c
                                                                 from CanadaPostWebServiceHelp__c
                                                                 where Name = :lstobjCase[0].CaseNumber LIMIT 1];
                        objHelper.Is_Shipping_Label_Created__c = false ;
                        objHelper.PDFLink__c = pLink;
                        update objHelper;
                        strError = System.label.ErrorMessage;
                    }else{
                        getShipmentPDfFromLink(pLink ,pstrCaseId );
                    }//End if-else
                }//End if-else-if
            }catch(System.CalloutException e) {
                System.debug(res.toString());
                strError = strError + res.toString() + e.getMessage();
                blnProcessing = false;
            }//End try-catch
        }//End if
    }//End getShipmentPDfFromLink

    // Method to make GetArtifact Rest Api Callout // Use to retrive PDF from 1 st callout
    public void getShipmentPDF(String pLink , Id pstrCaseId ){
        if(pLink != '' || pLink !=null){
            objhttp = new Http();
            req = new HttpRequest();
            res = new HttpResponse();
            req.setMethod('GET');
            req.setEndpoint(pLink );
            Blob headerValue = Blob.valueOf(System.Label.UserName + ':' + System.Label.Password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Accept','application/pdf');
            req.setHeader('Accept-Language', 'en-CA');
            req.setTimeout(120000);
            try{
                if(!Test.isRunningTest()){
                    res = objhttp.send(req);
                }else{
                    res.setHeader('Content-Type', 'application/pdf');
                    res.setBody('TEST PDF');
                    res.setStatusCode(200);
                    res.setStatus('OK');
                }//End if-else
                calloutcnt++;
                if(res.getStatus().equalsIgnoreCase('OK') && res.getStatusCode() == 200){
                    Blob beforeBlob = res.getBodyAsBlob();
                    Attachment objAttachmnt = new Attachment(parentId = pstrCaseId ,
                                                             name= 'AuthorizeReturn.pdf', body = beforeBlob);
                    insert objAttachmnt;

                    //Added logic to insert tracking label and its status
                    system.debug('strTrackingPin********'+strTrackingPin);
                    if(strTrackingPin  <> NULL && String.isNotBlank(strTrackingPin)){
                        list<case> lstCaseToUpdate = new list<case>();
                        for(Case objCase: lstobjCase){
                            objCase.RA_Tracking__c = strTrackingPin;
                            objCase.RA_Tracking_Status__c =System.label.Tracking_Status;
                            lstCaseToUpdate.add(objCase);
                        }// end for
                        if(lstCaseToUpdate <> NULL && !lstCaseToUpdate.isEmpty()){
                            update lstCaseToUpdate;
                        }
                    }// end if

                    if(objAttachmnt.Id != null){
                        List<CanadaPostWebServiceHelp__c>  lstHelper = [select Name ,
                                                                        Is_Shipping_Label_Created__c ,
                                                                        PDFLink__c
                                                                        from CanadaPostWebServiceHelp__c
                                                                        where Name = :lstobjCase[0].CaseNumber LIMIT 1];
                        if(lstHelper.size() == 0){
                            CanadaPostWebServiceHelp__c objHelper = new CanadaPostWebServiceHelp__c();
                            objHelper.Name = lstobjCase[0].CaseNumber;
                            objHelper.Is_Shipping_Label_Created__c = true ;
                            objHelper.PDFLink__c = pLink;
                            insert objHelper;
                        }else{
                            lstHelper[0].Name = lstobjCase[0].CaseNumber ;
                            lstHelper[0].Is_Shipping_Label_Created__c = true ;
                            lstHelper[0].PDFLink__c = pLink;
                            update lstHelper;
                        }//End if-else
                        sendemailToCustomer(beforeBlob);
                    }else{
                        blnProcessing = false;
                    }//End if-else
                }else if(res.getStatus().equalsIgnoreCase('Accepted') && res.getStatusCode() == 202){
                    if(calloutcnt >= 9){
                        blnProcessing = false;
                        List<CanadaPostWebServiceHelp__c>  lstHelper = [select Name ,
                                                                        Is_Shipping_Label_Created__c ,
                                                                        PDFLink__c
                                                                        from CanadaPostWebServiceHelp__c
                                                                        where Name = :lstobjCase[0].CaseNumber LIMIT 1];
                        if(lstHelper.size() == 0){
                            CanadaPostWebServiceHelp__c objHelper = new CanadaPostWebServiceHelp__c();
                            objHelper.Name = lstobjCase[0].CaseNumber;
                            objHelper.Is_Shipping_Label_Created__c = false ;
                            objHelper.PDFLink__c = pLink;
                            insert objHelper;
                        }else{
                            lstHelper[0].Name = lstobjCase[0].CaseNumber ;
                            lstHelper[0].Is_Shipping_Label_Created__c = false ;
                            lstHelper[0].PDFLink__c = pLink;
                            update lstHelper;
                        }//End if-else
                        strError = System.label.ErrorMessage;
                    }else{
                        getShipmentPDF(pLink ,pstrCaseId );
                    }//End if-else
                }//End if-else-if
            }catch(System.CalloutException e){
                System.debug(res.toString());
                strError = strError + res.toString() + e.getMessage();
                blnProcessing = false;
            }//End try-catch
        }//End if
    }//End getShipmentPDF

    // Method to send email to Customber with generated PDF as attachment and using email template
    public void sendemailToCustomer(Blob PDFBody){

        EmailTemplate template = new EmailTemplate();

        if(lstobjCase[0].Service_Center__r.Name!=null && lstobjCase[0].Service_Center__r.Name.contains(System.label.DRPAccount)){
            template = [SELECT Id,
                        Subject,
                        HtmlValue,
                        Body
                        FROM EmailTemplate
                        WHERE DeveloperName =: System.label.DRPTemplate LIMIT 1];
        }else if(lstobjCase[0].Service_Center__r.Name!=null && !lstobjCase[0].Service_Center__r.Name.contains(System.label.DRPAccount)){
            if(lstobjCase[0].Warranty__c == System.label.InWarranty){
                blnNonDRP = true;
                template = [SELECT Id,
                            Subject,
                            HtmlValue,
                            Body
                            FROM EmailTemplate
                            WHERE DeveloperName =: System.label.WithWarrantyTemplate LIMIT 1];
            }else if(lstobjCase[0].Warranty__c == System.label.OutWarranty){
                blnNonDRP = true;
                template = [SELECT Id,
                            Subject,
                            HtmlValue,
                            Body
                            FROM EmailTemplate
                            WHERE DeveloperName =: System.label.NoWarrantyTemplate LIMIT 1];
            }//End if-else
        }//End if-else-if

        if(template.Id!=null && !String.isBlank(lstobjCase[0].Account.PersonEmail)){
            String[] BccAddress = new String[]{};
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(System.label.AttachmentName);
            efa.setBody(PDFBody);
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setTemplateId(template.Id);
            //msg.setToAddresses(toAddresses);
            if(!String.isBlank(lstobjCase[0].Service_Center__r.Business_Email__c))
                BccAddress.add(lstobjCase[0].Service_Center__r.Business_Email__c);
            msg.setBccAddresses(BccAddress);
            msg.setTargetObjectId(lstobjCase[0].ContactId);
            msg.setWhatId(lstobjCase[0].id);
            msg.setFileAttachments(new Messaging.EmailFileattachment[]{efa});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });

            /* String subject = template.Subject;
               String htmlBody = template.Body;
               String strFirstName;
               String strLastName;
               String strAccName;
               if(lstobjCase[0].Account.FirstName != null )
               strFirstName = lstobjCase[0].Account.FirstName;
               else
               strFirstName = '';

               if(lstobjCase[0].Account.LastName != null )
               strLastName = lstobjCase[0].Account.LastName;
               else
               strLastName = '';

               strAccName = strFirstName + ' ' + strLastName;
               if(strAccName!= '' )
               htmlBody = htmlBody.replace('{!Case.Account}', strAccName);

               if(lstobjCase[0].CaseNumber != null )
               htmlBody = htmlBody.replace('{!Case.CaseNumber}', lstobjCase[0].CaseNumber);

               if(blnNonDRP == true){
               if(lstobjCase[0].Product__r.Name != null )
               htmlBody = htmlBody.replace('{!Case.Product__c}', lstobjCase[0].Product__r.Name);
               if(lstobjCase[0].Batch_Code__c != null )
               htmlBody = htmlBody.replace('{!Case.Batch_Code__c}', lstobjCase[0].Batch_Code__c);
               if(lstobjCase[0].Service_Center__r.Name != null )
               htmlBody = htmlBody.replace('{!Case.Service_Center__c}', lstobjCase[0].Service_Center__r.Name);
               if(lstobjCase[0].Service_Center_Phone__c != null )
               htmlBody = htmlBody.replace('{!Case.Service_Center_Phone__c}', lstobjCase[0].Service_Center_Phone__c);
               }//End if

               Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
               email.setSubject(subject);
               // email.setPlainTextBody(htmlBody);
               email.setPlainTextBody(htmlBody);
               String[] toAddresses = new String[]{};
               String[] BccAddress = new String[]{};
               if(lstobjCase[0].Account.PersonEmail != null )
               toAddresses.add(lstobjCase[0].Account.PersonEmail);
               else
               toAddresses.add(System.label.DefaultEmail);

               email.setToAddresses(toAddresses);

               if(lstobjCase[0].Service_Center__r.Business_Email__c != null )
               BccAddress.add(lstobjCase[0].Service_Center__r.Business_Email__c);

               email.setBccAddresses(BccAddress);

               Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
               efa.setFileName(System.label.AttachmentName);
               efa.setBody(PDFBody);

               email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});*/

        }//End If
    }//End sendemailToCustomer

}//End CreateShipmentHandler