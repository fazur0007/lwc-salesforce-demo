@isTest
private class CWSIdentityTokenTest {

    @isTest static void testConstructorBasedOnExistingToken() {

        DateTime expirationDate = DateTime.now().addMinutes(60);
        String tokenValue = new Uuid().getValue();
        String tokenType = CWSIdentityToken.tokenUsageToType.get(CWSIdentityToken.Usage.VERIFY_EMAIL);
        
        System.runAs(CWSIdentityUserTestDataFactory.systemAdmin()) {
            CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
            Identity_Service_Token__c expectedToken = new Identity_Service_Token__c();
            expectedToken.Token_Type__c = tokenType;
            expectedToken.Token__c = tokenValue;
            expectedToken.Subject__c = result.observed.id;
            expectedToken.Expires_On__c = expirationDate;
            insert expectedToken;
        
            CWSIdentityToken observedToken = new CWSIdentityToken(expectedToken);
            System.assertEquals(CWSIdentityToken.Usage.VERIFY_EMAIL,observedToken.usage,'Token usage');
            System.assertEquals(expirationDate,observedToken.expirationDate,'Token expiration date');
            System.assertEquals(result.observed.id,observedToken.issuedTo,'Issued to (user/subject)');
            System.assertEquals(result.observed.id,observedToken.issuedTo().id,'Issued to (user/subject)');
            System.assertEquals(tokenType,observedToken.type,'Token type');
            System.assertEquals(tokenValue,observedToken.value,'Token value');
            System.assertEquals(false,observedToken.isRedeemed(),'Token has been redeemed');
            System.assertEquals(false,observedToken.isExpired(),'Token has expired');
            System.assertEquals(true,observedToken.isRedeemable(),'Token is NOT redeemable');   
            System.assertEquals(expectedToken.id,observedToken.id,'Token id');   
        }
    }
    
     @isTest static void testConstructorNewToken() {
        
        String appId = CWSIdentityConfiguration.getInstance().appIds()?.get(0);
        System.assertNotEquals(null,appId,'At least one client app must be registered');
        DateTime expirationDateLowerBound = CWSIdentityToken.determineExpirationDate(CWSIdentityToken.Usage.VERIFY_EMAIL,appId);
        DateTime expirationDateUpperBound = expirationDateLowerBound.addSeconds(10);
       
        System.runAs(CWSIdentityUserTestDataFactory.systemAdmin()) {
            CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
            CWSIdentityToken observedToken = new CWSIdentityToken(CWSIdentityToken.Usage.VERIFY_EMAIL,result.observed.id);
           
            System.assertEquals(CWSIdentityToken.Usage.VERIFY_EMAIL,observedToken.usage,'Token usage');
            System.assertEquals(result.observed.id,observedToken.issuedTo,'Issued to (user/subject)');
            System.assertEquals(CWSIdentityToken.tokenUsageToType.get(CWSIdentityToken.Usage.VERIFY_EMAIL),
                observedToken.type,'Token type');
            System.assertEquals(false,observedToken.isRedeemed(),'Token has been redeemed');
            System.assertEquals(false,observedToken.isExpired(),'Token has expired');
        }
    }
    
    private static void testExpiration(CWSIdentityToken.Usage usage) {
        
        String appId = CWSIdentityConfiguration.getInstance().appIds()?.get(0);
        System.assertNotEquals(null,appId,'At least one client app must be registered');
        DateTime expirationDateLowerBound = CWSIdentityToken.determineExpirationDate(usage,null);
        DateTime expirationDateUpperBound = expirationDateLowerBound.addSeconds(30);
       
        System.runAs(CWSIdentityUserTestDataFactory.systemAdmin()) {
            CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
            CWSIdentityToken observedToken = new CWSIdentityToken(usage,result.observed.id);
            
            System.assert(expirationDateLowerBound.getTime() < observedToken.expirationDate.getTime(),
                'Expiration date ' + observedToken.expirationDate + ' should be later than ' + expirationDateLowerBound);
            System.assert(expirationDateUpperBound.getTime() > observedToken.expirationDate.getTime(),
                'Expiration date ' + observedToken.expirationDate + ' should be earlier than ' + expirationDateUpperBound);
            System.assert(!observedToken.isExpired(),'Token has expired');
        }
    }
    
