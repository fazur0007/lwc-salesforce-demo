@RestResource(urlMapping='/ContactPointAddress/*')
global class DeleteContactPointAddressAPI{
    @HttpDelete
    global static RestResponseCls doDelete() {
        RestResponseCls restResp = new RestResponseCls();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String contactPointAddressId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        try{
            ContactPointAddress ContactPointAddressDelete = [SELECT Id FROM ContactPointAddress WHERE Id = :contactPointAddressId];
            delete ContactPointAddressDelete; 
            restResp.AddressId = contactPointAddressId;
            restResp.Message = 'Record has been deleted successfully';
            restResp.error = '';
            res.StatusCode = 200;
            restResp.StatusCode = 200;
        }catch(Exception e){
            restResp.AddressId = '';
            restResp.Message = '';
            restResp.error = 'Record has been deleted already or something wen\'t wrong';
            res.StatusCode = 404;
            restResp.StatusCode = 404;
        }
    return restResp;
    }
    global class RestResponseCls{
        global String AddressId {get;set;}
        global Integer StatusCode {get;set;}
        global String Message {get;set;}
        global String error {get;set;}
    }
}