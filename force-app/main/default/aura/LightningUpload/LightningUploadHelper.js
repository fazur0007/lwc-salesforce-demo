({
    handleUploadFinished : function(component, event, helper) {
        var uploadedFileArr = [];
        var sObjectAttachedFiles = component.get("v.sObjectAttachedFiles");
        var sObjectAttachedFilesArr = [];
        if(sObjectAttachedFiles != null && sObjectAttachedFiles != undefined && sObjectAttachedFiles.length > 0){
            [].forEach.call(sObjectAttachedFiles, function(file) {
                sObjectAttachedFilesArr.push({'Id' : file.Id,'Title': file.Title});
            });
        }
        var uploadedFiles = event.getParam("files");
        [].forEach.call(uploadedFiles, function(file) {
            uploadedFileArr.push({'Id' : file.documentId,'Name': file.name});
            sObjectAttachedFilesArr.push({'Id' : file.documentId,'Title': file.name});
        });
        component.set("v.sObjectAttachedFiles", sObjectAttachedFilesArr);
        var filesUploadedPreviously = component.get('v.uploadedFiles');
        if(filesUploadedPreviously != null && filesUploadedPreviously != undefined && filesUploadedPreviously.length > 0){
            [].forEach.call(filesUploadedPreviously, function(file) {
                uploadedFileArr.push({'Id' : file.Id,'Name': file.Name});
            });
        }
        console.log('****'+JSON.stringify(uploadedFileArr));
        component.set("v.uploadedFiles",uploadedFileArr);
    },
    handleSaveClick : function(component, event, helper){
        component.set("v.showLoader",true);
        var sObjectId = component.get("v.sObjectId");
        console.log("****"+JSON.stringify(component.get("v.uploadedFiles")));
        let uploadedFiles = component.get("v.uploadedFiles");
        helper.apexUtil(component,helper,'cloneAndInsertContentDocumentLinkRecord',{
            recordId : sObjectId,
            documentObjectId : uploadedFiles[0].Id
        })
        .then(function(result){
            console.log("new object details*****"+JSON.stringify(result));
            component.set("v.showLoader",false);
        })
    },
    apexUtil : function(component,helper, apexMethod, params ) {
        return new Promise( $A.getCallback( function( resolve , reject ) { 
            var action = component.get("c."+apexMethod+"");
            action.setParams( params );
            action.setCallback( this , function(response) {
                if(response.getState()=='SUCCESS') {
                    resolve( response.getReturnValue() );
                }else if(response.getState()=='ERROR') {    
                    console.log("error::"+JSON.stringify(response.getError()));
                    helper.errorUtil(component,'Error',response.getError()[0].message,'error');                    
                    component.set("v.showLoader",false);
                }
            });
            $A.enqueueAction( action );
        }));    
    },
    errorUtil : function(component,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:'1000',
            key: 'error_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
        component.set("v.showLoader",false);
    },
})