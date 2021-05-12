({
    createRecord : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "WorkOrder",
            "recordTypeId": "0120L000000DHv2"
        });
        createRecordEvent.fire();
    }
})