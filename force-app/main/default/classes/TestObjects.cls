/**
 * Test class the is used to create objects needed for code coverage.
 *
 * @author james@highondemand.com
 * @version 1.0
 * @since December 12, 2012 
 */
@isTest
    public class TestObjects {
        
    public User getUser(Boolean doInsert){
        User user = new User();
        user.FirstName = 'User1';
        user.LastName = 'User1';
        user.Alias = 'User1';
        user.Email = 'test@test.org';
        user.Username = Datetime.now().getTime()+'_' +UserInfo.getOrganizationId()+'_'+'testuser@test.org';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.ProfileId = '00eE0000000NMcA';
        user.LanguageLocaleKey = 'en_US';
        
        if(doInsert){
            insert user;
        }
        return user;
    }

    /**
     * This method creates an account
     *
     * @param doInsert  a boolean value passed to determine if acct should be inserted
     * @return account  returns the generated account
     */
    public Account getAccount(Boolean doInsert){
        Account account = new Account();
        account.Name = 'Test';
        account.ShippingPostalCode = 'Test111';
        account.BillingStreet = '1234 E Main st';
        if(doInsert){
            insert account;
        }
        return account;
    }

    public Contact getContact(Id idAccount, Boolean doInsert){
        Contact contact = new Contact();
        contact.LastName = 'Test';
        contact.AccountId = idAccount;
        contact.Phone = '9999999764';
        contact.Email = 'a@b.com';
        if(doInsert){
            insert contact;
        }
        return contact;
    }

    public Account getPersonAccount(Boolean doInsert){
        Account account = new Account();
        account.LastName = 'Test';
        account.ShippingPostalCode = 'Test111';
        account.PersonEmail = 'test@test.org';
        account.Phone = '(111) 111-19764';
        if(doInsert){
            insert account;
        }
        return account;
    }

    public Tax_Rate__c getTaxRate(Boolean doInsert){
        Tax_Rate__c tr = new Tax_Rate__c();
        tr.Name = 'Test111';
        tr.Combined_Rate__c = 2.3;
        if(doInsert){
            insert tr;
        }
        return tr;
    }

    public Product2 getProduct(Boolean doInsert){
        Product2 prod = new Product2();
        prod.MAP__c = 15.99;
        prod.CurrencyIsoCode = 'USD';
        prod.Authorization_Amount__c = 10.00;
        prod.Name = 'Test';
        prod.IsActive = true;
        prod.Description = 'Test Product';
        prod.Available_To_Sell__c = true;
        if(doInsert){
            insert prod;
        }
        return prod;
    }

    public Case getCase(Id acctId, Boolean doInsert){
        Case cse = new Case();
        cse.AccountId = acctid;
        cse.eComm__c = false;
        cse.Order_Type__c = 'SALE';


        if(doInsert){
            insert cse;
        }
        return cse;
    }

    public Case getCase2(Id acctId, Id prodId, Boolean doInsert){
		Case cse = new Case();
		cse.AccountId = acctid;
		
		cse.Item_1_Qty__c = 1;
		cse.Item_2__c = prodid;
		cse.Item_2_Qty__c = 1;
		cse.Item_3__c = prodId;
		cse.Item_3_Qty__c = 1;
		cse.Item_4__c = prodId;
		cse.Item_4_Qty__c = 1;
		cse.Item_5__c = prodId;
		cse.Item_5_Qty__c = 1;
		cse.eComm__c = false;
		cse.Order_Type__c = 'SALE';
		cse.Item_1__c = prodId;
		if(doInsert){
			insert cse;
		}
		return cse;
    }

    public Case getCase3(Id acctId, Id prodId, String orderType, Boolean doInsert){
        Case cse = new Case();
        cse.AccountId = acctid;
        
        cse.Item_1_Qty__c = 1;
        cse.Item_2__c = prodid;
        cse.Item_2_Qty__c = 1;
        cse.Item_3__c = prodId;
        cse.Item_3_Qty__c = 1;
        cse.Item_4__c = prodId;
        cse.Item_4_Qty__c = 1;
        cse.Item_5__c = prodId;
        cse.Item_5_Qty__c = 1;
        cse.eComm__c = false;
        cse.Order_Type__c = orderType;
        cse.Item_1__c = prodId;
        if(doInsert){
            insert cse;
        }
        return cse;
    }    

    public zkfedex__Shipment__c getShipment(Id caseId, Boolean doInsert) {

        zkfedex__Shipment__c shipment = new zkfedex__Shipment__c();
        shipment.zkfedex__RecipientName__c = 'RSS Tester';
        shipment.zkfedex__RecipientPhone__c = '123-456-7890';
        shipment.zkfedex__RecipientCity__c = 'Newport Beach';
        shipment.zkfedex__RecipientState__c = 'CA';
        shipment.zkfedex__RecipientStreet__c = '3600 Birch Street.';
        shipment.zkfedex__RecipientPostalCode__c = '92660';
        shipment.zkfedex__RecipientCountry__c = 'US';
        shipment.zkfedex__RecipientEMail__c = 'egonzalez@redskysolutions.com';
        shipment.zkfedex__StatusDescription__c = 'Testing the description field.';
        shipment.zkfedex__MasterTrackingId__c = '1234567890';
        shipment.zkfedex__SsProcessReturnShipment__c = true;
        shipment.Case__c = caseId;

        if (doInsert) {
            insert shipment;
        }
        return shipment;
    }

    public Order getOrder(Id idAccount, Boolean doInsert){

    Order orderObj = new Order();
    orderObj.AccountId = idAccount;
    orderObj.Channel__c = 'CCC';
    orderObj.Source__c = 'Breville';
    orderObj.Status = 'Draft';
    orderObj.Type = 'Service';
    orderObj.EffectiveDate = system.today();

     if (doInsert) {
            insert orderObj;
        }
        return orderObj;
    }

    public pymt__PaymentX__c getPayment(Id caseId, String status, String tranId, Boolean doInsert) {

        pymt__PaymentX__c payment = new pymt__PaymentX__c ();
        payment.Name = 'RSS_Test';
        payment.Case__c = caseId;
        payment.pymt__Status__c = status;
        payment.pymt__Transaction_Id__c = tranId;
        payment.pymt__Authorization_Id__c = 'abcde';

        if (doInsert) {
            insert payment;
        }
        return payment;
    }
}