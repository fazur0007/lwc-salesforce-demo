({
    getCurrentRecordDetails : function(component, event, helper) {
        helper.apexUtil(component,helper,'getOrderRecord',{ recordId : component.get("v.recordId")})
        .then(function(result){
            window.orderDetails = result;
            component.set("v.objectConfig",result);
            console.log("faz ::"+JSON.stringify(orderDetails));
            
            if (orderDetails.Status === "Order Generated" &&  orderDetails.Source === "AEM" && orderDetails.Channel === "ECOMM") {
                helper.apexUtil(component,'cancelOrder',{ orderRecord : orderDetails.Id})
                .then(function(result){
                    helper.errorUtil(component,'Order Success Alert','Process has been successfully completed','success');
                    helper.navigationUtil(component,"view","Order",component.get("v.recordId"));
                    component.set("v.showLoader",false);
                })
            }else{
                helper.errorUtil(component,'Order Warning','Order cannot be cancelled!","Order cannot be cancelled','warning');
            }
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
                    helper.navigationUtil(component,"view","Order",component.get("v.recordId"));  
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
        $A.get('e.force:refreshView').fire();
    },
})