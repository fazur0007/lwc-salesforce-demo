({
	helperMethodForSummitProductDetails : function(component, event, helper) {
		// alert("Inside of Summit productsummary ");
		//var productDetails = component.get("v.accountList");
        var summit = component.get("c.summitForInsert");
        summit.setParams({
            accountSummit : "12344444"
         //   record: {  accountSummit : productDetails }
        });
        summit.setCallback(this,function(response){
            var state = response.getState();
            var a = response.getReturnValue();
        });
          $A.enqueueAction(summit);
        console.log("productDetails>>>>>>>>>>>"+"NewPage");
	}
})