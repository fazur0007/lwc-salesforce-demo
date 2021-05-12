@isTest
global class OrderPriceAPIMockImpl implements HttpCalloutMock {
    
    
    Integer statusCode;
    Id custReference;
    String jsonResponse;
    
    public OrderPriceAPIMockImpl(Integer statusC,Id custRef){
    	statusCode = statusC;
    	custReference = custRef;
    	
    	jsonResponse = '<?xml version="1.0" encoding="UTF-8"?>' + 
						  '<SalesPriceLookupsResponseContract xmlns:ns="http://schemas.datacontract.org/2004/07/Dynamics.Ax.Application">' +
    					  '<ns:SalesPriceLookupResponseContract>' +
      					  '<ns:CostPrice>80.2304081632653</ns:CostPrice>' +
        				  '<ns:DiscDescription/>' +
      					  '<ns:DiscPercent>0</ns:DiscPercent>' +
      					  '<ns:IsTaxExempt>1</ns:IsTaxExempt>' +
      					  '<ns:IsUnitPrice>1</ns:IsUnitPrice>' +
      					  '<ns:ItemId>ZBBL800BSS1BCA1</ns:ItemId>' +
      					  '<ns:RetailPrice>449.99</ns:RetailPrice>' +
     				      '<ns:SalesPrice>200.99</ns:SalesPrice>' +
      					  '<ns:StatusCode/>' +
      					  '<ns:CustRef>' + custReference + '</ns:CustRef>' +
  						  '</ns:SalesPriceLookupResponseContract>' +
						  '</SalesPriceLookupsResponseContract>';
    } 
    
    
						  
						  
	public HTTPResponse respond(HTTPRequest req) {
	   	HttpResponse resp = new HttpResponse();
	   	resp.setStatusCode(statusCode);
	   	resp.setStatus('Complete');
	   	resp.setBody(jsonResponse);
	   	return resp;
	   	
	}
}