    @isTest static void testExpirationForVerifyEmail() {
        testExpiration(CWSIdentityToken.Usage.VERIFY_EMAIL);
    }
    
    @isTest static void testExpirationForPasswordReset() {
        testExpiration(CWSIdentityToken.Usage.PASSWORD_RESET);
    }
    
    @isTest static void testSetRedeemed() {
          System.runAs(CWSIdentityUserTestDataFactory.systemAdmin()) {
            CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
            CWSIdentityToken verifyEmailToken = new CWSIdentityToken(CWSIdentityToken.Usage.VERIFY_EMAIL,result.observed.id);
            System.assertEquals(false,verifyEmailToken.isRedeemed());
            verifyEmailToken.setRedeemed(true);
            System.assertEquals(true,verifyEmailToken.isRedeemed());
        }    
     }
    
    @isTest static void testRedeemabilityVerifyEmailToken() {
          System.runAs(CWSIdentityUserTestDataFactory.systemAdmin()) {
            CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
            CWSIdentityToken verifyEmailToken = new CWSIdentityToken(CWSIdentityToken.Usage.VERIFY_EMAIL,result.observed.id);
            System.assertEquals(true,verifyEmailToken.isRedeemable(),'Verify email token is NOT redeemable');
        }    
     }
     
     @isTest static void testRedeemabilityPasswordResetToken() {
          System.runAs(CWSIdentityUserTestDataFactory.systemAdmin()) {
            CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
            CWSIdentityToken pwdResetToken = new CWSIdentityToken(CWSIdentityToken.Usage.PASSWORD_RESET,result.observed.id);
            System.assertEquals(false,pwdResetToken.isRedeemable(),'Password reset token IS redeemable');
        }    
     }
     
    @isTest static void testRedemptionForPasswordResetToken() {
          System.runAs(CWSIdentityUserTestDataFactory.systemAdmin()) {
            CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
            CWSIdentityToken expectedToken = new CWSIdentityToken(CWSIdentityToken.Usage.PASSWORD_RESET,result.observed.id);
            CWSIdentityToken observedToken = expectedToken.redeem();
            System.assertEquals(false,observedToken.isRedeemed(),'Password reset token has been redeemed');
            System.assertEquals(expectedToken,observedToken);
        }    
     }
    
    @isTest static void testRedemptionForVerifyEmail() {
          System.runAs(CWSIdentityUserTestDataFactory.systemAdmin()) {
            CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
            CWSIdentityToken expectedToken = new CWSIdentityToken(CWSIdentityToken.Usage.VERIFY_EMAIL,result.observed.id);
            CWSIdentityToken observedToken = expectedToken.redeem();
            System.assertEquals(true,observedToken.isRedeemed(),'Verify email token has NOT been redeemed');
            System.assertEquals(expectedToken,observedToken);
        }    
     }
     
     @isTest static void testRedemptionOfPreviouslyRedeemedVerifyEmailToken() {
          boolean repeatedRedemptionFailed = false;
          System.runAs(CWSIdentityUserTestDataFactory.systemAdmin()) {
            CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
            CWSIdentityToken expectedToken = new CWSIdentityToken(CWSIdentityToken.Usage.VERIFY_EMAIL,result.observed.id);
            expectedToken.redeem();
            try {
                expectedToken.redeem();
            }
            catch (CWSIdentityException e) {
                System.assertEquals(CWSIdentityException.INVALID_EMAIL_VERIFICATION_TOKEN,e.messageCode,
                    'Redeeming an already redeemed Verify Email token');
                repeatedRedemptionFailed = true;
            }
            System.assertEquals(true,repeatedRedemptionFailed,'Repeated redemption of a Verify Email token did NOT fail');
        }    
     }
     
    @isTest static void testRedemptionOfPreviouslyRedeemedPasswordResetToken() {
        boolean repeatedRedemptionFailed = false;
        System.runAs(CWSIdentityUserTestDataFactory.systemAdmin()) {
            CWSIdentityUserTestDataFactory.ExpectedObservedUser result = CWSIdentityUserTestDataFactory.newlyRegisteredUser();
            CWSIdentityToken expectedToken = new CWSIdentityToken(CWSIdentityToken.Usage.PASSWORD_RESET,result.observed.id);
            for(Integer i=0;i<2;i++) {
                System.assertEquals(false,expectedToken.isRedeemed());
                expectedToken.redeem();
            }
        }
    }
    
}