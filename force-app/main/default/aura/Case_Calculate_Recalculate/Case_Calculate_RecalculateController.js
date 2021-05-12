({
    doInit : function(component, event, helper) { 
        helper.doInit(component, event, helper); 
    },
    handleCancel : function(component, event, helper) {
        component.set("v.showLoader",true);
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        component.set("v.showLoader",false);
    },
    doConfirm :function(component, event, helper) { 
        helper.doConfirm(component, event, helper); 
    },
})