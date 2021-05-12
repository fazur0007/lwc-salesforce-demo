({
    doLoadData :function(component, event, helper) {
        var recordIdVal = component.get("v.recordId");
        if (recordIdVal != undefined) {
            component.set("v.isBrandTypeSelected",false);
            component.set("v.showFinishedGoodProduct",false);
            component.set("v.isOptionSelected",true);
            component.set("v.showButtons", true);
            component.set("v.showLoader",false);
            helper.apex(component,helper,'doInit',{})
        		.then(function(result){
                window.config = result;
                component.set("v.isPortalUser",config.isPortalUser);
                if(config.currency){
                    return helper.apex(component,helper,'getBrands',{
                        cur : config.currency 
                    });
                }
        })
        } else {
            helper.doLoadData(component, event, helper);    
        }
    },
    onSelectOfOption : function(component, event, helper){
        helper.onSelectOfOption(component, event, helper);
    },
    onNext : function(component, event, helper) {         
        var pageNumber = component.get("v.currentPageNumber"); 
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper,'wrapperList');
    },
    onPrev : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper,'wrapperList');
    },
    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper,'wrapperList');
    },    
    onFirst : function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper,'wrapperList');
    },
    onLast : function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper,'wrapperList');
    },
    onNextFG : function(component, event, helper) {         
        var pageNumber = component.get("v.currentPageNumber"); 
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper,'finishedGoodWrapper');
    },
    onPrevFG : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper,'finishedGoodWrapper');
    },
    processMeFG : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper,'finishedGoodWrapper');
    },    
    onFirstFG : function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper,'finishedGoodWrapper');
    },
    onLastFG : function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper,'finishedGoodWrapper');
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
    doSelectPricebooks :function(component, event, helper) {
        helper.doSelectPricebooks(component, event, helper);        
    },
    handleOrderTypes : function(component, event, helper) {
        component.set("v.isErrorOccured",false);
        var orderType = component.find("orderTypes").get("v.value");
        component.set("v.isWorkOrderSelected",false);
        component.set("v.isServiceTypeSelected",false);
        
    },
    doSaveSeletedPricebooks : function(component,event,helper){
        helper.doSaveSeletedPricebooks(component,event,helper);
    },
    goBackToSelectionPage : function(component,event,helper){
        component.set("v.isQuantitySectionEnabled",false);
    },
    handleSelectProduct : function (component,event,helper){
        var recordIdVal = component.get("v.recordId");
        if (recordIdVal != undefined) {} else {
            component.set('v.showLoader',true);
            var ordRef = component.get("v.orderRefNum");
            component.set("v.selectedBrand",component.find("brands").get("v.value"));
            component.set("v.selectedOrderType", component.find("orderTypes").get("v.value"));
            var selectedBrand =  component.get("v.selectedBrand");
			var selectedOrderType =  component.get("v.selectedOrderType");
            if(ordRef == undefined || ordRef == ""){
				  component.set("v.orderRefErrorMsg","Please enter order reference number"); 
				  component.set('v.showLoader',false);
			} else if(!selectedBrand || !selectedOrderType ) {
				if(!selectedBrand && selectedOrderType){
				   helper.errorUtil(component,'Error',"Please Select 'Brand'",'error');									 
				}else if(selectedBrand && !selectedOrderType){
					helper.errorUtil(component,'Error',"Please Select 'Order Type'",'error');									   
				}else{
				  helper.errorUtil(component,'Error',"Please Select 'Brand' and 'Order Type'",'error');									   
				}
            } else {
                 component.set("v.isBrandTypeSelected",false);
                 component.set("v.isOptionSelected",true);
        		 component.set("v.showButtons", true);
                 component.set('v.showLoader',false);
            }
        }
    },
    doSearchFinishGood :function (component,event,helper){
        helper.doSearchFinishGood(component,helper);
    },
    handleBack : function(component,event,helper){
        helper.handleBack(component,helper);
    },
    fetchSparePartsList : function(component,event,helper) {
        helper.fetchSparePartsList(component,event,helper);
    }
})