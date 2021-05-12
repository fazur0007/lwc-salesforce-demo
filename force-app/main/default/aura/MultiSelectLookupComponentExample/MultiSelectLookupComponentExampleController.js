({
    doInit : function(cmp, evt, hlp) {        
        hlp.apex(cmp,'initProductsLoadSearch',{ searchString : null })
        .then(function(result){  
            console.log(JSON.stringify(result));
            var items = [];
            for(var key in result){
                items.push({label: result[key], value: key});
            }
            //cmp.set("v.itemOptions", items);
            return hlp.apex(cmp,'getBusinessUnits',{ searchString : null });
        })
        .then(function(result){
            var regionOptions = [];
            for(var key in result){
                regionOptions.push({label: result[key], value: key});
            }
            cmp.set("v.regionOptions", regionOptions);
            cmp.find("RegionId").set("v.value", 'Select');
            return hlp.apex(cmp,'getDocTypes',{ searchString : null });
            
        })
        .then(function(result){
            var docOptions = [];
            for(var key in result){
                docOptions.push({label: result[key], value: key});
            }
            cmp.set("v.docOptions", docOptions);
            cmp.find("DocTypeId").set("v.value", 'Select');
            cmp.set("v.showLoader",false);
        })
    },
    onblur : function(cmp,event,hlp){
        cmp.set("v.listOfSearchRecords", null );
        cmp.set("v.SearchKeyWord", '');
        var forclose = cmp.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');        
    },
    onfocus : function(cmp,evt,hlp){
        $A.util.addClass(cmp.find("mySpinner"), "slds-show");
        cmp.set("v.listOfSearchRecords", null ); 
        var forOpen = cmp.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        var getInputkeyWord = '';
        hlp.searchhlp(cmp,evt,getInputkeyWord);
    },
    keyPressController : function(cmp, evt, hlp) {
        $A.util.addClass(cmp.find("mySpinner"), "slds-show");
        var getInputkeyWord = cmp.get("v.SearchKeyWord");
        if(getInputkeyWord.length > 2){
            var forOpen = cmp.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            console.log("event code ::"+evt.getParams().keyCode);
            console.log(evt);
            /*if(evt.getParams().keyCode === 13){
                hlp.searchDB(cmp,evt,hlp,getInputkeyWord);
            }else{
                hlp.searchhlp(cmp,evt,getInputkeyWord);
            }*/
            hlp.searchDB(cmp,evt,hlp,getInputkeyWord);
        }
        else{  
            cmp.set("v.listOfSearchRecords", null ); 
            var forclose = cmp.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    clear :function(cmp,evt,hlp){        
        var selectedPillId = evt.getSource().get("v.name");
        var AllPillsList = cmp.get("v.lstSelectedRecords"); 
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].value == selectedPillId){
                AllPillsList.splice(i, 1);
                cmp.set("v.lstSelectedRecords", AllPillsList);
            }  
        }
        cmp.set("v.SearchKeyWord",null);
        cmp.set("v.listOfSearchRecords", null );      
    },
    selectRecord: function(cmp, evt, hlp) {
        cmp.set("v.SearchKeyWord",null);        
        var selectedItem = evt.currentTarget;        
        var listSelectedItems =  cmp.get("v.lstSelectedRecords");
        listSelectedItems.push({
            "label": selectedItem.dataset.label,
            "value": selectedItem.dataset.value
        });
        cmp.set("v.lstSelectedRecords" , listSelectedItems); 
        var forclose = cmp.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = cmp.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open'); 
    },
    doSearch :  function(cmp, evt, hlp) {
        cmp.set("v.showLoader",true);
        const searchStr = cmp.find('enter-search').get('v.value');
        const docType = cmp.find('DocTypeId').get('v.value');
        const businessUnit = cmp.find('RegionId').get('v.value');
        const selectedRecords = cmp.get("v.lstSelectedRecords");
        const productList = [];
        
        for(var key in selectedRecords){
            productList.push(selectedRecords[key].value);
        }
        if(searchStr.length>0 || productList.length>0)
        {   
            hlp.apex(cmp,'searchKnowledgeBase',{
                productList : productList,
                businessUnit : businessUnit,
                docType : docType,
                searchStr : searchStr
            })
            .then(function(result){
                if(result.length > 0){
                    hlp.onLoad(cmp,evt,hlp,result);
                    cmp.set("v.showLoader",false);
                }else{
                    cmp.set("v.data","");
                    hlp.errorUtil(cmp,'Error',"No results found!",'error');
                }
            })
            
        }
        else
        {
            cmp.set("v.data","");
            hlp.errorUtil(cmp,'Error',"Please Select a Product or Search the Knowledge Base !",'error');
        }
    },
    handleClearFilters : function(cmp, evt, hlp) {        
        hlp.removeFilters(cmp, hlp);
        hlp.buildDataAfterFilter(cmp, hlp);
    },
    keyCheck : function(cmp, evt, hlp){
        if (evt.which == 13){
            cmp.set("v.showLoader",true);
            cmp.set('v.issearching', true);
            const searchStr = cmp.find('enter-search').get('v.value');
            const docType = cmp.find('DocTypeId').get('v.value');
            const businessUnit = cmp.find('RegionId').get('v.value');
            const selectedRecords = cmp.get("v.lstSelectedRecords");
            const productList = [];
            cmp.set("v.searchString",searchStr);
            for(var key in selectedRecords){
                productList.push(selectedRecords[key].value);
            }
            if(searchStr.length>0 || productList.length>0)
            {
                hlp.apex(cmp,'searchKnowledgeBase',{
                    productList : productList,
                    businessUnit : businessUnit,
                    docType : docType,
                    searchStr : searchStr
                })
                .then(function(result){
                    if(result.length > 0){
                        hlp.onLoad(cmp,evt,hlp,result);
                        cmp.set('v.issearching', false);
                        cmp.set("v.showLoader",false);
                    }else{
                        cmp.set("v.data","");
                        hlp.errorUtil(cmp,'Error',"No Results found!",'error');
                    }
                })
            }
            else
            {
                cmp.set("v.data","");
                hlp.errorUtil(cmp,'Error',"Please Select a Product or Search the Knowledge Base !",'error');
            }
        }
    },    
    handleMouseHover: function(cmp, evt, hlp) {
        cmp.set("v.accountIdHover",evt.srcElement.id);
        hlp.getMiniLayout(cmp, evt, hlp)
    },
    handleMouseOut: function(cmp, evt, hlp) {
        cmp.set("v.hoverRow",-1);
        cmp.set("v.togglehover",false);
    },
    onNext : function(cmp, evt, hlp) {        
        var pageNumber = cmp.get("v.currentPageNumber"); 
        cmp.set("v.currentPageNumber", pageNumber+1);
        hlp.buildData(cmp, hlp);
    },
    onPrev : function(cmp, evt, hlp) {        
        var pageNumber = cmp.get("v.currentPageNumber");
        cmp.set("v.currentPageNumber", pageNumber-1);
        hlp.buildData(cmp, hlp);
    },
    processMe : function(cmp, evt, hlp) {
        cmp.set("v.currentPageNumber", parseInt(evt.target.name));
        hlp.buildData(cmp, hlp);
    },    
    onFirst : function(cmp, evt, hlp) {        
        cmp.set("v.currentPageNumber", 1);
        hlp.buildData(cmp, hlp);
    },
    onLast : function(cmp, evt, hlp) {        
        cmp.set("v.currentPageNumber", cmp.get("v.totalPages"));
        hlp.buildData(cmp, hlp);
    },
    searchDescription :function(cmp, evt, hlp) {
        var queryTerm = cmp.find('descriptionName').get('v.value');
        if(queryTerm){
            var allDataArray = [];
            allDataArray = hlp.filterDataFromAllData(cmp,queryTerm, 'Description__c');
            hlp.buildDataArray(cmp, hlp,allDataArray);
        }
    },
    searchKKnowledge: function(cmp, evt, hlp) {
        var queryTerm = cmp.find('KnowledgeName').get('v.value');
        if(queryTerm){
            var allDataArray = [];
            allDataArray = hlp.filterDataFromAllData(cmp,queryTerm, 'Name');
            hlp.buildDataArray(cmp, hlp,allDataArray);
        }
    },
    searchTitle: function(cmp, evt, hlp) {
        var queryTerm = cmp.find('titleName').get('v.value');
        if(queryTerm){
            var allDataArray = [];
            allDataArray = hlp.filterDataFromAllData(cmp,queryTerm, 'Title__c');
            hlp.buildDataArray(cmp, hlp,allDataArray);
        }
    },
    searchRegion: function(cmp, evt, hlp) {
        var queryTerm = cmp.find('regionName').get('v.value');
        if(queryTerm){            
            var allDataArray = [];
            allDataArray = hlp.filterDataFromAllData(cmp,queryTerm.toUpperCase(), 'Region__c');
            hlp.buildDataArray(cmp, hlp,allDataArray);
        }
    },
    searchProduct: function(cmp, evt, hlp) {
        var queryTerm = cmp.find('productName').get('v.value');
        if(queryTerm){            
            var allDataArray = [];
            allDataArray = hlp.filterDataFromAllData(cmp,queryTerm.toUpperCase(), 'Product__r.Name');
            hlp.buildDataArray(cmp, hlp,allDataArray);
        }
    },
    searchDoctype: function(cmp, evt, hlp) {
        var queryTerm = cmp.find('docType').get('v.value');
        if(queryTerm){            
            var allDataArray = [];
            allDataArray = hlp.filterDataFromAllData(cmp,queryTerm.toUpperCase(), 'DocType__c');
            hlp.buildDataArray(cmp, hlp,allDataArray);
        }
    },	
    searchDownloadLink : function(cmp, evt, hlp) {
        var queryTerm = cmp.find('downloadLink').get('v.value');
        if(queryTerm){
            var allDataArray = [];
            allDataArray = hlp.filterDataFromAllData(cmp,queryTerm, 'DownloadLink__c');
            hlp.buildDataArray(cmp, hlp,allDataArray);
        }
    }, 
    searchOutOfDate : function(cmp, evt, hlp) {
        var queryTerm = cmp.find('outOfDate').get('v.value');
        if(queryTerm){
            var allDataArray = [];
            allDataArray = hlp.filterDataFromAllData(cmp,queryTerm, 'isOutOfDate__c');
            hlp.buildDataArray(cmp, hlp,allDataArray);
        }
    },
    searchNewKnowledgeName : function(cmp, evt, hlp) {
        var queryTerm = cmp.find('newKnowledgeName').get('v.value');
        if(queryTerm){
            var allDataArray = [];
            allDataArray = hlp.filterDataFromAllData(cmp,queryTerm, 'New_Knowledge_Base__r.Name');
            hlp.buildDataArray(cmp, hlp,allDataArray);
        }
    },
    redirectToRecord : function(cmp, evt, hlp) { 
        var navService = cmp.find("navService");
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: '',
                recordId : evt.currentTarget.getAttribute("data-attriVal") 
            },
        };
        navService.navigate(pageRef, true); 
    },
    handleCloseModal: function(component, event, helper) {
        component.set("v.isDownloadView", false);
        //$A.get('e.force:refreshView').fire();
    },
    loadpdf : function(component, event, helper) {
        helper.loadpdf(component,event);
    },
    downloadAWSStorage : function(cmp, evt, hlp) {
        cmp.set("v.showLoader",true);
        const downloadURL = evt.currentTarget.getAttribute("data-attriVal");
        cmp.set("v.downloadURL",downloadURL.split('"')[1]);
        cmp.set("v.isDownloadView",true);
        setTimeout(function(){ cmp.set("v.showLoader",false); }, 2000);
    },
    searchResultsFromDB : function(cmp, evt, hlp) {
        alert("abhish");
    },        
})