({
    doCancelSubscription : function (component, event, helper) { 
        var selectedEventId = event.target.id;
        var msg ='Are you sure you want to cancel this item?';
        if (!confirm(msg)){
            console.log('No');
            return false;
        }else {
            component.set("v.showLoader",true); 
            helper.apex(component,helper,'doCancelSubscriptionAPI',{ 
                selectedBrand : component.get("v.brandOption"),
                accountId : component.get("v.recordId"),
                subscriptionId : event.getSource().get('v.value')
            })
            .then(function(result){
                   helper.doGetSubscriptionsFromEP(component,event,helper);
            });
        }
    },
    doGetSubscriptionsFromEP : function(component,event,helper){
        component.set("v.showLoader",true); 
        helper.apex(component,helper,'getSubscriptions',{
            selectedBrand : component.get("v.brandOption"),
            accountId : component.get("v.recordId"),
            pageSize : 10,
            pageNumber : 20
        })
        .then(function(result){  
            component.set("v.orderData",null); 
            component.set("v.showOrders",false);            
            console.log("result*****"+JSON.stringify(result));
            component.set("v.subscriptionResultTemp",result);
            if(result.status === "SUCCESS"){
                component.set("v.subscriptionResult",result);
                let brevilleStoreCodes = ["brevilleCA","brevilleUS","sageUK","sageEU","sageCH","brevilleAU","brevilleNZ"];
                if(result.subscriptions!=null && result.subscriptions.length>0)
        		{
                    let resultBreville = result.subscriptions.filter(function(item){
                        return brevilleStoreCodes.includes(item.storeCode);
                    });
                    component.set("v.data",resultBreville);
                }
                
                component.set("v.Message",result.Message ? result.Message : "No subscriptions exist for the User");                
                component.set("v.showLoader",false);
            }else if(result.status === "ERROR"){
                component.set("v.Message",result.Message ? result.Message : "No subscriptions exist for the User"); 
                component.set("v.showLoader",false);
            }
        })
    },
    doGetProductDetails : function (component, event, helper) {
        component.set("v.highlightRow",event.getSource().get('v.value'));
        component.set("v.showLoader",true);         
        helper.apex(component,helper,'getOrders',{ 
            subscriptionId : event.getSource().get('v.value')
        })
        .then(function(result){  
            component.set("v.orderData",result);
            component.set("v.showOrders",true);
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