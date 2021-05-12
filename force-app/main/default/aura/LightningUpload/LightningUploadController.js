({
    handleUploadFinished : function (component, event, helper) {
        helper.handleUploadFinished(component, event, helper);
    },   
    handleSaveClick : function(component, event, helper){
        helper.handleSaveClick(component, event, helper);
    },
    dateUpdate : function(component, event, helper) {
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();   
        if(dd < 10){
            dd = '0' + dd;
        }  
        if(mm < 10){
            mm = '0' + mm;
        }
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(component.get("v.myDate") != '' && component.get("v.myDate") < todayFormattedDate){
            component.set("v.dateValidationError" , false);
        }else{
            component.set("v.dateValidationError" , true);
        }
    },
    submit : function(component,event,helper){
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();   
        if(dd < 10){
            dd = '0' + dd;
        }  
        if(mm < 10){
            mm = '0' + mm;
        }
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(component.get("v.myDate") != '' && component.get("v.myDate") < todayFormattedDate){
            component.set("v.dateValidationError" , false);
        }else{
            component.set("v.dateValidationError" , true);
        }
        var isDateError = component.get("v.dateValidationError");
        if(isDateError != true){
            alert('date is valid****'+component.get("v.myDate"));
        }
    }
})