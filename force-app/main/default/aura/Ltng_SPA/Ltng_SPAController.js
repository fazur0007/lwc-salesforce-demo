({
    doInit : function(component, event, helper) {
        helper.apex(component,helper,'getWorkOrderRecordTypeID',{ recordId : component.get("v.recordId")}) 
        .then(function(result){
            window.configObjectDetails = result;
            console.log(JSON.stringify(result));
            if(result.userInfo[0] && result.userInfo[0].Contact)
            {
                component.set("v.showOrderForAdmin",true);
                window.CurrencyIsoCode = result.userInfo[0].Contact.Account.CurrencyIsoCode;
                window.workOrderRecordTypeId = result.workOrderId;
            }else{
                component.set("v.showOrderForAdmin",false);
                window.CurrencyIsoCode = 'USD';
                window.workOrderRecordTypeId = result.workOrderId;
            }
        });
    },
    createWorkRecord : function(component, event, helper) {
        component.set("v.showLoader",true);
        component.set("v.showWorkOrder",true); 
        component.set("v.showSinglePageApplication",false);
        component.set("v.isKnowledgeSearch",true);
        component.set("v.isCommunityShow",true);
        component.set("v.isRMAEnabled",true);
        component.set("v.showLoader",false);
    },
    doCreateNewWorkOrder :function(component, event, helper) {
        console.log("CurrencyIsoCode*****"+CurrencyIsoCode);
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "WorkOrder",
            "defaultFieldValues": {
                "CurrencyIsoCode": CurrencyIsoCode,
            },
            recordTypeId: workOrderRecordTypeId
        });
        createRecordEvent.fire();
    },
    createOrderRecord :function(component, event, helper) {
        component.set("v.isCommunityShow",false);
        component.set("v.showNewOrder",true);
        component.set("v.isKnowledgeSearch",true);
        component.set("v.showSinglePageApplication",true);
    },
    createRecord :function(component, event, helper) {
        component.set("v.isRMAEnabled",false);
        component.set("v.isKnowledgeSearch",true);
        component.set("v.showSinglePageApplication",true);
    },
    createNewRMA : function(component, event, helper) {
        helper.doLoadData(component, event, helper); 
    },
    searchknowledgeBase : function(component, event, helper) {
        component.set("v.isKnowledgeSearch",false);
        component.set("v.showSinglePageApplication",false);
        component.set("v.isCommunityShow",true);
        component.set("v.isRMAEnabled",true);
    },
    doCreateNewOrder : function(component, event, helper) {
        
        
        if(configObjectDetails.userInfo[0].IsPortalEnabled){
            component.set("v.isCommunityShow",false);
            component.set("v.showNewOrder",false);
            component.set("v.showSinglePageApplication",false);
            component.set("v.isKnowledgeSearch",true);
        }else{
            component.set("v.isCommunityShow",false);
            component.set("v.showNewOrder",false);
            component.set("v.showSinglePageApplication",false);
            component.set("v.isKnowledgeSearch",true);
            
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "Order"
            });
            createRecordEvent.fire();
            component.set("v.showLoader",false);
        }
    },
    onPicklistChange : function(component, event, helper) {
        alert("hello there");
    },
    doRedirectQCAlerts : function(component,event,helper){
        component.set("v.isKnowledgeSearch",true);
        component.set("v.showSinglePageApplication",false);
        component.set("v.isCommunityShow",true);
        component.set("v.isRMAEnabled",true);
        component.set("v.isQCAlertsEnabled",false);
    }
})