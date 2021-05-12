({
    doInit : function(component, event, helper) {    
        var action=  component.get('c.getMandatoryDetails');  
        action.setCallback(this,function(response) {
            var state=response.getState();            
            if(state==='SUCCESS'){
                var finaloptions = [];
                var result = response.getReturnValue();
                for(var key in result){
                    var returnVal = result[key];
                    finaloptions.push({'label':returnVal.label,'value':returnVal.value});
                }                      
                component.set('v.options',finaloptions);
            }                               
        });
        $A.enqueueAction(action);
    },
    handleChange: function (component, event) {
        var checkboxArray = component.find("checkboxgroup");
        if (checkboxArray.get("v.value").length == 3){
             component.set('v.enableProceedButton',false);
        } else {
            component.set('v.enableProceedButton',true);
        }
    }
})