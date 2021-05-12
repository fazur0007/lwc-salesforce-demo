/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

@isTest
global class Zip2TaxMockImpl implements HttpCalloutMock  {
	
	String jsonResponse = '{"Z2tLookup": {'+
			'  "errorInfo": {'+
			'    "errorCode": "0",'+
			'    "errorMessage": "Success",'+
			'    "elapsedTime": "00:00.60",'+
			'    "startTime": "2016-08-28 09:49:37.5547",'+
			'    "endTime": "2016-08-28 09:49:38.1557",'+
			'    "ServerName": "CASPER06",'+
			'    "Version": "1.0.5",'+
			'    "warnings": ['+
			'      {"warning": "Login: Success (brevilla @ level 3)"},'+
			'      {"warning": "PinPoint Lookup: Insufficient input to specify a tax jurisdiction (PinPoint resolution) (, , )"},'+
			'      {"warning": "Zip+4 Lookup: Insufficient input to specify a tax jurisdiction (ZIP+4 resolution) (32081)"},'+
			'      {"warning": "ZIP Lookup: Success"}]},'+
			'  "addressInfo": {'+
			'    "addressResolution": "ZIP",'+
			'    "addresses": ['+
			'      {"address": {'+
			'        "place": "Ponte Vedra",'+
			'        "state": "FL",'+
			'        "zipCode": "32081",'+
			'        "county": "Saint Johns",'+
			'        "Latitude": "30.1736",'+
			'        "Longitude": "-81.3956",'+
			'        "salesTax": {'+
			'          "rateInfo": {'+
			'            "taxRate": "6.5000",'+
			'            "rateDetails": ['+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "State",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "6.0000",'+
			'                "authorityName": "State of FL"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "County",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.5000",'+
			'                "authorityName": "County of Saint Johns"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "City",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.0000",'+
			'                "authorityName": "City of Ponte Vedra"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "Special",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.0000",'+
			'                "authorityName": "Special District"}}]}},'+
			'        "useTax": {'+
			'          "rateInfo": {'+
			'            "taxRate": "6.5000",'+
			'            "rateDetails": ['+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "State",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "6.0000",'+
			'                "authorityName": "State of FL"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "County",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.5000",'+
			'                "authorityName": "County of Saint Johns"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "City",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.0000",'+
			'                "authorityName": "City of Ponte Vedra"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "Special",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.0000",'+
			'                "authorityName": "Special District"}}]}},'+
			'        "notes": ['+
			'          {"noteDetail": {'+
			'            "jurisdiction": "State of FL",'+
			'            "category": "Special Rate",'+
			'            "note": "Portion over $5000 is only taxed at the State Rate of 6%"}},'+
			'          {"noteDetail": {'+
			'            "jurisdiction": "State of FL",'+
			'            "category": "Tax on Shipping",'+
			'            "note": "Shipping charges are taxable except when charges are stated separately and not bundled with other charges such as handling; and charges are optional or shipment occurs after title passes to purchaser.  "}}]}},'+
			'      {"address": {'+
			'        "place": "Ponte Vedra Beach",'+
			'        "state": "FL",'+
			'        "zipCode": "32081",'+
			'        "county": "Saint Johns",'+
			'        "Latitude": "30.1736",'+
			'        "Longitude": "-81.3956",'+
			'        "salesTax": {'+
			'          "rateInfo": {'+
			'            "taxRate": "6.5000",'+
			'            "rateDetails": ['+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "State",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "6.0000",'+
			'                "authorityName": "State of FL"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "County",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.5000",'+
			'                "authorityName": "County of Saint Johns"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "City",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.0000",'+
			'                "authorityName": "City of Town Of Nocatee"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "Special",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.0000",'+
			'                "authorityName": "Special District"}}]}},'+
			'        "useTax": {'+
			'          "rateInfo": {'+
			'            "taxRate": "6.5000",'+
			'            "rateDetails": ['+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "State",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "6.0000",'+
			'                "authorityName": "State of FL"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "County",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.5000",'+
			'                "authorityName": "County of Saint Johns"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "City",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.0000",'+
			'                "authorityName": "City of Town Of Nocatee"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "Special",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.0000",'+
			'                "authorityName": "Special District"}}]}},'+
			'        "notes": ['+
			'          {"noteDetail": {'+
			'            "jurisdiction": "State of FL",'+
			'            "category": "Special Rate",'+
			'            "note": "Portion over $5000 is only taxed at the State Rate of 6%"}},'+
			'          {"noteDetail": {'+
			'            "jurisdiction": "State of FL",'+
			'            "category": "Tax on Shipping",'+
			'            "note": "Shipping charges are taxable except when charges are stated separately and not bundled with other charges such as handling; and charges are optional or shipment occurs after title passes to purchaser.  "}}]}},'+
			'      {"address": {'+
			'        "place": "Town Of Nocatee",'+
			'        "state": "FL",'+
			'        "zipCode": "32081",'+
			'        "county": "Saint Johns",'+
			'        "Latitude": "30.1736",'+
			'        "Longitude": "-81.3956",'+
			'        "salesTax": {'+
			'          "rateInfo": {'+
			'            "taxRate": "6.5000",'+
			'            "rateDetails": ['+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "State",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "6.0000",'+
			'                "authorityName": "State of FL"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "County",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.5000",'+
			'                "authorityName": "County of Saint Johns"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "City",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.0000",'+
			'                "authorityName": "City of Ponte Vedra Beach"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "Special",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.0000",'+
			'                "authorityName": "Special District"}}]}},'+
			'        "useTax": {'+
			'          "rateInfo": {'+
			'            "taxRate": "6.5000",'+
			'            "rateDetails": ['+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "State",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "6.0000",'+
			'                "authorityName": "State of FL"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "County",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.5000",'+
			'                "authorityName": "County of Saint Johns"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "City",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.0000",'+
			'                "authorityName": "City of Ponte Vedra Beach"}},'+
			'              {"rateDetail": {'+
			'                "jurisdictionLevel": "Special",'+
			'                "jurisdictionCode":"",'+
			'                "taxRate": "0.0000",'+
			'                "authorityName": "Special District"}}]}},'+
			'        "notes": ['+
			'          {"noteDetail": {'+
			'            "jurisdiction": "State of FL",'+
			'            "category": "Special Rate",'+
			'            "note": "Portion over $5000 is only taxed at the State Rate of 6%"}},'+
			'          {"noteDetail": {'+
			'            "jurisdiction": "State of FL",'+
			'            "category": "Tax on Shipping",'+
			'            "note": "Shipping charges are taxable except when charges are stated separately and not bundled with other charges such as handling; and charges are optional or shipment occurs after title passes to purchaser.  "}}]}}]}}}';
			
	
	public HTTPResponse respond(HTTPRequest req) {
	   	HttpResponse resp = new HttpResponse();
	   	resp.setStatusCode(200);
	   	resp.setStatus('Complete');
	   	resp.setBody(jsonResponse);
	   	return resp;
	   	
	}

}