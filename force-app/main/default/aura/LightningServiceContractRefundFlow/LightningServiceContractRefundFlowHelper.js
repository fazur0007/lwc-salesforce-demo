({
    doSubmitAssets : function (component, event, helper){
        component.set("v.showLoader",true);
        const selectedRecord = component.get("v.selectedRecord");
        const data = component.get("v.data");
        if(selectedRecord){
            for (var item of data){      
                if(item.Id === selectedRecord) {
                    if (item.isReturnSC) {
                        component.set("v.showLoader", false);
                        component.set("v.showWarning", true);
                    } else {
                        helper.saveDetails(component, event, helper);
                    }
                }
            }
        } else {
            helper.errorUtil(component,'Record Selection Warning','Please select atleast one row','warning');
        }
    },
    saveDetails : function (component, event, helper){
        component.set("v.showLoader",true);
        const newAssetList = [];
        const selectedRecord = component.get("v.selectedRecord");
        const data = component.get("v.data");
        let caseId = component.get("v.recordId"); 
        if(selectedRecord){
            for (var item of data){      
                if(item.Id === selectedRecord) {
                    console.log("item json***"+JSON.stringify(item));
                    console.log("item json***"+caseId);
                    helper.apex(component,helper,'doUpdateAssets',{
                        recordId: caseId,
                        newAssetList : JSON.stringify(item)
                    })
                    .then(function(result){
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                        helper.errorUtil(component,'Success Alert','Record has been updated succefully!','success');
                        helper.navigationUtil(component,"view","Case",component.get("v.recordId"));
                        component.set("v.showLoader",false);
                    })
                }
            }
        }else{
            helper.errorUtil(component,'Record Selection Warning','Please select atleast one row','warning');
        }
    },
    getAssets : function(component,event,helper){
        component.set("v.showLoader",true); 
        helper.apex(component,helper,'getAssetDetails',{
            recordId : component.get("v.recordId") 
        })
        .then(function(result){
            if (result.isSuccess) {
                component.set("v.data", result.assets);
            } else {
                helper.errorUtil(component,'Case', result.error,'error');
                helper.navigationUtil(component,"view","Case",component.get("v.recordId"));
            }
            component.set("v.showLoader",false);
        });
    },
    errorUtil : function(component,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:'5000',
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
                if (callbackResult.getState() == 'SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if (callbackResult.getState() == 'ERROR') {
                    const fieldErrors = callbackResult.getError()[0].fieldErrors;
                    const pageErrors = callbackResult.getError()[0].pageErrors;
                    let errorMsg = '';
                    if (fieldErrors) {
                        for (const fieldName in fieldErrors) {
                            const errs = fieldErrors[fieldName];
                            for (const index in errs) {
                                errorMsg +=  fieldName + ': ' + errs[index].message + ' \n';
                            }
                        }
                    }
                    if (pageErrors) {
                        for (const pageError of pageErrors) {
                            errorMsg += pageError.message + ' \n';
                        }
                    }
                    if (errorMsg) {
                        helper.errorUtil(component,'Error', errorMsg,'error');
                        component.set("v.showLoader",false);
                    } else {
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