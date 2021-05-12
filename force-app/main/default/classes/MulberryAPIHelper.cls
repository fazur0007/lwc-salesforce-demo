public class MulberryAPIHelper {
    public static void CreateWarranty(Id OrderId)
    {
        try 
        {
            MulberryWarrantyRequestClass objMulberryWarrantyRequestClass = PrepareCreateWarrantyAPIRequest(OrderId);
            String regionCode = objMulberryWarrantyRequestClass.billing_address.country_code;
            String integrationName = 'callout:Mulberry_Warranty_' + regionCode + '/checkout';
            system.debug('API request:'+objMulberryWarrantyRequestClass);
            HttpRequest mulberryHTTPRequest = new HttpRequest();
            Http APIHttp = new Http();
            mulberryHTTPRequest.setEndpoint(integrationName);
            mulberryHTTPRequest.setMethod('POST');
            mulberryHTTPRequest.setHeader('Authorization', 'Bearer {!$Credential.Password}');
            mulberryHTTPRequest.setHeader('Content-Type', 'application/json');
            mulberryHTTPRequest.setBody(JSON.serialize(objMulberryWarrantyRequestClass));
            
            system.debug('API request:'+mulberryHTTPRequest.getBody());
            System.debug ('Cred: ' + mulberryHTTPRequest.getHeader('Authorization'));
            
            System.debug ('http: ' + mulberryHTTPRequest);
            HttpResponse MulberryAPIResponse;       
//            MulberryAPIResponse = APIHttp.send(mulberryHTTPRequest);
            system.debug('API response:'+MulberryAPIResponse.getBody());
            
            ProcessWarrantyRegistrationResponse(OrderId,MulberryAPIResponse.getBody());
        } 
        catch (Exception ex)    
        {
            Error_Log__c error = ErrorLog.logErrorActivity(ex.getStackTraceString(),ex.getMessage(),'MulberryAPIHelper.CreateWarranty',false,'Mulberry Warranty Registration',OrderId);
            system.debug('error:'+error);
            insert error;
        }
    }
    
    public static void ProcessWarrantyRegistrationResponse(string OrderId,string strAPIResonse)
    {
        Map<string,Object> result = (Map<string,Object>)Json.deserializeUntyped(strAPIResonse);
        if((Boolean)result.get('success'))
        {
            string strMulberryOrderId = (String)result.get('order_id');
            Order objOrder = new Order();
            objOrder.Id = OrderId;
            objOrder.warr_Order_ID__c = strMulberryOrderId;
            update ObjOrder;
            system.debug('ObjOrder');
        }
        
        //string response = '{\"success\":true,\"order_id\":\"207e78b616344001ba87e4122bbae490\",\"data\":{\"order_status_value\":\"Active\",\"external_order_id\":\"14553536302\",\"customer\":{\"phone\":\"12345678901\",\"billing_city\":\"Brooklyn\",\"email\":\"Yogiraj.Mahajan@breville.com.au\",\"billing_zip\":\"11231\",\"has_reviewed\":false,\"billing_state\":\"NY\",\"last_name\":\"Clark\",\"billing_address_2\":\"\",\"first_name\":\"Josephine\",\"billing_country\":\"United States\",\"show_review_prompt\":false,\"billing_address_1\":\"123 Mint St. Apt 3F\"},\"created_date\":\"2020-04-24 08:39:04.052375+00:00\",\"warranties\":[{\"id\":\"89696220fafc47069078dd338101a901\",\"created_date\":\"2020-04-24 08:39:04.020606+00:00\",\"line_items\":[{\"id\":\"cf50a43ecc1a4512891bdfea6682387e\",\"product\":{\"name\":\"the oracle touch\",\"price\":\"2999.95\",\"external_product_id\":\"123456787913\",\"product_meta\":[{\"field_name\":\"SKU\",\"field_value\":\"BES990BSS1BUS1\"}]}}],\"service_type\":\"None\",\"customer_cost\":\"145.50\",\"duration_months\":\"24\",\"warranty_hash\":\"881827f31c1ebec21006bc0fc570e062ad824efb1d25d7c83fd403e4ab9655bb\"}],\"id\":\"207e78b616344001ba87e4122bbae490\"}}';
        //Map<string,Object> result = (Map<string,Object>) JSON.deserializeUntyped(response);
        Map<string,string> mapOPIdWithMulLineId = new Map<string,string>();
        system.debug('Mulberry order ID:' + (string)result.get('order_id'));
        Map<string,Object> data = (Map<string,Object>)result.get('data');
        system.debug('data:' + data.get('order_status_value'));
        List<Object> lstWarranties = (List<Object>)data.get('warranties');
        system.debug(lstWarranties.size());
        for(Object objWarranty:lstWarranties)
        {
            Map<string,Object> mapCurrentWarranty = (Map<string,Object>)objWarranty;
            system.debug(mapCurrentWarranty.get('id'));
            List<Object> lstLineItems = (List<Object>)mapCurrentWarranty.get('line_items');
            for(Object objLineItem:lstLineItems)
            {
                string strMulberryLineId='';
                Map<string,Object> mapLineitem = (Map<string,Object>) objLineItem;
                system.debug('Line item Id:' + mapLineitem.get('id'));
                Map<string,Object> mapProduct = (Map<string,Object>) mapLineitem.get('product');
                system.debug('External Id:' + mapProduct.get('external_product_id'));
                string strOrderPOId = (string)mapProduct.get('external_product_id');
                if(mapOPIdWithMulLineId.containsKey(strOrderPOId))
                {
                    strMulberryLineId = mapOPIdWithMulLineId.get(strOrderPOId) + ',';
                }
                strMulberryLineId = strMulberryLineId + (string)mapLineitem.get('id');
                mapOPIdWithMulLineId.put(strOrderPOId,strMulberryLineId);
            }
        }
        system.debug('mapOPIdWithMulLineId:'+mapOPIdWithMulLineId);
        if(mapOPIdWithMulLineId.keySet().size()>0)
        {
            List<Asset> lstAsset = new List<Asset>();
            for(string objKey:mapOPIdWithMulLineId.keySet())
            {
                Asset ObjAsset = new Asset();
                ObjAsset.Id = objKey;
                ObjAsset.Mulberry_Warranty_Line_Id__c = mapOPIdWithMulLineId.get(objKey);
                lstAsset.Add(ObjAsset);
            }
            system.debug('lstAsset:'+lstAsset);
            update lstAsset;
        }
    }
    
    public static void CancelWarranty(Id CaseId)
    {
        Case recCase = [select id,Order__c,Order__r.warr_Order_ID__c,Order__r.BillingCountryCode from case where id=:CaseId];
        MulberryCancellationRequestClass ObjMulberryCancellationRequestClass = PrepareCancellationRequest(recCase);
        String regionCode = recCase.Order__r.BillingCountryCode;
        String integrationName = 'callout:Mulberry_Warranty_' + regionCode + '/order_cancelled';
        system.debug('API request:'+ObjMulberryCancellationRequestClass);
        HttpRequest mulberryHTTPRequest = new HttpRequest();
        Http APIHttp = new Http();
        mulberryHTTPRequest.setEndpoint(integrationName);
        mulberryHTTPRequest.setMethod('POST');
        mulberryHTTPRequest.setHeader('Authorization', 'Bearer {!$Credential.Password}');
        mulberryHTTPRequest.setHeader('Content-Type', 'application/json');
        mulberryHTTPRequest.setBody(JSON.serialize(ObjMulberryCancellationRequestClass));
        system.debug('request:'+JSON.serialize(ObjMulberryCancellationRequestClass));
        HttpResponse MulberryAPIResponse;
        if(!Test.isrunningtest())
        {
            MulberryAPIResponse = APIHttp.send(mulberryHTTPRequest);
            system.debug('API response:'+MulberryAPIResponse.getBody());
        }
        
    }
    
    public static MulberryCancellationRequestClass PrepareCancellationRequest(Case recCase)
    {
        MulberryCancellationRequestClass ObjMulberryCancellationRequestClass = new MulberryCancellationRequestClass();
        List<MulberryCancellationRequestClass.Line_items> lstItems = new List<MulberryCancellationRequestClass.Line_items>();
//        Case CurrentCase = [select id,Order__c,Order__r.warr_Order_ID__c,Order__r.BillingCountryCode from case where id=:CaseId];
        List<Asset> lstAsset = [select Id,Mulberry_Warranty_Line_Id__c from Asset where ParentOrder__c=:recCase.Order__c and Trigger_Mulberry_Cancellation__c=true];
        //Map Mulberry order fields
        ObjMulberryCancellationRequestClass.cancelled_date = Datetime.now().format('yyyy-MM-dd');
        ObjMulberryCancellationRequestClass.order_id = recCase.Order__r.warr_Order_ID__c;
        
        //Map line items to cancel
        for(Asset ObjAsset:lstAsset)
        {
            MulberryCancellationRequestClass.Line_items ObjLineitem = new MulberryCancellationRequestClass.Line_items();
            ObjLineitem.product_id = ObjAsset.Id;
            lstItems.add(ObjLineitem);
        }
        ObjMulberryCancellationRequestClass.line_items = lstItems;
        return ObjMulberryCancellationRequestClass;
    }
    
    public static MulberryWarrantyRequestClass PrepareCreateWarrantyAPIRequest(Id OrderId)
    {
        MulberryWarrantyRequestClass objMulberryWarrantyRequestClass = new MulberryWarrantyRequestClass();
        List<MulberryWarrantyRequestClass.Line_items> lstLineItems = new List<MulberryWarrantyRequestClass.Line_items>(); 
        Map<Id,Id> mapWarrantyOPWithProductOP = new Map<Id,Id>();
        Order objOrder = [select id,Createddate,Pricebook2Id,ordernumber,Asset__c,Asset__r.Product2.AX_Item_Number__c,Asset__r.Product2.WebPrice__c,Asset__r.Product2.Description,Asset__r.PurchaseDate,Asset__r.Batch_Code__c
                          ,(select id,Quantity,ListPrice,Product2.Ax_item_number__c,Product2.Warranty_In_Months__c,UnitPrice,Product2.Product_Type__c,Product_Description__c from OrderItems)
                          ,(select id,Parent_order_product__c,Warranty_order_product__c from Product_Extended_warranties__r)
                          ,(select id,PurchaseDate,Product_Extended_warranty__c,Product_Extended_warranty__r.Warranty_order_product__c,Product_Extended_warranty__r.Parent_order_product__c,Product_Extended_warranty__r.Parent_order_product__r.UnitPrice, Product_Extended_warranty__r.Parent_order_product__r.Product_Description__c, Product_Extended_warranty__r.Parent_order_product__r.Product2.AX_Item_Number__c,Batch_Code__c from Assets__r where Product_Extended_warranty__c!='')
                          ,Account.firstname,Account.Lastname,billingstreet
                          ,billingcity,billingstate,billingcountry,account.Email_External_ID__c,Account.PersonEmail
                          ,billingpostalcode,billingcountrycode,account.phone from Order where id=:OrderId];
        
        //Map Header values
        objMulberryWarrantyRequestClass.id = Integer.valueOf(objOrder.Ordernumber);
        objMulberryWarrantyRequestClass.email=objOrder.Account.PersonEmail;
        objMulberryWarrantyRequestClass.phone=objOrder.Account.Phone;
        //objMulberryWarrantyRequestClass.cart_token='';
        Map<Id,List<Asset>> mapAssetWithOrderProduct = new Map<Id,List<Asset>>();
        Map<Id,List<Asset>> mapAssetWithWarrantyOrderProduct = new Map<Id,List<Asset>>();
        system.debug('objOrder.Assets__r:'+objOrder.Assets__r);
        for(Asset ObjAsset:objOrder.Assets__r)
        {            
            List<Asset> lstAsset;
            if(mapAssetWithWarrantyOrderProduct.containsKey(ObjAsset.Product_Extended_warranty__r.Warranty_order_product__c))
            {
                lstAsset = mapAssetWithWarrantyOrderProduct.get(ObjAsset.Product_Extended_warranty__r.Warranty_order_product__c);
            }
            else 
            {
                lstAsset = new List<Asset>();
            }
            lstAsset.Add(ObjAsset);
            mapAssetWithWarrantyOrderProduct.put(ObjAsset.Product_Extended_warranty__r.Warranty_order_product__c,lstAsset);
            system.debug('lstAsset:'+lstAsset);
            
        }
        system.debug('mapAssetWithOrderProduct:'+mapAssetWithOrderProduct);
        system.debug('mapAssetWithWarrantyOrderProduct:'+mapAssetWithWarrantyOrderProduct);
        Decimal FGPrice = 0;
        Boolean isPostSales = false;
        if(objOrder.Asset__c!=null)
        {
            isPostSales = true;
            List<PricebookEntry> lstPBE = [select id,Product2.AX_Item_Number__c,UnitPrice from PricebookEntry where Pricebook2Id=:objOrder.Pricebook2Id and Product2.AX_Item_Number__c=:objOrder.Asset__r.Product2.AX_Item_Number__c];
            if(lstPBE.size()>0)
            {
                FGPrice = lstPBE[0].UnitPrice;
            }
            else
            {
                List<Product2> lstFGProduct = [select id,MAP__c from Product2 where AX_Item_Number__c=:objOrder.Asset__r.Product2.AX_Item_Number__c];
                FGPrice = lstFGProduct[0].MAP__c;
            }
        }
        
        //Populate line items in the request - start
        List<OrderItem> lstWarrantyProducts = new List<OrderItem>();
        Map<Id,OrderItem> mapAllFGProducts = new Map<Id,OrderItem>();
        //List warranty items for which warranty registration has to be done
        Map<Id,List<OrderItem>> mapWarrantyIdWithFGProduct = new  Map<Id,List<OrderItem>>();
        for(OrderItem ObjItem:objOrder.OrderItems)
        {
            if(ObjItem.Product2.Product_Type__c.EqualsIgnoreCase('EXTWTY'))
                lstWarrantyProducts.Add(ObjItem);
            else
                mapAllFGProducts.put(ObjItem.Id,ObjItem);
        }
        
        //Map Warranty OrderProducts with FG OrderProduct
        for(ProductExtended_warranty__c ObjProductExtendedWarranty:objOrder.Product_Extended_warranties__r)
        {
            mapWarrantyOPWithProductOP.put(ObjProductExtendedWarranty.Warranty_order_product__c,ObjProductExtendedWarranty.Parent_order_product__c);
        }
        system.debug('mapWarrantyOPWithProductOP:'+mapWarrantyOPWithProductOP);
        
        
        for(OrderItem ObjOrderItem:lstWarrantyProducts)
        {
            
            List<Asset> lstAssetForCurrentFG = new List<Asset>();
            lstAssetForCurrentFG = mapAssetWithWarrantyOrderProduct.get(ObjOrderItem.Id);
            if(mapAssetWithWarrantyOrderProduct.get(ObjOrderItem.Id)!=null)
            {
                System.debug('lstAssetForCurrentFG.count'+lstAssetForCurrentFG.size());
                System.debug('===lstAssetForCurrentFG==='+lstAssetForCurrentFG);
            }
            
            for(Integer iQuantity=0;iQuantity<ObjOrderItem.Quantity;iQuantity++)
            {
                Asset currAsset = new Asset();
                if(mapAssetWithWarrantyOrderProduct.get(ObjOrderItem.Id)!=null)
                {   
                    currAsset = lstAssetForCurrentFG.get(iQuantity);
                }
                System.debug('===currAsset==='+currAsset);
                MulberryWarrantyRequestClass.Line_items ObjLineItem = new MulberryWarrantyRequestClass.Line_items();
                ObjLineItem.product_id = objOrder.Asset__c!=null?objOrder.Asset__c:currAsset.Id;
                system.debug('ObjLineItem.product_id:'+ObjLineItem.product_id);
                ObjLineItem.product_price =  objOrder.Asset__c!=null?String.valueOf(FGPrice):String.valueOf(currAsset.Product_Extended_warranty__r.Parent_order_product__r.UnitPrice);
                ObjLineItem.product_title = objOrder.Asset__c!=null?objOrder.Asset__r.Product2.Description:currAsset.Product_Extended_warranty__r.Parent_order_product__r.Product_Description__c;
                
                //Populate warranty data
                MulberryWarrantyRequestClass.Warranty objWarranty = new MulberryWarrantyRequestClass.Warranty();
                objWarranty.warranty_duration = Integer.valueOf(ObjOrderItem.Product2.Warranty_In_Months__c);
                objWarranty.warranty_id = ObjOrderItem.Product2.Ax_item_number__c;
                objWarranty.warranty_price = String.valueOf(ObjOrderItem.ListPrice);
                System.debug ('Billing Country Code: ' + objOrder.BillingCountryCode); 
                String programId = getWarrantyProgramID(objOrder.BillingCountryCode, isPostSales, objWarranty.warranty_duration);
                
                objWarranty.warranty_program_id = programId;
                ObjLineItem.warranty = objWarranty;
                
                //product meta data
                MulberryWarrantyRequestClass.Product_meta objProductmeta = new MulberryWarrantyRequestClass.Product_meta();
                objProductmeta.field_name = 'SKU';
                objProductmeta.field_value = objOrder.Asset__c!=null?objOrder.Asset__r.Product2.AX_Item_Number__c:currAsset.Product_Extended_warranty__r.Parent_order_product__r.Product2.AX_Item_Number__c;
                
                List<MulberryWarrantyRequestClass.Product_meta> lstProductmeta = new List<MulberryWarrantyRequestClass.Product_meta>();
                lstProductmeta.Add(objProductmeta);
                
				//Added purchase date mapping				
                Date purchaseDate;
                purchaseDate = objOrder.Asset__c!=null?objOrder.Asset__r.PurchaseDate:currAsset.PurchaseDate;
                if(purchaseDate==null)
                {
                    string batchCode = objOrder.Asset__c!=null?objOrder.Asset__r.Batch_code__c:currAsset.Batch_code__c;
                    if(string.isNotBlank(batchCode))
                        purchaseDate = CaseTriggerHandler.getBatchCodeDate(batchCode);
                }
					
                MulberryWarrantyRequestClass.Product_meta objProductmeta2 = new MulberryWarrantyRequestClass.Product_meta();
                objProductmeta2.field_name = 'date_of_purchase';
                //objProductmeta2.field_value = purchaseDate.month() + '/' + purchaseDate.day() + '/' + purchaseDate.year();
                objProductmeta2.field_value = datetime.newInstance(purchaseDate.year(), purchaseDate.month(),purchaseDate.day()).format('MM/dd/yyyy');
				lstProductmeta.Add(objProductmeta2);
                system.debug('lstProductmeta:'+lstProductmeta);
                
                ObjLineItem.product_meta = lstProductmeta; 
                system.debug('ObjLineItem:'+ObjLineItem);      
                lstLineItems.Add(ObjLineItem);
            }
        }
        objMulberryWarrantyRequestClass.line_items = lstLineItems;
        system.debug('lstLineItems:'+lstLineItems);
        //Populate line items in the request - end
        
        //Populate billing address
        MulberryWarrantyRequestClass.Billing_address ObjBillingAddress = new MulberryWarrantyRequestClass.Billing_address();
        ObjBillingAddress.address1 = objOrder.BillingStreet;
        //ObjBillingAddress.address2 = objOrder.Billing_Street_Line_1__c;
        ObjBillingAddress.city = objOrder.BillingCity;
        ObjBillingAddress.country = objOrder.BillingCountry;
        ObjBillingAddress.country_code = objOrder.BillingCountryCode;
        ObjBillingAddress.first_name = objOrder.Account.Firstname;
        ObjBillingAddress.last_name = objOrder.Account.Lastname;
        ObjBillingAddress.phone = objOrder.Account.Phone;
        ObjBillingAddress.state = objOrder.BillingState;
        ObjBillingAddress.zip = objOrder.BillingPostalCode;
        objMulberryWarrantyRequestClass.billing_address = ObjBillingAddress;
        system.debug('ObjBillingAddress:'+ObjBillingAddress);
        
        return objMulberryWarrantyRequestClass;
    }
    private static String getWarrantyProgramID (String regionCode, boolean isPostSales, Integer warrantyDuration) {
        String programID;
        
        String confName = 'ProgramID_Data';
        String specificConfigName;
        
        if (String.isNotBlank(regionCode)) 
        {
            confName += '_' + regionCode ;
			if (warrantyDuration != null)
	        	specificConfigName = confName + '_' + warrantyDuration;
        }

        for (Mulberry_Detail__mdt conf: [SELECT id,	DeveloperName, Sales_Program_ID__c, Post_Sales_Program_ID__c FROM 
                                         Mulberry_Detail__mdt WHERE DeveloperName IN (:specificConfigName, :confName)])
        {
            if(isPostSales)
                programID = conf.Post_Sales_Program_ID__c;
            else
                programID = conf.Sales_Program_ID__c;
        }
        system.debug('Program ID: ' + programID);
        return programID;
    }
}