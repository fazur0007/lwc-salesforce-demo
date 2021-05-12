public class CWSIdentityEventLog {
    
    public static void logInboundRESTCall(CWSIdentityEvent msg) {
        logEvents(new List<CWSIdentityEvent>{msg},CWSIdentityEvent.Source.REMOTE_CLIENT,CWSIdentityEvent.Destination.IDENTITY_SERVICES);
    }

    
    private static void logEvents(List<CWSIdentityEvent> msgs, CWSIdentityEvent.Source source, CWSIdentityEvent.Destination destination) {
        List<Service_Event_Log__c> logMessages = new List<Service_Event_Log__c>();
        CWSIdentityEvent.Topic topic = CWSIdentityConfiguration.getInstance().eventLoggingTopic;
        for (CWSIdentityEvent msg : msgs) {
            if (!msg.accept(topic,destination)) {
                System.debug(String.format('Event {0} does not match topic {1} for destination {2} and therefore will not be logged',
                    new List<Object>{msg,topic,destination}));
                continue;
            }
            Service_Event_Log__c logMessage = new Service_Event_Log__c();
            logMessage.Trace_Id__c = msg.traceId;
            logMessage.Trace_Parent_Segment_Id__c = msg.parentSegmentId;
            String aService = msg.getServiceName();
            logMessage.Source_IP__c = msg.sourceIP;
            logMessage.Source__c = msg.getSourceName(source);
            logMessage.Destination__c = msg.getDestinationName(destination);
            logMessage.Event__c = aService == null ? 'Unknown' : aService;
            logMessage.Request_Method__c = msg.requestMethod.name();
            logMessage.Request__c = msg.requestBody == null ? null : prettyPrint(msg.requestBody.toString());
            logMessage.Request_Parameters__c = 
                msg.requestParams == null || msg.requestParams.isEmpty() ? null : msg.requestParams.toString();
            logMessage.Request_URI__c = msg.requestURI;
            logMessage.Requested_At__c = msg.requestedAt;
           
            
            logMessage.Response__c = msg.hasResponseFailureRootCause() ? 
                msg.responseFailureRootCause :
                msg.responseBody == null ? null : prettyPrint(msg.responseBody.toString());
            logMessage.Responded_At__c = msg.respondedAt;
            //logMessage.Response_Status_Code__c = msg.isError() ? -1 : msg.responseStatusCode;
            logMessage.Response_Status_Code__c = msg.responseStatusCode;
            logMessages.add(logMessage);
        }
    
        insert logMessages;
    }
    
    private static String prettyPrint(String s) {
        try {
            Object o =  JSON.deserializeUntyped(s);
            return JSON.serializePretty(o,true); // suppress nulls    
        }
        catch (Exception e) {
            return s;
        }
    }
}