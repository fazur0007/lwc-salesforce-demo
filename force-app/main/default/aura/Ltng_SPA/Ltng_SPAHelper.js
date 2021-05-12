({
    doLoadData : function(component,event,helper){
        component.set("v.showLoader",true);
        helper.apex(component,helper,'doGetConfigDetails',{ recordId : null })
        .then(function(result){
            console.log(result.RecordTypeId+"******result******"+JSON.stringify(result));
            window.config = result;
            var createRecordRMACase = $A.get("e.force:createRecord");
            createRecordRMACase.setParams({
                "entityApiName": "Case",
                "defaultFieldValues": {
                    "AccountId": config.AccountId,
                    "ContactId": config.ContactId,
                    "RecordTypeId": config.RecordTypeId,
                    "Origin": config.Origin,
                    "Type": config.Type, 
                    "CurrencyIsoCode": config.CurrencyIsoCode,
                    "Pickup_Address_1__c": config.Pickup_Address_1__c,
                    "Pickup_City__c": config.Pickup_City__c,
                    "Pickup_Postal_Code__c": config.Pickup_Postal_Code__c,
                    "Pickup_State__c": config.Pickup_State__c,
                    "Pickup_Country__c": config.Pickup_Country__c,
                    "Consignee_Contact_Name__c": config.Consignee_Contact_Name__c,
                    "Consignee_Email__c": config.Consignee_Email__c,
					"Consignee_Phone__c" : config.Consignee_Phone__c ,
                },
                recordTypeId: config.RecordTypeId
            });
            createRecordRMACase.fire();
            component.set("v.showLoader",false);
        });
    },
    errorUtil : function(component,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 1000',
            key: 'error_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
        component.set("v.showLoader",false);
    },    
    fetchDepValues: function(component, ListOfDependentFields) {
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        component.set("v.listDependingValues", dependentFields);        
    },
    apex : function( component,helper, apexAction, params ) {
        var p = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this , function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    helper.errorUtil(component,'Error',callbackResult.getError()[0].message,'error');
                    reject( callbackResult.getError()[0].message);
                }
            });
            $A.enqueueAction( action );
        }));            
        return p;
    },
    navigationUtil : function(component,actionName,objectApiName,recordId){
        var navLink = component.find("navLink");
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: actionName,
                objectApiName: objectApiName,
                recordId : recordId
            },
        };
        navLink.navigate(pageRef, true);
    }
})