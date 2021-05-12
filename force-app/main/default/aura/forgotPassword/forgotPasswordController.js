({
    handleForgotPassword: function (component, event, helpler) {
        helpler.handleForgotPassword(component, event, helpler);
    },
    onKeyUp: function(component, event, helpler){
        if (event.which === 13) {
            helpler.handleForgotPassword(component, event, helpler);
        }
    },
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        alert(expId);
        helper.setBrandingCookie(component, event, helper);
    },
    initialize: function(component, event, helper) {        
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
        
        var action = component.get("c.getExperienceIdFromSite");
        action.setCallback(this, function(a) {
            let expId = a.getReturnValue();
            if (expId != null) {
                console.log(expId);
                var submitButComp = component.find('loginButton');
                var bodyDiv = component.find('bodydiv');        
                var createAccountHeader = component.find('headerh1');
                var resetPwdHeader = component.find('headerh2');
                var resetPwdHeader3 = component.find('headerh3');
                var emailTextBox = component.find('username');
                var communityForgotPassword = component.find("communityForgotPassword");
                var passwordTextBox = component.find('password');
                var passwordStrengthLabel = component.find('passwordStrengthLabel');
                var divAlreaMem = component.find('divAlrMem');
                var divLoginHere = component.find('divLoginHere');
                if(expId.includes('app'))
                {     
                    component.set("v.dynamicLogo","app");
                    $A.util.addClass(communityForgotPassword, 'communityForgotPassword_app');
                    $A.util.addClass(submitButComp, 'sfdc_button_app');
                    $A.util.addClass(bodyDiv, 'bodyClass_app');	
                    $A.util.addClass(createAccountHeader, 'h1class_app');	
                    $A.util.addClass(emailTextBox, 'LabelStyle_app');	
                    $A.util.addClass(passwordTextBox, 'LabelStyle_app');
                    $A.util.addClass(passwordStrengthLabel, 'PasswordStreStyle_app');
                    $A.util.addClass(divAlreaMem, 'csRed_app');
                    $A.util.addClass(divLoginHere, 'LoginLink_app');  
                    $A.util.addClass(resetPwdHeader, 'h2class_app');
					$A.util.addClass(resetPwdHeader3, 'h1class_app');                    
                }else if(expId.includes('beanz')){
                    component.set("v.dynamicLogo","beanz");
                    $A.util.addClass(communityForgotPassword, 'communityForgotPassword_beanz');
                    $A.util.addClass(submitButComp, 'sfdc_button_beanz');
                    $A.util.addClass(bodyDiv, 'bodyClass_beanz');	
                    $A.util.addClass(createAccountHeader, 'h1class_beanz');	
                    $A.util.addClass(emailTextBox, 'LabelStyle_beanz');	
                    $A.util.addClass(passwordTextBox, 'LabelStyle_beanz');
                    $A.util.addClass(passwordStrengthLabel, 'PasswordStreStyle_beanz');
                    $A.util.addClass(divAlreaMem, 'csRed_beanz');
                    $A.util.addClass(divLoginHere, 'LoginLink_beanz');  
                    $A.util.addClass(resetPwdHeader, 'h2class_beanz');
                    $A.util.addClass(resetPwdHeader3, 'h1class_beanz');
                } else
                {
                    if(expId.includes('sage'))
                        component.set("v.dynamicLogo","sage");
                    else
                        component.set("v.dynamicLogo","Breville");

                    $A.util.addClass(communityForgotPassword, 'communityForgotPassword_breville');
                    $A.util.addClass(submitButComp, 'sfdc_button_breville');	
                    $A.util.addClass(bodyDiv, 'bodyClass_breville');
                    $A.util.addClass(createAccountHeader, 'h1class_breville');	
                    $A.util.addClass(emailTextBox, 'LabelStyle_breville');
                    $A.util.addClass(passwordTextBox, 'LabelStyle_breville');
                    $A.util.addClass(passwordStrengthLabel, 'PasswordStreStyle_breville');
                    $A.util.addClass(divAlreaMem, 'csRed_breville');
                    $A.util.addClass(divLoginHere, 'LoginLink_breville'); 
                    $A.util.addClass(resetPwdHeader, 'h2class_breville');
                    $A.util.addClass(resetPwdHeader3, 'h1class_breville');
                }
                var action1 = component.get("c.getTranslationsByExpID");
                action1.setParams({"expId":expId});
                action1.setCallback(this, function(result){
                    helper.translationalUtil(component,result.getReturnValue());
                });
                $A.enqueueAction(action1);
            }
        });
        $A.enqueueAction(action);
    },
    
})