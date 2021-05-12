public with sharing class BILTUtility {
    
    public static final String PRIVATE_KEY           = 'PKCS8PrivateKey';
    public static final String ACCESS_KEY            = 'AccessKey';
    public static final String SECRET_KEY            = 'SecretKey';
    public static final String NEXT_START_TIME_STAMP = 'NextStartTimestamp';
    
    public static final Map<String, String> BILT_SETTINGS {
        get {
            if (BILT_SETTINGS == null) {
                BILT_SETTINGS = new Map<String, String>();
                for (BILTSetting__mdt settingRecord :[SELECT DeveloperName, Value__c, LongValue__c FROM BILTSetting__mdt]) {
                    if (settingRecord.DeveloperName.equalsIgnoreCase(PRIVATE_KEY)) {
                        BILT_SETTINGS.put(settingRecord.DeveloperName, settingRecord.LongValue__c);
                    } else {
                        BILT_SETTINGS.put(settingRecord.DeveloperName, settingRecord.Value__c);
                    }
                }
            }
            return BILT_SETTINGS;
        }
        private set;
    }
    
    public static BILT.ProductRegistrationResponse getProductRegistrations() {
        String endpoint = 'callout:BILTProductRegistrations?withSubsidiaries=true';
        String startTimeStamp = BILT_SETTINGS.get(NEXT_START_TIME_STAMP);
        if (String.isNotBlank(startTimeStamp)) {
            endpoint += '&startTimestamp=' + startTimeStamp;
        }
        HttpResponse res = makeAPICallout(endpoint, new Map<String, String>());
        System.debug(res.getBody());
        BILT.ProductRegistrationResponse response = (BILT.ProductRegistrationResponse) System.JSON.deserialize(res.getBody(), BILT.ProductRegistrationResponse.class);
        System.debug(response);
        return response;
    }
    
    public static BILT.ProductIntegrationResponse getProducts() {
        HttpResponse res = makeAPICallout('callout:BILTProductIntegration?withSubsidiaries=true', new Map<String, String>());
        System.debug(res.getBody());
        JSONParser parser = JSON.createParser(res.getBody());
        parser.nextToken();
        parser.nextToken();
        BILT.ProductIntegrationResponse availableProducts = (BILT.ProductIntegrationResponse) parser.readValueAs(BILT.ProductIntegrationResponse.class);
        System.debug(availableProducts);
        return availableProducts;
    }
    
    private static HttpResponse makeAPICallout(String endpoint, Map<String, String> params) {
        Datetime currentTime = Datetime.now();
        Datetime truncatedTime = Datetime.newInstance(currentTime.year(), currentTime.month(), currentTime.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        String currentTimeString = truncatedTime.formatGMT('EEE, dd MMM yyy HH:mm:ss z');
        System.debug(currentTimeString);
        String jwt = issueJWT(truncatedTime);
        System.debug(jwt);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('date', currentTimeString);
        req.setHeader('Authorization', 'Bearer ' + jwt);
        req.setTimeout(120000);
        HttpResponse res = new Http().send(req);
        
        return res;
    }
    
    public static String issueJWT(Datetime dt) {
        JWT j = new JWT('RS512');
        j.iss = 'app-gateway';
        System.debug(dt.getTime());
        j.claims = new Map<String, Object> {
            'date' => dt.getTime(),
            'secret_key' => BILT_SETTINGS.get(SECRET_KEY),
            'access_key' => BILT_SETTINGS.get(ACCESS_KEY),
            'Content-Type' => 'application/json'
        };
        
        j.pkcs8 = BILT_SETTINGS.get(PRIVATE_KEY);

        return j.issue();
    }
    
    public class UpdateTimeStamp implements Queueable, Database.AllowsCallouts {
        public String timeStampString;
        
        public UpdateTimeStamp(String timeStampString) {
            this.timeStampString = timeStampString;
        }
        
        public void execute(QueueableContext ctx) {
            List<String> componentNameList = new List<String> { 'BILTSetting__mdt.NextStartTimestamp' };
            List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.CustomMetadata, componentNameList);
            Metadata.CustomMetadata customMetadata = (Metadata.CustomMetadata) components.get(0);
        
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = 'Value__c';
            customField.value = timeStampString;
        
            customMetadata.values.add(customField);
        
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);
        
            MetadataDeployCallBack callback = new MetadataDeployCallBack();
        
            Id jobId = Test.isRunningTest() ? '000000000000000AAA' : Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
    }
    
    public class MetadataDeployCallBack implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result,
                                 Metadata.DeployCallbackContext context) {
            if (result.status == Metadata.DeployStatus.Succeeded) {
                System.debug('Deployment Succeeded');
            } else {
                System.debug('Deployment Failed');
            }
        }
    }
}