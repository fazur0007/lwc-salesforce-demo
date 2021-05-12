@isTest
public class LiveChatPreChatControllerTest {
    
    public static testMethod void LiveChatPreChatControllerTesting() {
        Test.startTest();
        PageReference pageRef = Page.LiveChatPreChat;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('button_id', 'button');
        
        LiveChatPreChatController lcpc = new LiveChatPreChatController();
        System.assertEquals(lcpc.code, 'en_US');
        Test.stopTest();
    }
}