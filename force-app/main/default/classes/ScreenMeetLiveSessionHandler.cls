public class ScreenMeetLiveSessionHandler {
    public static void doUpdateScreenMeetLiveSessionObj(List < screenmeet__Live_Session__c > screenMeetLiveSessionList) {
        Map < String, String > mapOfScreenMeetSessions = new Map < String, String > ();
        Map < String, String > mapOfCaseDetails = new Map < String, String > ();
        for (screenmeet__Live_Session__c ls: screenMeetLiveSessionList) {
            if (ls.screenmeet__parentObjectType__c.equalsIgnoreCase('livechattranscript')) 
                mapOfScreenMeetSessions.put(ls.Id, ls.screenmeet__parentObjectId__c);
            else if (ls.screenmeet__parentObjectType__c.equalsIgnoreCase('case')) 
                mapOfCaseDetails.put(ls.Id, ls.screenmeet__parentObjectId__c);
        }
        doCreateScreenMeetChatTranscriptSessionRecord(screenMeetLiveSessionList, mapOfScreenMeetSessions);
        doCreateScreenMeetCaseSessionRecord(screenMeetLiveSessionList, mapOfCaseDetails);
    }
    public static void doCreateScreenMeetChatTranscriptSessionRecord(List < screenmeet__Live_Session__c > screenMeetLiveSessionList, Map < String, String > mapOfScreenMeetSessions) {
        if (mapOfScreenMeetSessions.size() > 0) {
            Map < String, LiveChatTranscript > mapOfLiveChatTranscript = new Map < String, LiveChatTranscript > ([Select Id, CaseId From
                LiveChatTranscript Where Id IN: mapOfScreenMeetSessions.values()
            ]);
            List < ScreenMeet_Chat_Transcript_Session__c > listOfJunctionRecords = new List < ScreenMeet_Chat_Transcript_Session__c > ();
            List < ScreenMeet_Case_Session__c > listOfCaseSessionRecords = new List < ScreenMeet_Case_Session__c > ();
            for (screenmeet__Live_Session__c ls: screenMeetLiveSessionList) {
                if (String.isNotBlank(ls.screenmeet__parentObjectId__c)) {
                    ScreenMeet_Chat_Transcript_Session__c screenMeetJunctionObj = new ScreenMeet_Chat_Transcript_Session__c(
                        Chat_Transcript__c = mapOfLiveChatTranscript.get(ls.screenmeet__parentObjectId__c).Id, 
                        Case__c = mapOfLiveChatTranscript.get(ls.screenmeet__parentObjectId__c).CaseId, 
                        ScreenMeet_Live_Session__c = ls.Id
                    );
                    listOfJunctionRecords.add(screenMeetJunctionObj);
                    ScreenMeet_Case_Session__c screenMeetCaseSessionObj = new ScreenMeet_Case_Session__c(
                        Case__c = mapOfLiveChatTranscript.get(ls.screenmeet__parentObjectId__c).CaseId, 
                        ScreenMeet_Live_Session__c = ls.Id
                    );
                    listOfCaseSessionRecords.add(screenMeetCaseSessionObj);
                }
            }
            system.debug(listOfCaseSessionRecords.size() + '****listOfCaseSessionRecords***' + JSON.serializePretty(listOfCaseSessionRecords.size()));
            if (listOfJunctionRecords.size() > 0) {
                insert listOfJunctionRecords;
            }
            if (listOfCaseSessionRecords.size() > 0) {
                insert listOfCaseSessionRecords;
            }
        }
    }
    public static void doCreateScreenMeetCaseSessionRecord(List < screenmeet__Live_Session__c > screenMeetLiveSessionList, Map < String, String > mapOfCaseDetails) {
        if (mapOfCaseDetails.size() > 0) {
            List < ScreenMeet_Case_Session__c > listOfCaseSessionRecords = new List < ScreenMeet_Case_Session__c > ();
            for (screenmeet__Live_Session__c ls: screenMeetLiveSessionList) {
                if (String.isNotBlank(ls.screenmeet__parentObjectId__c)) {
                    ScreenMeet_Case_Session__c screenMeetCaseSessionObj = new ScreenMeet_Case_Session__c(
                        Case__c = mapOfCaseDetails.get(ls.Id), 
                        ScreenMeet_Live_Session__c = ls.Id
                    );
                    listOfCaseSessionRecords.add(screenMeetCaseSessionObj);
                }
            }
            system.debug('****listOfCaseSessionRecords***' + JSON.serializePretty(listOfCaseSessionRecords.size()));
            if (listOfCaseSessionRecords.size() > 0) {
                insert listOfCaseSessionRecords;
            }
        }
    }
}