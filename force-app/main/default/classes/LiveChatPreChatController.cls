public class LiveChatPreChatController{
    public String code {get; set;}
    private String buttonId;
    private String url;
    
	public LiveChatPreChatController(){
		code = 'en_US';
		url = ApexPages.currentPage().getURL();
		String urlDecoded = EncodingUtil.urlDecode(url, 'UTF-8').remove('language=#');
		PageReference pageRef = new PageReference(urlDecoded);
		buttonId = pageRef.getParameters().get('button_id');
        
        List<Live_Chat_Settings__mdt> liveChatMetadataRecord = [SELECT Id, ButtonId__c, Language_Code__c FROM Live_Chat_Settings__mdt WHERE ButtonId__c =:buttonId];
        if(liveChatMetadataRecord != null && liveChatMetadataRecord.size() > 0) {
        	code = liveChatMetadataRecord[0].Language_Code__c;
        }
	}
}