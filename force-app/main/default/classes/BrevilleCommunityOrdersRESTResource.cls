@RestResource(urlMapping='/CommunityOrders/*')
global with sharing class BrevilleCommunityOrdersRESTResource {
    @HttpGet
    global static List<OrderResponse> doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Customer_Community_Settings__mdt ObjSettings = [select value__c,Developername from Customer_Community_Settings__mdt where Developername='BeanzBaseImagePath'];
        string strBeanzImageBasePath = ObjSettings.value__c;
        Set<String> setOfSources = new Set<String>{
            'Breville','AEM','GWP'
        };  
        String brand;  
        if(!Test.IsRunningTest())
        {
            brand = RestContext.request.params.get('brand');   
            system.debug('brand:'+brand);
        }
        String beanz = 'Beanz';   
        //String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String query = 'SELECT Id,Has_Subscriptions__c,Narvar_Tracking_Link__c,Carrier_Link__c,source__c,websiteorderid__c,OrderNumber,Status,Createddate,Payment_Method__c,Order_Grand_Total__c,Tax__c,Currency_Formula__c,'
                        +'Shipping_Amount__c,Order_Shipped_Date__c,ShippingStreet,ShippingCity,ShippingState,toLabel(ShippingStateCode),ShippingCountry,toLabel(ShippingCountryCode),ShippingPostalCode,' +
                        +'BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,toLabel(BillingCountryCode),toLabel(BillingStateCode),'+
                        +'BillToContact.Name,Ship_To_Name__c ,Cancel_date__c,Promo_Code__c,ExactOfferCode__c,AppliedOfferCode__c,Brand__c,' +
                        +'(select id,Ax_item_number__c,Quantity,TotalPrice,UnitPrice,Product_Description__c,EP_Standing_Order_Id__c,EP_Line_Tax__c,Line_Item_Tax__c,Roaster__c,Grind_Type__c,LineStatus__c,Item_Discount__c,Line_Item_Discount__c,EP_Standing_Order_Iteration__c,Narvar_Tracking_Link__c,Shipment_Tracking_Link__c,Is_Mystery_Item__c,Product_Shipped_for_Mystery_SKU__c,Bag_size__c,EP_Standing_Order_Frequency__c,Vendor_Number__c,Product2.Coffee_Type__c from OrderItems order by createddate) ' +
                        +'FROM Order where createddate=LAST_N_DAYS:730 and xTotalProducts__c>0 and source__c in :setOfSources ';
       if(brand != null && String.isNotBlank(brand)){
            query = query + ' AND Brand__c =:brand order by CreatedDate DESC';
        }else{
            query = query +'  AND Brand__c !=:beanz order by CreatedDate DESC';
        }
        
        List<Order> lstOrders = Database.query(query);
        List<OrderResponse> result = new List<OrderResponse>();
        for(Order objOrder:lstOrders)
        {
            OrderResponse Obj = new OrderResponse();
            Obj.HasSubscriptions = objOrder.Has_Subscriptions__c;
            Obj.OrderNumber = objorder.source__c=='AEM'? objOrder.websiteorderid__c:objOrder.OrderNumber;
            Switch on objOrder.Status
            {
                When 'Auth Cancelled'
                {
                    Obj.OrderStatus = 'Cancelled';
                }
                When 'Order Shipped', 'Invoiced'
                {
                    Obj.OrderStatus = 'Shipped';
                }
                When 'Partial Shipped'
                {
                    Obj.OrderStatus = 'Partially Shipped';
                }
                When else
                {
                    Obj.OrderStatus = 'Processing';
                }
            }
            //Obj.OrderStatus = objOrder.Status=='Open'?'PROCESSING':objOrder.Status;
            Obj.OrderCreatedDate = objOrder.Createddate;
            Obj.PaymentMethod = objOrder.Payment_Method__c;
            Obj.Tax = objOrder.Tax__c;
            Obj.OrderGrandTotal = objOrder.Order_Grand_Total__c;
            Obj.ShippingAmount = objOrder.Shipping_Amount__c;
            Obj.CurrencyCode = objOrder.Currency_Formula__c;
            if(objOrder.Order_Shipped_Date__c!=null)
            {
                Obj.ShippedDate = objOrder.Order_Shipped_Date__c;
            }
            Obj.ShippingAmount = objOrder.Shipping_Amount__c;
            if(objOrder.Cancel_date__c!=null)
            {
                Obj.CancelDate = objOrder.Cancel_date__c;
            }
            
            //Shipping address
            Obj.ShippingContactName = objOrder.Ship_To_Name__c;
            Obj.ShippingStreet = objOrder.ShippingStreet;
            Obj.ShippingCity = objOrder.ShippingCity;
            Obj.ShippingStateCode = objOrder.ShippingState;
            Obj.ShippingCountryCode = objOrder.ShippingCountry;
            Obj.ShippingPostalCode = objOrder.ShippingPostalCode;
            Obj.ShippingCountry = objOrder.ShippingCountryCode;
            Obj.ShippingState = objOrder.ShippingStateCode;
            
            //Billing address
            Obj.BillingContactName = objOrder.BillToContact.Name;
            Obj.BillingStreet = objOrder.BillingStreet;
            Obj.BillingCity = objOrder.BillingCity;
            Obj.BillingStateCode = objOrder.BillingState;
            Obj.BillingCountryCode = objOrder.BillingCountryCode;
            Obj.BillingPostalCode = objOrder.BillingPostalCode;
            Obj.BillingCountry = objOrder.BillingCountryCode;
            Obj.BillingState = objOrder.BillingStateCode;
            
            //Tracking link - Obj.TrackingLink
            if(objOrder.source__c=='AEM' && objOrder.ShippingCountry == 'US')
            {
                if(string.isNotBlank(objOrder.Narvar_Tracking_Link__c))
                {
                    Obj.TrackingLink = objOrder.Narvar_Tracking_Link__c;
                }
            }
            else
            {
                 if(string.isNotBlank(objOrder.Carrier_Link__c))
                {
                    Obj.TrackingLink = objOrder.Carrier_Link__c;
                }
            }
            
            if(objOrder.OrderItems.size()>0)
            {
                List<OrderProduct> lstItems = new List<OrderProduct>();       
                Integer itemSequence = 1;
                for(OrderItem ObjItem:objOrder.OrderItems)
                {
                    OrderProduct ObjOrderProduct = new OrderProduct();
                    ObjOrderProduct.ProductNumber = ObjItem.Ax_item_number__c;
                    ObjOrderProduct.Quantity = ObjItem.Quantity != null ? Integer.valueOf(ObjItem.Quantity): 0;
                    ObjOrderProduct.TotalPrice = ObjItem.TotalPrice;
                    ObjOrderProduct.UnitPrice = ObjItem.UnitPrice;
                    ObjOrderProduct.ItemDescription = ObjItem.Product_Description__c;
                    ObjOrderProduct.EPStandingOrderId = ObjItem.EP_Standing_Order_Id__c;
                    //Changes for marketplace
                    if(objorder.source__c=='AEM' && ObjItem.EP_Line_Tax__c!=null)
                    {
                        ObjOrderProduct.ItemTax =ObjItem.EP_Line_Tax__c;
                    }
                    else if(ObjItem.Line_Item_Tax__c!=null)
                    {
                        ObjOrderProduct.ItemTax =ObjItem.Line_Item_Tax__c;
                    }       
                    ObjOrderProduct.Promocode = objorder.AppliedOfferCode__c;
                    ObjOrderProduct.VendorName = ObjItem.Roaster__c;
                    ObjOrderProduct.GrindType = ObjItem.Grind_Type__c;
                    ObjOrderProduct.IsSubscriptionItem = String.isNotBlank(ObjItem.EP_Standing_Order_Id__c)?true:false;                    
                    ObjOrderProduct.ItemStatus = (!string.isBlank(ObjItem.LineStatus__c) && (ObjItem.LineStatus__c=='Shipped' || ObjItem.LineStatus__c=='Invoiced'))?'Shipped':'Processing';
                    if(ObjItem.Item_Discount__c!=null)
                    	ObjOrderProduct.DiscountPercentage = ObjItem.Item_Discount__c;
                    if(ObjItem.Line_Item_Discount__c!=null)
                    	ObjOrderProduct.Discount = ObjItem.Line_Item_Discount__c;
                    ObjOrderProduct.ItemSequence = itemSequence;
                    //To be changed to valid link
                    //ObjOrderProduct.ItemTrackingLink = 'https://www.breville.com';
                    if(objOrder.source__c=='AEM' && objOrder.ShippingCountryCode =='US' && objOrder.Brand__c!='Beanz')
                    {
                        if(string.isNotBlank(ObjItem.Narvar_Tracking_Link__c))
                        {
                            ObjOrderProduct.ItemTrackingLink = ObjItem.Narvar_Tracking_Link__c;
                        }
                    }
                    else
                    {
                         if(string.isNotBlank(ObjItem.Shipment_Tracking_Link__c))
                        {
                            ObjOrderProduct.ItemTrackingLink = ObjItem.Shipment_Tracking_Link__c;
                        }
                    }
                    
                    if(string.isNotBlank(objOrder.Brand__c) && objOrder.Brand__c.equalsIgnoreCase('Beanz'))
                    {
                        ObjOrderProduct.IsMysteryItem = ObjItem.Is_Mystery_Item__c;                        
                        ObjOrderProduct.SubscriptionFrequency = ObjItem.EP_Standing_Order_Frequency__c;
                        ObjOrderProduct.Weight = ObjItem.Bag_size__c;
                        ObjOrderProduct.DisplayAsMysteryItem = false;
                        if(!ObjItem.Is_Mystery_Item__c)
                            ObjOrderProduct.ProductImageUrl = GenerateImageUrlForBeanz(ObjItem.Vendor_Number__c,ObjItem.Ax_item_number__c,strBeanzImageBasePath);
                        if(ObjItem.Is_Mystery_Item__c)
                            ObjOrderProduct.DisplayAsMysteryItem = true;
                        ObjOrderProduct.CoffeeType = ObjItem.Product2.Coffee_Type__c;
                    }
                    lstItems.Add(ObjOrderProduct);
                    itemSequence++;
                }
                Obj.Items = lstItems;
            }
            result.Add(Obj);
        }
        return result;
    }
    
    global static string GenerateImageUrlForBeanz(string Roaster,string SKUCode,string BaseUrl)
    {
        String ImageUrl;
        //String BaseUrl = 'https://uat.beanz.com/content/dam/marketplace/us/assets/';
        ImageUrl = BaseUrl + Roaster.toUpperCase() + '/' + SKUCode.toLowerCase() + '/pdp.jpg';
        return ImageUrl;
    }
    
    
    global class OrderResponse
    {
        global string OrderNumber{get;set;}
        global string OrderStatus{get;set;}
        global Datetime OrderCreatedDate{get;set;}//Createddate
        global string PaymentMethod {get;set;}//Payment_Method__c
        global Decimal Tax {get;set;}//Order_Grand_Total__c
        global Decimal OrderGrandTotal {get;set;}//Tax__c
        global Decimal ShippingAmount {get;set;}//Shipping_Amount__c
        global Datetime ShippedDate {get;set;}//Order_Shipped_Date__c
        global string ShippingContactName {get;set;}     
        global string ShippingStreet {get;set;}        
        global string ShippingCity {get;set;}
        global string ShippingStateCode {get;set;}
        global string ShippingCountry {get;set;}
        global string ShippingCountryCode {get;set;}
        global string ShippingState {get;set;}
        global string ShippingPostalCode {get;set;}
        global string BillingStreet {get;set;}        
        global string BillingCity {get;set;}
        global string BillingState {get;set;}
        global string BillingStateCode {get;set;}
        global string BillingCountry {get;set;}
        global string BillingCountryCode {get;set;}
        global string BillingPostalCode {get;set;}
        global string BillingContactName {get;set;}
        global Datetime CancelDate {get;set;}
        global string CurrencyCode {get;set;}
        global string TrackingLink {get;set;}
        global Boolean HasSubscriptions {get;set;}      
        global List<OrderProduct> Items {get;set;}
    }
    
    global class OrderProduct
    {
        global string ProductNumber {get;set;}
        global Integer Quantity {get;set;}
        global Decimal TotalPrice {get;set;}
        global Decimal UnitPrice {get;set;}
        global string ItemDescription {get;set;}
        global string EPStandingOrderId {get;set;}
        //New fields added for marketplace
        global Decimal ItemTax {get;set;}
        global string VendorName {get;set;}
        global string GrindType{get;set;}
        global boolean IsSubscriptionItem {get;set;}
        global string ItemStatus {get;set;}
        global string Promocode {get;set;}
        global Decimal DiscountPercentage {get;set;}
        global Decimal Discount{get;set;}
        global Integer ItemSequence {get;set;}
        global String ItemTrackingLink {get;set;}
        global Boolean IsMysteryItem {get;set;}
        global Boolean DisplayAsMysteryItem {get;set;}        
        global string SubscriptionFrequency {get;set;}
        global string Weight {get;set;}    
        global string ProductImageUrl {get;set;}
        global string CoffeeType {get;set;}
    }
    
    
}