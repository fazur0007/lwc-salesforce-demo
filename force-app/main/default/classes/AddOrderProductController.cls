public with sharing class AddOrderProductController {
    public list<Pricebookentrywrapper> pberecordlist { get; set;}
    public List<PricebookEntry> priceBookEntList{get; set;} 
    public List<Pricebookentrywrapper> selectedOrderProducts{get;set;}
    public String filters {get;set;}
    public String searchText {get;set;}
    public static Boolean showPromotionalPriceforB2COrder {get; set;}
    
    public integer count=1;   //to track the function calling
    public integer counter=0;   //to keep track of offset
    public integer list_size=10; //to set the page size to show the rows/records
    public integer total_size; //used to show user the total size of the list 
    public integer totalpages;
    public boolean callSearchMethod;
    public String currencycode;
    
    List<Order> ordValues = new List<Order>();
    Id orderId;
    public static Map<string,list<Offer_Product__c>> offerProductMap = new Map<string,list<Offer_Product__c>>();
    
    public AddOrderProductController(ApexPages.StandardController stdController) {
        
        orderId = ApexPages.currentPage().getParameters().get('id');
        ordValues =[select Id,PriceBook2Id,CurrencyIsoCode,OrderCustomerType__c,Type, AX_Order_Account__c from Order where Id =: orderId];
        currencycode =ordValues[0].CurrencyIsoCode; 
        showPromotionalPriceforB2COrder = false;        
        
        total_size=[Select Count() from PricebookEntry where Pricebook2Id = :ordValues[0].PriceBook2Id and Product2.IsActive= true and Product2.AX_Item_Number__c != null ];
        totalpages=  total_size - math.mod(total_size, list_size);
        
        priceBookEntList = new List<PricebookEntry>();
        pberecordlist = new list<Pricebookentrywrapper>();
        selectedOrderProducts = new List<Pricebookentrywrapper>();
        
        getPriceBookEntryList();
    }
    
    //Method to fetch the currently active Promotion and Offer Product Details based on currency code and Promotion Start and End Datetime
    public void getOfferProducts(){
        Datetime dt = Datetime.now();
        String currentdt = dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        
        String sql = 'SELECT Id,Promotion__r.Name, Promotion__r.Promotion_Name__c,CurrencyIsoCode,Promotional_Pricing__c,isActive__c,Product__c,Promotion__r.isActive__c,Promotion__r.Start_Date_Time__c,Promotion__r.End_Date_Time__c FROM Offer_Product__c where isActive__c=true and Promotion__r.Start_Date_Time__c <= '+currentdt+' and Promotion__r.End_Date_Time__c >='+currentdt+ ' and Promotion__r.isActive__c=true and CurrencyIsoCode= \''  + currencycode + '\'';
        
        Offer_Product__c[] ofp =Database.query(sql);
        
        for(Offer_Product__c offProduct : ofp){
            if(offerProductMap.containsKey(offProduct.Product__c)){
                offerProductMap.get(offProduct.Product__c).add(offProduct);//offerProductMap.get(offProduct.Product__c).add(offProduct); 
            }
            else{
                offerProductMap.put(offProduct.Product__c, new List<Offer_Product__c> { offProduct});
            }
        }
    }  
    
    //Method to set the value of the boolean variable responsible for displaying the promotional price based on Order Type and Order Customer Type
    public void calcPPriceforB2COrder(){
        if(ordValues[0].OrderCustomerType__c == 'B2C' && ordValues[0].Type == 'Sale'){
            showPromotionalPriceforB2COrder = true;   
        }else
        { 
            showPromotionalPriceforB2COrder = false;
        }
    }
    
    
    //Method to fetch the Pricebook Entry records by querying Products and Pricebook
    public void getPriceBookEntryList(){
        getOfferProducts();
        
        List<PricebookEntry> priceBookEntList = [SELECT Id, Pricebook2Id, Product2Id,Product2.AX_Item_Number__c ,
                                                 Product2.Description,Product2.Name,Product2.MAP__c,
                                                 Product2.Quantity_Available__c, Product2.Serviceable__c , 
                                                 Product2.Service_Charge__c,Product2.Substitution_Number__c,
                                                 Product2.Spare_Parts_Use_Internal__c,Product2.Spare_Parts_Use_External__c,
                                                 Product2.Available_Date__c,Product2.AlternativeProduct__c,Product2.Available_To_Sell__c,
                                                 Product2.AX_Reserved_Inventory__c,
                                                 UnitPrice
                                                 FROM PricebookEntry 
                                                 where Pricebook2Id =:ordValues[0].PriceBook2Id 
                                                 and Product2.IsActive= true 
                                                 and Product2.AX_Item_Number__c != null 
                                                 order by Product2.Name Limit :list_size offset:counter ];
        
        pberecordlist = new list<Pricebookentrywrapper>();
        calcPPriceforB2COrder();
        
        if(priceBookEntList.size()!=0){
            for(PricebookEntry p:priceBookEntList){
                pberecordlist.add(new Pricebookentrywrapper(p, ordValues[0]));
            }
        }
        
    }
    
    //to display the filters option on page
    public List<SelectOption> getFilterItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('AX_Item_Number__c','AX Item Number'));
        options.add(new SelectOption('Name','SKU'));
        options.add(new SelectOption('Product_Type__c','Product Type'));
        options.add(new SelectOption('BusinessUnit__c','Business Unit'));
        return options;
    }
    
    //Method to show the list of selected Products and its promotional price if promotion is applied
    public void ordersSelected() {
        calcPPriceforB2COrder();
        
        Integer i=0;
        for(Pricebookentrywrapper PricebookentrywrapperObj : pberecordlist) {
            if(PricebookentrywrapperObj.selected == true) {
                selectedOrderProducts.add(PricebookentrywrapperObj);
                
                if(selectedOrderProducts[i].isPromotionApplied == true){
                    selectedOrderProducts[i].promotionAppliedMessage = ' ' + Label.PromotionalPrice_isApplied;
                }
                i++;
            }
        } 
    }
    
    //Method to save the OrderProduct to Order after successful validation and redirect the user to Order Page
    //Also this method checks whether the product being added to Order already exists or not.
    public boolean addOrderProductToOrderAndCheckDuplicates()
    {
        List<OrderItem> orderItmList = new list<OrderItem>();
        
        List<String> existingorderItmList = new list<String>();
 		List<OrderItem> orderItemsList=[Select Product2Id from OrderItem where OrderId = : orderId];
        for(OrderItem orderItmObj:orderItemsList)
        {
            existingorderItmList.add(orderItmObj.Product2Id);
        }
      
        List<Pricebookentrywrapper> selectedOrderProductTemp = new List<Pricebookentrywrapper>();
        selectedOrderProductTemp.addall(selectedOrderProducts);
        boolean showError=false;
        boolean showDuplicate=false;
        integer i=0;
     
        for(Pricebookentrywrapper item :  selectedOrderProductTemp)
        { 
           
            if(item.quantity == null || item.quantity <= 0 )
            {
                selectedOrderProducts[i].qtyErrorMessage= ' ' + Label.Please_enter_valid_Quantity;
                selectedOrderProducts[i].quantity=null;
                showError=true;
             
            }
            else{
                selectedOrderProducts[i].qtyErrorMessage='';
                System.debug('existingorderItmList===>'+existingorderItmList + ' is duplicate entry>' + existingorderItmList.contains(item.pberecord.Product2Id));
                if(existingorderItmList.contains(item.pberecord.Product2Id))
                {
                    showDuplicate=true;
                }
                else{
                    OrderItem orderItm = new OrderItem();
                    orderItm.orderId=orderId;
                    orderItm.PricebookEntryId=item.pberecord.Id;
                    orderItm.Product2Id=item.pberecord.Product2Id;
                    orderItm.UnitPrice = item.unitPrice;  
                    orderItm.Quantity =item.quantity; 
                    orderItm.Available_To_Sell__c = item.isAvailableToSell;
                    orderItmList.add(orderItm);
                }
            }
            i++;
        }  
        if(showError){
          return false;
        }
        
        else if(showDuplicate){
           
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Duplicate_Order_Product));
            return false;
        }
        else if(!orderItmList.isEmpty()){
            insert orderItmList;
        }
        
        return true;
    }

    public PageReference save()
    {
       Boolean status = addOrderProductToOrderAndCheckDuplicates();
   
        if(status ==  true){
        PageReference redirect = null;
        String url = System.Url.getSalesforceBaseURL().toExternalForm() +
        Site.getPathPrefix() +'/' + orderId;
        redirect = new PageReference(url);
        redirect.setRedirect(true);
        return redirect;
        }
        
        return null;
    }
    
    public PageReference saveMore()
    {
        Boolean status = addOrderProductToOrderAndCheckDuplicates();
    
        if(status ==  true){
        PageReference redirect = null;                                                 
        String url = System.Url.getSalesforceBaseURL().toExternalForm() +
        Site.getPathPrefix() +'/apex/AddOrderProduct?id=' + orderId;
        redirect = new PageReference(url);
        redirect.setRedirect(true);
        return redirect;
        }
    
        return null;
    }
    
    public void resetTheCounterOnNewSearch(){
        counter = 0;
        search();
    }
    
    //Method to query the Pricebook entry records based on the search parameter passed from VF Page.
    public void search(){
        callSearchMethod = true;
        calcPPriceforB2COrder();
        String searchByValue= '%'+searchText+'%';
        
        String query = 'SELECT Id, Pricebook2Id, Product2Id,Product2.AX_Item_Number__c ,Product2.Description,Product2.Name,Product2.MAP__c,Product2.Quantity_Available__c,' +
            ' Product2.Serviceable__c , Product2.Service_Charge__c,Product2.Substitution_Number__c,Product2.Spare_Parts_Use_Internal__c,Product2.Spare_Parts_Use_External__c,Product2.Available_Date__c,Product2.AlternativeProduct__c,Product2.AX_Reserved_Inventory__c,' +
            ' Product2.Available_To_Sell__c,Product2.Product_Type__c, UnitPrice '+
            ' FROM PricebookEntry where Pricebook2Id = ' + '\'' +  ordValues[0].PriceBook2Id + '\' and Product2.IsActive= true AND Product2.AX_Item_Number__c != null AND Product2.' +
            filters + ' like ' + '\'' + searchByValue + '\' order by Product2.Name Limit ' + list_size + ' offset ' + counter ;
        
        
        priceBookEntList = Database.query(query); 
        getOfferProducts();
        
        pberecordlist = new list<Pricebookentrywrapper>();
        if(priceBookEntList.size()!=0){
            for(PricebookEntry p:priceBookEntList){
                pberecordlist.add(new Pricebookentrywrapper(p, ordValues[0]));
            }
        }
        
        String fetchAllRecordQuery = 'SELECT Count() FROM PricebookEntry where Pricebook2Id = ' + '\'' +  ordValues[0].PriceBook2Id + '\' and Product2.IsActive= true AND Product2.AX_Item_Number__c != null AND Product2.' +
            filters + ' like ' + '\'' + searchByValue + '\'';
        total_size =  Database.countQuery(fetchAllRecordQuery);
        
        getTotalPages();
        getPageNumber();
        
    }
    
    //Wrapper class created to show Promotional Price value with Pricebook entry records
    //Also determines which price(Retail/Promotional Price) will be applicable while creation of the Order.
    public class Pricebookentrywrapper{
        public PricebookEntry pberecord  { get; set;}
        public Decimal promotionalPrice { get; set;}
        public String promotionalPricewithCurrency { get; set;}
        public Boolean selected {get; set;}
        public Integer quantity {get; set;}
        public Decimal unitPrice { get; set;}
        public String qtyErrorMessage { get; set;}
        public String promotionAppliedMessage { get; set;}
        public Boolean isPromotionApplied {get; set;}
        public Boolean isAvailableToSell { get; set; }
        
        public Pricebookentrywrapper(PricebookEntry pberecord){
            this(pberecord, null);
        }
        
        public Pricebookentrywrapper(PricebookEntry pberecord, Order orderObj){
            this.pberecord = pberecord;
            selected = false;
            this.qtyErrorMessage='';
            this.promotionAppliedMessage ='';
            this.unitPrice = pberecord.UnitPrice;      
            this.isAvailableToSell = pberecord.Product2.Available_To_Sell__c;
            
            if(showPromotionalPriceforB2COrder){
                if(pberecord.Product2Id!=null){
                    if(offerProductMap != null && offerProductMap.containsKey(pberecord.Product2Id)){
                        Offer_Product__c[] ofp = offerProductMap.get(pberecord.Product2Id);
                        
                        if (ofp.size() > 0){
                            promotionalPricewithCurrency= ofp[0].CurrencyIsoCode + ' '+ String.valueOf(ofp[0].Promotional_Pricing__c); 
                            promotionalPrice = ofp[0].Promotional_Pricing__c;
                        }
                        else{
                            promotionalPrice= null;
                        }
                        
                    } 
                }
                if (promotionalPrice != null && pberecord.Product2.Quantity_Available__c >0){
                    unitPrice =promotionalPrice; 
                    isPromotionApplied =true;
                }
            }
            if (orderObj != null) {
                isAvailableToSell = Utility.isAvailableToSell(orderObj, pberecord.Product2);
            }
        }
    }
    
    //Method to fetch the total no of pages based on list size to display per page
    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) >= 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }
    
    //Method to show the current page number on page
    public Integer getPageNumber() {
        return counter/list_size + 1;
    }
    
    //Method to navigate to next page
    Public PageReference Next() {
        counter += list_size;
        if(callSearchMethod == true){
            search();
        }else
            getPriceBookEntryList();
        return null;
    }
    
    //Method to navigate to Previous Page
    Public PageReference Previous() {
        counter -= list_size;
        if(count==1){
            getPriceBookEntryList();
            count++;
        }
        else 
            getPriceBookEntryList();
        return null;
    }
    
    //Method to navigate to First Page
    Public PageReference Beginning() {
        counter=0;
        getPriceBookEntryList();
        return null;
    }
    
    //Method to navigate to the Last Page
    public PageReference End() {
        counter = total_size - math.mod(total_size, list_size);
        getPriceBookEntryList();
        return null;
    }
    
    //Method to disable the Previous and First button when the user is already on the first page
    public Boolean getDisabledPrevious() {         
        if(counter>0)
            return false;
        else 
            return true;
        
    }
    
    //Method to disable the Next and Last button when the user is already on the last page
    public Boolean getDisabledNext() {            
        if (counter + list_size < total_size)            
            return false; 
        else 
            return true;
    }
}