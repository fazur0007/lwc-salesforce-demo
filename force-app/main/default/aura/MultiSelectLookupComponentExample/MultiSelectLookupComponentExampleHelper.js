({
    apex : function( cmp, apexAction, params ) {
        var p = new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = cmp.get("c."+apexAction+""); 
            action.setParams( params );
            action.setCallback( this , function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));            
        return p;
    },
    onLoad : function(cmp,evt,hlp,result) {
        cmp.set("v.totalPages", Math.ceil(result.length/cmp.get("v.pageSize")));
        cmp.set("v.allData", result);
        cmp.set("v.currentPageNumber",1);
        window.allData = cmp.get("v.allData");
        hlp.buildData(cmp, hlp);
    },
    searchDB : function(cmp,evt,hlp,term) {        
        var excludeitemsList= cmp.get("v.lstSelectedRecords");
        var excludeitemsListValues = [];
        for(var i =0; i<excludeitemsList.length; i++){
            excludeitemsListValues.push(excludeitemsList[i].value);
        }
        var searchList = [];
        var searchList1 = [];
        term = term.toLowerCase();
        //cmp.set("v.itemOptions", null);
        hlp.apex(cmp,'initProductsLoadSearch',{
            searchString : cmp.get("v.SearchKeyWord") 
        })
        .then(function(result){  
            console.log("faz result::"+JSON.stringify(result));
            var items = [];
            for(var key in result){
                items.push({label: result[key], value: key});
            }
            cmp.set("v.itemOptions", items);
        })
        var listOfOptions = cmp.get("v.itemOptions");
        for(var i =0; i<listOfOptions.length; i++){
            var option = listOfOptions[i].label.toLowerCase();
            if(option.indexOf(term) !== -1 && excludeitemsListValues.indexOf(listOfOptions[i].value) < 0){
                searchList.push(listOfOptions[i]);
            }
            if(!term && excludeitemsListValues.indexOf(listOfOptions[i].value) < 0){
                searchList1.push(listOfOptions[i]);
            }
        }
        $A.util.removeClass(cmp.find("mySpinner"), "slds-show");
        cmp.set("v.listOfSearchRecords", searchList);
        if(!term){
            cmp.set("v.listOfSearchRecords", searchList1);
        }
    },
    searchhlp : function(cmp,evt,term) {        
        var excludeitemsList= cmp.get("v.lstSelectedRecords");
        var excludeitemsListValues = [];
        for(var i =0; i<excludeitemsList.length; i++){
            excludeitemsListValues.push(excludeitemsList[i].value);
        }
        var searchList = [];
        var searchList1 = [];
        term = term.toLowerCase();
        var listOfOptions = cmp.get("v.itemOptions");
        for(var i =0; i<listOfOptions.length; i++){
            var option = listOfOptions[i].label.toLowerCase();
            if(option.indexOf(term) !== -1 && excludeitemsListValues.indexOf(listOfOptions[i].value) < 0){
                searchList.push(listOfOptions[i]);
            }
            if(!term && excludeitemsListValues.indexOf(listOfOptions[i].value) < 0){
                searchList1.push(listOfOptions[i]);
            }
        }
        $A.util.removeClass(cmp.find("mySpinner"), "slds-show");
        cmp.set("v.listOfSearchRecords", searchList);
        if(!term){
            cmp.set("v.listOfSearchRecords", searchList1);
        }
    },
    buildDataArray : function(cmp, hlp,allDataArray) {
        var data = [];
        var pageNumber = cmp.get("v.currentPageNumber");
        var pageSize = cmp.get("v.pageSize");
        var allData = allDataArray;
        var x = (pageNumber-1)*pageSize;
        
        for(; x<=(pageNumber)*pageSize; x++){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        cmp.set("v.data", data);
        hlp.generatePageList(cmp, pageNumber);
    },
    buildData : function(cmp, hlp) {
        var data = [];
        var pageNumber = cmp.get("v.currentPageNumber");
        var pageSize = cmp.get("v.pageSize");
        var allData = cmp.get("v.allData");
        var x = (pageNumber-1)*pageSize;
        
        for(; x<=(pageNumber)*pageSize; x++){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        cmp.set("v.data",data);
        console.log("data format ::"+JSON.stringify(data));
        hlp.generatePageList(cmp, pageNumber);
    },
    buildDataAfterFilter : function(cmp, hlp) {
        var data = [];
        var pageNumber = 1;
        var pageSize = cmp.get("v.pageSize");
        var allData = cmp.get("v.allData");
        var x = (pageNumber-1)*pageSize;
        
        for(; x<=(pageNumber)*pageSize; x++){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        cmp.set("v.data",data);
        console.log("data format ::"+JSON.stringify(data));
        hlp.generatePageList(cmp, pageNumber);
    },
    generatePageList : function(cmp, pageNumber){
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = cmp.get("v.totalPages");
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
        cmp.set("v.pageList", pageList);        
        cmp.set("v.showLoader",false);
    }, 
    filterDataFromAllData: function(cmp,queryTerm, searchField){
        try {
            var tempArray = allData.filter(function(item){
                var temp = '';
                if(searchField === 'Profile_Linkable'){
                    temp = (item && item[searchField] && item[searchField].toString()) ? item[searchField].toString() : 'false';
                }else{
                    temp = (item && item[searchField] && item[searchField].toString()) || '' ? item[searchField].toString() : '';    
                }
                return temp.includes(queryTerm)
            });
            return tempArray;
        }
        catch(e) {
            alert(e);
        }
    },
    removeFilters : function(cmp,hlp){
        cmp.find("KnowledgeName").set("v.value", "");
        cmp.find("titleName").set("v.value", "");
        cmp.find("descriptionName").set("v.value", "");
        cmp.find("regionName").set("v.value", "");
        cmp.find("productName").set("v.value", "");
        cmp.find("docType").set("v.value", "");
        cmp.find("downloadLink").set("v.value", "");
        cmp.find("outOfDate").set("v.value", "");
        cmp.find("newKnowledgeName").set("v.value", "");
    },
    loadpdf:function(component,event){
        try{
            var pdfData = component.get('v.pdfData');
            var pdfjsframe = component.find('pdfFrame')
            if(typeof pdfData != 'undefined'){
                pdfjsframe.getElement().contentWindow.postMessage(pdfData,'*');	
            }
        }catch(e){
            alert('Error: ' + e.message);
        }
    },
    errorUtil : function(cmp,title,message,type){
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
        cmp.set("v.showLoader",false);
    }, 
})