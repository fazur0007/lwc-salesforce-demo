({
    qsToEventMap: {
        'language'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleSelfRegister: function (component, event, helpler) {
        var accountId = component.get("v.accountId");
        var regConfirmUrl = component.get("v.regConfirmUrl");
        var email = component.find("email").get("v.value");
        var includePassword = component.get("v.includePasswordField");
        var action = component.get("c.selfRegister");
        var extraFields = JSON.stringify(component.get("v.extraFields"));   // somehow apex controllers refuse to deal with list of maps
        var startUrl = component.get("v.startUrl");
        
        var firstname = '';
        var lastname = '';
        var password = component.find("password").get("v.value");
        var confirmPassword = '';
        
        startUrl = decodeURIComponent(startUrl);
        
        action.setParams({firstname:firstname,lastname:lastname,email:email,
                          password:password, confirmPassword:confirmPassword, accountId:accountId, regConfirmUrl:regConfirmUrl, extraFields:extraFields, startUrl:startUrl, includePassword:includePassword});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set("v.errorMessage",rtnValue.message);
                if(rtnValue.messageType==='error')
                {   
                    component.set("v.showError",true);
                    component.set("v.showSucess",false);
                }
                else
                {
                    component.set("v.showSucess",true);
                    component.set("v.showError",false);
                }
                component.set("v.messageType",rtnValue.messageType);
                component.set("v.messageTitle",rtnValue.messageTitle);
            }
        });
        $A.enqueueAction(action);
    },
    
    getExtraFields : function (component, event, helpler) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            
            if (rtnValue !== null) {
                
                component.set('v.extraFields',rtnValue);
                if(!component.get('v.expid'))
                {
                    var expidFromServer = rtnValue[0].experienceId;
                    component.set('v.expid',expidFromServer.replace('signup',''));
                    console.log('rtnValue:'+ rtnValue[0].experienceId);                                                 
                    //console.log('rtnValue:'+ JSON.stringify(rtnValue));                   
                }
                if(component.get('v.expid'))
                {
                    var startUrlParam = component.get('v.startUrl');
                    var loginURLSetting = "/BrevilleCustomerCommunity/s/login?expid=" + component.get('v.expid') + "&startURL=" + startUrlParam;
                    component.set("v.LoginUrl", loginURLSetting);
                    console.log('login url:'+ loginURLSetting );
                }
                if(rtnValue[0].translations !== null){
                    this.translationalUtil(component,rtnValue[0].translations);
                }
                
                this.setStylesBasedOnExpId(component, event, helpler);
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
    
    setStylesBasedOnExpId: function (component, event, helpler){
        var experience = component.get('v.expid');
        var submitButComp = component.find('submitButton');
        var bodyDiv = component.find('bodydiv');        
        var createAccountHeader = component.find('headerh1');
        var emailTextBox = component.find('email');
        var passwordTextBox = component.find('password');
        var passwordStrengthLabel = component.find('passwordStrengthLabel');
        var hyperLinkTC = component.find("hyperLinkTandC");
        var hyperLinkPP = component.find("hyperLinkPolicy");
        var divAlreaMem = component.find('divAlrMem');
        var divLoginHere = component.find('divLoginHere');
        var divTandC = component.find('termsAndConds');
        if(experience.includes('app'))
        {
            component.set("v.dynamicLogo","app");
            component.set("v.showTermsAndConditions",false);
            $A.util.addClass(submitButComp, 'sfdc_button_app');
            $A.util.addClass(bodyDiv, 'bodyClass_app');	
            $A.util.addClass(createAccountHeader, 'h1class_app');	
            $A.util.addClass(emailTextBox, 'LabelStyle_app');	
            $A.util.addClass(passwordTextBox, 'LabelStyle_app');
            $A.util.addClass(passwordStrengthLabel, 'PasswordStreStyle_app');
            $A.util.addClass(divAlreaMem, 'csRed_app');
            $A.util.addClass(divLoginHere, 'LoginLink_app');
            $A.util.addClass(hyperLinkTC, 'hyperLinkTC_app');
            $A.util.addClass(hyperLinkPP, 'hyperLinkTC_app');
            $A.util.addClass(divTandC, 'divTandC_app');
        }else if(experience.includes('beanz')){
            component.set("v.dynamicVariant","label-hidden");
            component.set("v.dynamicLogo","beanz");
            component.set("v.showTermsAndConditions",false);
            $A.util.addClass(submitButComp, 'sfdc_button_beanz');
            $A.util.addClass(bodyDiv, 'bodyClass_beanz');	
            $A.util.addClass(createAccountHeader, 'h1class_beanz');	
            $A.util.addClass(emailTextBox, 'LabelStyle_beanz');	
            $A.util.addClass(passwordTextBox, 'LabelStyle_beanz');
            $A.util.addClass(passwordStrengthLabel, 'PasswordStreStyle_beanz');
            $A.util.addClass(divAlreaMem, 'csRed_beanz');
            $A.util.addClass(divLoginHere, 'LoginLink_beanz');
            $A.util.addClass(hyperLinkTC, 'hyperLinkTC_beanz');
            $A.util.addClass(hyperLinkPP, 'hyperLinkTC_beanz');
            $A.util.addClass(divTandC, 'divTandC_beanz');
        }
        else
        {
            if(experience.includes('sage'))
                component.set("v.dynamicLogo","sage");
            else
                component.set("v.dynamicLogo","Breville");
            component.set("v.showTermsAndConditions",true);
            component.set('v.submitButtonLabel','Continue');
            $A.util.addClass(submitButComp, 'sfdc_button_breville');	
            $A.util.addClass(bodyDiv, 'bodyClass_breville');
            $A.util.addClass(createAccountHeader, 'h1class_breville');	
            $A.util.addClass(emailTextBox, 'LabelStyle_breville');
            $A.util.addClass(passwordTextBox, 'LabelStyle_breville');
            $A.util.addClass(passwordStrengthLabel, 'PasswordStreStyle_breville');
            $A.util.addClass(divAlreaMem, 'csRed_breville');
            $A.util.addClass(divLoginHere, 'LoginLink_breville'); 
            $A.util.addClass(hyperLinkTC, 'hyperLinkTC_breville');
            $A.util.addClass(hyperLinkPP, 'hyperLinkTC_breville');
            $A.util.addClass(divTandC, 'divTandC_breville');
        }
    },
    setBrandingCookie: function (component, event, helpler) {        
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    } 
    
})