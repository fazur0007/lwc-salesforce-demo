({
	doInit : function(component, event, helper) {
		 // To make step 1 Active
		var circle = component.find('circle1');
        var label = component.find('label1');
        $A.util.toggleClass(circle, 'activeStep');
        $A.util.toggleClass(circle, 'activeBackground');
        $A.util.toggleClass(label, 'activeLabel');
	}
})