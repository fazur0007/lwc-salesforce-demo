({
	handleClick : function(component, event, helper) {
		console.log('Button click from child');
        var cmpevent = component.getEvent('eventonchild');
        console.log(component.get('v.message'));
        var paramValue = component.get('v.message');
        cmpevent.setParams({"messageFromChild" :paramValue  });
        cmpevent.fire();
	}
})