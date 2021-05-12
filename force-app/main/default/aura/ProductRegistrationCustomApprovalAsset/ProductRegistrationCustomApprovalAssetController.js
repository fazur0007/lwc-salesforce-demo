({
	getProcessInstanceId : function(component, event, helper) {
        var action = component.get('c.getWorkItemId');
        action.setParams({
            "targetObjectId" : component.get('v.recordId') 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.processInstanceId",response.getReturnValue());
                component.set("v.spinner",false);
            }
            else {
                component.set("v.spinner",false);
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
	},
    handleApprove : function(component, event, helper) {
        component.set("v.spinner",true);
        var comments = component.find('comments');
        var commentsValue = comments.get('v.value');
        var approvalRejectionReason = component.find('aprovalRejectionReason');
        $A.util.removeClass(comments, 'slds-has-error');
        $A.util.removeClass(approvalRejectionReason, 'slds-has-error');
        component.set("v.commentsError",false);
        component.set("v.rejectedReasonError",false);
        
        
        var action = component.get('c.approveRecord');
        action.setParams({
            "targetObjectId" : component.get('v.recordId'),
            "comments" : commentsValue
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == 'sucess') {
                    component.set("v.spinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": 'success',
                        "message": "Approved SucessFully !!."
                    });
    				toastEvent.fire();
                    // Close the action panel
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
            }
            else {
                component.set("v.spinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "error!",
                    "type": 'error',
                    "message": response.getReturnValue()
                });
                toastEvent.fire();
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
		
	},
 	handleReject : function(component, event, helper) {
        component.set("v.spinner",true);
        var comments = component.find('comments');
        var commentsValue = comments.get('v.value');
        var approvalRejectionReason = component.find('aprovalRejectionReason');
        var approvalRejectionReasonValue = approvalRejectionReason.get('v.value');
        var isErrorFound = false;
        if(commentsValue == undefined || commentsValue == ''){
            component.set("v.spinner",false);
            $A.util.addClass(comments, 'slds-has-error');
            component.set("v.commentsError",true);
            isErrorFound = true;
        }
        if(approvalRejectionReasonValue == undefined || approvalRejectionReasonValue == ''){
            component.set("v.spinner",false);
            $A.util.addClass(approvalRejectionReason, 'slds-has-error');
            component.set("v.rejectedReasonError",true);

            isErrorFound = true;
        }
        if (isErrorFound){
            return;
        } else {
            $A.util.removeClass(comments, 'slds-has-error');
            $A.util.removeClass(approvalRejectionReason, 'slds-has-error');
            component.set("v.commentsError",false);
            component.set("v.rejectedReasonError",false);

        }
        var action = component.get('c.rejectRecord');
        action.setParams({
            "targetObjectId" : component.get('v.recordId'),
            "rejectedReason" : approvalRejectionReasonValue,
            "comments" : commentsValue
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == 'sucess') {
                    component.set("v.spinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": 'success',
                        "message": "Rejected"
                    });
    				toastEvent.fire();
                    // Close the action panel
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
            }
            else {
                component.set("v.spinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "error!",
                    "type": 'error',
                    "message": response.getReturnValue()
                });
                toastEvent.fire();
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
		
	}
})