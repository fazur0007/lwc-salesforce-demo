({
    init : function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var flow = component.find("flowData");
        var flowInputVariables = [
            { name : "caseId", type : "String", value: recordId }
        ];	
        var action = component.get("c.GetFlowName");
        action.setParams({ "CaseId" : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert(response.getReturnValue());
                var resultObj = response.getReturnValue();
                if(resultObj.isError)
                {
                    //alert(resultObj.ErrorMessage);
                    helper.raiseToast(component,'Troubleshoot',resultObj.ErrorMessage,'error');                   
                    $A.get("e.force:closeQuickAction").fire();                    
                }
                else
                {
                	flow.startFlow(resultObj.Name,flowInputVariables);
                }
            } 
            else {
                console.log(state);
                //flow.startFlow("Espresso_With_Grinder_Troubleshoot_Flow",flowInputVariables);
            }
        });
        $A.enqueueAction(action);        
    },
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        }
    }
})