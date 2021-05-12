({
	myAction : function(component, event, helper) {
        console.log("Data from event: " + event.getParam('messageFromChild'));
        alert(event.getParam('messageFromChild'));
	}
})