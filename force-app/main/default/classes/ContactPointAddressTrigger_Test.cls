@isTest public class ContactPointAddressTrigger_Test{
    @isTest public static void testContactPointAddress(){
        Account objAcc = TestDataFactory.createAccountRecord('firstName','lastName', true);
        objAcc.firstName = 'firstName1';
        objAcc.PersonEmail = 'PersonEmail@x.com';
        objAcc.Phone = '12356';
        objAcc.DataAreaID__c='BUS';
        objAcc.ShippingStreet = '24 FALCON CIRCUIT';
        objAcc.ShippingCity = 'SPRINGFIELD LAKES';
        objAcc.ShippingPostalCode = '4300';
        //objAcc.ShippingState = 'QLD';
        //objAcc.ShippingCountry = 'AU';
        Update objAcc;
        ContactPointAddress contactPointAddrss = new ContactPointAddress(
            ParentId = objAcc.Id,
            IsDefault = true,
            Name = objAcc.firstName,
            AddressType = 'Shipping',
            Street = objAcc.ShippingStreet,
            City = objAcc.ShippingCity,
            PostalCode = objAcc.ShippingPostalCode
            //State = objAcc.ShippingState,
            //Country = objAcc.ShippingCountry
        );
        insert contactPointAddrss; 
        
        contactPointAddrss.Name = 'Test';
        contactPointAddrss.IsDefault = true;
        update contactPointAddrss;
    }
}