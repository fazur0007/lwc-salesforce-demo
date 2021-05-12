({
    translationalUtil: function (component, translations){
        let objectKeys = Object.keys(translations);
        for (let i = 0; i < objectKeys.length; i++) {
            component.set("v." + objectKeys[i], translations[objectKeys[i]]);
        }
        component.set("v.showLoader",false);
    },
})