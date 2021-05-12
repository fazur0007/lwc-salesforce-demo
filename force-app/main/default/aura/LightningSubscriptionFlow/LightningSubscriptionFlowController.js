({
    doGetSubscriptionsFromEP : function(component, event, helper) {
        helper.doGetSubscriptionsFromEP(component, event, helper);
    },
    doGetProductDetails : function (component, event, helper) {
        helper.doGetProductDetails(component, event, helper);
    },
    doNavigateToOrder : function (component, event, helper) { 
        helper.navigationUtil(component,"view","Order",event.currentTarget.getAttribute("data-attriVal"));
    },
    doNavigateToTrackingLink : function (component, event, helper) { 
        window.open(event.currentTarget.getAttribute("data-attriVal"), "_blank");
    },
    doCancelSubscription : function (component, event, helper) { 
        helper.doCancelSubscription(component, event, helper);
    },
    doSelectBrand :function (component, event, helper) { 
        component.set("v.showOrders",false);
         //helper.doGetSubscriptionsFromEP(component, event, helper);
        let AllSubscriptions = component.get("v.subscriptionResult");
        component.set("v.data",null);
        let beanzStoreCodes = ["brevilleUSMP"];
        let brevilleStoreCodes = ["brevilleCA","brevilleUS","sageUK","sageEU","sageCH","brevilleAU","brevilleNZ"];
        let filterStoreCodes = component.get("v.brandOption") === "Beanz" ? beanzStoreCodes :brevilleStoreCodes;
        let filteredSubscriptions;
        if(AllSubscriptions!=null && AllSubscriptions.subscriptions!=null && AllSubscriptions.subscriptions.length>0)
        {
            filteredSubscriptions = AllSubscriptions.subscriptions.filter(function(item){
                return filterStoreCodes.includes(item.storeCode);
            });
        }
        
        if(AllSubscriptions!=null && AllSubscriptions.subscriptions!=null && filteredSubscriptions!=null && AllSubscriptions.subscriptions.length>0 && filteredSubscriptions.length>0)
        {
            component.set('v.data',filteredSubscriptions);
        }        
        else
        {
            component.set("v.Message","No subscriptions exist for the User"); 
        }
    }
})