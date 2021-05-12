global class MockHttpResponseGenerator
{
	/*

global class MockHttpResponseGenerator implements HttpCalloutMock
{
	global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://ct.soa-gw.canadapost.ca', req.getEndpoint());
      //  System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        if( req.getMethod() == 'POST')
        {
	         HttpResponse res = new HttpResponse();
	         res.setHeader('Content-Type', 'application/vnd.cpc.shipment-v4+xml; charset=UTF-8');
	        
	         string strResponse = '<authorized-return-info>'+
								  '<tracking-pin>12345678901234</tracking-pin>'+
								  '<links>'+
								  '<link href="https://ct.soa-gw.canadapost.ca/ers/artifact/76108cb5192002d5/21238/0" rel="returnLabel" media-type="application/pdf" index="0"></link>'+
								  '</links>'+
								  '</authorized-return-info>';
	        res.setBody(strResponse);
	        res.setStatus('OK');
	        res.setStatusCode(200);
	       
	       // system.debug('*******^^^^^^^^^^^res'+res);
	        return res;
        }
        else
        {
        	 HttpResponse res = new HttpResponse();
	         res.setHeader('Content-Type', 'application/pdf');
			 res.setBody('TEST PDF');
	         res.setStatusCode(200);
	         res.setStatus('OK');
	        
	         return res;
        }
        
    }*/
}