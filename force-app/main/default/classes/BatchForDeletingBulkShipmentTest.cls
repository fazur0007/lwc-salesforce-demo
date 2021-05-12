@isTest

public  class BatchForDeletingBulkShipmentTest {
	
	private static list<sObject> bulkshipments = new  list<sObject>(); 
	
    
    private static  void createData(){
    	 //Create return shipment for UPS
    	zkups__UPSShipmatePreference__c upsshipmatePref = new zkups__UPSShipmatePreference__c();
    	insert upsshipmatePref;
		//Create return shipment for MC
		zkmulti__MCShipmate_Preference__c mcshipmatePref = new zkmulti__MCShipmate_Preference__c();
    	insert mcshipmatePref;
    	//Create fedEx Prefernce shipment for MC
		zkfedex__ShipmatePreference__c fedExshipmentPref = new zkfedex__ShipmatePreference__c();
    	insert fedExshipmentPref;
    	
    	
    	zkups__BulkShipment__c upsbulkShipment = new zkups__BulkShipment__c (
                                        						zkups__ShipmatePreference__c = upsshipmatePref.Id
        
                                        						);
        bulkshipments.add(upsbulkShipment);
        //insert upsbulkShipment;
        
         
        
                                    
        zkfedex__BulkShipment__c  fedexbulkShipment = new zkfedex__BulkShipment__c  (
                                        				zkfedex__ShipmatePreference__c  = fedExshipmentPref.Id
                                        			);
        bulkshipments.add(fedexbulkShipment); 
        //insert fedexbulkShipment;
        
        zkmulti__MCBulk_Shipment__c mcbulkShipment = new zkmulti__MCBulk_Shipment__c (
                                                   	 zkmulti__Shipmate_Preference__c = mcshipmatePref.Id
                                                	);
        bulkshipments.add(mcbulkShipment); 
        insert bulkshipments;
            
    }
    
    public static  testmethod void testBatchForDeletingBulkShipment(){
    	
    	createData();
    	for(sObject sobjectRec : bulkshipments){
    		Test.setCreatedDate(sobjectRec.Id, DateTime.now().addMonths(-2));
    	}
    	
    	Test.startTest();
        Database.executeBatch(new BatchForDeletingBulkShipment());
        Test.stopTest();
        
        system.assertEquals(0, [select count() from zkups__BulkShipment__c]);
        system.assertEquals(0, [select count() from zkfedex__BulkShipment__c]);
        system.assertEquals(0, [select count() from zkmulti__MCBulk_Shipment__c]);
        system.assertEquals(1, [select count() from zkups__UPSShipmatePreference__c]);
    }
   
}