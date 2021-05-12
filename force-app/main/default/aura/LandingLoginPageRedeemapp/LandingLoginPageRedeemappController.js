({
    handleClick: function(cmp, event, helper) {
        var navService = cmp.find("applianceRegister");
        // Uses the pageReference definition in the init handler
        var pageReference = cmp.get("v.pageReference");
        event.preventDefault();
        navService.navigate(pageReference);
    }
})