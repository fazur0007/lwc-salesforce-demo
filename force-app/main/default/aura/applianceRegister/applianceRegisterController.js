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
        var baseURL = window.location.href;
        var stateValue = baseURL.split('state=')[1];
        var offerCode = stateValue.substring(0, stateValue.indexOf("&"));
        console.log ('offerCode: ' + offerCode);
        component.set("v.offerCode",offerCode);

        helper.doInitHelper(component, event, helper);        
        helper.getProductCategories(component, event, helper);
        helper.getCountryList(component, event,helper);
        helper.getStatePicklistValues(component, event);
        component.set("v.provinceOptions", helper.getProvinceOptions(component.get("v.country")));
        document.addEventListener("grecaptchaVerified", function(e) {
            component.set('v.recaptchaResponse', e.detail.response);
            component.set("v.captchaVerify", true);
            
            component.set('v.hideCaptcha' , false);
        });
        
        document.addEventListener("grecaptchaExpired", function() {
            console.log('Ji');
            component.set("v.captchaVerify", false);
        }); 
        
    },
    onRender: function (component, event, helper){ 
        //valide values for badge: bottomright bottomleft inline
        document.dispatchEvent(new CustomEvent("grecaptchaRender", { "detail" : { element: 'recaptchaCheckbox'} }));
    },
    
    goOnApplianceRegisterSummary : function(component, event, helper) { 
        helper.goOnApplianceRegisterSummaryPage(component, event, helper,true)
    }, 
        
    goRegistrationSummary : function(component, event,helper) {
        helper.goRegistrationSummaryPage(component, event,helper,true,false);
    },
    
    validateDateForDOB : function(component, event, helper) {
        var cmpDiv = component.find('enableDOBError');
        $A.util.removeClass(cmpDiv, 'slds-has-error');
        component.set('v.hideBirthDate' , false);
        
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
    
    validateDateOfPurchase : function(component, event, helper) {
        var cmpDiv = component.find('enableDateOfPurchaseError');
        $A.util.removeClass(cmpDiv, 'slds-has-error');
        component.set('v.hideDateOfPurchase' , false);
        
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
            /* This is for calling Gifts Product method after selecting the purchase date */
          //  helper.getGiftProducts(component, event, helper);
        }
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
     //   var cmpDiv = component.find('enableCountryError');
     //   $A.util.removeClass(cmpDiv, 'slds-has-error');
     //   component.set('v.hideCountry' , "false");//{!v.myMap.key1}
     		var countryList = component.get("v.states");
            var selectedCountryCode = component.find("CountryId").get("v.value");
            countryList.forEach(function(country) {
                if(country.value == selectedCountryCode){
                    component.set("v.billingCountryValue",country.label);
                }
        	});
     	component.set('v.hideCountry' , "false");
        
        helper.getStates(component, event, helper);
        
    },
    changeState : function(component, event, helper) {        
        if(component.find("stateId"))
        {
            var stateList = component.get("v.states");
            var selectedStateCode = component.find("stateId").get("v.value");
            stateList.forEach(function(state) {
                if(state.value == selectedStateCode){
                    component.set("v.billingStateValue",state.label);
                }
        	});
        }
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
    },
    chooseYourGift : function(component, event, helper) {
        var cmpDiv = component.find('enableChooseGiftError');
        $A.util.removeClass(cmpDiv, 'slds-has-error');
        component.set('v.hideChooseGift' , false);
        
        
        var giftsList = component.get("v.listGiftProducts");
        var selectedGiftCode = component.find("chooseYourGiftId").get("v.value");
        giftsList.forEach(function(gift) {
            if(gift.value == selectedGiftCode){
                component.set("v.selectedGift",gift.label);
            }
        });
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
        component.set("v.saveInAsset.Product2Id" , '');
        component.set("v.showGift",false);
        console.log("handleOptionSelectedForProduct");
        var selectedCategory = event.getSource().get("v.value");
        var products = [{value:'',label:'',disabled:false}];
        let getProductsAction = component.get("c.getProducts");
        let offerCode = component.get("v.offerCode");
        console.log("selectedCategory: " + selectedCategory);
        getProductsAction.setParams({
            category : selectedCategory,
            offerCode: offerCode
        });
        getProductsAction.setCallback(this, function(response){
            products = response.getReturnValue();
            console.log("products: " + products);
            component.set("v.models",products);
            
        });
        $A.enqueueAction(getProductsAction);        
    }, 
    handleOptionSelectedForModel : function(component, event, helper) {
       var cmpDiv = component.find('enableModelError');
        $A.util.removeClass(cmpDiv, 'slds-has-error');
        component.set('v.hideModel' , false);
        var models = [{value:'',label:'',disabled:false}];
        var  selectedModelId = component.find("selectedModelId");
        var selectedModelValue = selectedModelId.get("v.value");
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
        component.set("v.newAccount.ShippingState",null);
        var offerCode = component.get("v.offerCode");
        action.setParams(	{ 
            acctString : JSON.stringify(component.get("v.newAccount")),
            assetString :  JSON.stringify(component.get("v.saveInAsset")),
            contentDocumentId : uploadedFiles[0].Id,
            offerCode: offerCode
        }
                        );
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                let result = response.getReturnValue();
                component.set("v.isProductDetails" , false);
                component.set("v.isDeliveryDetails" , false);
                component.set("v.isSummaryRegistration" , false);
                component.set("v.isThankYou" , true);
                component.set("v.isOfferCodeApplied" , result.isOfferCodeApplied);
                if(!result.isSuccess && result.messsage === 'Already_Registered_Product')
                	component.set("v.isDuplicateAsset" , true);
                if(result.assetOfferCode)
                	component.set("v.assetGiftCode" , result.assetOfferCode);
            }
            else {
                console.log(response.getError());
            }
            
        });
        $A.enqueueAction(action);
    },
     getStageId :  function(component, event, helper) { 
         if (component.get('v.isThankYou')){
             return false;
         }
         var current = component.get("v.intCurrentStep");
         if (current == 2){
             var secondMethodResult  = helper.goOnApplianceRegisterSummaryPage(component, event, helper,false)
             if (secondMethodResult != false) {
                 return false
             }
         }
          if (current == 3){
             var thirdMethodResult  = helper.goRegistrationSummaryPage(component, event,helper,false,true);
             if (thirdMethodResult != false) {
                 return false
             }
         }
        var convoId = event.target.getAttribute("data-id");
        if (convoId ==2) {
            if (component.get('v.isAccountCompleted')) {
                component.set("v.isProductDetails", true);
                component.set("v.isDeliveryDetails", false);
                component.set("v.isSummaryRegistration", false);
                component.set("v.intCurrentStep",2 );
                if (current > convoId) {
                    helper.backUpdateCss(component, event, helper);
                } else {
                    helper.updateCss(component, event, helper);
                }
            }
            
        } else if (convoId == 3) {
            if (component.get('v.isYourPurchaseCompleted')) {
                component.set("v.isProductDetails", false);
                component.set("v.isDeliveryDetails", true);
                component.set("v.isSummaryRegistration", false);
                component.set("v.intCurrentStep",3 );
                if (current > convoId) {
                    helper.backUpdateCss(component, event, helper);
                } else {
                    helper.updateCss(component, event, helper);
                }
            }
        } else if (convoId == 4) {
            if (component.get('v.isYourDeliveryCompleted')) {
                component.set("v.isProductDetails", false);
                component.set("v.isDeliveryDetails", false);
                component.set("v.isSummaryRegistration", true);
                component.set("v.intCurrentStep",4);
                if (current > convoId) {
                    helper.backUpdateCss(component, event, helper);
                } else {
                    helper.updateCss(component, event, helper);
                }
            }
        }
    }  
})