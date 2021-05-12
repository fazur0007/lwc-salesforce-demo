({
	backToLogin: function (component, event, helpler) {
        var qs = window.location.search.substring(1); // remove leading question mark 
        var startUrl = null;
        qs.split("&").some(x => { if(x.indexOf("startURL")==0) { return startUrl = x.split("=")[1]; } }); 
        
        console.log("startUrl****"+startUrl); 
        window.location.href = '/BrevilleCustomerCommunity/s/login/?ec=302&inst=c&startURL='+startUrl;
    },
    translationalUtil: function (component, translations){
        let objectKeys = Object.keys(translations);
        for (let i = 0; i < objectKeys.length; i++) {
            component.set("v." + objectKeys[i], translations[objectKeys[i]]);
        }
    }
})