({
    doInit : function(component, event, helper) {
        var url_string = window.location.href;
        var url = new URL(url_string);
		console.log('===url===' + url);
        
        var baseURL = url_string.substring(0, url_string.indexOf("/s"));
 		component.set("v.cbaseURL", baseURL);
        console.log('===baseURL===' + baseURL);
        
        var action = component.get("c.getCurrentUserConfig");
        
        action.setCallback(this, function(response){

            console.log(JSON.stringify(response.getReturnValue()));
            let userInfo = response.getReturnValue();
            console.log('===userInfo===' + userInfo);
            var createAccountHeader = component.find('headerh1');
            var experienceId = userInfo.Exp_ID__c ? userInfo.Exp_ID__c : "brevilleENUS";
            console.log('===Automated_Portal_User_Created_From===' + userInfo.Account.Automated_Portal_User_Created_From__c)

            component.set("v.Automated_Portal_User_Created_From",userInfo.Account.Automated_Portal_User_Created_From__c);

            
            var expId = experienceId;
            console.log('===expId===' + expId);
            if(experienceId.includes('app'))
            {
                component.set("v.dynamicLogo","app");
                $A.util.addClass(createAccountHeader, 'h1class_app');	           
            }else if(experienceId.includes('beanz')){
                component.set("v.dynamicLogo","beanz");
                $A.util.addClass(createAccountHeader, 'h1class_beanz');	
            }else{
                if (experienceId.includes('sage'))
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