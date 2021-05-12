({
    getCurrentRecordDetails : function(component, event, helper) {
        helper.apexUtil(component,'getOrderRecord',{ recordId : component.get("v.recordId")})
        .then(function(result){
            window.orderDetails = result;
            component.set("v.orderDetails",result);
            component.set("v.showLoader",false);
        })
        .catch(function(error) {
            helper.showNoticeUtil(component,"error","Error",error);
        });
    },
    cancelWebOrder : function(component,event,helper){  
        component.set("v.showLoader",true);
        if (orderDetails.Status === "Order Generated" &&  orderDetails.Source === "AEM" && orderDetails.Channel === "ECOMM") {
            helper.apexUtil(component,'cancelOrder',{ orderRecord : orderDetails.Id})
            .then(function(result){
                helper.toastAlert(component,"success","Success","sticky","Process has been successfully completed");
                helper.refreshUtil(component,event,helper);
            })
            .catch(function(error) {
                if (error[0] && error[0].pageErrors[0].message) {
                    helper.showNoticeUtil(component,"warning",error[0].pageErrors[0].statusCode,error[0].pageErrors[0].message);
                }else{
                    helper.showNoticeUtil(component,"error","Error","Unknow error occured");
                }
            });
        }else{
            helper.showNoticeUtil(component,"warning","Order cannot be cancelled!","Order cannot be cancelled");
        }
    },
    handleSendQuote : function(component,event,helper){
        component.set("v.showLoader",true); 
        helper.apexUtil(component,'sendQuote',{ recordId : component.get("v.recordId")})
        .then(function(result){
            helper.refreshUtil(component,event,helper);
            console.log("send quote ::"+JSON.stringify(result));
            helper.errorUtil(component,'Success',result,'success');
            component.set("v.showLoader",false);
        })
        .catch(function(error) {   
            helper.showNoticeUtil(component,"error","Error",JSON.stringify(error));            
        });
    },
    handleCancelOder : function(component,event,helper){
        component.set("v.showLoader",true);
        if (orderDetails.Sent_to_AX) {
            helper.toastAlert(component,"warning","Alert","sticky","Order cannot be cancelled, Order has already been sent to AX"); 
        }else{
            helper.apexUtil(component,'handleCancelOrder',{ recordId : orderDetails.Id})
            .then(function(result){
                helper.toastAlert(component,"success","Success","sticky","Order has been cancelled successfully");                        
                helper.refreshUtil(component,event,helper);
            })
            .catch(function(error) {
                if (error[0] && error[0].pageErrors[0].message) {
                    helper.showNoticeUtil(component,"warning",error[0].pageErrors[0].statusCode,error[0].pageErrors[0].message);
                }else{
                    helper.showNoticeUtil(component,"error","Error","Unknow error occured");
                }
            });
        }
    },
    handleCalculate : function(component,event,helper){
        component.set("v.showLoader",true);
        console.log("orderDetails type ::"+JSON.stringify(component.get("v.orderDetails")));
        if (orderDetails.AccountType === 'Retailer') {
            if (orderDetails.RequestedShipDate) {
                if (orderDetails.ActivatedDate) {
                    alert("You cannot perform re-calculation on activated order");
                }else{
                    helper.apexUtil(component,'handleCalculateRecalculate',{ recordId : orderDetails.Id})
                    .then(function(result){
						helper.toastAlert(component,"success","Success","sticky","Calculation is completed successfully");                        
                        helper.refreshUtil(component,event,helper);
                    })
                    .catch(function(error) {
                        if (error[0] && error[0].pageErrors[0].message) {
                            helper.showNoticeUtil(component,"warning",error[0].pageErrors[0].statusCode,error[0].pageErrors[0].message);
                        }else{
                            helper.showNoticeUtil(component,"error","Error","Unknow error occured");
                        }
                    });
                }                
            }else {
                helper.toastAlert(component,"warning","Alert","Please enter Requested Ship Date first.","Order cannot be cancelled, Order has already been sent to AX");
            }
        }else {
            helper.toastAlert(component,"warning","Alert","sticky","This function is only applicable for retailers");            
        }
    },
    handlePaymentTerminal : function(component,event,helper){        
        if (orderDetails.BillToContactId) {
            if (orderDetails.OrderCustomerType === 'B2B' || orderDetails.Shipping_Method) {
                //helper.openSubtabUtil(component,event,helper);
                //var paymentUrl = "/apex/ChargentPaymentTerminal?order_id=" + orderDetails.Id;
                //window.location.href = paymentUrl;
                helper.showModalHelper(component, event, helper);
            }else {
                helper.toastAlert(component,"warning","Alert","Alert","Please select Shipping Method before taking payment.");
            }
        }else {
            helper.toastAlert(component,"warning","Alert","Alert","Please select Bill To Contact before taking payment.");
        }
    },
    openTab: function(component, event, helper) {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.openTab({
                recordId: orderDetails.Id,
                focus: true
            }).then(function(response) {
                workspaceAPI.getTabInfo({
                    tabId: response
                }).then(function(tabInfo) {
                    console.log("The url for this tab is: " + tabInfo.url);
                });
            })
            .catch(function(error) {
                console.log(error);
            });
        }
    })