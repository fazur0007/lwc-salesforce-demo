({
    getProductCategories : function(component, event, helper) { 
        var products1 = [{value:'',label:'',disabled:false}];
        let getCategoriesAction = component.get("c.getProductCategories");
        let offerCode = component.get("v.offerCode");
        console.log ('offerCode: ' + offerCode);
        getCategoriesAction.setParams({
           offerCode : offerCode
        });
        
        getCategoriesAction.setCallback(this, function(response){
            products1 = response.getReturnValue();
            component.set("v.productsList",products1);
            
        });
        $A.enqueueAction(getCategoriesAction);
    },
    
	helperRemoveAttachment : function(component, event, helper) {
        var deleteFile = component.get("c.deleteAttachment");
        deleteFile.setParams({
           'attachmentId' : component.get("v.uploadedFileId")
        });
        deleteFile.setCallback(this,function(response){
            var state = response.getState();
            var a = response.getReturnValue();
            if (state == "SUCCESS") 
            {
                component.set("v.fileNameJs","");
                component.set("v.uploadedFileId","");
                component.set("v.uploadedFileName","");	
                component.set("v.uploadedFiles",null);
            }
        });
        $A.enqueueAction(deleteFile);
     },
    
    fetchPicklistValues: function(component, event, helper,objDetails,controllerField, dependentField) {
        
        var action = component.get("c.getDependentMap");
        action.setParams({
            'objDetail' : objDetails,
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var storeList = response.getReturnValue();
                
                console.log("storeList :"+storeList);
                var responseForAUS = storeList.AUS;
                console.log("fetchPicklistValues storeList :",responseForAUS);
                component.set("v.placeOfPurchaseList",responseForAUS);
                console.log("fetchPicklistValues purchaseList :",component.get("v.placeOfPurchaseList"));
                
            }
        });
        $A.enqueueAction(action);
    },
    
    helperMethodForProductRegister : function(component, event, helper) {
        var objectValue = component.get("v.saveInAsset");
        var action = component.get("v.isDeliveryDetails");
        var action = true;
        
        component.set("v.isProductDetails" , false);
        component.set("v.isDeliveryDetails" , action);
        console.log("Asset Object to be Save>>>>"+ JSON.stringify(component.get("v.saveInAsset")));
        console.log("Account Object to be Save>>>>"+ JSON.stringify(component.get("v.newAccount")));
        
    },
    
    helperMethodForProductRegistrationSummery : function(component, event,helper) {
        
        var action = component.get("c.getProductSummaryDetails");
        action.setParams({ assetRecordString :  JSON.stringify(component.get("v.saveInAsset")) });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.productName",response.getReturnValue().productName);
                component.set("v.modelName",response.getReturnValue().modelName);                
                var action = component.get("v.isSummaryRegistration");
                var action = true;
                component.set("v.isProductDetails" , false);
                component.set("v.isDeliveryDetails" , false);
                component.set("v.isSummaryRegistration" , action);
                component.set("v.isThankYou" , false);
                
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        
    },
    
    helperMethodForProductSummary : function(component, event, helper) {
        
        component.set("v.isProductDetails" , false);
        component.set("v.isDeliveryDetails" , true);
        component.set("v.isThankYou" , false);
        console.log("Asset Object to be Save>>>>"+ JSON.stringify(component.get("v.saveInAsset")));
        console.log("Account Object to be Save>>>>"+ JSON.stringify(component.get("v.newAccount")));
        var objectValue = component.get("v.saveInAsset");
    
    },
    
    helperMethodForSummitProductDetails : function(component, event, helper) {
        
        var productDetails = component.get("v.saveInAsset");
        var summit = component.get("c.summitForInsert");
        summit.setParams({
            //     accountSummit : productDetails
            //   record: {  accountSummit : productDetails }
        });
        summit.setCallback(this,function(response){
            var state = response.getState();
            var a = response.getReturnValue();
        });
        $A.enqueueAction(summit);
            },
    /*
    fetchProducts : function(component, fieldName, elementId ){
        
        var action = component.get("c.getProductsList");
        action.setParams({
            "objObject": component.get("v.objInfo"),
            "fld": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log(allValues);
                
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.find(elementId).set("v.options", opts);
            }
        });
        $A.enqueueAction(action);
    },
    */
    //***********File upload Start****************//
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadHelper : function(component, event, helper) {
        console.log("inisd eof helper uplaod"); 
        var fileInput = component.find("file").getElement();
        console.log("inisd eof helper uplaod>>",fileInput);
        var file = fileInput.files[0];
        
        component.set("v.uploadedFile",file.name);
        component.set("v.saveInAsset.attachment",file.name);
        console.log("fileInput>>>>",fileInput);
        if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
    	          'Selected file size: ' + file.size);
    	    return;
        }
    
        var fr = new FileReader();
        var self = this;
       	fr.onload = function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);
        
    	    self.upload(component, file, fileContents);
        };

        fr.readAsDataURL(file);
    },
        
    upload: function(component, file, fileContents) {
        var action = component.get("c.uploadedFile"); 
   
        component.set("v.fileNameJs",file.name);
        component.set("v.fileTypeJs",file.type);
        component.set("v.fileContentJs",encodeURIComponent(fileContents));
    },
   
    
    getCountryList: function(component, event,helper) {
        var action = component.get("c.getCountryList");
        var sURL = window.location.href;
        var stateValue = sURL.split('state=')[1];
        var offerCode = stateValue.substring(0, stateValue.indexOf("&"));
        action.setParams({
           offerCode : offerCode
        });
        action.setCallback( this, function( response ) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                    component.set('v.billingCountryValue', result[key]);
                    component.set('v.newAccount.ShippingCountryCode', key);
                }
                if(fieldMap.length === 1){
                    component.set('v.disableCountryField', true);
                }
                component.set("v.fieldMap", fieldMap);
                helper.getStates(component, event,helper);
            }
        });
        $A.enqueueAction(action);
    },
    
    getPicklistValues: function(component, event) {
        var action = component.get("c.getCountryFieldValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result>>>>>',result);
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.fieldMap", fieldMap);
                console.log("fieldMap Details>>>>"+ fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
    getStatePicklistValues: function(component, event) {
        var controllerValueKey = event.getSource().get("v.value"); 
        var action = component.get("c.getStateFieldValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result>>>>>',result);
                var statefieldMap = [];
                for(var key in result){
                    statefieldMap.push({key: key, value: result[key]});
                }
                component.set("v.stateFieldMap", statefieldMap);
                console.log("statefieldMap Details>>>>"+ stateFieldMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    
    countryProvinceMap: {
        US: [
            {'label': 'California', 'value': 'CA'},
            {'label': 'Texas', 'value': 'TX'},
            {'label': 'Washington', 'value': 'WA'}
        ],
        CN: [
            {'label': 'GuangDong', 'value': 'GD'},
            {'label': 'GuangXi', 'value': 'GX'},
            {'label': 'Sichuan', 'value': 'SC'}
        ],
        VA: []
    },
    
    getProvinceOptions: function(country) {
        return this.countryProvinceMap[country];
    },
    
    doInitHelper : function(component, event, helper){ 
        //debugger;
        var action = component.get("c.fetchAccountId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Recid", response.getReturnValue().Id);
                component.set("v.newAccount", response.getReturnValue()); 
                var result = response.getReturnValue();
                console.log('result:'+result);
                component.set("v.billingStateValue", result.ShippingState); 
                component.set("v.billingCountryValue", result.ShippingCountry);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);        
    },
    
    customValidation: function(component, event,ValueName,StringValue) {
        ValueName.setCustomValidity(StringValue);
        ValueName.reportValidity();
        return;
    },
    validateSelectedDate: function(component, selectedDate) {
	var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
   // var minDate = component.get("v.minDate");
    if (true) {
      component.set("v._error", true);
      component.set("v._errorMessage", "Date cannot be future date");
    } else {
      component.set("v._error", false);
      component.set("v._errorMessage", "");
    }
  },
     getGiftProducts: function(component, event) {
        var action = component.get("c.getGiftProducts");
        let offerCode = component.get("v.offerCode");
        action.setParams({
            currAsset: component.get("v.saveInAsset"),
            selectedProduct:component.get("v.saveInAsset.Product2Id"),
            offerCode: offerCode
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.length>0)
                	component.set("v.showGift",true);
                component.set("v.listGiftProducts", result);                
                console.log("giftProducts"+ result);
            }
        });
        $A.enqueueAction(action);
    },
    
 //Progress indicator - start
    updateCss : function(component, event, helper) {
        let intCurrentStep = component.get('v.intCurrentStep');
        let circle = component.find('circle' +intCurrentStep);
        let label = component.find('label' +intCurrentStep);
        let line = component.find('line' +(intCurrentStep-1));
        
        $A.util.removeClass(circle, 'activeStep');
        $A.util.removeClass(circle, 'activeBackground');        
        $A.util.removeClass(label, 'activeLabel');
        $A.util.removeClass(line, 'activeBackground');
        
        $A.util.addClass(circle, 'activeStep');
        $A.util.addClass(circle, 'activeBackground');
        $A.util.addClass(label, 'activeLabel');
        $A.util.addClass(line, 'activeBackground');
        
        $A.util.removeClass(circle, 'inactiveStep'); 
        
        let inactiveCircle;
        let inactiveLabel;
        let inactiveLine;
        /*if(intCurrentStep === 2){
            inactiveCircle = component.find('circle' +intCurrentStep);
            inactiveLabel = component.find('label' +intCurrentStep);
            inactiveLine = component.find('line' +intCurrentStep);
        }
        else{*/
            inactiveCircle = component.find('circle' +(intCurrentStep-1));
            inactiveLabel = component.find('label' +(intCurrentStep-1));
            inactiveLine = component.find('line' +(intCurrentStep-1));
        //}
        $A.util.removeClass(inactiveCircle, 'activeStep');
        $A.util.removeClass(inactiveCircle, 'activeBackground');
        $A.util.removeClass(inactiveLabel, 'activeLabel');
        $A.util.removeClass(inactiveLine, 'activeBackground');
        
        inactiveCircle = component.find('circle' +(intCurrentStep-2));
        inactiveLabel = component.find('label' +(intCurrentStep-2));
        inactiveLine = component.find('line' +(intCurrentStep-2));
        $A.util.removeClass(inactiveCircle, 'activeStep');
        $A.util.removeClass(inactiveCircle, 'activeBackground');
        $A.util.removeClass(inactiveLabel, 'activeLabel');
        $A.util.removeClass(inactiveLine, 'activeBackground');
        
        //$A.util.toggleClass(inactiveCircle, 'inactiveStep');
    },
    backUpdateCss : function(component, event, helper) {
        let intCurrentStep = component.get('v.intCurrentStep');
        let circle = component.find('circle' +intCurrentStep);
        let label = component.find('label' +intCurrentStep);
        let line = component.find('line' +(intCurrentStep-1));
        
        $A.util.removeClass(circle, 'activeStep');
        $A.util.removeClass(circle, 'activeBackground');
        $A.util.removeClass(label, 'activeLabel');
        $A.util.removeClass(line, 'activeBackground');
		$A.util.removeClass(circle, 'inactiveStep');
        
        $A.util.addClass(circle, 'activeStep');
        $A.util.addClass(circle, 'activeBackground');
        $A.util.addClass(label, 'activeLabel');
        $A.util.addClass(line, 'activeBackground');
		$A.util.addClass(circle, 'inactiveStep');
        $A.util.removeClass(circle, 'inactiveStep'); 
        
        let inactiveCircle;
        let inactiveLabel;
        let inactiveLine;
        let intLastStep = component.get("v.intLastStep");
        //if(intLastStep != intCurrentStep ){
            inactiveCircle = component.find('circle' +(intCurrentStep+1));
            inactiveLabel = component.find('label' +(intCurrentStep+1));
            inactiveLine = component.find('line' +intCurrentStep);
        //}
        $A.util.removeClass(inactiveCircle, 'activeStep');
        $A.util.removeClass(inactiveCircle, 'activeBackground');
        $A.util.removeClass(inactiveLabel, 'activeLabel');
        $A.util.removeClass(inactiveLine, 'activeBackground');
        
        if(intCurrentStep+2 <= intLastStep ){
            let inactiveCircle2;
            let inactiveLabel2;
            let inactiveLine2;
            let intLastStep2 = component.get("v.intLastStep");
            
            inactiveCircle2 = component.find('circle' +(intCurrentStep+2));
            inactiveLabel2 = component.find('label' +(intCurrentStep+2));
            inactiveLine2 = component.find('line' +intCurrentStep+1);
    
            $A.util.removeClass(inactiveCircle2, 'activeStep');
            $A.util.removeClass(inactiveCircle2, 'activeBackground');
            $A.util.removeClass(inactiveLabel2, 'activeLabel');
            $A.util.removeClass(inactiveLine2, 'activeBackground');
            
        }
        
        
        //$A.util.toggleClass(inactiveCircle, 'inactiveStep');
    },
    //Progress indicator - end
	
    /*getCountryStateDependencie: function(component, event) {
        var action = component.get("c.getFieldDependencies");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result>>>>',result);
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({label: result[key], value: key});
                }
                component.set("v.countryOptions", fieldMap);
                console.log('hi>>',component.get("v.countryOptions"));
            }
        });
        $A.enqueueAction(action);
    },*/
    
    getStates : function(component, event, helper) { 
        console.log('Data');                
        var countryValue = component.get("v.newAccount.ShippingCountryCode");
        console.log('countryValue>>>>>',countryValue);        
        var action = component.get("c.getStatesWithStateCodes");
        
        action.setParams({ "selectedCountry" : countryValue,
                          "objectAPIName" : component.get("v.objectAPIName"),
                          "countryPicklistAPIName" : component.get("v.countryPicklistAPIName"),
                          "statePicklistAPIName" : component.get("v.statePicklistAPIName")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var stateList = response.getReturnValue();
                component.set("v.states", stateList);
                component.set("v.stateFieldMap", stateList);
            }
            else if (state === "ERROR") {
                console.error("Error calling action: "+ response.getState());
            }
        });
        $A.enqueueAction(action);
    },
    
    customValidation: function(component, event,ValueName,StringValue) {
        ValueName.setCustomValidity(StringValue);
        ValueName.reportValidity();
        return;
    },
    
    removeCustomValidation: function(component, event,PhoneId,AddressLineId,BillingCityId,PostalCodeId) {
        PhoneId.setCustomValidity("");
        PhoneId.reportValidity();
        AddressLineId.setCustomValidity("");
        AddressLineId.reportValidity();
        BillingCityId.setCustomValidity("");
        BillingCityId.reportValidity();
        PostalCodeId.setCustomValidity("");
        PostalCodeId.reportValidity();
        return;
    },
    
     handleUploadFinishedHelper : function(component, event, helper) {
         
        var uploadedFileArr = [];
        var sObjectAttachedFiles = component.get("v.sObjectAttachedFiles");
        var sObjectAttachedFilesArr = [];
        if(sObjectAttachedFiles != null && sObjectAttachedFiles != undefined && sObjectAttachedFiles.length > 0){
            [].forEach.call(sObjectAttachedFiles, function(file) {
                sObjectAttachedFilesArr.push({'Id' : file.Id,'Title': file.Title});
            });
        }
        var uploadedFiles = event.getParam("files");
        [].forEach.call(uploadedFiles, function(file) {
            uploadedFileArr.push({'Id' : file.documentId,'Name': file.name});
            component.set("v.fileNameJs",file.name);
            component.set("v.uploadedFileId",file.documentId);
            component.set("v.uploadedFileName",file.name);
            sObjectAttachedFilesArr.push({'Id' : file.documentId,'Title': file.name});
        });
        component.set("v.sObjectAttachedFiles", sObjectAttachedFilesArr);
        var filesUploadedPreviously = component.get('v.uploadedFiles');
        if(filesUploadedPreviously != null && filesUploadedPreviously != undefined && filesUploadedPreviously.length > 0){
            [].forEach.call(filesUploadedPreviously, function(file) {
                uploadedFileArr.push({'Id' : file.Id,'Name': file.Name});
            });
        }
        console.log('****'+JSON.stringify(uploadedFileArr));
        component.set("v.uploadedFiles",uploadedFileArr);
    },
    handleSaveClick : function(component, event, helper){
        component.set("v.showLoader",true);
        var sObjectId = component.get("v.sObjectId");
        console.log("****"+JSON.stringify(component.get("v.uploadedFiles")));
        let uploadedFiles = component.get("v.uploadedFiles");
        helper.apexUtil(component,helper,'cloneAndInsertContentDocumentLinkRecord',{
            recordId : sObjectId,
            documentObjectId : uploadedFiles[0].Id
        })
        .then(function(result){
            console.log("new object details*****"+JSON.stringify(result));
            component.set("v.showLoader",false);
        })
    },
    apexUtil : function(component,helper, apexMethod, params ) {
        return new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c."+apexMethod+"");
            action.setParams( params );
            action.setCallback( this , function(response) {
                if(response.getState()=='SUCCESS') {
                    resolve( response.getReturnValue() );
                }else if(response.getState()=='ERROR') {    
                    console.log("error::"+JSON.stringify(response.getError()));
                    helper.errorUtil(component,'Error',response.getError()[0].message,'error');                    
                    component.set("v.showLoader",false);
                }
            });
            $A.enqueueAction( action );
        }));    
    },
    errorUtil : function(component,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:'1000',
            key: 'error_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
        component.set("v.showLoader",false);
    },
    
    goRegistrationSummaryPage : function(component, event,helper,isCheckValidation,skipcaptcha) {
        
        var count;
        var captchaVerify =  component.get("v.captchaVerify");
        if (skipcaptcha){
            captchaVerify = true;
        }
        
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
        if(!captchaVerify ){
            component.set('v.hideCaptcha' , true);
        }
        if(Phonevalue !== undefined && Phonevalue !== '' ){
            if(AddressLinevalue !== '' && AddressLinevalue !== undefined){
                if(CountryValue !== '' && CountryValue != undefined && CountryValue !== 'false'){                
                    if(stateValue !== undefined && stateValue !== '' && stateValue !== 'false' ){
                        if(BillingCityValue !== '' && BillingCityValue !== undefined){
                            if(PostalCodeValue !== '' && PostalCodeValue !== undefined){
                                if(captchaVerify){
                                    if (isCheckValidation == false) {
                                        return false;
                                    }
                                    if(isCheckValidation){
                                        component.set('v.intCurrentStep', 4);
                                        component.set('v.isYourDeliveryCompleted', true);
                                        helper.updateCss(component, event, helper);
                                        //update billingStateValue,billingCountryValue
                                        var stateList = component.get("v.states");
                                        var selectedStateCode = component.find("stateId").get("v.value");
                                        stateList.forEach(function(state) {
                                            if(state.value == selectedStateCode){
                                                component.set("v.billingStateValue",state.label);
                                            }
                                        });
                                        
                                        var countryList = component.get("v.fieldMap");
                                        var selectedCountryCode = component.find("CountryId").get("v.value");
                                        countryList.forEach(function(country) {
                                            if(country.value == selectedCountryCode){
                                                component.set("v.billingCountryValue",country.label);
                                            }
                                        });
                                        
                                        helper.helperMethodForProductRegistrationSummery(component, event,helper);
                                        return true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    },
    
    goOnApplianceRegisterSummaryPage : function(component, event, helper,isCheckValidation) { 
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
      //  var selectedSubProductValue = component.find("selectedSubProductId").get("v.value");
        var selectedModelId = component.find("selectedModelId");
        var selectedModelValue = selectedModelId.get("v.value");
        var placeOfPurchaseId = component.find("placeOfPurchaseId");
        var placeOfPurchaseValue = placeOfPurchaseId.get("v.value");
        var dobId = component.find("dobId");
        var selectedDOBValue = dobId.get("v.value");
        var dateOfPurchaseId = component.find("dateOfPurchaseId");
        var selectedDateOfPurchaseValue = dateOfPurchaseId.get("v.value");
        
       
        if(component.get("v.showGift")){
        var chooseYourGiftId = component.find("chooseYourGiftId");
        var chooseYourGiftValue = chooseYourGiftId.get("v.value");
        }
   
           if(selectedDOBValue ==='' || selectedDOBValue === undefined ){
            var cmpDiv = component.find('enableDOBError');
            var showGiftError = true;
        	$A.util.addClass(cmpDiv, 'slds-has-error');
            component.set('v.hideBirthDate' , true);
        } 
        
         if(selectedDateOfPurchaseValue ==='' || selectedDateOfPurchaseValue === undefined ){
            var cmpDiv = component.find('enableDateOfPurchaseError');
            var showGiftError = true;
        	$A.util.addClass(cmpDiv, 'slds-has-error');
            component.set('v.hideDateOfPurchase' , true);
        } 
         if(chooseYourGiftValue ==='' || chooseYourGiftValue === undefined && component.get("v.showGift")){
            var cmpDiv = component.find('enableChooseGiftError');
            var showGiftError = true;
        	$A.util.addClass(cmpDiv, 'slds-has-error');
            component.set('v.hideChooseGift' , true);
        } 
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
        if(selectedSubProductValue !='' && selectedModelValue !='' && placeOfPurchaseValue !='' && selectedDOBValue !='' && selectedDateOfPurchaseValue !='' &&  !component.get("v.isFileUploaded") && blank==0   && !showGiftError ){
            if (isCheckValidation == false) {
                return false;
            }
            if(isCheckValidation){
                component.set('v.intCurrentStep', 3);
                component.set('v.isYourPurchaseCompleted', true);
                helper.updateCss(component, event, helper);
                helper.helperMethodForProductRegister(component, event, helper);
            }
        }
    }, 
})