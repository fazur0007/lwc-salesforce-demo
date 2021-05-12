public class RMA_Bulk_Upload_CC {
    public string Filename{get;set;}
    public Blob FileContent{get;set;}
    String[] filelines = new String[]{};
    public List<RMA_Product__c> rmaProductUpload{get;set;}
    public static Map<String,Product2> idVsProduct{get;set;}
    public static Map<String,Case> nameVsCase{get;set;}
    Set<String> productName;
    Set<String> caseName;
    public boolean isDataUploaded{get;set;}
    public RMA_Bulk_Upload_CC(ApexPages.StandardSetController controller){
        system.debug('Inside Constructor');
        controller.setPageSize(10);
    }
    public RMA_Bulk_Upload_CC(){
        
    }
    
    public Pagereference readFile(){
        try{
            /*rmaProductUpload =  new List<RMA_Product__c>();
            Filename=FileContent.toString();
            filelines = Filename.split('\n');
            
            Set<String> axUniqueId=new Set<String>();
            Set<String> caseName=new Set<String>();
            //Creating Map of Name Vs Product
            for(Integer i=1;i<filelines.size();i++)
            {
                String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');
                axUniqueId.add(inputvalues[0]);
                caseName.add(inputvalues[3]);
            }
            //Retriving Products
            List<Product2> productList=[select id,Name,AX_Unique_ID__c from Product2 where AX_Unique_ID__c IN: axUniqueId];
            List<Case> caseList=[select id,CaseNumber from Case where CaseNumber IN: caseName];
            idVsProduct= new Map<String,Product2>();
            nameVsCase=new Map<String,Case>();
            for(Product2 pr:productList){
                idVsProduct.put(pr.AX_Unique_ID__c,pr);
            }
            for(Case c:caseList){
                nameVsCase.put(c.CaseNumber,c);
            }
            system.debug('Printing Case List'+caseList);
            for(Integer i=1;i<filelines.size();i++)
            {
                String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');
                RMA_Product__c pr=new RMA_Product__c();
                pr.Product__c=idVsProduct.get(inputvalues[0]).id;
                pr.Product_Name__c=idVsProduct.get(inputvalues[0]).Name;
                pr.Quantity__c=Decimal.valueOf(inputvalues[1]);
                pr.Price__c=Decimal.valueOf(inputvalues[2]);
                pr.Case__c=nameVsCase.get(inputvalues[3]).id;
                pr.CurrencyIsoCode=(inputvalues[4]);
                rmaProductUpload.add(pr);
            }  */
            
            rmaProductUpload =  new List<RMA_Product__c>();
            Filename=FileContent.toString();
            filelines = Filename.split('\n');
            Set<String> caseName=new Set<String>();
            Map<String,String> caseNumberVsCurrency =new Map<String,String>();
            Map<String,Product2> nameVsProduct=new Map<String,Product2>();
            
            nameVsCase=new Map<String,Case>();
            for(Integer i=1;i<filelines.size();i++)
            {
                String[] inputvalues = new String[]{};
                inputvalues = filelines[i].split(',');
                caseName.add(inputvalues[3].trim());
            }
            system.debug('Printing Case Name'+caseName);
            List<Case> caseList=[select id,CaseNumber,CurrencyIsoCode from Case where CaseNumber IN: caseName];
            system.debug('Printign Case List'+caseList);
            for(Case c:caseList){
                
                system.debug('Print cc'+c.CurrencyIsoCode);
                caseNumberVsCurrency.put(c.CaseNumber,c.CurrencyIsoCode);
                nameVsCase.put(c.CaseNumber,c);
            }
            //Creating Map of Item No vs Ax Uniques Item Number
            Map<String,String> itemNoVsUniqueItemNo=new Map<String,String>();
            for(Integer i=1;i<filelines.size();i++)
            {
                String[] inputvalues = new String[]{};
                inputvalues = filelines[i].split(',');
                String prefix;
                system.debug('Printing Case SUrrency'+caseNumberVsCurrency.get(inputvalues[3]));
                if(caseNumberVsCurrency.get(inputvalues[3].trim()) == 'USD'){
                    prefix='BUS';
                }else if((caseNumberVsCurrency.get(inputvalues[3].trim()) == 'EUR')){
                    prefix='BDE';
                }else if((caseNumberVsCurrency.get(inputvalues[3].trim()) == 'GBP')){
                    prefix='BUK';
                }else if((caseNumberVsCurrency.get(inputvalues[3].trim()) == 'AUD')){
                    prefix='BAU';
                }else if((caseNumberVsCurrency.get(inputvalues[3].trim()) == 'CHF')){
                    prefix='BCH';
                }else if((caseNumberVsCurrency.get(inputvalues[3].trim()) == 'CAD')){
                    prefix='BCA';
                }else if((caseNumberVsCurrency.get(inputvalues[3].trim()) == 'NZD')){
                    prefix='BNZ';
                }
                itemNoVsUniqueItemNo.put(inputvalues[0],prefix+inputvalues[0]);
            }
            system.debug('itemNoVsUniqueItemNo: '+itemNoVsUniqueItemNo);
            List<Product2> productList=[select id,Name,AX_Unique_ID__c from Product2 where AX_Unique_ID__c IN: itemNoVsUniqueItemNo.values()];
            idVsProduct= new Map<String,Product2>();
            for(Product2 pr:productList){
                idVsProduct.put(pr.AX_Unique_ID__c,pr);
            }
            for(Integer i=1;i<filelines.size();i++)
            {
                String[] inputvalues = new String[]{};
                inputvalues = filelines[i].split(',');
                RMA_Product__c pr=new RMA_Product__c();
                pr.Product__c=idVsProduct.get(itemNoVsUniqueItemNo.get(inputvalues[0].trim())).id;
                pr.Product_Name__c=idVsProduct.get(itemNoVsUniqueItemNo.get(inputvalues[0].trim())).Name;
                pr.Quantity__c=Decimal.valueOf(inputvalues[1].trim());
                pr.Price__c=Decimal.valueOf(inputvalues[2].trim());
                pr.Case__c=nameVsCase.get(inputvalues[3].trim()).id;
                pr.CurrencyIsoCode=caseNumberVsCurrency.get(inputvalues[3].trim());
                rmaProductUpload.add(pr);
            } 
            
            
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Kindly verify uploaded file and try again'));
        }
        return null;
        
    }
    public  void upload(){
        system.debug('Printing RMA Product'+rmaProductUpload);
        if(rmaProductUpload.size() != 0){
            insert rmaProductUpload;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Data uploaded successfully,close the tab'));
            isDataUploaded =true;
        }
    }
    public PageReference  download(){
        
      /*  var urlEvent = $A.get('e.force:navigateToURL');
        urlEvent.setParams({
            'url': '/apex/Template'
        });
        urlEvent.fire();*/
        PageReference pageRef = new PageReference('/apex/Template');
        pageRef.setRedirect(false);
        return pageRef;
    }
    public PageReference done(){
        
        Id ProductId;
        PageReference redirect = null;
        productId=ApexPages.currentPage().getParameters().get('id');
        
        String url = System.Url.getSalesforceBaseURL().toExternalForm() +
        Site.getPathPrefix() +'/' + productId;
        system.debug('url ****'+url);
        redirect = new PageReference(url);
        redirect.setRedirect(true);
        return redirect;
    }
}