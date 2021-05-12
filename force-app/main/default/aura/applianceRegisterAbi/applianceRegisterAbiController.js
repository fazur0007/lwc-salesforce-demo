({
    handleUploadFinished1 : function (component, event, helper) {
        console.log("Inside of fileupload method"); 
        component.set('v.isFileUploaded' , false);
        helper.handleUploadFinishedHelper(component, event, helper);
    },  
    previewFile :function(component, event, helper){
    var selectedPillId = event.getSource().get("v.name");
    $A.get('e.lightning:openFiles').fire({
            recordIds: [selectedPillId]
            });
	},
    doPopulateBatchCodeImage :function(component, event, helper){
        component.set("v.openModal",true);
    },
    handleCloseModal: function(component, event, helper) {
        component.set("v.openModal", false);
    },
	removeFile :function(component, event, helper){
        event.preventDefault();
        helper.helperRemoveAttachment(component, event, helper);
	},
    
     navigateToBrevilleHome:function(component, event, helper){
        let brevilleHomeUrl = component.get("v.backToBrevilleUrl");
        window.open(brevilleHomeUrl,'_top');
    },
  
    doinit : function(component, event, helper) {
        var objDetails = component.get("v.objDetail");
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        
        //Progress indicator - start
        let circle = component.find('circle2');
        let label = component.find('label2');
        $A.util.toggleClass(circle, 'activeStep');
        $A.util.toggleClass(circle, 'activeBackground');
        $A.util.removeClass(circle, 'inactiveStep');        
        $A.util.toggleClass(label, 'activeLabel');
        //Progress indicator -end
        
        helper.fetchPicklistValues(component, event, helper,objDetails,controllingFieldAPI, dependingFieldAPI);
        
        helper.helperMethodForProduct(component, event, helper);
        // Rajan Code 
        helper.doInitHelper(component, event, helper);
        helper.getCountryOptions(component, event);
        helper.getStatePicklistValues(component, event);
        //  helper.doInitHelper(component, event);
        component.set("v.provinceOptions", helper.getProvinceOptions(component.get("v.country")));
        document.addEventListener("grecaptchaVerified", function(e) {
            component.set('v.recaptchaResponse', e.detail.response);
            component.set("v.captchaVerify", true);
            
            component.set('v.hideCaptcha' , false);
            // myButton = component.find("myButton");
            //myButton.set('v.disabled', false);
            //alert(123);
        });
        
        document.addEventListener("grecaptchaExpired", function() {
            //let myButton = component.find("myButton");
            //myButton.set('v.disabled', true);
            console.log('Ji');
            component.set("v.captchaVerify", false);
        }); 
        
    },
    onRender: function (component, event, helper){ 
        //valide values for badge: bottomright bottomleft inline
        document.dispatchEvent(new CustomEvent("grecaptchaRender", { "detail" : { element: 'recaptchaCheckbox'} }));
    },
    
    goOnApplianceRegisterSummary : function(component, event, helper) { 
        console.log('Hi Value');
        
        
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();   
        if(dd < 10){
            dd = '0' + dd;
        }  
        if(mm < 10){
            mm = '0' + mm;
        }
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(component.get("v.newAccount.PersonBirthdate") != '' && component.get("v.newAccount.PersonBirthdate") <= todayFormattedDate){
            component.set("v.dateValidationErrorForDOB" , false);
        }
        else if (component.get("v.newAccount.PersonBirthdate") === '' || component.get("v.newAccount.PersonBirthdate") === undefined){
            //component.set("v.dateValidationErrorForDOBPast" , false);
            component.set("v.dateValidationErrorForDOB" , true);
            
        }
            else{
                //component.set("v.dateValidationErrorForDOB" , false);
                component.set("v.dateValidationErrorForDOBPast" , true);
                
            }
        var isDateError = component.get("v.dateValidationErrorForDOB");
        if(isDateError != true){
            //   alert('date is valid****'+component.get("v.newAccount.PersonBirthdate"));
        }
        
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();   
        if(dd < 10){
            dd = '0' + dd;
        }  
        if(mm < 10){
            mm = '0' + mm;
        }
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(component.get("v.saveInAsset.PurchaseDate") != '' && component.get("v.saveInAsset.PurchaseDate") <= todayFormattedDate){
            component.set("v.dateValidationError" , false);
        }
        else if (component.get("v.saveInAsset.PurchaseDate") === ''){
            //component.set("v.dateValidationErrorPast" , false);
            component.set("v.dateValidationError" , true);
            
        }
            else{
                // component.set("v.dateValidationError" , false);
                component.set("v.dateValidationErrorPast" , true);
                
            }
        var isDateError = component.get("v.dateValidationError");
        if(isDateError != true){
            //   alert('date is valid****'+component.get("v.saveInAsset.PurchaseDate"));
        }        
        
        var fileUploaderValue = component.get("v.uploadedFileName")
        //var fileUploaderValue = fileUploaderId.get("v.value");
        //var fileUploaderValue = event.getSource().get("v.name");
        if(fileUploaderValue ==='' || fileUploaderValue === undefined){
          //  alert('error in file upload');
          component.set('v.isFileUploaded' , true);
        } 
        if( fileUploaderValue != ""){
          //  alert('error in file upload');
          component.set('v.isFileUploaded' , false);
        }        
        /* var blank=0;
        if(CountryValue.length!=undefined) {
            var allValid = contactFields.reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
            if (!allValid) {
                blank++;
            }
        }*/
        
        
        /*    var dropVali = component.find("mySelect");
        var datepk = component.find("mySelect");
        console.log("dropVali>>>>",dropVali.selectedIndex); 
        var nii = component.find("formFieldToValidated");
        helper.validateSelectedDate(nii,'{!v.newAccount.PersonBirthdate}');
        if(!dropVali.get('v.value')){
            dropVali.set("v._error", true);
      dropVali.set("v._errorMessage", "Date cannot be future date");
             //dropVali.set('v.validity', {valid:false, badInput :true});
        	//dropVali.showHelpMessageIfInvalid();
        } */
     
        
        var contactFields = component.find("formFieldToValidate");
        if(contactFields.length!=undefined)
            var blank=0;
        if(contactFields.length!=undefined) {
            var allValid = contactFields.reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
            if (!allValid || component.get("v.dateValidationErrorPast") || component.get("v.dateValidationErrorForDOBPast") ) {
                blank++;
            }
        } else {
            var allValid = contactFields;
            if (!allValid.get('v.validity').valid) {
                blank++;
            }
        }
        if(blank==0) {
            //helper.helperMethodForProductRegister(component, event, helper);
        }
        
        var selectedSubProductId = component.find("selectedSubProductId");
        var selectedSubProductValue = selectedSubProductId.get("v.value");
        var selectedSubProductValue = component.find("selectedSubProductId").get("v.value");
        var selectedModelValue = component.find("selectedModelId").get("v.value");
        var placeOfPurchaseValue = component.find("placeOfPurchaseId").get("v.value");
        console.log('selectedSubProductId>>>>',selectedSubProductId);
        console.log('selectedSubProductValue>>>>',selectedSubProductValue);
        if(selectedSubProductValue ==='' || selectedSubProductValue === undefined){
             var cmpDiv = component.find('enableSubProductError');
        	$A.util.addClass(cmpDiv, 'slds-has-error');
            component.set('v.hideSubProduct' , true);
        } 
        if(selectedModelValue ==='' || selectedModelValue === undefined){
            var cmpDiv = component.find('enableModelError');
        	$A.util.addClass(cmpDiv, 'slds-has-error');
            component.set('v.hideModel' , true);
        }  
        if(placeOfPurchaseValue ==='' || placeOfPurchaseValue === undefined){
            var cmpDiv = component.find('enablePlaceOfPurchaseError');
        	$A.util.addClass(cmpDiv, 'slds-has-error');
            component.set('v.hidePlaceOfPurchase' , true);
        }
        if(selectedSubProductValue !='' && selectedModelValue !='' && placeOfPurchaseValue !='' &&  !component.get("v.isFileUploaded") ){
            component.set('v.intCurrentStep', 3);
        	helper.updateCss(component, event, helper);
            helper.helperMethodForProductRegister(component, event, helper);
        }
    }, 
    validateDateForDOB : function(component, event, helper) {
        
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(component.get("v.newAccount.PersonBirthdate") != '' && component.get("v.newAccount.PersonBirthdate") > todayFormattedDate){
            //  component.set("v.dateValidationErrorForDOB" , false);
            component.set("v.dateValidationErrorForDOBPast" , true);
            component.set("v.dateValidationErrorForDOB" , false);
        }else{
            component.set("v.dateValidationErrorForDOBPast" , false);
            component.set("v.dateValidationErrorForDOB" , false);
        }
    },
    
    validateDate : function(component, event, helper) {
        
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(component.get("v.saveInAsset.PurchaseDate") != '' && component.get("v.saveInAsset.PurchaseDate") > todayFormattedDate){
            //component.set("v.dateValidationError" , false);            
            component.set("v.dateValidationErrorPast" , true);
            component.set("v.dateValidationError" , false);
            
        }else{
            component.set("v.dateValidationErrorPast" , false);
            component.set("v.dateValidationError" , false);
        }
    },
    
    //Product Indicator
    /*   component.set('v.intCurrentStep', component.get('v.intCurrentStep') + 1);
        helper.updateCss(component, event, helper);
      
        if(fName ==='' || fName === undefined){
            helper.customValidation(component, event, firstName);
            return;
        }
        else if(lName ==='' || lName === undefined){
            helper.customValidation(component, event, lastName);
            return;
        } */
    //helper.helperMethodForProductSummary(component, event, helper);
    // helper.helperMethodForProductRegister(component, event, helper);
    
    
    goRegistrationSummary : function(component, event,helper) {
        
        var count;
        var captchaVerify =  component.get("v.captchaVerify");
        
        var PhoneId = component.find("PhoneId");
        var Phonevalue = PhoneId.get("v.value");
        var AddressLineId = component.find("AddressLineId");
        var AddressLinevalue = AddressLineId.get("v.value");
        var CountryId = component.find("CountryId");
        var CountryValue = CountryId.get("v.value");
        var stateId = component.find("stateId");
        var stateValue = stateId.get("v.value");
        var BillingCityId = component.find("BillingCityId");
        var BillingCityValue = BillingCityId.get("v.value");
        var PostalCodeId = component.find("PostalCodeId");
        var PostalCodeValue = PostalCodeId.get("v.value");
        if(Phonevalue == undefined || Phonevalue == '' ){
            var StringValue = $A.get("$Label.c.Mandatory_field_error_PDPage");
            helper.customValidation(component, event, PhoneId,StringValue);
        }
        if(AddressLinevalue ==='' || AddressLinevalue === undefined){
            var StringValue = $A.get("$Label.c.Mandatory_field_error_PDPage");
            helper.customValidation(component, event, AddressLineId,StringValue);
        }
        if(CountryValue ==='' || CountryValue === undefined || CountryValue == 'false'){
            var cmpDiv = component.find('enableCountryError');
        	$A.util.addClass(cmpDiv, 'slds-has-error');
            component.set('v.hideCountry' , true);
        }
        if(stateValue === 'false' || stateValue === undefined || stateValue == ''){
            var cmpDiv = component.find('enableStateError');
        	$A.util.addClass(cmpDiv, 'slds-has-error');
            component.set('v.hideState' , true);
        }
        
        if(BillingCityValue ==='' || BillingCityValue === undefined){
            var StringValue = $A.get("$Label.c.Mandatory_field_error_PDPage");
            helper.customValidation(component, event, BillingCityId,StringValue);
        }
        if(PostalCodeValue ==='' || PostalCodeValue === undefined){
            var StringValue = $A.get("$Label.c.Mandatory_field_error_PDPage");
            helper.customValidation(component, event, PostalCodeId,StringValue);
        }
        if(!captchaVerify){
            component.set('v.hideCaptcha' , true);
        }
        if(Phonevalue !== undefined && Phonevalue !== '' ){
            if(AddressLinevalue !== '' && AddressLinevalue !== undefined){
                if(CountryValue !== '' && CountryValue != undefined && CountryValue !== 'false'){                
                    if(stateValue !== undefined && stateValue !== '' && stateValue !== 'false' ){
                        if(BillingCityValue !== '' && BillingCityValue !== undefined){
                            if(PostalCodeValue !== '' && PostalCodeValue !== undefined){
                                if(captchaVerify){
                                    component.set('v.intCurrentStep', 4);
        							helper.updateCss(component, event, helper);
                                    helper.helperMethodForProductRegistrationSummery(component, event,helper);
                                    return true;
                                }
                            }
                        }
                    }
                }
            }
        }
        /*if(stateValue != '' && CountryValue != '' && Phonevalue != '' && AddressLinevalue != '' && BillingCityValue != '' && PostalCodeValue != ''){
            helper.updateCss(component, event, helper);
            helper.helperMethodForProductRegistrationSummery(component, event,helper);
            return true;
        }*/
        /*const requiredFields = component.find('fieldId') || [];
        
        requiredFields.every(e => {
            if (!e.get('v.value')) {
             
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
            		title : 'Error',
           			message:e.get('v.fieldName') + ': Field is Required',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
            		 
                });
                toastEvent.fire();
        		return false;
            }
    		component.set('v.intCurrentStep', 4);
        	helper.updateCss(component, event, helper);
        	helper.helperMethodForProductRegistrationSummery(component, event,helper);
    		return true;
   
        });*/
        /*    var selectedItemNew = document.getElementById(BillingStreetId);
        console.log('selectedItemNew>>',selectedItemNew);
        console.log('Hi');
        var BillingStreetId = component.find('BillingStreetId');
        console.log('Hi>>',BillingStreetId);
        
        var mPhone = BillingStreetId.get('v.value');
        
        if(mPhone ==='' || mPhone === undefined){
            helper.customValidation(component, event, BillingStreetId);
            return;
        }*/
        //Progress indicator
        /*  	component.set('v.intCurrentStep', component.get('v.intCurrentStep') + 1);
        helper.updateCss(component, event, helper);
        
        helper.helperMethodForProductRegistrationSummery(component, event,helper);*/
    },
    
    removeValidation :  function(component, event,helper) {
        var PhoneId = component.find("PhoneId");
        var Phonevalue = PhoneId.get("v.value");
        var AddressLineId = component.find("AddressLineId");
        var AddressLinevalue = AddressLineId.get("v.value");
        var BillingCityId = component.find("BillingCityId");
        var BillingCityValue = BillingCityId.get("v.value");
        var PostalCodeId = component.find("PostalCodeId");
        var PostalCodeValue = PostalCodeId.get("v.value");
        if(Phonevalue !=='' || Phonevalue !== undefined
           ||AddressLinevalue !=='' || AddressLinevalue !== undefine
           ||BillingCityValue !=='' || BillingCityValue !== undefined
           ||PostalCodeValue !=='' || PostalCodeValue !== undefined){
            helper.removeCustomValidation(component, event, PhoneId,AddressLineId,BillingCityId,PostalCodeId);
            return;
        }
        else if(AddressLinevalue !=='' || AddressLinevalue !== undefine){
            helper.removeCustomValidation(component, event, AddressLineId);
            return;
        }
            else if(BillingCityValue !=='' || BillingCityValue !== undefined){
                helper.removeCustomValidation(component, event, BillingCityId);
                return;
            }
                else if(PostalCodeValue !=='' || PostalCodeValue !== undefined){
                    helper.removeCustomValidation(component, event, PostalCodeId);
                    return;
                }
        
    }, 
    
    changeCountry : function(component, event, helper) {
        var cmpDiv = component.find('enableCountryError');
        $A.util.removeClass(cmpDiv, 'slds-has-error');
        component.set('v.hideCountry' , "false");//{!v.myMap.key1}
        helper.getStates(component, event, helper);
        
    },
    changeState : function(component, event, helper) {
        //component.set('v.hideState' , "false");
        var key = component.get("v.billingStateValue");
        var mapObject= component.get('v.stateFieldMap');
        var countryValue;
        mapObject.forEach(function(state) {
            if(state.value == key){
                countryValue = state.key;
            }
        });
        console.log('countryValue', countryValue);
        component.set('v.newAccount.BillingStateCode' , countryValue);
        component.set('v.hideState' , "false");
        var cmpDiv = component.find('enableStateError');
        $A.util.removeClass(cmpDiv, 'slds-has-error');
    },
    
    navigateToComTwo : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:productregistrationLightning",
            componentAttributes: {    
                Text : component.get("v.Txt")
            }
        });
        evt.fire();
    },
    
    placeOfPurchase : function(component, event, helper) {
        var cmpDiv = component.find('enablePlaceOfPurchaseError');
        $A.util.removeClass(cmpDiv, 'slds-has-error');
        component.set('v.hidePlaceOfPurchase' , false);
        var selectedPlaceOfPurchaseId = event.getSource().get("v.value");
        console.log('selectedPlaceOfPurchaseId>>',selectedPlaceOfPurchaseId);
    },
    chooseYourGift : function(component, event, helper) {
        //  console.log("Needs to code for this");
        
        var chooseYourGidtId = component.find("chooseYourGift");
        console.log("chooseYourGidtId>>>",chooseYourGidtId);
        var value = chooseYourGidtId.get("v.value");
        console.log("chooseYourGidtId value>>>",value);
        /*alert(value);
          if(value===''||value==='-- None --') {
            
            chooseYourGidtId.showHelpMessageIfInvalid();
     
        }*/
                                },
    goBackOnProductRegister : function(component, event, helper) {
        helper.helperMethodForProductRegister(component, event, helper);
    },
    
    handleUploadFinished  : function(component, event, helper) {
        console.log("***Inside of file upload****");
        var uploadedFiles = event.getParam("filetype");
        alert("Files uploaded : " + uploadedFiles.length);
        console.log("**uploadedFiles****"+uploadedFiles.length);
        // Get the file name
        uploadedFiles.forEach(file => console.log(file.name));
        console.log("**uploadedFiles****"+uploadedFiles.length);
    },
    
    handleOptionSelectedForProduct :function(component, event, helper) {
        var cmpDiv = component.find('enableSubProductError');
        $A.util.removeClass(cmpDiv, 'slds-has-error');
        component.set('v.hideSubProduct' , false);
        var selectedProductId = event.getSource().get("v.value");
        console.log('subcategory productId>>',selectedProductId);
        var products1 = [{value:'',label:'',disabled:false}];
        var offersList = component.get("c.getProductRelateToSubProduct");
        offersList.setParams({
            selectedSubCategory : selectedProductId
        });
        offersList.setCallback(this, function(response){
            products1 = response.getReturnValue();
            component.set("v.models",products1);
            console.log("Selected models>>>>"+ JSON.stringify(products1));
            
        });
        $A.enqueueAction(offersList); 
    }, 
    handleOptionSelectedForM : function(component, event, helper) {
        var cmpDiv = component.find('enableModelError');
        $A.util.removeClass(cmpDiv, 'slds-has-error');
        component.set('v.hideModel' , false);
        var products1 = [{value:'',label:'',disabled:false}];
        var productId = event.getSource().get("v.value");
        console.log('productId>>',productId);
        component.set("v.showGift",false);
        if(component.get("v.saveInAsset.Product2Id") != "-- None --")
            helper.getGiftProducts(component, event, helper);
    },
    save: function(component, event, helper) {
        helper.uploadHelper(component, event, helper);
    },
    
    handleFilesChangeForUploadingFile: function(component, event, helper) {
        
        console.log("***Inside of file upload****");   
        /*   helper.uploadHelper(component, event, helper);
       var uploadedImage = 'No File Selected..';
        if (event.getSource().get("v.fileToUploadId").length > 0) {
            uploadedImage = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.uploadedFile", uploadedImage);
        console.log("***Inside of file upload****"+uploadedImage);*/
                            },
    
    showToolTipForPDC : function(component, event, helper) {
        component.set("v.tooltipForPDC" , true);
        
    },
    HideToolTipForPDC : function(component, event, helper){
        component.set("v.tooltipForPDC" , false);
    },
    
    showToolTipForDOB : function(component, event, helper) {
        component.set("v.tooltipForDOB" , true);
    },
    HideToolTipForDOB : function(component, event, helper){
        component.set("v.tooltipForDOB" , false);
    },
    getParamValue: function(component, event, helper) {
        //Get Id Parameter Value From Community URL
        var idParamValue = helper.getURLParameterValue().id;
        console.log('Id-' + idParamValue);
        
        //Get Name Parameter Value From Community URL
        var nameParamValue = helper.getURLParameterValue().name;
        console.log('Name-' + nameParamValue);
    },
    updateProvinces: function(cmp, event, helper) {
        if (cmp.get("v.previousCountry") !== cmp.get("v.country")) {
            cmp.set("v.provinceOptions", helper.getProvinceOptions(cmp.get("v.country")));
        }
        cmp.set("v.previousCountry", cmp.get("v.country"));
    },
    handleOnChange : function(component, event, helper) {
        helper.getStatePicklistValues(component, event); 
    },
    
    getNextRecords: function(component, event, helper) {
        component.set("v.showAccountAsset", false);
    },
    handleNavigationComplete : function(component, event, helper) {
        var canGoBack = event.getParam("canGoBack");
        // take any other action based on if back navigation is possible or not
    },
    purchaseEdit : function(component, event, helper) { 
        component.set('v.intCurrentStep', 2);
        helper.backUpdateCss(component, event, helper);
        component.set("v.captchaVerify", false);
        component.set("v.isProductDetails" , true);
        component.set("v.isDeliveryDetails" , false);
        component.set("v.isSummaryRegistration" , false);
        component.set("v.isThankYou" , false);
    },
    deliveryEdit : function(component, event, helper) {  
        component.set('v.intCurrentStep', 3);
        helper.backUpdateCss(component, event, helper);
        component.set("v.captchaVerify", false);
        component.set("v.isProductDetails" , false);
        component.set("v.isDeliveryDetails" , true);
        component.set("v.isSummaryRegistration" , false);
        component.set("v.isThankYou" , false);
    },
    back : function(component, event, helper) {   
        //Progress indicator
        component.set('v.intCurrentStep', 3);
        helper.backUpdateCss(component, event, helper);
        
        component.set("v.isProductDetails" , false);
        component.set("v.isDeliveryDetails" , true);
        component.set("v.isSummaryRegistration" , false);
        component.set("v.isThankYou" , false);
    },
    handleBackButton : function(component, event, helper) {  
        //Progress indicator
        component.set('v.intCurrentStep', 2);
        helper.backUpdateCss(component, event, helper);
        
        component.set("v.isProductDetails" , true);
        component.set("v.isDeliveryDetails" , false);
        component.set("v.isSummaryRegistration" , false);
        component.set("v.isThankYou" , false);
    },
    
    submitClaimJs : function(component, event, helper) { 
        var action = component.get("c.submitClaim");
        console.log('Account>>>',JSON.stringify(component.get("v.newAccount")));
        let uploadedFiles = component.get("v.uploadedFiles");
        
        action.setParams(	{ 
            acctString : JSON.stringify(component.get("v.newAccount")),
            assetString :  JSON.stringify(component.get("v.saveInAsset")),
            contentDocumentId : uploadedFiles[0].Id
        }
                        );
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.isProductDetails" , false);
                component.set("v.isDeliveryDetails" , false);
                component.set("v.isSummaryRegistration" , false);
                component.set("v.isThankYou" , true);
            }
            else {
                console.log(response.getError());
            }
            
        });
        $A.enqueueAction(action);
    },
})