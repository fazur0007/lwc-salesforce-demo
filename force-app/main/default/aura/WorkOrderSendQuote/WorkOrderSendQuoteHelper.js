({
    doInit : function(component, event, helper) {
        helper.apexUtil(component,helper,'sendQuote',{ recordId : component.get("v.recordId")})
        .then(function(result){
            window.caseconfig = result;
            console.log(JSON.stringify(caseconfig));
            component.set("v.caseconfig",result);
            component.set("v.showLoader",false);
        })
    },
    handleBrandValue : function(component, event, helper) {
        let caseconfig = component.get("v.caseconfig");
        let optionValue = component.get("v.optionValue");
        if(caseconfig.isReturnBoxNeeded && optionValue === 'Yes'){
            caseconfig.createOrderPanel = true;
            caseconfig.createBoxOrder = 'No';
            component.set("v.isBoxorderoptionshow",true);
        }else{
            caseconfig.createOrderPanel = false;
            caseconfig.createBoxOrder = 'No';
            component.set("v.isBoxorderoptionshow",false);
        }
    },
    doSubmit :function (component,event,helper){
        component.set("v.showLoader",true);
        let caseconfig = component.get("v.caseconfig");
        let optionValue = component.get("v.optionValue");
        if(optionValue === "Yes"){
            caseconfig.createReturnLabel = "Yes";
        }else{
            caseconfig.createReturnLabel = "No";
        }
        let boxorderoption =  component.get("v.Boxorderoption");
        if(boxorderoption === "Yes"){
            caseconfig.createBoxOrder = "Yes";
        }else{
            caseconfig.createBoxOrder = "No";
        }
        helper.apexUtil(component,helper,'submitResponse',{
            recordId : component.get("v.recordId"),
            createReturnLabel : caseconfig.createReturnLabel,
            createBoxOrder : caseconfig.createBoxOrder,
            createOrderPanel : caseconfig.createOrderPanel,
            quoteSent : caseconfig.quoteSent,
            hidePanels : caseconfig.hidePanels
        })
        .then(function(result){
            console.log(JSON.stringify(result));
            let quoteSent = result.Send_Quote__c ? result.Send_Quote__c : result.quoteSent;
            if(quoteSent){
                helper.errorUtil(component,'Work Order Success !',"Quote Sent Successfully",'success');                    
                helper.navigationUtil(component,"view","WorkOrder",component.get("v.recordId"));  
                component.set("v.showLoader",false);
            }
        });
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
                    helper.navigationUtil(component,"view","WorkOrder",component.get("v.recordId"));  
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