({
   
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
        //  helper.doInitHelper(component, event);
        component.set("v.provinceOptions", helper.getProvinceOptions(component.get("v.country")));
         document.addEventListener("grecaptchaVerified", function(e) {
            component.set('v.recaptchaResponse', e.detail.response);
            let myButton = component.find("myButton");
            myButton.set('v.disabled', false);
        });
        
        document.addEventListener("grecaptchaExpired", function() {
            let myButton = component.find("myButton");
            myButton.set('v.disabled', true);
        }); 
        
    },
    onRender: function (component, event, helper){ 
        //valide values for badge: bottomright bottomleft inline
         document.dispatchEvent(new CustomEvent("grecaptchaRender", { "detail" : { element: 'recaptchaCheckbox'} }));
    },
     
    goOnApplianceRegisterSummary : function(component, event, helper) { 
      
        
      		component.set('v.intCurrentStep', component.get('v.intCurrentStep') + 1);
        helper.updateCss(component, event, helper);

            var contactFields = component.find("formFieldToValidate");
    
        if(contactFields.length!=undefined)
            // Initialize the counter to zero - used to check validity of fields
            var blank=0;
            // If there are more than 1 fields
            if(contactFields.length!=undefined) {
                // Iterating all the fields
                var allValid = contactFields.reduce(function (validSoFar, inputCmp) {
                // Show help message if single field is invalid
                inputCmp.showHelpMessageIfInvalid();
                // return whether all fields are valid or not
                return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
                // If all fields are not valid increment the counter
                if (!allValid) {
                    blank++;
                }
            } else {
                // If there  is only one field, get that field and check for validity (true/false)
                var allValid = contactFields;
                // If field is not valid, increment the counter
                if (!allValid.get('v.validity').valid) {
                    blank++;
                }
            }
            // Call the helper method only when counter is 0
            if(blank==0) {
                // Calling saveContacts if the button is save
                  helper.helperMethodForProductRegister(component, event, helper);
               
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
   
    
    goRegistrationSummery : function(component, event,helper) {
        const requiredFields = component.find('fieldId') || [];
        
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
    		component.set('v.intCurrentStep', component.get('v.intCurrentStep') + 1);
        	helper.updateCss(component, event, helper);
        	helper.helperMethodForProductRegistrationSummery(component, event,helper);
    		return true;
   
        });
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
      var selectedPlaceOfPurchaseId = event.getSource().get("v.value");
      console.log('selectedPlaceOfPurchaseId>>',selectedPlaceOfPurchaseId);
    },
    chooseYourGift : function(component, event, helper) {
      //  console.log("Needs to code for this");
    
      var chooseYourGidtId = component.find("chooseYourGift");
        console.log("chooseYourGidtId>>>",chooseYourGidtId);
        var value = chooseYourGidtId.get("v.value");
        console.log("chooseYourGidtId value>>>",value);
        alert(value);
          if(value===''||value==='-- None --') {
            
            chooseYourGidtId.showHelpMessageIfInvalid();
     
        }
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
       var products1 = [{value:'',label:'',disabled:false}];
       var productId = event.getSource().get("v.value");
        console.log('productId>>',productId);
    },
   
    handleFilesChangeForUploadingFile: function(component, event, helper) {
        var uploadedImage = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            uploadedImage = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.uploadedFile", uploadedImage);
        console.log("***Inside of file upload****"+uploadedImage);
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
        component.set("v.isProductDetails" , true);
        component.set("v.isDeliveryDetails" , false);
        component.set("v.isSummaryRegistration" , false);
        component.set("v.isThankYou" , false);
    },
    deliveryEdit : function(component, event, helper) {  
        component.set("v.isProductDetails" , false);
        component.set("v.isDeliveryDetails" , true);
        component.set("v.isSummaryRegistration" , false);
        component.set("v.isThankYou" , false);
    },
    back : function(component, event, helper) {   
        //Progress indicator
        component.set('v.intCurrentStep', component.get('v.intCurrentStep') - 1);
        helper.backUpdateCss(component, event, helper);
        
        component.set("v.isProductDetails" , false);
        component.set("v.isDeliveryDetails" , true);
        component.set("v.isSummaryRegistration" , false);
        component.set("v.isThankYou" , false);
    },
    handleBackButton : function(component, event, helper) {  
        //Progress indicator
        component.set('v.intCurrentStep', component.get('v.intCurrentStep') - 1);
        helper.backUpdateCss(component, event, helper);
        
        component.set("v.isProductDetails" , true);
        component.set("v.isDeliveryDetails" , false);
        component.set("v.isSummaryRegistration" , false);
        component.set("v.isThankYou" , false);
    },
    
    submitClaimJs : function(component, event, helper) { 
        var action = component.get("c.submitClaim");
        action.setParams(	{ 
                                acctString : JSON.stringify(component.get("v.newAccount")),
                                assetString :  JSON.stringify(component.get("v.saveInAsset")) 
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