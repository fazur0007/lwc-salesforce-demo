({
    helperMethodForProduct : function(component, event, helper) { 
        var products1 = [{value:'',label:'',disabled:false}];
        var offersList = component.get("c.getOffers");
        
        offersList.setCallback(this, function(response){
            products1 = response.getReturnValue();
            component.set("v.productsList",products1);
            
        });
        $A.enqueueAction(offersList);
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
                var StoreResponse = response.getReturnValue();
                
                console.log("StoreResponse :"+StoreResponse);
                var responseForAUS = StoreResponse.AUS;
                console.log("responseForAUS :",responseForAUS);
                component.set("v.placeOfPurchaseList",responseForAUS);
                console.log("responseForAUS :",component.get("v.placeOfPurchaseList"));
                
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
        var action = component.get("v.isSummaryRegistration");
        var action = true;
        component.set("v.isProductDetails" , false);
        component.set("v.isDeliveryDetails" , false);
        component.set("v.isSummaryRegistration" , action);
        component.set("v.isThankYou" , false);
    },
    
    helperMethodForProductSummary : function(component, event, helper) {
        
        component.set("v.isProductDetails" , false);
        component.set("v.isDeliveryDetails" , true);
        component.set("v.isThankYou" , false);
        console.log("Asset Object to be Save>>>>"+ JSON.stringify(component.get("v.saveInAsset")));
        console.log("Account Object to be Save>>>>"+ JSON.stringify(component.get("v.newAccount")));
        var objectValue = component.get("v.saveInAsset");
        
        /**
        *This is for setting the Account & Asset details on summary Page 
        **/
        //    component.set("v.placeOfPurchase", pdcName);
        //   component.set("v.serialNumber", objectValue.input_type_id__c);
        //   component.set("v.placeOfPurchase", objectValue.surveyitelios_survey__c);
        //   component.set("v.dateOfPurchase", objectValue.dateOfPurchase);
        //   component.set("v.dateOfPurchase", objectValue.surveyitelios_survey__ct);
        
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
    
    //***********File upload Start****************//
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadHelper: function(component, event) {
        // start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });
        
        objFileReader.readAsDataURL(file);
    },
    
    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
    
    
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: component.get("v.parentId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        });
        
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    alert('your File is uploaded successfully');
                    component.set("v.showLoadingSpinner", false);
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    getCountryOptions: function(component, event) {
        var action = component.get("c.getCountryFieldValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({label: result[key], value: key});
                }
                component.set("v.countryOptions", fieldMap);
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
                component.set("v.statefieldMap", statefieldMap);
                console.log("statefieldMap Details>>>>"+ statefieldMap);
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
                
                // alert("From server: " + response.getReturnValue());
                component.set("v.Recid", response.getReturnValue()); 
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
        /*var selectedRecords = component.get("v.saveInAccount");
        var selectedRecordstr=JSON.stringify(selectedRecords);
        console.log('selectedRecordstr>>>>>>',selectedRecordstr);
        
        var selectedRecords1 = component.get("v.saveInAsset");
        var selectedRecordstr1=JSON.stringify(selectedRecords1);
        console.log('selectedRecordstr1>>>>>>',selectedRecordstr1);*/
        
    },
    
    customValidation: function(component, event,ValueName) {
      //  console.log('hi...',ValueName);
      //  console.log('Test>>>>',document.getElementById(ValueName));
      //  
        ValueName.setCustomValidity("Please Insert Value");
        ValueName.reportValidity();
        return;
    },
    
    //Progress indicator - start
    updateCss : function(component, event, helper) {
        let intCurrentStep = component.get('v.intCurrentStep');
        let circle = component.find('circle' +intCurrentStep);
        let label = component.find('label' +intCurrentStep);
        let line = component.find('line' +(intCurrentStep-1));
        
        $A.util.toggleClass(circle, 'activeStep');
        $A.util.toggleClass(circle, 'activeBackground');
        $A.util.toggleClass(label, 'activeLabel');
        $A.util.toggleClass(line, 'activeBackground');
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
        //$A.util.toggleClass(inactiveCircle, 'inactiveStep');
    },
    backUpdateCss : function(component, event, helper) {
        let intCurrentStep = component.get('v.intCurrentStep');
        let circle = component.find('circle' +intCurrentStep);
        let label = component.find('label' +intCurrentStep);
        let line = component.find('line' +(intCurrentStep-1));
        
        $A.util.toggleClass(circle, 'activeStep');
        $A.util.toggleClass(circle, 'activeBackground');
        $A.util.toggleClass(label, 'activeLabel');
        $A.util.toggleClass(line, 'activeBackground');
		$A.util.toggleClass(circle, 'inactiveStep');
        $A.util.removeClass(circle, 'inactiveStep'); 
        
        let inactiveCircle;
        let inactiveLabel;
        let inactiveLine;
        let intLastStep = component.get("v.intLastStep");
        if(intLastStep != intCurrentStep ){
            inactiveCircle = component.find('circle' +(intCurrentStep+1));
            inactiveLabel = component.find('label' +(intCurrentStep+1));
            inactiveLine = component.find('line' +intCurrentStep);
        }
        $A.util.removeClass(inactiveCircle, 'activeStep');
        $A.util.removeClass(inactiveCircle, 'activeBackground');
        $A.util.removeClass(inactiveLabel, 'activeLabel');
        $A.util.removeClass(inactiveLine, 'activeBackground');
        //$A.util.toggleClass(inactiveCircle, 'inactiveStep');
    }
    //Progress indicator - end
    
})({
    helperMethodForProduct : function(component, event, helper) { 
        var products1 = [{value:'',label:'',disabled:false}];
        var offersList = component.get("c.getOffers");
        
        offersList.setCallback(this, function(response){
            products1 = response.getReturnValue();
            component.set("v.productsList",products1);
            
        });
        $A.enqueueAction(offersList);
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
                var StoreResponse = response.getReturnValue();
                
                console.log("StoreResponse :"+StoreResponse);
                var responseForAUS = StoreResponse.AUS;
                console.log("responseForAUS :",responseForAUS);
                component.set("v.placeOfPurchaseList",responseForAUS);
                console.log("responseForAUS :",component.get("v.placeOfPurchaseList"));
                
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
        var action = component.get("v.isSummaryRegistration");
        var action = true;
        component.set("v.isProductDetails" , false);
        component.set("v.isDeliveryDetails" , false);
        component.set("v.isSummaryRegistration" , action);
        component.set("v.isThankYou" , false);
    },
    
    helperMethodForProductSummary : function(component, event, helper) {
        
        component.set("v.isProductDetails" , false);
        component.set("v.isDeliveryDetails" , true);
        component.set("v.isThankYou" , false);
        console.log("Asset Object to be Save>>>>"+ JSON.stringify(component.get("v.saveInAsset")));
        console.log("Account Object to be Save>>>>"+ JSON.stringify(component.get("v.newAccount")));
        var objectValue = component.get("v.saveInAsset");
        
        /**
        *This is for setting the Account & Asset details on summary Page 
        **/
        //    component.set("v.placeOfPurchase", pdcName);
        //   component.set("v.serialNumber", objectValue.input_type_id__c);
        //   component.set("v.placeOfPurchase", objectValue.surveyitelios_survey__c);
        //   component.set("v.dateOfPurchase", objectValue.dateOfPurchase);
        //   component.set("v.dateOfPurchase", objectValue.surveyitelios_survey__ct);
        
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
    
    //***********File upload Start****************//
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadHelper: function(component, event) {
        // start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });
        
        objFileReader.readAsDataURL(file);
    },
    
    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
    
    
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: component.get("v.parentId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        });
        
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    alert('your File is uploaded successfully');
                    component.set("v.showLoadingSpinner", false);
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    getCountryOptions: function(component, event) {
        var action = component.get("c.getCountryFieldValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({label: result[key], value: key});
                }
                component.set("v.countryOptions", fieldMap);
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
                component.set("v.statefieldMap", statefieldMap);
                console.log("statefieldMap Details>>>>"+ statefieldMap);
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
                
                // alert("From server: " + response.getReturnValue());
                component.set("v.Recid", response.getReturnValue()); 
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
        /*var selectedRecords = component.get("v.saveInAccount");
        var selectedRecordstr=JSON.stringify(selectedRecords);
        console.log('selectedRecordstr>>>>>>',selectedRecordstr);
        
        var selectedRecords1 = component.get("v.saveInAsset");
        var selectedRecordstr1=JSON.stringify(selectedRecords1);
        console.log('selectedRecordstr1>>>>>>',selectedRecordstr1);*/
        
    },
    
    customValidation: function(component, event,ValueName) {
      //  console.log('hi...',ValueName);
      //  console.log('Test>>>>',document.getElementById(ValueName));
      //  
        ValueName.setCustomValidity("Please Insert Value");
        ValueName.reportValidity();
        return;
    },
    
    //Progress indicator - start
    updateCss : function(component, event, helper) {
        let intCurrentStep = component.get('v.intCurrentStep');
        let circle = component.find('circle' +intCurrentStep);
        let label = component.find('label' +intCurrentStep);
        let line = component.find('line' +(intCurrentStep-1));
        
        $A.util.toggleClass(circle, 'activeStep');
        $A.util.toggleClass(circle, 'activeBackground');
        $A.util.toggleClass(label, 'activeLabel');
        $A.util.toggleClass(line, 'activeBackground');
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
        //$A.util.toggleClass(inactiveCircle, 'inactiveStep');
    },
    backUpdateCss : function(component, event, helper) {
        let intCurrentStep = component.get('v.intCurrentStep');
        let circle = component.find('circle' +intCurrentStep);
        let label = component.find('label' +intCurrentStep);
        let line = component.find('line' +(intCurrentStep-1));
        
        $A.util.toggleClass(circle, 'activeStep');
        $A.util.toggleClass(circle, 'activeBackground');
        $A.util.toggleClass(label, 'activeLabel');
        $A.util.toggleClass(line, 'activeBackground');
		$A.util.toggleClass(circle, 'inactiveStep');
        $A.util.removeClass(circle, 'inactiveStep'); 
        
        let inactiveCircle;
        let inactiveLabel;
        let inactiveLine;
        let intLastStep = component.get("v.intLastStep");
        if(intLastStep != intCurrentStep ){
            inactiveCircle = component.find('circle' +(intCurrentStep+1));
            inactiveLabel = component.find('label' +(intCurrentStep+1));
            inactiveLine = component.find('line' +intCurrentStep);
        }
        $A.util.removeClass(inactiveCircle, 'activeStep');
        $A.util.removeClass(inactiveCircle, 'activeBackground');
        $A.util.removeClass(inactiveLabel, 'activeLabel');
        $A.util.removeClass(inactiveLine, 'activeBackground');
        //$A.util.toggleClass(inactiveCircle, 'inactiveStep');
    }
    //Progress indicator - end
    
})