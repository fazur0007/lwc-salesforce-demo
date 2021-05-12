({
    doInit : function(component, event, helper) { 
        helper.doInit(component, event, helper); 
    },
    handleBrandValue : function(component, event, helper) {
        helper.handleBrandValue(component, event, helper);
    },
    doSubmit :  function(component,event,helper){
        helper.doSubmit(component,event,helper);        
    },
    handleCancel : function(component, event, helper) {
        component.set("v.showLoader",true);
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        component.set("v.showLoader",false);
    },
})