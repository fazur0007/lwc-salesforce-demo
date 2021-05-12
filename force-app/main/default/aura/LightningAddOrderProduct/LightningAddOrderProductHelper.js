({
    getPriceBooksFromApex : function(component,event,helper){
        component.set("v.showLoader",true); 
        helper.apex(component,helper,'loadInit',{ recordId : component.get("v.recordId") })
        .then(function(result){
            //console.log("******result******"+JSON.stringify(result));
            window.config = result;
            component.set("v.isPersonAccount",config.isPersonAccount);
            component.set("v.isPortalUser",config.isPortalUser);
            if(config){
                component.set("v.config",result);
                return helper.apex(component,helper,'getOrderConfig',{ 
                    orderId : component.get("v.recordId")
                })
            }
        })
        .then(function(result){
            console.log("******order result******"+JSON.stringify(result));
            component.set("v.brandValue",result.Brand__c ? result.Brand__c : '');
            return helper.apex(component,helper,'getPriceBooks',{ 
                orderId : component.get("v.recordId")
            })
        })
        .then(function(result){
            //console.log("order id ::"+result.length);
            //console.log("pricebooks***"+JSON.stringify(result));
            component.set("v.isQuantitySectionEnabled",false);
            component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
            component.set('v.wrapperList',result);
            component.set("v.currentPageNumber",1);
            helper.buildData(component, helper);                                    
            component.set("v.showLoader",false);
        });
    },
    doSelectPricebooks :  function(component,event,helper){       
        component.set("v.showLoader",true);       
        var newProductList = [];
        var listOfProductIds  = [];
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
            }                        
        }
        if(!config.isPortalUser){
            if(Array.isArray(listOfProductIds) && listOfProductIds.length > 0){
                console.log(component.get("v.recordId")+"****list of products ::"+JSON.stringify(listOfProductIds));
                helper.apex(component,helper,'doGetProductsandRelatedProducts',{
                    listOfProductsIds : JSON.stringify(listOfProductIds),
                    orderId : component.get("v.recordId")
                })
                .then(function(result){ 
                    component.set("v.selectedWrapperfromApex",result);
                    component.set("v.isQuantitySectionEnabled",true);
                    console.log("******result******"+JSON.stringify(result));
                });
                component.set("v.showLoader",false);
            }else{
                helper.errorUtil(component,'Error','Please Select atleast one record','error');
                component.set("v.showLoader",false);            
            }
        }else{
            if(Array.isArray(newProductList) && newProductList.length > 0){
                component.set("v.selectedWrapper",newProductList);
                console.log("selectedWrapper list of ids ::"+JSON.stringify(newProductList));
                component.set("v.showLoader",false);
                component.set("v.isQuantitySectionEnabled",true);
            }else{
                helper.errorUtil(component,'Error','Please Select atleast one record','error');
                component.set("v.showLoader",false);            
            }
        }
    },
    doSaveSeletedPricebooks : function(component,event,helper){
        var allValid = [].concat(component.find('field')).reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);        
        if (allValid) {
            component.set("v.showLoader",true);
            helper.apex(component,helper,'doGetOrderItem',{ 
                orderId : component.get("v.recordId")
            })
            .then(function(result){
                var existingorderItmList = result;
                var showError = false;
                var showServiceQuantityError = false;
                var showServiceQtyGreaterError = false;
                var showDuplicate = false;
                var orderItmList = [];
                let selectedGrindTypeError = false;
                var duplicateProductsString = '';
                if(!config.isPortalUser){
                    console.log("sel****"+JSON.stringify(component.get("v.selectedWrapperfromApex")));
                    for(var item of component.get("v.selectedWrapperfromApex")){
                        if(item.quantity === null || item.quantity <= 0){
                            item.qtyErrorMessage = ' ' + 'Please enter valid Quantity';
                            item.quantity = null;
                            showError = true;                        
                        }
                        else if(component.get("v.brandValue") ==="Beanz" && item.selectedGrindType === ""){
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
                    }
                    else if(showServiceQuantityError)
                    {
                        helper.errorUtil(component,'Error','Please enter valid Quantity for warranty product','error');
                    }
                        else if(showServiceQtyGreaterError)
                        {
                            helper.errorUtil(component,'Error','Warranty product cannot be greater than Product','error');
                        }
                            else if(showDuplicate){   
                                helper.errorUtil(component,'Warning','Duplicate Order Products: '+duplicateProductsString,'warning');
                            }else if(Array.isArray(orderItmList) && orderItmList.length){
                                console.log('faz::non portal ****'+JSON.stringify(orderItmList));
                                helper.apex(component,helper,'doSaveRelatedProducts',{ 
                                    orderId : component.get("v.recordId"),
                                    selectedOrderProducts : JSON.stringify(orderItmList)
                                })
                                .then(function(result){
                                    if(Array.isArray(result) && result.length){
                                        if(event.getSource().get("v.title") === "Save"){
                                            helper.navigationUtil(component,"view","Order",component.get("v.recordId"));
                                            component.set("v.showLoader",false);
                                        }else if(event.getSource().get("v.title") === "SaveMore"){   
                                            component.set('v.wrapperList',[]);
                                            component.set('v.data',[]);
                                            helper.apex(component,helper,'getPriceBooks',{ 
                                                orderId : component.get("v.recordId")
                                            })
                                            .then(function(result){
                                                component.set("v.isQuantitySectionEnabled",false);
                                                component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
                                                component.set('v.wrapperList',result);
                                                component.set("v.currentPageNumber",1);
                                                helper.buildData(component, helper);                                    
                                                component.set("v.showLoader",false);
                                            });
                                        }
                                    }else{
                                        console.log("error occured");
                                    }                        
                                });
                            }
                }else{
                    for(var item of component.get("v.selectedWrapper")){
                        if(item.quantity === null || item.quantity <= 0 ){
                            item.qtyErrorMessage = ' ' + 'Please enter valid Quantity';
                            item.quantity = null;
                            showError = true;                        
                        }else{
                            item.qtyErrorMessage=''; 
                            if(existingorderItmList.includes(item.pberecord.Product2Id)){
                                duplicateProductsString = duplicateProductsString + item.pberecord.Product2.Name+',';
                                showDuplicate = true;
                            }else{
                                orderItmList.push(item);
                            }
                        }
                    }
                    if(showError){
                        inputCmp.showHelpMessageIfInvalid();
                        helper.errorUtil(component,'Error','Please enter valid Quantity','error');
                    }else if(showDuplicate){   
                        helper.errorUtil(component,'Warning','Duplicate Order Products: '+duplicateProductsString,'warning');
                    }else if(Array.isArray(orderItmList) && orderItmList.length){
                        console.log('faz::'+JSON.stringify(orderItmList));
                        helper.apex(component,helper,'doSave',{ 
                            orderId : component.get("v.recordId"), 
                            selectedOrderProducts : JSON.stringify(orderItmList)
                        })
                        .then(function(result){
                            if(Array.isArray(result) && result.length){
                                if(event.getSource().get("v.title") === "Save"){
                                    helper.navigationUtil(component,"view","Order",component.get("v.recordId"));
                                    component.set("v.showLoader",false);
                                }else if(event.getSource().get("v.title") === "SaveMore"){   
                                    component.set('v.wrapperList',[]);
                                    component.set('v.data',[]);
                                    helper.apex(component,helper,'getPriceBooks',{ 
                                        orderId : component.get("v.recordId")
                                    })
                                    .then(function(result){
                                        component.set("v.isQuantitySectionEnabled",false);
                                        component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
                                        component.set('v.wrapperList',result);
                                        component.set("v.currentPageNumber",1);
                                        helper.buildData(component, helper);                                    
                                        component.set("v.showLoader",false);
                                    });
                                }
                            }else{
                                console.log("error occured");
                            }                        
                        });
                    }
                }
            })
        }else {
            helper.errorUtil(component,'Error','Please enter valid Quantity','error');
        }
    },
    doSearchRecs : function(component,event,helper){
        component.set("v.showLoader",true);
        console.log(component.find('enter-search').get('v.value')+"--"+component.get("v.selectedValue"));
        helper.apex(component,helper,'doSearch',{ 
            orderId : component.get("v.recordId"),
            searchText : component.find('enter-search').get('v.value'),
            filters : component.get("v.selectedValue")
        })
        .then(function(result){
            component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
            component.set('v.wrapperList',result);
            component.set("v.showLoader",false);
            component.set("v.currentPageNumber",1);
            helper.buildData(component, helper);
        })
    },
    buildData : function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.wrapperList");
        var x = (pageNumber-1)*pageSize;        
        for(; x<=(pageNumber)*pageSize; x++){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        component.set("v.data", data); 
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
                    var validationError = callbackResult.getError()[0].message.includes("Validation Error");
                    console.log('===validationError=='+validationError);
                    if(validationError){
                        var mes = callbackResult.getError()[0].message.split(':');
                        helper.errorUtil(component,'Error',mes[1],'error');
                        //reject(mes);
                        
                        component.set("v.showLoader",true);
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                        component.set("v.showLoader",false);
                    }else{
                        helper.errorUtil(component,'Error',callbackResult.getError()[0].message,'error');
                        reject( callbackResult.getError()[0].message);
                    } 
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
    }
})