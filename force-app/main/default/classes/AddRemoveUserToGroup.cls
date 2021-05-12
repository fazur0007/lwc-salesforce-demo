public class AddRemoveUserToGroup implements Queueable{
    
    Map<Id, String> userIdToCurrencyToDeleteMap;
    Map<Id, String> userIdToCurrencyToInsertMap;
    Set<String> currencyISOCodeSet;
    Map<String, Id> currencyCodeToGroupIdMap;
    
    public AddRemoveUserToGroup(Map<Id, String> deleteMembershipMap, Map<Id, String> newMembership, Set<String> currencyCodeSet ){
    	Map<String, String> publicGroupNameToCurrencyCode = new Map<String, String>(); 
    	currencyCodeToGroupIdMap = new Map<String, Id>();
    	
    	this.userIdToCurrencyToDeleteMap = deleteMembershipMap;
    	this.userIdToCurrencyToInsertMap = newMembership;
    	this.currencyISOCodeSet = currencyCodeSet;
    	
    	
    	for(All_Literal__mdt allLiteral : [SELECT DeveloperName, Category__c, Value__c, CurrencyISOCode__c 
    														FROM All_Literal__mdt
    														WHERE Category__c = 'PublicGroup'
    														AND CurrencyISOCode__c IN: currencyCodeSet]){
    		publicGroupNameToCurrencyCode.put(allLiteral.Value__c, allLiteral.CurrencyISOCode__c);
    	}
    	if(publicGroupNameToCurrencyCode != null && publicGroupNameToCurrencyCode.size() > 0){
    		for(Group groupRec : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN: publicGroupNameToCurrencyCode.keySet()]){
    			currencyCodeToGroupIdMap.put(publicGroupNameToCurrencyCode.get(groupRec.DeveloperName), groupRec.Id);
    		}
    	}
    }
    
    public void execute(QueueableContext context) {
    	if(currencyCodeToGroupIdMap != null && currencyCodeToGroupIdMap.size() > 0){
    		List<GroupMember> oldGroupMemberList = new List<GroupMember>();
    		//Delete Old Membership Records
    		if(userIdToCurrencyToDeleteMap != null && userIdToCurrencyToDeleteMap.size() > 0){
    			for(GroupMember oldGroupMember : [SELECT Id, UserOrGroupId, GroupId 
    															FROM GroupMember 
    															WHERE UserOrGroupId IN: userIdToCurrencyToDeleteMap.keySet() 
    															AND GroupId IN: currencyCodeToGroupIdMap.values()]){
    				if(currencyCodeToGroupIdMap.containsKey(userIdToCurrencyToDeleteMap.get(oldGroupMember.UserOrGroupId)) 
    							&& currencyCodeToGroupIdMap.get(userIdToCurrencyToDeleteMap.get(oldGroupMember.UserOrGroupId)) == oldGroupMember.GroupId){
    					oldGroupMemberList.add(oldGroupMember);		
    				}
    			}
    			if(oldGroupMemberList != null && oldGroupMemberList.size() > 0){
    				delete oldGroupMemberList;
    			}
    		}
    		
    		//Create New Membership Records
    		if(userIdToCurrencyToInsertMap != null && userIdToCurrencyToInsertMap.size() > 0){
    			List<GroupMember> newGroupMemberList = new List<GroupMember>();
    			
    			for(Id userId : userIdToCurrencyToInsertMap.keySet()){
    				if(currencyCodeToGroupIdMap.containsKey(userIdToCurrencyToInsertMap.get(userId))){
    					GroupMember newGroupMember = new GroupMember();
				        newGroupMember.GroupId = currencyCodeToGroupIdMap.get(userIdToCurrencyToInsertMap.get(userId));
				        newGroupMember.UserOrGroupId = userId;
				        newGroupMemberList.add(newGroupMember);
    				}
    			}
    			if(newGroupMemberList != null && newGroupMemberList.size() > 0){
    				insert newGroupMemberList;
    			}
    		}
    	}
    }
}