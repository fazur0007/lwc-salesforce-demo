({
    raiseToast : function(component,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:'1000',
            key: 'error_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
        component.set("v.showLoader",false);
    }
})