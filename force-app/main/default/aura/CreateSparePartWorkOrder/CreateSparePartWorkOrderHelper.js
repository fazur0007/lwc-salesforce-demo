({
    doInit : function(component,event,helper) {
        helper.apex(component,helper,'doLoadInitData',{ workOrderId : component.get("v.recordId") })
        .then(function(result){
            console.log("result ::"+JSON.stringify(result));
            component.set("v.data",result);
            component.set("v.showLoader",false);
        })
    },
    doSaveLineItems : function(component, event, helper){
        component.set("v.showLoader",true);
        var data = component.get("v.data");
        if(data){
            var newProductList = [];
            for (var item of data){      
                if(item.isSelected)
                {
                    newProductList.push(item);
                }                        
            }
            if(Array.isArray(newProductList) && newProductList.length > 0){
                console.log("selecte array ::"+JSON.stringify(newProductList));
                
                helper.apex(component,helper,'createsparePartOrder',{
                    workOrderId : component.get("v.recordId"),
                    selectedOrderProducts : JSON.stringify(newProductList)
                })
                .then(function(result){
                    helper.navigationUtil(component,"view","Order",result);
                    component.set("v.showLoader",false);
                })
            }else{
                helper.errorUtil(component,'Warning',"Please select items to add in an Order",'warning');
            }
        }else{
            helper.errorUtil(component,'Warning',"Please select items to add in an Order",'warning');
        }
    },
    handleCancel : function(component, event, helper) {
        component.set("v.showLoader",true);
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
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
                    helper.errorUtil(component,'Error',callbackResult.getError()[0].message,'error');
                    reject( callbackResult.getError()[0].message);
                }
            });
            $A.enqueueAction( action );
        }));            
        return p;
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