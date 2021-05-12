({
    getCurrentRecordDetails : function(component, event, helper) {
        helper.apexUtil(component,helper,'getOrderRecord',{ recordId : component.get("v.recordId")})
        .then(function(result){
            window.orderDetails = result;
            component.set("v.orderDetails",result);
            helper.handleCalculate(component, event, helper);
            component.set("v.showLoader",false);
        })
    },
    handleCalculate : function(component,event,helper){
        component.set("v.showLoader",true);
        console.log("orderDetails type ::"+JSON.stringify(component.get("v.orderDetails")));
        if (orderDetails.AccountType === 'Retailer') {
            if (orderDetails.RequestedShipDate) {
                if (orderDetails.ActivatedDate) {
                    helper.errorUtil(component,'Error',"You cannot perform re-calculation on activated order",'error');
                }else{
                    helper.apexUtil(component,'handleCalculateRecalculate',{ recordId : orderDetails.Id})
                    .then(function(result){
                        helper.errorUtil(component,'Success','Calculation is completed successfully','success'); 
                        helper.navigationUtil(component,"view","Order",component.get("v.recordId"));
                    })
                }                
            }else {
                helper.errorUtil(component,'Please enter Requested Ship Date first.','Order cannot be cancelled, Order has already been sent to AX','warning'); 
                helper.navigationUtil(component,"view","Order",component.get("v.recordId"));
            }
        }else {
            helper.errorUtil(component,'Alert','This function is only applicable for retailers','warning'); 
            helper.navigationUtil(component,"view","Order",component.get("v.recordId"));
            
        }
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