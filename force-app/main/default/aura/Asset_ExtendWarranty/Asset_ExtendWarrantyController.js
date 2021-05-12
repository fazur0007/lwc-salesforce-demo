({
	doLoadData :function(component, event, helper) {
        helper.getExtendedWarrantyList(component, event, helper);        
    },
    handleCancel : function(component, event, helper) {
        component.set("v.showLoader",true);
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        component.set("v.showLoader",false);
    },
    handleSubmit : function(component, event, helper) {
        helper.handleSubmit(component, event, helper);
    }
})