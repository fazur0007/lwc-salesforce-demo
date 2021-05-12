({
    getPriceBooksFromApex : function(component, event, helper) {
        helper.getPriceBooksFromApex(component, event, helper);
    },
    onNext : function(component, event, helper) {         
        var pageNumber = component.get("v.currentPageNumber"); 
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper);
    },
    onPrev : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper);
    },
    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper);
    },    
    onFirst : function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper);
    },
    
    onLast : function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper);
    },
    handleCancel : function(component, event, helper) {
        component.set("v.showLoader",true);
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        component.set("v.showLoader",false);
    },
    handleNext : function(component, event, helper) {
        helper.handleNext(component, event, helper);
    },
    doSearchRecs : function(component, event, helper) {
        helper.doSearchRecs(component, event, helper);
    },
    handleBrandValue : function(component, event, helper) {
        component.set("v.isErrorOccured",false);
    },
    handleOrderTypes : function(component, event, helper) {
        component.set("v.isErrorOccured",false);
    },
    doSelectPricebooks :function(component, event, helper) {
        helper.doSelectPricebooks(component, event, helper);        
    },
    doSaveSeletedPricebooks : function(component,event,helper){
        helper.doSaveSeletedPricebooks(component,event,helper);
    },
    goBackToSelectionPage : function(component,event,helper){
        component.set("v.isQuantitySectionEnabled",false);
    },
})