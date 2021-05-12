({
    getMyOrders : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'View',type: 'button-icon',initialWidth: 75,typeAttributes: {iconName: 'action:preview',title: 'Preview',variant: 'border-filled',alternativeText: 'View'}},
            {label: 'Order Id', fieldName: 'orderId', type: 'text'},
            {label: 'Order Number', fieldName: 'orderNumber', type: 'text'},
            {label: 'Order Key', fieldName: 'orderKey', type: 'text'},
            {label: 'Order Date', fieldName: 'orderDate', type: 'date'},
            {label: 'Order Status', fieldName: 'orderStatus', type: 'text'},
            {label: 'Carrier Code', fieldName: 'carrierCode', type: 'text'},
        ]);
        component.set("v.showLoader",true); 
        helper.apex(component,helper,'GetOrders')
        .then(function(result){  
            console.log("result*****"+JSON.stringify(result.orders));
            if(result.orders.length > 0 ){
                component.set("v.data",result.orders);
                component.set("v.showLoader",false);
            }else{
                helper.errorUtil(component,'My Orders',"No records found",'error');
                component.set("v.showLoader",false);
            }
            
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
    apex : function( component,helper, apexAction ) {
        var p = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c."+apexAction+"");
            //action.setParams( params );
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