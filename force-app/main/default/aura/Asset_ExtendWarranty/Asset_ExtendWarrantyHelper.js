({
    getExtendedWarrantyList : function(component,event,helper){
        
        var assetId = component.get("v.recordId");
        helper.apex(component,helper,'validateAssetProduct',{ assetId : assetId })
        .then(function(result){
            console.log('===validateAssetProduct==='+JSON.stringify(result));
            if(result){
                return helper.apex(component,helper,'getExtendedWarrantyList',{ assetId : assetId });
            }   
        })
        .then(function(result){
            console.log('===getExtendedWarrantyList==='+JSON.stringify(result));
            
            if(result != null){
                var extendedWarrantyList = [];
                for(var key in result){
                    extendedWarrantyList.push({label: result[key], value: key});
                }
                console.log('===ExtendedWarrantyList==='+ extendedWarrantyList);
                console.log("===extendedWarrantyList==="+JSON.stringify(extendedWarrantyList));
                component.set("v.extendedWarrantyList", extendedWarrantyList);
                component.set("v.showLoader",false);
            }else{
                helper.showToast(component,'Error!','Error! Order creation failed.','error');
            	component.set("v.showLoader",true);
        		//$A.get("e.force:closeQuickAction").fire();
        		//$A.get('e.force:refreshView').fire();
        		component.set("v.showLoader",false);
            }   
        })
        .catch(function(error) {
            console.log("error values ::"+JSON.stringify(error));
        });
    },
    handleSubmit : function(component,event,helper){
        component.set("v.showLoader",true);
        var assetId = component.get("v.recordId");
        var selectedExtWarranty =  component.get("v.extWarrantyValue");
        console.log('===selectedExtWarranty==='+ selectedExtWarranty);
        //console.log("===extendedWarranty==="+component.find("extendedWarranty").get("v.value"));
        
        helper.apex(component,helper,'createOrder',{ warrProdId : selectedExtWarranty, assetId : assetId })
        .then(function(result){
            console.log('===result==='+result);
            console.log('===createOrder==='+JSON.stringify(result));
            var newOrderId = result;

            if(result != null){
            	helper.showToast(component,'Success!','Order created successfully','success');
            	console.log("===Order Created===");
                helper.navigationUtil(component,"view","Order",newOrderId);                  
            }
            component.set("v.showLoader",false);
        })
        .catch(function(error) {
            console.log("error values ::"+JSON.stringify(error));
        });
        
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
                    helper.showToast(component,'Error',callbackResult.getError()[0].message,'error');
                    reject( callbackResult.getError()[0].message);
                    
                    component.set("v.showLoader",true);
        			$A.get("e.force:closeQuickAction").fire();
        			$A.get('e.force:refreshView').fire();
        			component.set("v.showLoader",false);
                }
            });
            $A.enqueueAction( action );
        }));            
        return p;
    },
    showToast : function(component,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 2000',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
        component.set("v.showLoader",false);
    },
    navigationUtil : function(component,actionName,objectApiName,recordId){
        console.log('===inside navigationUtil===');
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
});