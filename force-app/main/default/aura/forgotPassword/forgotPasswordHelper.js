({
    qsToEventMap: {
        'expid'  : 'e.c:setExpId'
    },
    
    translationalUtil: function (component, translations){
        let objectKeys = Object.keys(translations);
        for (let i = 0; i < objectKeys.length; i++) {
            component.set("v." + objectKeys[i], translations[objectKeys[i]]);
        }
    },

    handleForgotPassword: function (component, event, helpler) {
       
        var qs = window.location.search.substring(1); // remove leading question mark 
        var startUrl = null;
        qs.split("&").some(x => { if(x.indexOf("startURL")==0) { return startUrl = x.split("=")[1]; } }); 
        if(startUrl)
        {
            component.set('v.startUrl', startUrl);
        }
        
        var username = component.find("username").get("v.value");
        var checkEmailUrl = component.get("v.checkEmailUrl");
        var startUrl = component.get("v.startUrl");
        
        var action = component.get("c.forgotPassword");
        action.setParams({username:username, checkEmailUrl:checkEmailUrl,startUrl:startUrl});
        action.setCallback(this, function(a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue != null) {
               component.set("v.errorMessage",rtnValue);
               component.set("v.showError",true);
            }
       });
        $A.enqueueAction(action);
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