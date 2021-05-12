public class SiteVisitProductDetailsExtension{
    
    private ApexPages.StandardController controller {get; set;}
    public Site_Visit__c siteVisit {get; set;}
    public Site_Visit__c siteVisit1 {get; set;}
    public SiteVisitProductDetailsExtension(ApexPages.StandardController controller){
        this.controller = controller;
        this.siteVisit = (Site_Visit__c)controller.getRecord();
        this.siteVisit = [select id,CurrencyIsoCode,Out_of_Stock_Models__c,OutOfStockProducts__c,Knowledge_Products__c from Site_Visit__c where id =:siteVisit.Id ];
        this.siteVisit1 = new Site_Visit__c();
        this.siteVisit1.Knowledge_Products__c = siteVisit.Knowledge_Products__c;
        this.siteVisit1.CurrencyIsoCode = siteVisit.CurrencyIsoCode;
        this.siteVisit1.OutOfStockProducts__c= siteVisit.OutOfStockProducts__c;
        this.siteVisit1.Id= siteVisit.Id;
    }
    
    public void addOutOfStockModel(){
        List<Product2> productList = [select id, AX_Item_Number__c from Product2 where id =: siteVisit.OutOfStockProducts__c];
        if(productList != null && productList.size() >0 && productList[0].AX_Item_Number__c != ''){
            if(siteVisit.Out_of_Stock_Models__c == null ||siteVisit.Out_of_Stock_Models__c =='' ){
                siteVisit.Out_of_Stock_Models__c = ';'+productList[0].AX_Item_Number__c+';';
            }else{
                if(!siteVisit.Out_of_Stock_Models__c.contains(';'+productList[0].AX_Item_Number__c+';')){
                    siteVisit.Out_of_Stock_Models__c = siteVisit.Out_of_Stock_Models__c+productList[0].AX_Item_Number__c+';';
                }
            }
            siteVisit.OutOfStockProducts__c = null;
            update siteVisit;
        }
    }
    public void addKnowledgeProduct(){
        List<Product2> productList = [select id, AX_Item_Number__c from Product2 where id =: siteVisit1.OutOfStockProducts__c];
        if(productList != null && productList.size() >0 && productList[0].AX_Item_Number__c != ''){
            if(siteVisit1.Knowledge_Products__c == null ||siteVisit1.Knowledge_Products__c =='' ){
                siteVisit1.Knowledge_Products__c = ';'+productList[0].AX_Item_Number__c+';';
            }else{
                if(!siteVisit.Knowledge_Products__c.contains(';'+productList[0].AX_Item_Number__c+';')){
                    siteVisit1.Knowledge_Products__c = siteVisit1.Knowledge_Products__c+productList[0].AX_Item_Number__c+';';
                }
            }
            siteVisit1.OutOfStockProducts__c = null;
            siteVisit.Knowledge_Products__c = siteVisit1.Knowledge_Products__c;
            update siteVisit;
        }
    }
}