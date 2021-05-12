({
    getAccount : function(component,event,helper){
        component.set("v.showLoader",true); 
        helper.apex(component,helper,'getAccountData',{
            recordId : component.get("v.recordId") 
        })
        .then(function(result){
            var createRMACase = $A.get("e.force:createRecord");
            let country = '';
            switch(result.accountRecord.CurrencyIsoCode) {
                case 'GBP':
                    country = 'UK';
                    break;
                case 'EUR':
                    country = 'DE';
                    break;
                case 'CHF':
                    country = 'CH';
                    break;
                case 'AUD':
                    country = 'AUS';
                    break;
                case 'NZD':
                    country = 'NZ';
                    break;
                case 'CAD':
                    country = 'CAN';
                    break;
                default:
                    country = 'USA';
            }
            createRMACase.setParams({
                "entityApiName": "Case",
                "recordTypeId" : result.recordTypeId,
                "defaultFieldValues": {
                    "AccountId" : result.accountRecord.Id,
                    "CurrencyIsoCode" : result.accountRecord.CurrencyIsoCode,
                    "Pickup_Address_1__c" : result.accountRecord.Shipping_Street_Line_1__c,
                    "Pickup_Address_2__c" : result.accountRecord.Shipping_Street_Line_2__c,
                    "Pickup_State__c" : result.accountRecord.ShippingState,
                    "Pickup_City__c" : result.accountRecord.ShippingCity,
                    "Pickup_Postal_Code__c" : result.accountRecord.ShippingPostalCode,
                    "Pickup_Country__c" : result.accountRecord.ShippingCountry,
                    "Country__c" : country,
                    "RMA_Status__c" : "Open"
                }
            });
            component.set("v.showLoader",false);
            createRMACase.fire();
        })
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
    apex : function( component,helper, apexAction, params ) {
        var p = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this , function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    var validationError = callbackResult.getError()[0].message.includes("Validation Error");
                    if(validationError){
                        var mes = callbackResult.getError()[0].message.split(':');
                        helper.errorUtil(component,'Error',mes[1],'error');
                        component.set("v.showLoader",true);
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                        component.set("v.showLoader",false);
                    }else{
                        helper.errorUtil(component,'Error',callbackResult.getError()[0].message,'error');
                        reject( callbackResult.getError()[0].message);
                    } 
                }
            });
            $A.enqueueAction( action );
        }));            
        return p;
    }
})