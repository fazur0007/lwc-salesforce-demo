({
    init : function(component, event, helper) {
        var url_string = window.location.href;
        var url = new URL(url_string);
        var userId = url.searchParams.get("usersfid");
        var action = component.get("c.doGetCurrentUserConfig");
        action.setParams({currentUserId:userId});
        
        action.setCallback(this, function(response){

            console.log(JSON.stringify(response.getReturnValue()));
            let userInfo = response.getReturnValue();
            var createAccountHeader = component.find('headerh1');
            var expId = userInfo.Exp_ID__c ? userInfo.Exp_ID__c : "BrevilleENUS";
            if(expId.includes('app'))
            {
                component.set("v.dynamicLogo","app");
                $A.util.addClass(createAccountHeader, 'h1class_app');	           
            }else if(expId.includes('beanz')){
                component.set("v.dynamicLogo","beanz");
                $A.util.addClass(createAccountHeader, 'h1class_beanz');	
            }else{
                if (expId.includes('sage'))
                    component.set("v.dynamicLogo", "sage");
                else
                    component.set("v.dynamicLogo","Breville");
                $A.util.addClass(createAccountHeader, 'h1class_breville');	
            }
            var action1 = component.get("c.getTranslationsByExpID");
            action1.setParams({"expId":expId});
            action1.setCallback(this, function(result){
                helper.translationalUtil(component,result.getReturnValue());
            });
            $A.enqueueAction(action1);
        });
        $A.enqueueAction(action);        
    }
})