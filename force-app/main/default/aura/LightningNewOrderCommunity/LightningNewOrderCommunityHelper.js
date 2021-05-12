({
    doLoadData : function(component,event,helper){
       
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
        .then(function(result){
            
            if(result){
                var brands = [];
                 for(var key in result){
                    brands.push({label: result[key], value: key});
                }   
                component.set('v.brands',  brands);
                return helper.apex(component,helper,'getOrderTypes',{});
           }
        })
        .then(function(result){
           if(result){
            component.set("v.orderTypes",[{label: result.orderType, value: result.orderType}]);
            component.set("v.showLoader",false);
           }
            
             
        })
        .catch(function(error) {
            console.log("error values ::"+JSON.stringify(error));
        });
    },
    doSelectPricebooks :  function(component,event,helper){       
        component.set("v.showLoader",true);       
        var newProductList = [];
        var listOfProductIds  = [];
        console.log("wrapper list--->"+ component.get("v.wrapperList"));
        for (var item of component.get("v.wrapperList")){      
            if(item.selected)
            {
                if(item.isPromotionApplied)
                {
                    item.promotionAppliedMessage = 'Promotional Price is applied';
                }
                if(item.pberecord.Product2Id){
                    listOfProductIds.push(item.pberecord.Product2Id);
                } 
                
                newProductList.push(item); 
                console.log("inside for--11->");
            }                        
        }
        
        if(!config.isPortalUser){
            console.log("inside for-portal-->");
            if(Array.isArray(listOfProductIds) && listOfProductIds.length > 0){
                console.log("inside for-portal length-->");
                console.log(component.get("v.orderId")+"****list of products ::"+JSON.stringify(listOfProductIds));
                helper.apex(component,helper,'doGetProductsandRelatedProducts',{
                    listOfProductsIds : JSON.stringify(listOfProductIds),
                    orderId : component.get("v.orderId")
                })
                .then(function(result){ 
                    component.set("v.selectedWrapperfromApex",result);
                    component.set("v.isQuantitySectionEnabled",true);
                    component.set("v.showLoader",false);
                });                
            }else{
                helper.errorUtil(component,'Error','Please Select atleast one record','error');
                component.set("v.showLoader",false);            
            }
        }else{
            console.log("inside for-non-portal-->");
            if(Array.isArray(newProductList) && newProductList.length > 0){
                component.set("v.selectedWrapper",newProductList);
                component.set("v.showLoader",false);
                component.set("v.isQuantitySectionEnabled",true);
            }else{
                helper.errorUtil(component,'Error','Please Select atleast one record','error');
                component.set("v.showLoader",false);            
            }
        }
    },
    onSelectOfOption: function(component, event, helper) {
		var productDisplay = component.get("v.OptionsValue");
        console.log("productDisplay---->"+ productDisplay);
        component.set("v.selectedOption", productDisplay);
        if(productDisplay == "Add products with finished goods") {
            console.log("productDisplay--1-->"); 
            component.set("v.showLoader",true);
            component.set("v.showButtons", false); 
            component.set("v.showFinishedGoodProduct",true);
            helper.handleSelectProduct(component,helper);
        } else if (productDisplay == undefined){
            console.log("productDisplay--2-->"); 
            component.set("v.showLoader",false);
            helper.errorUtil(component,'Error','Please Select atleast one option','error');
        } else {
            console.log("productDisplay--3-->"); 
            component.set("v.showLoader",true);
			component.set("v.showFinishedGoodProduct",false);
			component.set("v.showButtons", true);   
            component.set("v.showLoader",false);
        }
    },
    doSaveSeletedPricebooks : function(component,event,helper){
        console.log('--doSaveSeletedPricebooks-->');
        var allValid = [].concat(component.find('field')).reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);        
        if (allValid) {
            component.set("v.showLoader",true);
            var recordIdVal = component.get("v.recordId");
            var OrderIdVal;
            if (recordIdVal != undefined) {
                OrderIdVal = recordIdVal;
            } else {
                OrderIdVal = component.get("v.orderId");
            }
            helper.apex(component,helper,'doGetOrderItem',{ 
                orderId : OrderIdVal
            })
            .then(function(result){
                console.log('---->'+ JSON.stringify(result));
                var existingorderItmList = result;
                var showError = false;
                var showServiceQuantityError = false;
                var showServiceQtyGreaterError = false;
                var showDuplicate = false;
                let selectedGrindTypeError = false;
                var orderItmList = [];
                var duplicateProductsString = '';
                if(!config.isPortalUser){
                   
                    for(var item of component.get("v.selectedWrapperfromApex")){
                        if(item.quantity === null || item.quantity <= 0){
                            item.qtyErrorMessage = ' ' + 'Please enter valid Quantity';
                            item.quantity = null;
                            showError = true;                        
                        }else if(component.get("v.brandValue") ==="Beanz" && item.selectedGrindType === ""){
                            selectedGrindTypeError = true;                        
                        }
                        else if(item.selectedRelatedProduct!=null && item.selectedRelatedProduct!='' && (item.relatedProductQuantity === null || item.relatedProductQuantity <= 0 )){
                            showServiceQuantityError = true;
                            item.relatedProductQuantity = null;
                        }
                            else if(item.quantity != null && item.relatedProductQuantity != null && item.selectedRelatedProduct!=null && item.selectedRelatedProduct!='' && item.relatedProductQuantity>item.quantity)
                            {
                                showServiceQtyGreaterError = true;
                            }
                                else{
                                    item.qtyErrorMessage=''; 
                                    
                                    /*if(existingorderItmList.includes(item.Product2Id)){
                                duplicateProductsString = duplicateProductsString + item.productRecName+',';
                                showDuplicate = true;
                            }else{*/
                                    orderItmList.push(item);
                                    //}*/
                                }
                    }
                    if(showError){
                        inputCmp.showHelpMessageIfInvalid();
                        helper.errorUtil(component,'Error','Please enter valid Quantity','error');
                    }
                    else if(selectedGrindTypeError){
                        helper.errorUtil(component,'Error','Grind Type is required for Beanz orders','error');
                    } else if(showServiceQuantityError)
                    {
                        helper.errorUtil(component,'Error','Please enter valid Quantity for warranty product','error');
                    } else if(showServiceQtyGreaterError){
                        helper.errorUtil(component,'Error','Warranty product cannot be greater than Product','error');
                    } else if(showDuplicate){   
                        helper.errorUtil(component,'Warning','Duplicate Order Products: '+duplicateProductsString,'warning');
                    }else if(Array.isArray(orderItmList) && orderItmList.length){ 
                        helper.apex(component,helper,'doSaveRelatedProducts',{ 
                            orderId : component.get("v.orderId"),
                            selectedOrderProducts : JSON.stringify(orderItmList)
                        })
                        .then(function(result){
                            if(Array.isArray(result) && result.length){
                                if(event.getSource().get("v.title") === "Save"){
                                    helper.navigationUtil(component,"view","Order",component.get("v.orderId"));
                                    component.set("v.showLoader",false);
                                }else if(event.getSource().get("v.title") === "SaveMore"){   
                                    component.set('v.wrapperList',[]);
                                    component.set('v.data',[]);
                                    helper.apex(component,helper,'getPriceBooks',{ 
                                        orderId : component.get("v.orderId")
                                    })
                                    .then(function(result){
                                        component.set("v.isQuantitySectionEnabled",false);
                                        component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
                                        component.set('v.wrapperList',result);
                                        component.set("v.currentPageNumber",1);
                                        helper.buildData(component, helper,'wrapperList');                                    
                                        component.set("v.showLoader",false);
                                    });
                                }
                            }else{
                                console.log("error occured");
                            }                        
                        });
                    }
                } else {
                    console.log('---->');
                    for(var item of component.get("v.selectedWrapper")){
                        if(item.quantity === null || item.quantity <= 0 ){
                            item.qtyErrorMessage = ' ' + 'Please enter valid Quantity';
                            item.quantity = null;
                            showError = true;                        
                        }else{
                            console.log('---->'+ JSON.stringify(existingorderItmList));
                            item.qtyErrorMessage=''; 
                            if(existingorderItmList.includes(item.pberecord.Product2Id)){
                                duplicateProductsString = duplicateProductsString + item.pberecord.Product2.Name+',';
                                showDuplicate = true;
                            } else {
                                orderItmList.push(item);
                            }
                        }
                    }
                    if(duplicateProductsString != '') {
                        duplicateProductsString = duplicateProductsString.substr(0, duplicateProductsString.length - 1);
                    }
                    if(showError){
                        inputCmp.showHelpMessageIfInvalid();
                        helper.errorUtil(component,'Error','Please enter valid Quantity','error');
                    }else if(showDuplicate){   
                        helper.errorUtil(component,'Error','Duplicate Order Products: '+duplicateProductsString);
                    }else if(Array.isArray(orderItmList) && orderItmList.length){
                        console.log('');
                        var recordIdVal = component.get("v.recordId");
                        if(recordIdVal != undefined) {
                            helper.apex(component,helper,'doSave',{ 
                                orderId : recordIdVal, 
                                selectedOrderProducts : JSON.stringify(orderItmList)
                            }).then(function(result){
                                if(Array.isArray(result) && result.length){
                                    if(event.getSource().get("v.title") === "Save"){
                                        console.log('--save-->');
                                        helper.navigationUtil(component,"view","Order",recordIdVal);
                                        component.set("v.showLoader",false);
                                    }else if(event.getSource().get("v.title") === "SaveMore"){  
                                        console.log('--save more-->');
                                        component.set('v.wrapperList',[]);
                                        component.set('v.data',[]);
                                        helper.apex(component,helper,'getPriceBooks',{ 
                                            orderId : recordIdVal
                                        })
                                        .then(function(result){
                                            console.log('--save then-->');
                                            component.set("v.isQuantitySectionEnabled",false);
                                            component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
                                            component.set('v.wrapperList',result);
                                            component.set("v.currentPageNumber",1);
                                            helper.buildData(component, helper,'wrapperList');                                    
                                            component.set("v.showLoader",false);
                                        });
                                    }
                                }else{
                                    console.log('--save error-->');
                                    console.log("error occured");
                                }                        
                            });
                        } else {
                            helper.apex(component,helper,'doSave',{ 
                                orderId : component.get("v.orderId"), 
                                selectedOrderProducts : JSON.stringify(orderItmList)
                            }).then(function(result){
                                if(Array.isArray(result) && result.length){
                                    if(event.getSource().get("v.title") === "Save"){
                                        helper.navigationUtil(component,"view","Order",component.get("v.orderId"));
                                        component.set("v.showLoader",false);
                                    }else if(event.getSource().get("v.title") === "SaveMore"){   
                                        component.set('v.wrapperList',[]);
                                        component.set('v.data',[]);
                                        helper.apex(component,helper,'getPriceBooks',{ 
                                            orderId : component.get("v.orderId")
                                        })
                                        .then(function(result){
                                            component.set("v.isQuantitySectionEnabled",false);
                                            component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
                                            component.set('v.wrapperList',result);
                                            component.set("v.currentPageNumber",1);
                                            helper.buildData(component, helper,'wrapperList');                                    
                                            component.set("v.showLoader",false);
                                        });
                                    }
                                }else{
                                    console.log("error occured");
                                }                        
                            });
                        }
                    }
                }
            })
        }else {
            helper.errorUtil(component,'Error','Please enter valid Quantity','error');
        }
    },
    handleNext : function(component,event,helper){
        var productDisplay = component.get("v.selectedOption");
        console.log("productDisplay---->"+ productDisplay);
        component.set("v.isOptionSelected",false);
        component.set("v.showButtons", false);
         component.set("v.showLoader",true);
        if(productDisplay == "Add products with finished goods") {
            var selectedFinishGoodProducts = [];
            for(var item of component.get("v.finishedGoodWrapper")){
                if(item.selected){
                    if(item.pberecord.Product2Id){
                        selectedFinishGoodProducts.push(item.pberecord.Product2Id);
                    } 
                }
            }
            if(selectedFinishGoodProducts.length === 0){
                helper.errorUtil(component,'Error',"Please select atleast one finished good product",'error');
            } else {
                component.set("v.selectedFinishGoodProducts",selectedFinishGoodProducts);
                component.set("v.showLoader",true);
                var recordIdVal = component.get("v.recordId");
                if (recordIdVal != undefined) {
                    helper.apex(component,helper,'getOrderRecordDetails',{
                        orderRecordId : recordIdVal
                    })
                    .then(function(result){
                        console.log("----count-else--->"+result.length);
                        if(result.length > 0 && result[0].Type === 'Sale') {
                            if(result[0].Type != undefined && result[0].Brand__c != undefined){                            
                                component.set("v.showFinishedGoodProduct",false);
                                component.set("v.showNormalProducts",true);
                                console.log('selectedFinishGoodProducts: '+selectedFinishGoodProducts);
                                helper.apex(component,helper,'getPriceBooks',{ 
                                    orderId : recordIdVal,
                                    selectedFinishGoodProdID : selectedFinishGoodProducts
                                })
                                .then(function(result){
                                    var val = Math.ceil(result.length/component.get("v.pageSize"));
                                    if(val <= 1) {
                                        component.set("v.totalPages", 1);
                                    } else if (val > 1) {
                                        component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
                                    }
                                    component.set('v.wrapperList',result);
                                    console.log('wrapperList: '+ component.get("v.wrapperList"));
                                    component.set("v.showLoader",false);
                                    component.set("v.currentPageNumber",1);
                                    helper.buildData(component, helper,'wrapperList');
                                });
                            } else {
                                helper.errorUtil(component,'Error',"Please Select 'Brand' and 'Type' and 'Shipment Method' to proceed",'error');
                            }
                        } else {
                            helper.errorUtil(component,'Error',"Order Type should be Sale",'error');
                        }
                    });
                } else {
                    var orderType = component.get("v.selectedOrderType");
                    var brand = component.get("v.selectedBrand");
                    console.log("orderRefNum::"+component.get("v.orderRefNum"));
                    if(orderType === 'Sale'){
                        if(orderType && brand){ 
                            helper.apex(component,helper,'save',{
                                idParam : config.accountRecord.Id,
                                brand : brand,
                                orderType : orderType,
                                currecnyCode : config.currency,
                                objectType : config.objectType,
                                isPortalUser : config.isPortalUser,
                                region : config.region,
                                isEmpPortalUser : config.isEmpPortalUser,
                                ordRefNum : component.get("v.orderRefNum")
                                //selectedDeliveryOption : config.selectedDeliveryOption
                                //shimentMethod : shippingMethod
                            })
                            .then(function(result){
                                console.log("----count-else-##############-->"+result.length);
                                //helper.errorUtil(component,'Order has been created successfully',result,'success');
                                console.log('result: '+result);
                                component.set("v.orderId",result);
                                component.set("v.showFinishedGoodProduct",false);
                                component.set("v.showNormalProducts",true);
                                console.log('selectedFinishGoodProducts: '+selectedFinishGoodProducts);
                                return helper.apex(component,helper,'getPriceBooks',{ 
                                    orderId : component.get("v.orderId"),
                                    selectedFinishGoodProdID : selectedFinishGoodProducts
                                });
                            })
                            .then(function(result){
                                console.log("val---"+component.get("v.pageSize"));
                                var val = Math.ceil(result.length/component.get("v.pageSize"));
                                console.log("val---"+ val);
                                if(val <= 1) {
                                    component.set("v.totalPages", 1);
                                } else if (val > 1) {
                                    component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
                                }
                                component.set('v.wrapperList',result);
                                console.log('wrapperList: '+ component.get("v.wrapperList"));
                                component.set("v.showLoader",false);
                                component.set("v.currentPageNumber",1);
                                helper.buildData(component, helper,'wrapperList'); 
                            })
                        } else {
                            helper.errorUtil(component,'Error',"Please Select 'Brand' and 'Type' and 'Shipment Method' to proceed",'error');
                        }
                    }
                }
            }
        } else if (productDisplay == "Add Spare Parts without selecting finished goods") {
            console.log("-###--->");
            component.set("v.showBackButton", false);
            var recordIdVal = component.get("v.recordId");
            if (recordIdVal != undefined) {
                helper.apex(component,helper,'getOrderRecordDetails',{
                    orderRecordId : recordIdVal
                })
                .then(function(result){
                    if(result.length > 0 && result[0].Type === 'Sale') {
                        if(result[0].Type != undefined && result[0].Brand__c != undefined){                            
                            component.set("v.showFinishedGoodProduct",false);
                            component.set("v.showNormalProducts",true);
                            helper.apex(component,helper,'getStandardPriceBooks',{ 
                                orderId : recordIdVal
                            })
                            .then(function(result){
                                console.log("----count---->"+result.length);
                                var val = Math.ceil(result.length/component.get("v.pageSize"));
                                if(val == 1) {
                                    component.set("v.totalPages", 1);
                                } else if (val > 1) {
                                    component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
                                }
                                component.set('v.wrapperList',result);
                                console.log('wrapperList: '+ component.get("v.wrapperList"));
                                component.set("v.showLoader",false);
                                component.set("v.currentPageNumber",1);
                                helper.buildData(component, helper,'wrapperList');
                            });
                        } else {
                            helper.errorUtil(component,'Error',"Please Select 'Brand' and 'Type' and 'Shipment Method' to proceed",'error');
                        }
                    } else {
                        helper.errorUtil(component,'Error',"Order Type should be Sale",'error');
                    }
                });
            } else {
                var orderType = component.get("v.selectedOrderType");
                var brand = component.get("v.selectedBrand");
                console.log("orderRefNum::"+component.get("v.orderRefNum"));
                if(orderType === 'Sale'){
                    if(orderType && brand){ 
                        helper.apex(component,helper,'save',{
                            idParam : config.accountRecord.Id,
                            brand : brand,
                            orderType : orderType,
                            currecnyCode : config.currency,
                            objectType : config.objectType,
                            isPortalUser : config.isPortalUser,
                            region : config.region,
                            isEmpPortalUser : config.isEmpPortalUser,
                            ordRefNum : component.get("v.orderRefNum")
                            //selectedDeliveryOption : config.selectedDeliveryOption
                            //shimentMethod : shippingMethod
                        })
                        .then(function(result){
                            //helper.errorUtil(component,'Order has been created successfully',result,'success');
                            console.log('result: '+result);
                            component.set("v.orderId",result);
                            component.set("v.showFinishedGoodProduct",false);
                            component.set("v.showNormalProducts",true);
                            console.log('selectedFinishGoodProducts: '+selectedFinishGoodProducts);
                            return helper.apex(component,helper,'getStandardPriceBooks',{ 
                                orderId : component.get("v.orderId"),
                            })
                        })
                        .then(function(result){
                            console.log("----count-else--->"+result.length);
                            var val = Math.ceil(result.length/component.get("v.pageSize"));
                            if(val == 1) {
                                component.set("v.totalPages", 1);
                            } else if (val > 1) {
                                component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
                            }
                            component.set('v.wrapperList',result);
                            console.log('wrapperList: '+ component.get("v.wrapperList"));
                            component.set("v.showLoader",false);
                            component.set("v.currentPageNumber",1);
                            helper.buildData(component, helper,'wrapperList'); 
                        })
                    } else {
                        helper.errorUtil(component,'Error',"Please Select 'Brand' and 'Type' and 'Shipment Method' to proceed",'error');
                    }
                }
            }
        } else {
            component.set("v.showLoader",false);
            component.set("v.isOptionSelected",true);
        	component.set("v.showButtons", true)
            helper.errorUtil(component,'Error','Please Select atleast one option','error');
        }
    },
    doSearchRecs : function(component,event,helper){
        var productDisplay = component.get("v.OptionsValue");
        var withFinishedGoods = false;
        if (productDisplay == "Add Spare Parts without selecting finished goods") {
            
        } else {
            withFinishedGoods = true;
        }
        var recordIdVal = component.get("v.recordId");
        var orderIdVal;
        if (recordIdVal != undefined) {
            orderIdVal = recordIdVal;
        } else {
            orderIdVal = component.get("v.orderId");
        }
        component.set("v.showLoader",true);
        console.log(component.find('enter-search').get('v.value')+"--"+component.get("v.selectedValue"));
        helper.apex(component,helper,'doSearch',{ 
            orderId : orderIdVal,
            searchText : component.find('enter-search').get('v.value'),
            filters : component.get("v.selectedValue"),
            selectedFinishGoodProdID : component.get("v.selectedFinishGoodProducts"),
            isAssociatedWithFinishedGoods : withFinishedGoods
        })
        .then(function(result){
            var val = Math.ceil(result.length/component.get("v.pageSize"));
            if(val == 1) {
                component.set("v.totalPages", 1);
            } else if (val > 1) {
                component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
            }
            //component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
            component.set('v.wrapperList',result);
            component.set("v.showLoader",false);
            component.set("v.currentPageNumber",1);
            helper.buildData(component, helper, 'wrapperList');
        })
    },
    buildData : function(component, helper, wrapperListName) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v."+wrapperListName);
        var x = (pageNumber-1)*pageSize;        
        for(; x<=(pageNumber)*pageSize; x++){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        if(wrapperListName === 'wrapperList'){
            component.set("v.data", data); 
            //console.log("data"+ component.get("v.data"));
        }else{
            component.set("v.finishedGoodData", data); 
        }
        
        helper.generatePageList(component, pageNumber);
    },
    generatePageList : function(component, pageNumber){
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if(totalPages > 1){
            if(totalPages <= 10){
                var counter = 2;
                for(; counter < (totalPages); counter++){
                    pageList.push(counter);
                } 
            } else{
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else{
                    if(pageNumber>(totalPages-5)){
                        pageList.push(totalPages-5, totalPages-4, totalPages-3, totalPages-2, totalPages-1);
                    } else{
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);        
        component.set("v.showLoader",false);
    },
    errorUtil : function(component,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 1000',
            key: 'error_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
        component.set("v.showLoader",false);
    },    
    fetchDepValues: function(component, ListOfDependentFields) {
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        component.set("v.listDependingValues", dependentFields);        
    },
    apex : function( component,helper, apexAction, params ) {
        var p = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this , function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log("---apex func-->");
                    helper.errorUtil(component,'Error',callbackResult.getError()[0].message,'error');
                    reject( callbackResult.getError()[0].message);
                    component.set("v.showLoader",true);
        			$A.get("e.force:closeQuickAction").fire();
        			$A.get('e.force:refreshView').fire();
        			component.set("v.showLoader",false);
                }
            });
            $A.enqueueAction( action );
        }));            
        return p;
    },
    navigationUtil : function(component,actionName,objectApiName,recordId){
        var navLink = component.find("navLink");
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: actionName,
                objectApiName: objectApiName,
                recordId : recordId
            },
        };
        navLink.navigate(pageRef, true);
    },
    handleSelectProduct : function(component,helper){
        var recordIdVal = component.get("v.recordId");
        if (recordIdVal != undefined) {
            helper.apex(component,helper,'doInit',{})
            .then(function(result){
                window.config = result;
                component.set("v.isPortalUser",config.isPortalUser);
                if(config.currency){
                    return helper.apex(component,helper,'getFinishGoodProducts',{
                        acnt : config.accountRecord
                    }).then(function(result){
                        console.log("----count-else--->"+result.length);
                        if(result){
                            component.set('v.showLoader',false);
                            component.set("v.showNext",true);
                            component.set("v.isBrandTypeSelected",false);
                            component.set("v.showFinishedGoodProduct",true);
                            component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
                            component.set('v.finishedGoodWrapper',result);
                            component.set("v.currentPageNumber",1);
                            helper.buildData(component, helper,'finishedGoodWrapper');
        
                        }
                    }).catch(function(error) {
                        console.log("error values ::"+JSON.stringify(error));
                    });
                }
            });
        } else {
            component.set('v.showLoader',true);
            helper.apex(component,helper,'getFinishGoodProducts',{
                acnt : config.accountRecord
            }).then(function(result){
                console.log("----count-else--->"+result.length);
                if(result){
                    component.set('v.showLoader',false);
                    component.set("v.showNext",true);
                    component.set("v.isBrandTypeSelected",false);
                    component.set("v.showFinishedGoodProduct",true);
                    component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
                    component.set('v.finishedGoodWrapper',result);
                    component.set("v.currentPageNumber",1);
                    helper.buildData(component, helper,'finishedGoodWrapper');
                }                
            }).catch(function(error) {
                console.log("error values ::"+JSON.stringify(error));
            });
        }
    },
    handleBack : function(component,helper) {
        component.set("v.showLoader",true);
        component.set("v.showNormalProducts",false);
        component.set("v.showFinishedGoodProduct",true);
        component.set("v.isOptionSelected",true);
        helper.handleSelectProduct(component,helper);
    },
    doSearchFinishGood : function(component,helper){
        component.set("v.showLoader",true);
        console.log(component.find('enter-search1').get('v.value')+"--"+component.get("v.selectedValue"));
        helper.apex(component,helper,'doSearchFinishedGoodProds',{ 
            pricebookId : config.accountRecord.Finished_Good_Pricebook__c,
            searchText : component.find('enter-search1').get('v.value'),
            filter : component.get("v.selectedValue")
        })
        .then(function(result){
            component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
            component.set('v.finishedGoodWrapper',result);
            component.set("v.showLoader",false);
            component.set("v.currentPageNumber",1);
            helper.buildData(component, helper,'finishedGoodWrapper');
        })
    },
    fetchSparePartsList : function(component,event,helper) {
        helper.handleNext(component,event,helper);
    }
});