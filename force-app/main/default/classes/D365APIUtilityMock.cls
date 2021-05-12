@isTest 
public class D365APIUtilityMock implements HttpCalloutMock {
    String jsonResponse = '[{'+
          '    "$id": "1",'+
          '    "ItemID": "SNE500BKS4EEU1",'+
          '    "Price": 84.7,'+
          '    "Quantity": 1,'+
          '    "UnitID": "ea",'+
          '    "PriceDate": "2019-05-07T12:00:00",'+
          '    "LegalEntity": "BDE",'+
          '    "CurrencyCode": "EUR"'+
          '}]';
   
 

    Public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json;charset=UTF-8');
        res.setStatusCode(200);
        res.setStatus('Complete');
        res.setBody(jsonResponse);
        return res; 
    }
    
    public class TradeAgreementMock implements HttpCalloutMock {
        String jsonResponse = '[{'+
            '    "$id": "1",'+
            '    "ItemID": "SNE500BKS4EEU1",'+
            '    "Price": 84.7,'+
            '    "Quantity": 1,'+
            '    "UnitID": "ea",'+
            '    "PriceDate": "2019-05-07T12:00:00",'+
            '    "LegalEntity": "BDE",'+
            '    "CurrencyCode": "EUR"'+
            '}]';
            
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setStatusCode(200);
            res.setStatus('Complete');
            res.setBody(jsonResponse);
            return res; 
        }
    }
    
    public class ProcessRMAMock implements HttpCalloutMock {
        String jsonResponse =  '[ {' +
            '"RMANumber" : "R101408500",' +
            '"RMAComplete" : 0,' +
            '"OriginalSalesOrder" : "00902982",' +
            '"InvoiceId" : "",' +
            '"ImportDate" : "2020-09-24T12:00:00",' +
            '"ExternalClaimNumber" : "",' +
            '"Error" : "",' +
            '"D365RMANumber" : "RMA6000328",' +
            '"D365ReturnSalesId" : "SO60013579",' +
            '"D365RecId" : 5637372759,' +
            '"AccountNumber" : "CUS60011"' +
          '} ]' ;
            
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setStatusCode(200);
            res.setStatus('Complete');
            res.setBody(jsonResponse);
            return res; 
        }
    }
    
}