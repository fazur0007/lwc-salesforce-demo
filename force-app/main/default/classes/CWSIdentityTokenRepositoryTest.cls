@isTest
private class CWSIdentityTokenRepositoryTest {

    private static void assertEquals(CWSIdentityToken t1, CWSIdentityToken t2) {
        System.assertEquals(t1.id,t2.id,'Token ID');
        System.assertEquals(t1.expirationDate,t2.expirationDate,'Token expiration');
        System.assertEquals(t1.issuedTo,t2.issuedTo, 'Token subject');
        System.assertEquals(t1.usage,t2.usage,'Token usage');
        System.assertEquals(t1.value,t2.value,'Token value');
    }

    private static CWSIdentityToken setUp() {
        CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
        return new CWSIdentityToken(CWSIdentityToken.Usage.VERIFY_EMAIL,result.observed.id);
    }
    
    private static User systemAdmin() {
        return [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
    }
    
    @isTest static void testSaveAndRedeemForARedeemableToken() {
        System.runAs(systemAdmin()) {
            CWSIdentityToken expectedToken = setUp();
            System.assertEquals(false,expectedToken.isRedeemed(),'Token has NOT been redeemed');
            CWSIdentityTokenRepository.getInstance().redeemAndSave(expectedToken);
            System.assertEquals(true,expectedToken.isRedeemed(),'Token has been redeemed');
            CWSIdentityToken observedToken = 
                    CWSIdentityTokenRepository.getInstance().findOneByValue(expectedToken.value);
            System.assertEquals(true,observedToken.isRedeemed(),'Token has been redeemed');
        }
    }
    
    @isTest static void testSaveAndRedeemForANonRedeemableToken() {
        System.runAs(systemAdmin()) {
            CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
            CWSIdentityToken expectedToken = new CWSIdentityToken(CWSIdentityToken.Usage.PASSWORD_RESET,result.observed.id);
            System.assertEquals(false,expectedToken.isRedeemed(),'Token has NOT been redeemed');
            CWSIdentityTokenRepository.getInstance().redeemAndSave(expectedToken);
            System.assertEquals(false,expectedToken.isRedeemed(),'Token has NOT been redeemed');
            CWSIdentityToken observedToken = 
                    CWSIdentityTokenRepository.getInstance().findOneByValue(expectedToken.value);
            System.assertEquals(false,observedToken.isRedeemed(),'Token has NOT been redeemed');
         }
    }

 
    @isTest static void testFindOneByValue() {
        System.runAs(systemAdmin()) {
            CWSIdentityToken expectedToken = setUp();
            CWSIdentityToken observedToken = 
                CWSIdentityTokenRepository.getInstance().findOneByValue(expectedToken.value);
            assertEquals(expectedToken,observedToken);
        }
    }
    
    @isTest static void testFindOneByValueAndRedeemed() {
        System.runAs(systemAdmin()) {
            CWSIdentityToken expectedToken = setUp();
            CWSIdentityToken observedToken = 
                CWSIdentityTokenRepository.getInstance().findOneByValueAndRedeemed(expectedToken.value,false);
            assertEquals(expectedToken,observedToken);
            CWSIdentityToken observedToken2 = 
                CWSIdentityTokenRepository.getInstance().findOneByValueAndRedeemed(expectedToken.value,true);
            System.assertEquals(null,observedToken2,
                'Redeemed email verification token was found even though the token is unredeemed');
            
            expectedToken.redeem();
            CWSIdentityToken observedToken3 = 
                CWSIdentityTokenRepository.getInstance().findOneByValueAndRedeemed(expectedToken.value,true);
            assertEquals(expectedToken,observedToken3);
            
            CWSIdentityToken observedToken4 = 
                CWSIdentityTokenRepository.getInstance().findOneByValueAndRedeemed(expectedToken.value,false);
            System.assertEquals(null,observedToken4,
                'Unredeemed email verification token was found even though this token has been redeemed');
        }
    }
}