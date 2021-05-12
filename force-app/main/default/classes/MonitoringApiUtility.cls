public with sharing class MonitoringApiUtility {
    
    private static final Integer REQUEST_PARAM_COUNT = 10;

    /**
     * callMonitoringApi Synchronous call to the monitoring API
     * @param  transactionID transactionID 
     * @param  component     component being called
     * @param  startTimeObj  start time of request
     * @param  endTimeObj    end time of request
     * @param  type          success/fail
     * @param  requestParams params passed to the api
     */
    public static void callMonitoringApi(String transactionID, String component, Datetime startTimeObj, Datetime endTimeObj, String type, Map<String, String> requestParams) {
        
        Map<String, String> request = new Map<String, String>();
        prepopulateMap(request);
        request.put('TransactionID', TransactionID);
        request.put('Component', Component);
        request.put('StartTime', startTimeObj.format('yyyy-MM-dd hh:mm:ss'));
        request.put('EndTime', endTimeObj.format('yyyy-MM-dd hh:mm:ss'));
        request.put('Type', type);
        request.put('Source', 'Salesforce');
        request.put('Domain', Utility.isProductionOrg() ? 'Production' : 'Sandbox');
        
        if (requestParams != null && requestParams.size() > 0) {
            Integer index = 1;
            for (String key : requestParams.keySet()) {
                if (index > REQUEST_PARAM_COUNT) {
                    break;
                }
                request.put('RequestParam' + index, key);
                request.put('RequestValue' + index, requestParams.get(key));
                index++;
            }
        }
        
        String body = JSON.serialize(request);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('callout:Enterprise_Monitoring_API');
        req.setHeader('x-api-key', '{!$Credential.Password}');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(body);
        
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() != 200) {
            System.debug(res);
            insert ErrorLog.logErrorActivity('Unknown Response from Enterprise Monitoring API', '', 'callMonitoringApi method',false, 'MonitoringApiError');
        }
    }
    
    /**
     * callMonitorApiAsync description
     * @param  transactionID transactionID 
     * @param  component     component being called
     * @param  startTimeObj  start time of request
     * @param  endTimeObj    end time of request
     * @param  type          success/fail
     * @param  requestParams params passed to the api
     */
    public static void callMonitorApiAsync(String transactionID, String component, Datetime startTimeObj, Datetime endTimeObj, String type, Map<String, String> requestParams) {
        System.enqueueJob(new MonitoringApi(transactionID, component, startTimeObj, endTimeObj, type, requestParams));
    }
    
    private static void prepopulateMap(Map<String, String> requestMap) {
        for (Integer index = 1; index <= REQUEST_PARAM_COUNT; index++) {
            requestMap.put('RequestParam' + index, '');
            requestMap.put('RequestValue' + index, '');
        }
    }
    
    public class MonitoringApi implements Queueable, Database.AllowsCallouts {
        String transactionID;
        String component;
        Datetime startTimeObj;
        Datetime endTimeObj;
        String type;
        Map<String, String> requestParams;
        
        public MonitoringApi(String transactionID, String component, Datetime startTimeObj, Datetime endTimeObj, String type, Map<String, String> requestParams) {
            this.transactionID = transactionID;
            this.component = component;
            this.startTimeObj = startTimeObj;
            this.endTimeObj = endTimeObj;
            this.type = type;
            this.requestParams = requestParams;
        }
        
        public void execute(QueueableContext ctx) {
            MonitoringApiUtility.callMonitoringApi(this.transactionID, this.component, this.startTimeObj, this.endTimeObj, this.type, this.requestParams);
        }
    }
}