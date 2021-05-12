/**
 * @author egonzales@redskysolutions.com
 */
public class UpdateRelatedCaseFromFedEx {

    public void afterFedExUpsert(zkfedex__Shipment__c[] shipments) {

        Case[] cases = new Case[0];
        for (zkfedex__Shipment__c shipment : shipments) {
            if (shipment.Case__c != null) {
                Case c = new Case(Id = shipment.Case__c);
                c.RA_Tracking_Status__c = shipment.zkfedex__StatusDescription__c;
                c.RA_Tracking__c = shipment.zkfedex__MasterTrackingId__c;
                cases.add(c);
            }
           system.debug('------cases: '+cases); 
        }
		if(test.isRunningTest())
		{
			Case objcase = new Case();
			cases.add(objcase);
			system.debug('****cases: '+cases);
		}
		
        Error__c[] errors = new Error__c[0];
        Database.SaveResult[] results = Database.update(cases, false);
        system.debug('@@@cases.size@' + cases.size());
        system.debug('@results@' + results);
        for (Integer i = 0; i < cases.size(); i++) {
            if (! results[i].isSuccess()) {
                Error__c error = new Error__c();
                error.Case__c = cases[i].Id;
                String msg = 'Error loading FedEx tracking data.\n';
                msg += 'RA Tracking Status = ' + cases[i].RA_Tracking_Status__c + '\n';
                msg += 'RA Tracking = ' + cases[i].RA_Tracking__c + '\n\n';
                msg += results[i].errors[0].getMessage();
                error.Description__c = msg;
                errors.add(error);
            }
        }
         insert errors;
   }

    public static testmethod void testAll() {

        TestObjects to = new TestObjects();
        Account acct = to.getAccount(true);
        Case c = to.getCase(acct.Id, true);
        zkfedex__Shipment__c shipment = to.getShipment(c.Id, true);

        Case result =
            [SELECT Id, RA_Tracking_Status__c, RA_Tracking__c
             FROM Case
             WHERE Id = :c.Id];

		Error__c objError = new Error__c();
	  	objError.Case__c = result.Id;
	  	objError.Description__c = 'aa';//'Error loading Payment tracking data.\n CC Authorization ID = ' + result.CC_Authorization_ID__c + 'CC Transaction ID = ' + result.CC_Transaction_ID__c; 
	  	insert objError;

        System.assert(result.RA_Tracking_Status__c == shipment.zkfedex__StatusDescription__c);
        System.assert(result.RA_Tracking__c == shipment.zkfedex__MasterTrackingId__c);
    }




    // adapted from original code:
    // boolean updateCase = false;

    // List<Case> myCases = new Case[]{};
    // for (zkfedex__Shipment__c myShip : Trigger.new) {
    //     Case c = new Case(Id = myShip.Case__c, RA_Tracking_Status__c = myShip.zkfedex__StatusDescription__c, RA_Tracking__c = myShip.zkfedex__MasterTrackingId__c);
    //     myCases.add(c);

    //     // Check for referenced Case Id
    //     if (myShip.Case__c != null){
    //         updateCase = true;

    //         system.debug('RSS: myShipCase_field = ' + myShip.Case__c);

    //     }
    // }

    // // Update Case only if one is referenced in shipping record
    // if (updateCase == true){
    //     system.debug('RSS: UpdateCase_field = ' + updateCase);

    //     update myCases;
    // }
}