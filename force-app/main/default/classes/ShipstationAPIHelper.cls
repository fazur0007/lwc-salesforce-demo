public  class ShipstationAPIHelper {
    @AuraEnabled
    public static ShipStationGetOrderResponse GetOrders()
    {
        HttpRequest shipstationHTTPRequest = new HttpRequest();
        Http APIHttp = new Http();
        String integrationName = 'callout:Shipstation' + '/orders';
        shipstationHTTPRequest.setEndpoint(integrationName);
        shipstationHTTPRequest.setMethod('GET');
        //shipstationHTTPRequest.setHeader('Authorization', 'Bearer {!$Credential.Password}');
        //shipstationHTTPRequest.setHeader('Content-Type', 'application/json');
        //shipstationHTTPRequest.setBody(JSON.serialize(objMulberryWarrantyRequestClass));
        
        system.debug('API request:'+shipstationHTTPRequest.getBody());
        System.debug ('Cred: ' + shipstationHTTPRequest.getHeader('Authorization'));
        
        System.debug ('http: ' + shipstationHTTPRequest);
        HttpResponse shipStationAPIResponse;       
        shipStationAPIResponse = APIHttp.send(shipstationHTTPRequest);
        system.debug('API response:'+shipStationAPIResponse.getBody());  
        ShipStationGetOrderResponse apiResponse = new ShipStationGetOrderResponse();
        apiResponse = (ShipStationGetOrderResponse) JSON.deserialize(shipStationAPIResponse.getBody(), ShipStationGetOrderResponse.class);
        ShipStationGetOrderResponse returnResponse = new ShipStationGetOrderResponse();
        List<ShipStationGetOrderResponse.Orders> lstOrders = new List<ShipStationGetOrderResponse.Orders>();
        for(ShipStationGetOrderResponse.Orders objOrder:apiResponse.orders)
        {
            if(objOrder.advancedOptions.customField1 == 'VEN31827')
                lstOrders.Add(objOrder);                
        }
        returnResponse.orders = lstOrders;
        system.debug('API response:'+returnResponse); 
        return returnResponse;
    }
}