@isTest
private class CWSIdentityEventLogTest {

    @isTest static void testGetRequestMethod() {
        CWSIdentityEvent.RequestMethod requestMethod = CWSIdentityEvent.getRequestMethod('GET');
        System.assertEquals(CWSIdentityEvent.RequestMethod.GET,requestMethod);
    }
    
    private static CWSIdentityEvent buildIdentityEvent(String traceId, Integer responseStatusCode) {
         return buildIdentityEvent(traceid,CWSIdentityEvent.Service.LOGIN,responseStatusCode);
    }
    
    
    private static CWSIdentityEvent buildIdentityEvent(String traceId, CWSIdentityEvent.Service service,
        Integer responseStatusCode) 
    {

       return new CWSIdentityEvent(traceId,null,
           service,
           '127.0.0.1', // source IP
           CWSIdentityEvent.RequestMethod.POST,
           '/identity/v1/login',
           new Map<String,String>{'requestParam1' => 'requestParam1Value'},
           Blob.valueOf('{"foo":"bar"}'),
           DateTime.now(), 
           Blob.valueOf('{"response":"blah"}'), 
           DateTime.now().addMinutes(1), 
           responseStatusCode);
    }
   
    
    @isTest static void testIsEventAnError() {    
         String traceId = new Uuid().getValue();
        
          
         CWSIdentityEvent evtIdentityOk = buildIdentityEvent(traceId,200); 
         CWSIdentityEvent evtIdentityFail = buildIdentityEvent(traceId,400); 
         CWSIdentityEvent evtIdentityRegOk = buildIdentityEvent(traceId,
             CWSIdentityEvent.Service.REGISTRATION,201); 
         CWSIdentityEvent evtIdentityRegFail = buildIdentityEvent(traceId,
             CWSIdentityEvent.Service.REGISTRATION,400);
            CWSIdentityEvent.getServiceName(CWSIdentityEvent.Service.REGISTRATION);
        CWSIdentityEvent evtIdentityRegFail2 = new CWSIdentityEvent(traceId,'parentseg',
             CWSIdentityEvent.Service.REGISTRATION,new HttpRequest(),DateTime.now(),new CWSIdentityException());
        CWSIdentityEvent evtIdentityRegFail3 = new CWSIdentityEvent(traceId,'parentseg',
             CWSIdentityEvent.Service.REGISTRATION,new HttpRequest(),DateTime.now(),new HttpResponse());
              
              
         System.assertEquals(false,evtIdentityOk.isError(),'Identity Login API with response status of 200 NOT should be tagged as an error');
         System.assertEquals(true,evtIdentityFail.isError(),'Identity Login API with response status of 400 should be tagged as an error');
         
         System.assertEquals(false,evtIdentityRegOk.isError(),'Identity Reg API with response status of 201 NOT should be tagged as an error');
         System.assertEquals(true,evtIdentityRegFail.isError(),'Identity Reg API with response status of 400 should be tagged as an error');
    }
    
     @isTest static void testIsIdentityEventAcceptedForLogging() {    
         String traceId = new Uuid().getValue();
         
         CWSIdentityEvent evtIdentityOk = buildIdentityEvent(traceId,200); 
         CWSIdentityEvent evtIdentityFail = buildIdentityEvent(traceId,400); 
         CWSIdentityEvent evtIdentityRegOk = buildIdentityEvent(traceId,
             CWSIdentityEvent.Service.REGISTRATION,201); 
         CWSIdentityEvent evtIdentityRegFail = buildIdentityEvent(traceId,
             CWSIdentityEvent.Service.REGISTRATION,400);
             
         Map<CWSIdentityEvent,Boolean> identityEventsUnderNone = new Map<CWSIdentityEvent,Boolean>{
             evtIdentityOk => false,
             evtIdentityFail => false,
             evtIdentityRegOk => false,
             evtIdentityRegFail => false
         };
             
         Map<CWSIdentityEvent,Boolean> identityEventsUnderAll = new Map<CWSIdentityEvent,Boolean>{
             evtIdentityOk => true,
             evtIdentityFail => true,
             evtIdentityRegOk => true,
             evtIdentityRegFail => true
         };
         
         Map<CWSIdentityEvent,Boolean> identityEventsUnderAllFailures = new Map<CWSIdentityEvent,Boolean>{
             evtIdentityOk => false,
             evtIdentityFail => true,
             evtIdentityRegOk => false,
             evtIdentityRegFail => true
         };
         
         Map<CWSIdentityEvent,Boolean> identityEventsUnderIdentityFailures = new Map<CWSIdentityEvent,Boolean>{
             evtIdentityOk => false,
             evtIdentityFail => true,
             evtIdentityRegOk => false,
             evtIdentityRegFail => true
         };
         
       
         
         Map<CWSIdentityEvent.Topic,Map<CWSIdentityEvent,Boolean>> topicsAndEvents = 
             new Map<CWSIdentityEvent.Topic,Map<CWSIdentityEvent,Boolean>> {
             CWSIdentityEvent.Topic.NONE => identityEventsUnderNone,
             CWSIdentityEvent.Topic.ALL => identityEventsUnderAll,
             CWSIdentityEvent.Topic.ALL_FAILURES => identityEventsUnderAllFailures
         };
       
         for (CWSIdentityEvent.Topic topic : topicsAndEvents.keySet()) {
             Map<CWSIdentityEvent,Boolean> events = topicsAndEvents.get(topic);
             for (CWSIdentityEvent event : events.keySet()) {
                 Boolean expectedResult = events.get(event);
                 boolean accepted = event.accept(topic,CWSIdentityEvent.Destination.IDENTITY_SERVICES);
                 System.assertEquals(expectedResult,accepted,
                 String.format('Event {0} should be accepted for logging under topic {1} and destination {2}',
                     new List<Object>{event,topic,CWSIdentityEvent.Destination.IDENTITY_SERVICES}));
             }
         }
     }
    
    @isTest static void testLogInboundRESTEvent() {
    
       CWSIdentityConfiguration.getInstance().setEventLoggingTopic(CWSIdentityEvent.Topic.ALL);
       String traceId = new Uuid().getValue();
       CWSIdentityEvent evt = buildIdentityEvent(traceId,200);
       CWSIdentityEventLog.logInboundRESTCall(evt);
       
       List<Service_Event_Log__c> events = [SELECT Id FROM Service_Event_Log__c WHERE Trace_Id__c = :traceId];
       System.assert(events != null,'No events found');
       System.assertEquals(1,events.size(),'Number of events');
    }
}