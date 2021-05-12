({
    createAccountRecord : function (component, event, helper) {
        component.set("v.showLoader",true);
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Account"
        });
        createRecordEvent.fire();
        component.set("v.showLoader",false);
    },
    handleClickAccountName: function(component, event, helper) {
        component.set("v.showLoader",true);
        const target = event.currentTarget;
        alert(target.dataset.sfid);
        const sfid = target.dataset.sfid;
        var navigateEvent = $A.get("e.force: navigateToSObject");
        navigateEvent.setParams({
            "recordId": sfid
        });
        navigateEvent.fire();
        component.set("v.showLoader",false);
    },
    handleNameFilterChange: function(component, event, helper){
        component.set("v.showLoader",true);
        //if (event.which == 13){
        //component.set("v.showLoader",true);
        component.set('v.issearching', true);
        helper.apex(component,'searchAllAccounts',{
            nameFilterString : component.find('enter-search').get('v.value')
        })
        .then(function(result){
            console.log(JSON.stringify(result));
            component.set("v.accounts", result);
            component.set('v.issearching', false);
            //component.set("v.showLoader",false);
            component.set("v.showLoader",false);
        })
        //}
    },
    redirectToAccount : function(component, event, helper) { 
        component.set("v.showLoader",true);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.currentTarget.getAttribute("data-attriVal"),
            "slideDevName": "related"
        });
        navEvt.fire();
        component.set("v.showLoader",false);
    },
    onSelectMenuItem : function(component, event, helper) {
        component.set("v.showLoader",true);
        var selectedOption = event.getParam("value");
        var selectedId = selectedOption.split('---')[0];
        if (selectedOption.split('---')[1] === "NewOrder") {            
            console.log('new order id to delete:'+selectedId);
            component.set("v.isSelectedNewOrder",true);
            component.set("v.openModal",true);
            component.set("v.recordId",selectedId);
            component.set("v.showLoader",false);
        }else if(selectedOption.split('---')[1] === "View"){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": selectedId,
                "slideDevName": "related"
            });
            navEvt.fire();
            component.set("v.showLoader",false);
        }else if(selectedOption.split('---')[1] === "Edit"){
            var editRecordEvent = $A.get("e.force:editRecord");
            editRecordEvent.setParams({
                "recordId": selectedId
            });
            editRecordEvent.fire();
            component.set("v.showLoader",false);
        }
    },
    handleOpenModal: function(component, event, helper) {
        component.set("v.showLoader",true);
        //For Display Modal, Set the "openModal" attribute to "true"
        component.set("v.openModal", true);
        component.set("v.showLoader",false);
    },
    
    handleCloseModal: function(component, event, helper) {
        //For Close Modal, Set the "openModal" attribute to "fasle"  
        component.set("v.openModal", false);
    }
})