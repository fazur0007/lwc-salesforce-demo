({
    getAssets : function(component, event, helper) {
        helper.getAssets(component, event, helper);
    },
    onChangeM : function (component, event, helper) {
        component.set("v.selectedRecord",event.getSource().get('v.value'));
    },
    doSubmitAssets :  function (component, event, helper) {
        helper.doSubmitAssets(component, event, helper);
    },
    closeModal: function(component, event, helper) {
        component.set("v.showWarning", false);
    },
    confirm :  function (component, event, helper) {
        helper.saveDetails(component, event, helper);
    }
})