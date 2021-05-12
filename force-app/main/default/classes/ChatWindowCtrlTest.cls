@IsTest(SeeAllData=true)
public with sharing class ChatWindowCtrlTest {
    
    static testMethod void testMethod1(){
    	
    	User user = TestDataFactory.createUser('CCC User', 'CCC Tier 1', 'USD', true);
    	
    	ChatWindowCtrl.getPhoto(user.id);
    }
    
}