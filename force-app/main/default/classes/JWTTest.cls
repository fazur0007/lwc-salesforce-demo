@isTest
private class JWTTest {
    private static final String KEY = 'MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBALFwazh4b50xjbgnZbzHOMXspFQ0BfSPBpbhYeryIyUhd7NsAAJgR2p4SrWRPd+EQ9d5rFnc+KBlpFI3QoEIjHpcAENUEqU3WvImAn2PBOMKWhEAg7nJ4lsM2FH61bk3b7UX56R6WR+zcHRQ/U+xoa+CbHbB+G0ZcUk/bjtp+OAZAgMBAAECgYAhuAFIG+rp7k7GHgaBV0J8qjmYHsK69KsF5RKceSMgnTmICQ//Y5hurSlVU6J0ZUgXHHIaKZm9sVMGpKWoq502Gkfl5kBxpUfw4l3VMHsPvv0xLihWAv/8DCyoU9NAW8z200s1KQVXXLfDQfnXUzn8o6EesyEG6/Gf1ZxC03PHuQJBAN/QwDI2mWpmMAry2GhYpkiUz+NCgn+nzQojtHaapffLmpdxGp7CGl6BmgdCV15TqlvVSoXtJGwrH2nTphNCNwcCQQDK9G59xv/NQJrrmpxDu7tL4pq1inkKYgqIjKUSMlsW6eXKtZgJViOrsiG+q1yyfdXW6/qGoCWWxmTizHE/uEffAkEAr15q6i1b4kG1jS6hIImtqRtpFMHtbMb3YuV9Jp2gQ9v2Aomt+Q1QChL0tJFn0dIunwwt+2hH7LWRRKOA8oAkiwJANE7ZZ2txpHoBM7YOjlqFRGKsExwUZDuukVEGfnEiDv7LrfotrEJaQTdRAS5zXsGV6qW5VRdTeM+7UsT0b0LUqwJAH4aBr4s7PwKdkNwH+Ono3yDBaVjgBjR8xjikq3JWPiOsOSUOKk3K9ToYa3FxmyJsaVVG3Cb6AJurhYBlHAgilA==';
    
    @isTest
    private static void testIssueToken() {
        Test.startTest();
        JWT j = new JWT('RS512');
        j.iss = 'app-gateway';
        j.claims = new Map<String, Object> {
            'secret_key' => 'xyz',
            'access_key' => 'abc',
            'Content-Type' => 'application/json',
            'lng' => 100000L,
            'd' => 1.000002
        };
        
        j.pkcs8 = KEY;

        System.assertNotEquals(null, j.issue());
        Test.stopTest();
    }
    
    @isTest
    private static void testIssueTokenWithTimeStamp() {
        Test.startTest();
        JWT j = new JWT('none', true);
        j.claims = new Map<String, Object> {
            'secret_key' => 'xyz',
            'access_key' => 'abc',
            'Content-Type' => 'application/json',
            'num' => 1,
            'dec' => (Decimal) 2.2
        };
        
        j.pkcs8 = KEY;

        System.assertNotEquals(null, j.issue());
        Test.stopTest();
    }
}