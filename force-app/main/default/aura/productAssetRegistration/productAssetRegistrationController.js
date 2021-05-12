({
    doInit: function(component, event, helper) {
       //helper.getPicklistValues(component, event); 
       //helper.getStatePicklistValues(component, event); 
    },
    //handle country Picklist Selection
    handleOnChange : function(component, event, helper) {
       // helper.getStatePicklistValues(component, event); 
    },
    createRegistration : function(component, event) {
        component.find("recordEditFormSubmit").submit();
    },
})