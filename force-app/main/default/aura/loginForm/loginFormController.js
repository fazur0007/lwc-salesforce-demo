({
    initialize: function(component, event, helper) {
        component.set('v.expidFromServer', helper.getExperienceIdFromSite(component, event, helper));
        const urlSearchParameters = {};
        let searchParameters = decodeURIComponent(window.location.search);
        let startURL;
        if (searchParameters !== '') {
            searchParameters = searchParameters.substring(1).split('&'); // get ride of '?'
            for (let i = 0; i < searchParameters.length; i++) {
                let eachKey = searchParameters[i].split('=');
                if(searchParameters[i].includes("startURL"))
                {
                    urlSearchParameters['startURL'] = searchParameters[i].replace('startURL=','');
                    startURL = searchParameters[i].replace('startURL=','');
                }
                else
                {
                    //[key, value] = searchParameters[i].split('=');
                    urlSearchParameters[eachKey[0]] = eachKey[1];
                }
            }
            if(startURL)
            {
                component.set('v.startUrl_custom', encodeURIComponent(startURL));
                component.set('v.startUrl', encodeURIComponent(startURL));
            }
        }
        console.log(startURL);
        //this.setStartUrl(component, event, helper);
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();    
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap2}).fire();
        component.set('v.isUsernamePasswordEnabled', helper.getIsUsernamePasswordEnabled(component, event, helper));
        component.set("v.isSelfRegistrationEnabled", helper.getIsSelfRegistrationEnabled(component, event, helper));
        component.set("v.communityForgotPasswordUrl", helper.getCommunitySelfRegisterUrl(component, event, helper));
        component.set("v.communitySelfRegisterUrl", helper.getCommunityForgotPasswordUrl(component, event, helper));
    },
    togglePassword : function(component, event, helper) {
        if(component.get("v.showpassword",true)){
            component.set("v.showpassword",false);
        }else{
            component.set("v.showpassword",true);
        }
    },
    
    handleLogin: function (component, event, helper) {
        helper.handleLogin(component, event, helper);
    },
    
    setStartUrl: function (component, event, helper) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            console.log('expId from setExpId event params:'+expId);
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
        helper.setStylesBasedOnExpId(component, event, helper);
    },
    
    onKeyUp: function(component, event, helper){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helper.handleLogin(component, event, helper);
        }
    },
    
    navigateToForgotPassword: function(cmp, event, helper) {
        var forgotPwdUrl = cmp.get("v.communityForgotPasswordUrl");
        if ($A.util.isUndefinedOrNull(forgotPwdUrl)) {
            forgotPwdUrl = cmp.get("v.forgotPasswordUrl");
        }
        var startUrl = cmp.get("v.startUrl");
        if(startUrl){
            if(forgotPwdUrl.indexOf("?") === -1) {
                forgotPwdUrl = forgotPwdUrl + '?startURL=' + decodeURIComponent(startUrl);
            } else {
                forgotPwdUrl = forgotPwdUrl + '&startURL=' + decodeURIComponent(startUrl);
            }
        }
        var attributes = { url: forgotPwdUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    
    navigateToSelfRegister: function(cmp, event, helper) {
        var selfRegUrl = cmp.get("v.communitySelfRegisterUrl");
        if (selfRegUrl == null) {
            selfRegUrl = cmp.get("v.selfRegisterUrl");
        }
        var startUrl = cmp.get("v.startUrl");
        console.log('startURL in button click:'+startURL);
        if(startUrl){
            if(selfRegUrl.indexOf("?") === -1) {
                selfRegUrl = selfRegUrl + '?startURL=' + decodeURIComponent(startUrl);
            } else {
                selfRegUrl = selfRegUrl + '&startURL=' + decodeURIComponent(startUrl);
            }
        }
        var attributes = { url: selfRegUrl };
        console.log('startURL in button click:'+selfRegUrl);
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
    
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
    doSubmit: function(component, event, helper){
        if(event.which == 13) {
            helper.handleLogin(component, event, helper);
        }
    }   
})