({
    doInit : function(component, event, helper) {
        helper.doInitHelper(component, event, helper);
    },
    handleNext : function(component, event, helper) {
        component.set('v.intCurrentStep', component.get('v.intCurrentStep') + 1);
        helper.updateCss(component, event, helper);
    },
    handleBack : function(component, event, helper) {
        component.set('v.intCurrentStep', component.get('v.intCurrentStep') - 1);
        helper.backUpdateCss(component, event, helper);
    },
    doinit : function(component, event, helper) {
        
        
        var objDetails = component.get("v.objDetail");
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        
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
        //helper.helperMethodForProductSummary(component, event, helper);
        helper.helperMethodForProductRegister(component, event, helper);
    },
    
    goRegistrationSummery : function(component, event,helper) {
        helper.helperMethodForProductRegistrationSummery(component, event,helper);
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
    
    handleOptionSelectedForM : function(component, event, helper) {
        var products1 = [{value:'',label:'',disabled:false}];
        var selectedProductId = event.getSource().get("v.value");
    },
    placeOfPurchase : function(component, event, helper) {
        
    },
    chooseYourGift : function(component, event, helper) {
        //  console.log("Needs to code for this");
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
        component.set("v.isProductDetails" , false);
        component.set("v.isDeliveryDetails" , true);
        component.set("v.isSummaryRegistration" , false);
        component.set("v.isThankYou" , false);
    },
    handleBackButton : function(component, event, helper) {   
        component.set("v.isProductDetails" , true);
        component.set("v.isDeliveryDetails" , false);
        component.set("v.isSummaryRegistration" , false);
        component.set("v.isThankYou" , false);
    },
    
    submitClaimJs : function(component, event, helper) { 
        var action = component.get("c.submitClaim");
        action.setParams(	{ 
            acct : component.get("v.newAccount"),
            asset :  component.get("v.saveInAsset") 
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
    handleShowPopover : function(component, event, helper) {
        component.find('overlayLib').showCustomPopover({
            body: "Popovers are positioned relative to a reference element",
            referenceSelector: ".mypopover",
            cssClass: "popoverclass, cMyCmp"
        }).then(function (overlay) {
            setTimeout(function(){
                //close the popover after 3 seconds
                overlay.close();
            }, 3000);
        });
    }
})