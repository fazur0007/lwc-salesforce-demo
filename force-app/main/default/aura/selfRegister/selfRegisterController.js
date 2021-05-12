({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap2}).fire();        
        component.set('v.extraFields', helper.getExtraFields(component, event, helper));

        var qs = window.location.search.substring(1); // remove leading question mark 
        var startUrl = null;
        qs.split("&").some(x => { if(x.indexOf("startURL")==0) { return startUrl = x.split("=")[1]; } }); 

        if(startUrl) {
            component.set("v.startUrl", startUrl);
            var decodedStartUrl = decodeURIComponent(startUrl);
            console.log(decodeURIComponent(startUrl));
            component.set("v.termsandconditionsUrl","https://www.breville.com/us/en/legal/terms-of-use.html");
            component.set("v.policyUrl","https://www.breville.com/us/en/legal/terms-of-use.html");
            if(decodedStartUrl.includes('/services/oauth2/authorize'))
            {
                var loginCompUrl = '/BrevilleCustomerCommunity/services/oauth2/authorize/';
                var experienceId = decodedStartUrl.split('?');    
                experienceId = experienceId[0].split('/');
                experienceId = experienceId[experienceId.length-1];
                experienceId = experienceId.replace('signup','');
                loginCompUrl = loginCompUrl + experienceId + '?' + decodedStartUrl.split('?')[1];
                component.set("v.LoginUrl", loginCompUrl);
                console.log('loginCompUrl:'+loginCompUrl);
            }
            else
            {
                component.set("v.LoginUrl", "/BrevilleCustomerCommunity/s/login?startURL="+startUrl);
            }
        }
    },
    
    togglePassword : function(component, event, helper) {
        if(component.get("v.showpassword",true)){
            component.set("v.showpassword",false);
        }else{
            component.set("v.showpassword",true);
        }
    },
    
    handleSelfRegister: function (component, event, helpler) {
        helpler.handleSelfRegister(component, event, helpler);
    },
    
    setStartUrl: function (component, event, helpler) {
        var qs = window.location.search.substring(1); // remove leading question mark 
        console.log(JSON.stringify(qs)+"****setStartUrl*****"+qs);
        var startUrl = null;
        qs.split("&").some(x => { if(x.indexOf("startURL")==0) { return startUrl = x.split("=")[1]; } }); 
        //var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    
    setExpId: function (component, event, helper) {
        
        var expId = event.getParam('expid');
        console.log(JSON.stringify(expId)+"****expId*****"+expId);
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
        helper.setStylesBasedOnExpId(component, event, helpler);
    },
    
    doSubmit: function(component, event, helpler){
        if(event.which == 13) {
            helpler.handleSelfRegister(component, event, helpler);
        }
    }   
})