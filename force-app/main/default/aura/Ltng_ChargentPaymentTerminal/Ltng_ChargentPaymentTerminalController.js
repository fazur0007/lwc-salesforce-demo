({
    doLoadData : function(component, event, helper) {
        helper.apexUtil(component,'getOrderDetails',{ orderId : component.get("v.recordId")},helper)
        .then(function(result){
            console.log("rs ::"+JSON.stringify(result));
            window.orderDetails = result;
            component.set("v.ChargentOrders__Payment_Method",result);
            component.find("BillingCountry").set("v.value", result.ChargentOrders__Billing_Country__c);

            component.set("v.showLoader",false);
        })
        .catch(function(error) {
            component.set("v.showLoader",false);
        });
    },
    handleSubmit : function(component, event, helper) {
        component.set("v.showLoader",true);
        event.preventDefault();
        var gatewayValue = component.find("requiredField");
        console.log("late result ::"+JSON.stringify(event.getParam("fields")));
        console.log("gatewayValue "+ gatewayValue.get("v.value"));
        if(gatewayValue.get("v.value")){
            var eventFields = event.getParam("fields"); 
            console.log("eventFields "+ eventFields);
            helper.apexUtil(component,'createPaymentTerminal',{ paymentTerminal : JSON.stringify(eventFields)},helper)
            .then(function(result){
                //(JSON.stringify(result));
                console.log("INSIDE TRY ONE");
                helper.showModalHelper(component, event, helper,result);
                //helper.paymentRedirection(component, event, helper, result); 
                console.log("INSIDE TRY TWO");  
                component.set("v.showLoader",false); 
                console.log("INSIDE TRY THREE");
            })
            .catch(function(error) {
                console.log("json details error ::"+JSON.stringify(error));
                component.set("v.showLoader",false);
            });
        }else{ 
			/*
            var eventFields = event.getParam("fields");          
            helper.apexUtil(component,'createPaymentTerminal',{ paymentTerminal : JSON.stringify(eventFields)})
            .then(function(result){
                helper.showModalHelper(component, event, helper,result);
                //helper.paymentRedirection(component, event, helper, result);   
            })
            .catch(function(error) {
                console.log("json details error ::"+JSON.stringify(error));
            });
            */
            helper.errorUtil(component,'Required Fields Are Missing!',gatewayValue.get("v.class"),'error');
        }
    },
    handleSuccess : function(component, event, helper) {      
        component.set("v.showLoader",true);
        var params = event.getParams();  
        //alert(params.response.id);  
        component.set("v.showLoader",false);
    },
    handleSave : function(component, event, helper) {
        component.set("v.showLoader",true);
        component.find("recordEditForm").submit();
        component.set("v.showLoader",false);
    },
    handleCancel : function(component, event, helper) {
        component.set("v.showLoader",true);
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        component.set("v.showLoader",false);
    },
})