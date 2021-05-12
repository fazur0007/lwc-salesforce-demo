public without sharing class SharingUtility{
	
	public static Receiving__Share createReceivingShare(Id receivingId, Id userOrGroupId){
	    Receiving__Share share = new Receiving__Share();
	    share.ParentId = receivingId;
	    share.UserOrGroupId = userOrGroupId;                                              
	    share.AccessLevel = 'Edit';
	    share.RowCause = 'Manual';
	    return share;
	}
	
}