public class AddRemoveExternalUserToGroup implements Queueable {
    
    Map<Id, String> externalUserIdToCurrencyToDeleteMap;
    Map<Id, String> externalUserIdToCurrencyToInsertMap;
    Set<String> currencyISOCodeSet;
    Map<String, Id> currencyCodeToGroupIdMap;
    
    public AddRemoveExternalUserToGroup(Map<Id, String> deleteMembershipMap, Map<Id, String> newMembership, Set<String> currencyCodeSet){
    	Map<String, String> publicExternalGroupNameToCurrencyCode = new Map<String, String>(); 
    	currencyCodeToGroupIdMap = new Map<String, Id>();
    	
    	this.externalUserIdToCurrencyToDeleteMap = deleteMembershipMap;
    	this.externalUserIdToCurrencyToInsertMap = newMembership;
    	this.currencyISOCodeSet = currencyCodeSet;
    	    	
    	for(All_Literal__mdt allLiteral : [SELECT DeveloperName, Category__c, Value__c, CurrencyISOCode__c 
    														FROM All_Literal__mdt
    														WHERE Category__c = 'PublicExternalGroup'
    														AND CurrencyISOCode__c IN: currencyCodeSet]){
    		publicExternalGroupNameToCurrencyCode.put(allLiteral.Value__c, allLiteral.CurrencyISOCode__c);
    	}
    	if(publicExternalGroupNameToCurrencyCode != null && publicExternalGroupNameToCurrencyCode.size() > 0){
    		for(Group groupRec : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN: publicExternalGroupNameToCurrencyCode.keySet()]){
    			currencyCodeToGroupIdMap.put(publicExternalGroupNameToCurrencyCode.get(groupRec.DeveloperName), groupRec.Id);
    		}
    	} 
    }
    
    public void execute(QueueableContext context) {
    	if(currencyCodeToGroupIdMap != null && currencyCodeToGroupIdMap.size() > 0){
    		List<GroupMember> oldGroupMemberList = new List<GroupMember>();
    		//Delete Old Membership Records
    		if(externalUserIdToCurrencyToDeleteMap != null && externalUserIdToCurrencyToDeleteMap.size() > 0){
    			for(GroupMember oldGroupMember : [SELECT Id, UserOrGroupId, GroupId 
    															FROM GroupMember 
    															WHERE UserOrGroupId IN: externalUserIdToCurrencyToDeleteMap.keySet() 
    															AND GroupId IN: currencyCodeToGroupIdMap.values()]){
    				if(currencyCodeToGroupIdMap.containsKey(externalUserIdToCurrencyToDeleteMap.get(oldGroupMember.UserOrGroupId)) 
    							&& currencyCodeToGroupIdMap.get(externalUserIdToCurrencyToDeleteMap.get(oldGroupMember.UserOrGroupId)) == oldGroupMember.GroupId){
    					oldGroupMemberList.add(oldGroupMember);		
    				}
    			}
    			if(oldGroupMemberList != null && oldGroupMemberList.size() > 0){
    				delete oldGroupMemberList;
    			}
    		}
    		
    		//Create New Membership Records
    		if(externalUserIdToCurrencyToInsertMap != null && externalUserIdToCurrencyToInsertMap.size() > 0){
    			List<GroupMember> newGroupMemberList = new List<GroupMember>();
    			
    			for(Id userId : externalUserIdToCurrencyToInsertMap.keySet()){
    				if(currencyCodeToGroupIdMap.containsKey(externalUserIdToCurrencyToInsertMap.get(userId))){
    					GroupMember newGroupMember = new GroupMember();
				        newGroupMember.GroupId = currencyCodeToGroupIdMap.get(externalUserIdToCurrencyToInsertMap.get(userId));
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