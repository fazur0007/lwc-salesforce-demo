public with sharing class MultipleFileUploadController {
    @AuraEnabled
    public static List<ContentDocumentLink> cloneAndInsertContentDocumentLinkRecord(String recordId, String documentObjectId){
        List<ContentDocumentLink> listOfContentDocumentLinkTobeInserted = new List<ContentDocumentLink>();
        List<ContentDocumentLink> listOfContentDocumentLinkTobeDeleted = new List<ContentDocumentLink>();
        for(ContentDocumentLink ContentDocumentLinkRecord : [SELECT Id,ContentDocumentId,Visibility,ShareType,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId=:documentObjectId]) {
            ContentDocumentLink clonedContentDocumentLinkRecord = ContentDocumentLinkRecord.clone();
            clonedContentDocumentLinkRecord.LinkedEntityId = recordId;
            clonedContentDocumentLinkRecord.ShareType = ContentDocumentLinkRecord.ShareType;
            listOfContentDocumentLinkTobeInserted.add(clonedContentDocumentLinkRecord);
            listOfContentDocumentLinkTobeDeleted.add(ContentDocumentLinkRecord);
        }
        if(listOfContentDocumentLinkTobeInserted.size() > 0)
            Database.insert(listOfContentDocumentLinkTobeInserted,false);
        if(listOfContentDocumentLinkTobeDeleted.size() > 0)
            Database.delete(listOfContentDocumentLinkTobeDeleted,false);
    return listOfContentDocumentLinkTobeInserted;
    }
}