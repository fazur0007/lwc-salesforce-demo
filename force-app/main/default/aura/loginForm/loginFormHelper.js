({
    
    qsToEventMap: {
        'myStartURL'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleLogin: function (component, event, helper) {
        var username = component.find("username").get("v.value");
        var password = component.find("password").get("v.value");
        var action = component.get("c.login");
        var startUrl = component.get("v.startUrl");
        
        startUrl = decodeURIComponent(startUrl);
        //console.log('startURL in button click:'+startURL);
        action.setParams({username:username, password:password, startUrl:startUrl});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsUsernamePasswordEnabled : function (component, event, helper) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsSelfRegistrationEnabled : function (component, event, helper) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityForgotPasswordUrl : function (component, event, helper) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                var startURL = component.get('v.startUrl_custom');
                if(startURL)
                {
                    component.set('v.communityForgotPasswordUrl',rtnValue+'?startURL='+startURL);
                }
                else
                {
                    component.set('v.communityForgotPasswordUrl',rtnValue);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getExperienceIdFromSite : function (component, event, helper) {
        var action = component.get("c.getExperienceIdFromSite");        
        action.setCallback(this, function(a){
            let rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                console.log('expid from getExperienceIdFromSite:'+ component.get('v.expid'));   
                if(!component.get('v.expid'))
                {
                    component.set('v.expid',rtnValue);
                    console.log('rtnValue:'+ rtnValue);                                                 
                    console.log('rtnValue:'+ JSON.stringify(rtnValue));   
                }
                if(component.get('v.expid') && component.get('v.expid').includes('signup'))
                {
                    this.navigateToCreateAccount(component, event, helper);
                }
                let expId = component.get('v.expid');
                this.setStylesBasedOnExpId(component, event, helper);
                
                var action1 = component.get('c.getTranslationsByExpID');
                action1.setParams({"expId":expId});
                action1.setCallback(this, function(result){
                    this.translationalUtil(component,result.getReturnValue());
                });
                $A.enqueueAction(action1);
            }
        });
        $A.enqueueAction(action);
    },
    
    translationalUtil: function (component, translations){
//        console.log("Helper: *** "+JSON.stringify(translations));
        let objectKeys = Object.keys(translations);
        for (let i = 0; i < objectKeys.length; i++) {
            component.set("v." + objectKeys[i], translations[objectKeys[i]]);
        }
    },
        
    navigateToCreateAccount: function(cmp, event, helper) {
        var selfRegUrl = cmp.get("v.communitySelfRegisterUrl");
        if (selfRegUrl == null) {
            selfRegUrl = cmp.get("v.selfRegisterUrl");
        }
        var startUrl = cmp.get("v.startUrl");
        if(startUrl){
            if(selfRegUrl.indexOf("?") === -1) {
                selfRegUrl = selfRegUrl + '?startURL=' + startUrl;
            } else {
                selfRegUrl = selfRegUrl + '&startURL=' + startUrl;
            }
        }
        var attributes = { url: selfRegUrl };
        console.log('navigateToCreateAccount:'+selfRegUrl);
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    
    setStylesBasedOnExpId: function (component, event, helper){
        var experience = component.get('v.expid');
        var submitButComp = component.find('loginButton');
        var bodyDiv = component.find('bodydiv');        
        var createAccountHeader = component.find('headerh1');
        var emailTextBox = component.find('username');
        var communityForgotPassword = component.find("communityForgotPassword");
        var passwordTextBox = component.find('password');
        var passwordStrengthLabel = component.find('passwordStrengthLabel');
        var divAlreaMem = component.find('divAlrMem');
        var divLoginHere = component.find('divLoginHere');
        var forgotpwddiv = component.find('forgotpwddiv');
        var forgotpwdlink = component.find('forgotpwdlink');
        if(experience.includes('app'))
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
            $A.util.addClass(forgotpwddiv, 'csRed_app');
            $A.util.addClass(forgotpwdlink, 'communityForgotPassword_app');            
        }else if(experience.includes('beanz')){
            component.set("v.dynamicLogo","beanz");
            component.set("v.dynamicVariant","label-hidden");
            $A.util.addClass(communityForgotPassword, 'communityForgotPassword_beanz');
            $A.util.addClass(submitButComp, 'sfdc_button_beanz');
            $A.util.addClass(bodyDiv, 'bodyClass_beanz');	
            $A.util.addClass(createAccountHeader, 'h1class_beanz');	
            $A.util.addClass(emailTextBox, 'LabelStyle_beanz');	
            $A.util.addClass(passwordTextBox, 'LabelStyle_beanz');
            $A.util.addClass(passwordStrengthLabel, 'PasswordStreStyle_beanz');
            $A.util.addClass(divAlreaMem, 'csRed_beanz');
            $A.util.addClass(divLoginHere, 'LoginLink_beanz');
            $A.util.addClass(forgotpwddiv, 'csRed_beanz');
            $A.util.addClass(forgotpwdlink, 'communityForgotPassword_beanz');
        }else{
            if(experience.includes('sage'))
                component.set("v.dynamicLogo","sage");
            else
                component.set("v.dynamicLogo","Breville");
            //component.set('v.submitButtonLabel','Continue');
            $A.util.addClass(communityForgotPassword, 'communityForgotPassword_breville');
            $A.util.addClass(submitButComp, 'sfdc_button_breville');	
            $A.util.addClass(bodyDiv, 'bodyClass_breville');
            $A.util.addClass(createAccountHeader, 'h1class_breville');	
            $A.util.addClass(emailTextBox, 'LabelStyle_breville');
            $A.util.addClass(passwordTextBox, 'LabelStyle_breville');
            $A.util.addClass(passwordStrengthLabel, 'PasswordStreStyle_breville');
            $A.util.addClass(divAlreaMem, 'csRed_breville');
            $A.util.addClass(divLoginHere, 'LoginLink_breville');   
            $A.util.addClass(forgotpwddiv, 'csRed_breville');
            $A.util.addClass(forgotpwdlink, 'communityForgotPassword_breville');
        }
        
    },
    
    getCommunitySelfRegisterUrl : function (component, event, helper) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl',rtnValue);
                var startURL = component.get('v.startUrl_custom');
                if(startURL)
                {
                    component.set('v.communitySelfRegisterUrl',rtnValue+'?startURL='+startURL);
                }
                else
                {
                    component.set('v.communitySelfRegisterUrl',rtnValue);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    setBrandingCookie: function (component, event, helper) {
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    }
})