@isTest
global class CWSIdentityAuthenticatorMock implements HttpCalloutMock {

/*
-- Response --
OK:
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" 
        xmlns="urn:partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <soapenv:Body>
        <loginResponse>
            <result>
                <passwordExpired>false</passwordExpired>
                ...
            </result>
        </loginResponse>
      </soapenv:Body>
    </soapenv:Envelope>
     
FAIL:
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" 
        xmlns:sf="urn:fault.partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <soapenv:Body>
        <soapenv:Fault>
            <faultcode>sf:INVALID_LOGIN</faultcode>
            <faultstring>INVALID_LOGIN: Invalid username, password, security token; or user locked out.</faultstring>
            <detail>
                <sf:LoginFault xsi:type="sf:LoginFault">
                    <sf:exceptionCode>INVALID_LOGIN</sf:exceptionCode>
                    <sf:exceptionMessage>Invalid username, password, security token; or user locked out.</sf:exceptionMessage>
                </sf:LoginFault>
            </detail>
        </soapenv:Fault>
      </soapenv:Body>
    </soapenv:Envelope>|           
*/

    private CWSIdentityAuthenticator.AuthenticationOutcome authenticationOutcome;

    public static CWSIdentityAuthenticatorMock ok() {
        return new CWSIdentityAuthenticatorMock(CWSIdentityAuthenticator.AuthenticationOutcome.OK);
    }
    
    public static CWSIdentityAuthenticatorMock passwordExpired() {
        return new CWSIdentityAuthenticatorMock(CWSIdentityAuthenticator.AuthenticationOutcome.ExpiredPassword);
    }
    
    public static CWSIdentityAuthenticatorMock loginFailed() {
        return new CWSIdentityAuthenticatorMock(CWSIdentityAuthenticator.AuthenticationOutcome.InvalidPassword);
    }
    
    private CWSIdentityAuthenticatorMock(CWSIdentityAuthenticator.AuthenticationOutcome outcome) {
        this.authenticationOutcome = outcome;
    }

    global HttpResponse respond(HTTPRequest req) {
        System.assertEquals('POST', req.getMethod());
        System.assertEquals('""', req.getHeader('SOAPAction'));
        System.assertEquals('text/xml', req.getHeader('Content-Type'));
        
        HttpResponse res = new HttpResponse();
        String body = null;
        
        switch on authenticationOutcome {
            when OK {
                 body = buildResponseWithoutFault(false);    
            }
            when ExpiredPassword {
                body = buildResponseWithoutFault(true);
            }
            when InvalidPassword {
                body = buildResponseWithFault();
            }
        }
        res.setBody(body);
        return res;
    }
    
    private String buildResponseWithFault() {
        dom.Document doc = new dom.Document();
        dom.XmlNode envelope = doc.createRootElement('Envelope',CWSIdentityAuthenticator.ENVELOPE_NS,
            CWSIdentityAuthenticator.ENVELOPE_NS_PREFIX);
        envelope.setNamespace(CWSIdentityAuthenticator.SF_NS_PREFIX, CWSIdentityAuthenticator.SF_PARTNER_NS);
        
        dom.XmlNode fault = envelope
            .addChildElement('Body',CWSIdentityAuthenticator.ENVELOPE_NS,CWSIdentityAuthenticator.ENVELOPE_NS_PREFIX)
            .addChildElement('Fault',CWSIdentityAuthenticator.ENVELOPE_NS,CWSIdentityAuthenticator.ENVELOPE_NS_PREFIX);
        fault.addChildElement('faultcode',CWSIdentityAuthenticator.SF_PARTNER_NS,null).addTextNode('sf:INVALID_LOGIN');
        fault.addChildElement('faultstring',CWSIdentityAuthenticator.SF_PARTNER_NS,null)
            .addTextNode('INVALID_LOGIN: Invalid username, password, security token; or user locked out.');
      
        return doc.toXmlString();
    }
   
    private String buildResponseWithoutFault(boolean passwordExpired) {
    
        dom.Document doc = new dom.Document();
        dom.XmlNode envelope = doc.createRootElement('Envelope',CWSIdentityAuthenticator.ENVELOPE_NS,
            CWSIdentityAuthenticator.ENVELOPE_NS_PREFIX);
        envelope.setNamespace(CWSIdentityAuthenticator.SF_NS_PREFIX, CWSIdentityAuthenticator.SF_PARTNER_NS);
        
        dom.XmlNode loginResponse = envelope
            .addChildElement('Body',CWSIdentityAuthenticator.ENVELOPE_NS,CWSIdentityAuthenticator.ENVELOPE_NS_PREFIX)
            .addChildElement('loginResponse',CWSIdentityAuthenticator.SF_PARTNER_NS,null)
            .addChildElement('result',CWSIdentityAuthenticator.SF_PARTNER_NS,null)
            .addChildElement('passwordExpired',CWSIdentityAuthenticator.SF_PARTNER_NS,null)
            .addTextNode(String.valueOf(passwordExpired));
            
        return doc.toXmlString();
    }
}