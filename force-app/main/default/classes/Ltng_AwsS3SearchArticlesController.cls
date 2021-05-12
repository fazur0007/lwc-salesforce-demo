public class Ltng_AwsS3SearchArticlesController {
    @AuraEnabled
    public static Map < String, String > initProductsLoadSearch(String searchString) {
        Map < String, String > mapOfProducts = new Map < String, String > ();
        if (String.isBlank(searchString)) {
            for (Product2 prod2: [select Id, Name, Country_code__c from Product2
                                  where IsActive = true
                                  and Finished_Good__c = true
                                  AND Exclude_from_Sync__c = false limit 40
                                 ]) 
            {
                   
                mapOfProducts.put(prod2.Id,  String.isNotBlank(prod2.Country_code__c)?prod2.Name +' ('+ prod2.Country_code__c +')':prod2.Name);
            }
            return mapOfProducts;
        }
        else {
            String searchFuzzy = +'%' + searchString + '%';
            for (Product2 prod2: [select Id, Name, Country_code__c from Product2
                                  where IsActive = true
                                  and Finished_Good__c = true
                                  AND Exclude_from_Sync__c = false
                                  and(
                                      Product_Sub_Family__c like: searchFuzzy or Name like: searchFuzzy
                                  )
                                  limit 100
                                 ]) {
                                     mapOfProducts.put(prod2.Id,  String.isNotBlank(prod2.Country_code__c)?prod2.Name +' ('+ prod2.Country_code__c +')':prod2.Name);
                                 }
            
            return mapOfProducts;
        }
        
    }
    @AuraEnabled
    public static Map < String, String > getBusinessUnits(String searchString) {
        Map < String, String > mapOfProducts = new Map < String, String > ();
        mapOfProducts.put(System.Label.Select2, System.Label.Select2);
        for (Region_Specific__mdt record: [SELECT DeveloperName FROM Region_Specific__mdt]) {
            mapOfProducts.put(record.DeveloperName, record.DeveloperName);
        }
        return mapOfProducts;
    }
    @AuraEnabled
    public static Map < String, String > getDocTypes(String searchString) {
        Map < String, String > mapOfProducts = new Map < String, String > ();
        mapOfProducts.put(System.Label.Select2, System.Label.Select2);
        Schema.DescribeFieldResult fieldResult = Knowledge_Base__c.DocType__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal: ple) {
            mapOfProducts.put(pickListVal.getLabel(), pickListVal.getLabel());
        }
        return mapOfProducts;
    }
    @AuraEnabled
    public static List<Knowledge_Base__c> searchKnowledgeBase(List < String > productList, String businessUnit, String docType, String searchStr) {
        String knowledgeBaseRecordId = Schema.SObjectType.Knowledge_Base__c.getRecordTypeInfosByName().get(Label.KBRecordTypeKnowledgeRepo).getRecordTypeId();
        List<Knowledge_Base__c> listOfKnowledgeRecs = new List<Knowledge_Base__c> ();
        if (searchStr != null && searchStr.length() > 1) {
            system.debug('productList::'+productList);
            system.debug('businessUnit::'+businessUnit);
            system.debug('docType::'+docType);
            system.debug('searchStr::'+searchStr);
            
            List < List < SObject >> searchList;
            if (productList != null && productList.size() > 0) {
                if (businessUnit != System.Label.Select2 && docType != System.Label.Select2) {
                    searchList = [FIND: searchStr IN ALL FIELDS RETURNING Knowledge_Base__c(Id, Name, Title__c, Description__c, DocType__c, Region__c, Product__c,Product__r.Name,New_Knowledge_Base__r.Name,DownloadLink__c, isOutOfDate__c, New_Knowledge_Base__c WHERE Product__c IN: productList AND Region__c INCLUDES(: businessUnit) AND DocType__c =: docType AND RecordTypeId =: knowledgeBaseRecordId AND Case__c=''  Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                    system.debug('1');
                }
                else if (businessUnit != System.Label.Select2) {
                    searchList = [FIND: searchStr IN ALL FIELDS RETURNING Knowledge_Base__c(Id, Name, Title__c, Description__c, DocType__c, Region__c, Product__c,Product__r.Name,New_Knowledge_Base__r.Name, DownloadLink__c, isOutOfDate__c, New_Knowledge_Base__c WHERE Product__c IN: productList AND Region__c INCLUDES(: businessUnit) AND RecordTypeId =: knowledgeBaseRecordId AND Case__c='' Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                    system.debug('2');
                }
                else if (docType != System.Label.Select2) {
                    searchList = [FIND: searchStr IN ALL FIELDS RETURNING Knowledge_Base__c(Id, Name, Title__c, Description__c, DocType__c, Region__c, Product__c,Product__r.Name,New_Knowledge_Base__r.Name, DownloadLink__c, isOutOfDate__c, New_Knowledge_Base__c WHERE Product__c IN: productList AND DocType__c =: docType AND RecordTypeId =: knowledgeBaseRecordId AND Case__c='' Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                    system.debug('3');
                }
                else {
                    searchList = [FIND: searchStr IN ALL FIELDS RETURNING Knowledge_Base__c(Id, Name, Title__c, Description__c, DocType__c, Region__c, Product__c,Product__r.Name,New_Knowledge_Base__r.Name, DownloadLink__c, isOutOfDate__c, New_Knowledge_Base__c WHERE Product__c IN: productList AND RecordTypeId =: knowledgeBaseRecordId AND Case__c='' Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                    system.debug('4');
                }
            }
            else {
                
                if (businessUnit != System.Label.Select2 && docType != System.Label.Select2) {
                    searchList = [FIND: searchStr IN ALL FIELDS RETURNING Knowledge_Base__c(Id, Name, Title__c, Description__c, DocType__c, Region__c, Product__c,Product__r.Name,New_Knowledge_Base__r.Name, DownloadLink__c, isOutOfDate__c, New_Knowledge_Base__c WHERE RecordTypeId =: knowledgeBaseRecordId AND Region__c INCLUDES(: businessUnit) AND DocType__c =: docType AND Case__c=''  Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                    system.debug('5');
                }
                else if (businessUnit != System.Label.Select2) {
                    searchList = [FIND: searchStr IN ALL FIELDS RETURNING Knowledge_Base__c(Id, Name, Title__c, Description__c, DocType__c, Region__c, Product__c,Product__r.Name,New_Knowledge_Base__r.Name, DownloadLink__c, isOutOfDate__c, New_Knowledge_Base__c WHERE RecordTypeId =: knowledgeBaseRecordId AND Region__c INCLUDES(: businessUnit)  AND Case__c='' Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                    system.debug('6');
                }
                else if (docType != System.Label.Select2) {
                    searchList = [FIND: searchStr IN ALL FIELDS RETURNING Knowledge_Base__c(Id, Name, Title__c, Description__c, DocType__c, Region__c, Product__c,Product__r.Name,New_Knowledge_Base__r.Name, DownloadLink__c, isOutOfDate__c, New_Knowledge_Base__c WHERE RecordTypeId =: knowledgeBaseRecordId AND DocType__c =: docType AND Case__c='' Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                    system.debug('7');
                }
                else {
                    searchList = [FIND: searchStr IN ALL FIELDS RETURNING Knowledge_Base__c(Id, Name, Title__c, Description__c, DocType__c, Region__c, Product__c,Product__r.Name,New_Knowledge_Base__r.Name, DownloadLink__c, isOutOfDate__c, New_Knowledge_Base__c WHERE RecordTypeId =: knowledgeBaseRecordId AND Case__c='' Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc)];
                    system.debug('8');
                }
            }
            Knowledge_Base__c [] knowList = (Knowledge_Base__c [])searchList[0];
            if(knowList.size() > 0){
                listOfKnowledgeRecs =  knowList;
            } 
        }
        else if (productList != null && productList.size() > 0) {
            List < Knowledge_Base__c > knowledgeList;
            if (businessUnit != System.Label.Select2 && docType != System.Label.Select2) {
                system.debug('Product list with business unit and doc type:'+productList + businessUnit);
                knowledgeList = [SELECT Id, Name, Title__c, Description__c, DocType__c, Region__c, Product__c,Product__r.Name,New_Knowledge_Base__r.Name, DownloadLink__c, isOutOfDate__c, New_Knowledge_Base__c
                                 FROM Knowledge_Base__c
                                 WHERE Product__c IN: productList
                                 AND RecordTypeId =: knowledgeBaseRecordId
                                 AND Region__c INCLUDES(: businessUnit)
                                 AND DocType__c =: docType
                                 AND Case__c=''
                                 Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc
                                ];
                
            }
            else if (businessUnit != System.Label.Select2) {
                system.debug('Product list with business unit:'+productList + businessUnit);
                knowledgeList = [SELECT Id, Name, Title__c, Description__c, DocType__c, Region__c, Product__c,Product__r.Name,New_Knowledge_Base__r.Name, DownloadLink__c, isOutOfDate__c, New_Knowledge_Base__c
                                 FROM Knowledge_Base__c
                                 WHERE Product__c IN: productList
                                 AND RecordTypeId =: knowledgeBaseRecordId
                                 AND Region__c INCLUDES(: businessUnit)
                                 AND Case__c=''
                                 Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc
                                ];
            }
            else if (docType != System.Label.Select2) {
                system.debug('Product list with doctype:'+productList + docType);
                knowledgeList = [SELECT Id, Name, Title__c, Description__c, DocType__c, Region__c, Product__c,Product__r.Name,New_Knowledge_Base__r.Name, DownloadLink__c, isOutOfDate__c, New_Knowledge_Base__c
                                 FROM Knowledge_Base__c
                                 WHERE Product__c IN: productList
                                 AND RecordTypeId =: knowledgeBaseRecordId
                                 AND DocType__c =: docType
                                 AND Case__c=''
                                 Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc
                                ];
            }
            else {
                system.debug('Only Product list:'+productList);
                knowledgeList = [SELECT Id, Name, Title__c, Description__c, DocType__c, Region__c, Product__c,Product__r.Name,New_Knowledge_Base__r.Name, DownloadLink__c, isOutOfDate__c, New_Knowledge_Base__c
                                 FROM Knowledge_Base__c
                                 WHERE Product__c IN: productList
                                 AND RecordTypeId =: knowledgeBaseRecordId
                                 AND Case__c=''
                                 Order by New_Knowledge_Base__c desc NULLS First, CreatedDate desc
                                ];
            }
            if(knowledgeList.size() > 0){
                listOfKnowledgeRecs  = knowledgeList;
            }            
        } 
        return listOfKnowledgeRecs;       
    }
}