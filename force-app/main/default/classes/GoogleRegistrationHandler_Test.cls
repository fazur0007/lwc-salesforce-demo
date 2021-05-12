@isTest class GoogleRegistrationHandler_Test {
    private static User createTestUser() {
        Profile profile = [Select Id From Profile Where Name = 'System Administrator'];
        User testUser = new User();
        testUser.Username = 'eventTest@invalid.user.address.com';
        testUser.LastName = 'Admin';
        testUser.Email = 'eventTest@invalid.user.address.breville.com';
        testUser.Alias = 'evtTst';
        testUser.CommunityNickname = 'evtTst';
        testUser.TimeZoneSidKey = 'Europe/Berlin';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.ProfileId = profile.Id;
        testUser.LanguageLocaleKey = 'en_US';
        insert testUser;
        return testUser;
    }
    @isTest static void validateOverralMethods() {
        System.runAs(createTestUser()) {
            Test.startTest();
                testCreateAndUpdateUser();
            Test.stopTest();
        }
    }
    @isTest static void testCreateAndUpdateUser() {
        GoogleRegistrationHandler handler = new GoogleRegistrationHandler();
        Auth.UserData sampleData = createUser('abc1237654@gmail.com', 'Thomas', 'Jones-Drew');
        String theCommunityId = '00000001';
        sampleData.attributeMap.put('sfdc_networkid', theCommunityId);

        try {
                 Id recordtype = [select id from RecordType where name='Person Account'].Id;

            Account acc = new Account(lastname= 'test acc',personemail='abc1237654@gmail.com',RecordTypeId=recordtype);
        insert acc;
        User newuser = new User();
          newuser.Account_ID__c = acc.Id;
            //newuser.ContactId = [select id,PersonContactId from account where id=:acc.Id].PersonContactId;
        String alias = 'br' + Integer.valueof((Math.random()*100000000));
        alias = alias.substring(0, 8);
        newuser.emailEncodingKey = 'UTF-8';
        newuser.timeZoneSidKey = 'America/Los_Angeles';       
        newuser.profileId = [select id,name from profile where name='Call Centre User'].Id;
        newuser.email = 'abc1237654@gmail.com';
        newuser.Username = 'abc1237654@gmail.com';
        newuser.lastName = 'TestEmp';
        newuser.languagelocalekey = 'en_CA';
        newuser.localesidkey= 'en_CA';
        newuser.alias = alias; 
        insert newuser;
            User u = handler.createUser(null, sampleData);
            sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
                'testNewFirst testNewLast', 'abc1237654@gmail.com', null, 'testnewuserlong', 'en_US', 'facebook',
                null, new Map < String, String > {});
            handler.updateUser(null, null, sampleData);
        }
        catch (Exception e) {

        }
    }
    
     @isTest static void testCreateAndUpdateUser_create() {
        GoogleRegistrationHandler handler = new GoogleRegistrationHandler();
        Auth.UserData sampleData = createUser('abc12376541@gmail.com', 'Thomas', 'Jones-Drew');
        String theCommunityId = '00000001';
        sampleData.attributeMap.put('sfdc_networkid', theCommunityId);

        try {
                 Id recordtype = [select id from RecordType where name='Person Account'].Id;

            Account acc = new Account(lastname= 'test acc',personemail='abc1237654@gmail.com',RecordTypeId=recordtype);
        insert acc;
        User newuser = new User();
          newuser.Account_ID__c = acc.Id;
            //newuser.ContactId = [select id,PersonContactId from account where id=:acc.Id].PersonContactId;
        String alias = 'br' + Integer.valueof((Math.random()*100000000));
        alias = alias.substring(0, 8);
        newuser.emailEncodingKey = 'UTF-8';
        newuser.timeZoneSidKey = 'America/Los_Angeles';       
        newuser.profileId = [select id,name from profile where name='Call Centre User'].Id;
        newuser.email = 'abc1237654@gmail.com';
        newuser.Username = 'abc1237654@gmail.com';
        newuser.lastName = 'TestEmp';
        newuser.languagelocalekey = 'en_CA';
        newuser.localesidkey= 'en_CA';
        newuser.alias = alias; 
        insert newuser;
            User u = handler.createUser(null, sampleData);
            sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
                'testNewFirst testNewLast', 'abc1237654@gmail.com', null, 'testnewuserlong', 'en_US', 'facebook',
                null, new Map < String, String > {});
            handler.updateUser(null, null, sampleData);
        }
        catch (Exception e) {

        }
    }
    
    private static Auth.UserData createUser(String email, String lastName, String firstName) {
        Map < String, String > attributeMap = new Map < String, String > ();
        String identifier = lastName + System.currentTimeMillis();
        String locale = 'en_US';
        return new Auth.UserData(identifier,
            firstName,
            lastName,
            '',
            email,
            '',
            '',
            locale,
            '',
            '',
            attributeMap);
    }
}