@isTest
private class ErrorLogTest
{
    static testMethod void testLogErrorActivity()
    {
    	Error_Log__c response = null;
    	Test.startTest();
    	try
    	{
    		String exceptionGen = null;
    		string data = exceptionGen.toUpperCase();
    	}
    	catch (Exception e)
    	{
    		response = ErrorLog.logErrorActivity(e, 'exception generation', true);
    	}
    	System.AssertNotEquals(null, response);
    	Test.stopTest();
    }
    
    static testMethod void testLogErrorActivityErrorType()
    {
    	Error_Log__c response = null;
    	Test.startTest();
    	try
    	{
    		String exceptionGen = null;
    		string data = exceptionGen.toUpperCase();
    	}
    	catch (Exception e)
    	{
    		response = ErrorLog.logErrorActivity(e, 'exception generation', true, 'Force Exception');
    	}
    	System.AssertNotEquals(null, response);
    	Test.stopTest();
    }
    
    static testMethod void testLogErrorActivityCustom()
    {
    	Test.startTest();
    	Error_Log__c response = null;
		response = ErrorLog.logErrorActivity('Trace Log', 'message', 'operation', true, 'Force Error');
    	System.AssertNotEquals(null, response);
    	Test.stopTest();
    }
    
    static testMethod void testLogAdditionalErrorInfo()
    {
    	Test.startTest();
		ErrorLog.logAdditionalErrorInfo('Additional Information');
    	System.AssertEquals(ErrorLog.additionalInfo, 'Additional Information');
    	
    	ErrorLog.logAdditionalErrorInfo(' Updated');
    	System.AssertEquals(ErrorLog.additionalInfo, 'Additional Information Updated');
    	Test.stopTest();
    }
}