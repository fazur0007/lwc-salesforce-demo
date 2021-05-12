public without sharing class ChatWindowCtrl {
    @RemoteAction
	public static Agent getPhoto(String userId)
	{
		system.debug('###Network.getNetworkId()'+Network.getNetworkId()+':'+userId);
		system.debug('###user'+[select id,Name from User]);
		
		ConnectApi.Photo ph =  ConnectApi.UserProfiles.getPhoto('internal', UserId);
        //return ph.fullEmailPhotoUrl;
        list<User> usreList = [select firstName from User where Id =:userId];
        String userName='';
        if(usreList != null && usreList.size() > 0){
        	userName = usreList[0].firstName;
        }
        Agent agent = new Agent(ph.fullEmailPhotoUrl,userName);
        return agent;
	}
	public class Agent{
		public String photoUrl;
		public String userName;
		
		public Agent(String photoUrl,String userName){
			this.photoUrl = photoUrl;
			this.userName = userName;
		} 
	}
}