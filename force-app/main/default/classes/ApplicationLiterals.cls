public with sharing class ApplicationLiterals{

    public static final String ACCESSTYPE='private';
    public static final String CONTENTTYPE='multipart/form-data';
    public static final String S3SERVERSIDEENCRYP='AES256';
    public static final String S3ALGORITHM='AWS4-HMAC-SHA256';
    public static final String HMACSHA256='hmacSHA256';
    
    public static final String RMA_SHIPPING_ERROR='RMA Label Error';
    
    public static final Decimal CM_TO_IN_CRATE = 0.393701;
    public static final Decimal IN_TO_CM_CRATE = 2.54;
    public static final Decimal KG_TO_LB_CRATE = 2.20462;
    public static final Decimal LB_TO_KG_CRATE = 0.453592;
    
    public static final String SHIPMATE_APP_NAME = 'UPS'; 
    public static final String MULTI_CARRIER_NAME = 'Multi Carrier'; 
    public static final String SHIPMATE_STATUS_ERROR = 'ERROR'; 
    public static final String SHIPMATE_SUCCESS = 'SUCCESS'; 
    
    public static final String RMA_CASE_ORIGIN = 'Partner';
	public static final String RMA_CASE_TYPE = 'RMA';
	public static final String RMA_CASE_RECORD_TYPE = 'RMA';
	
    public static final String ACCOMMODATION_TYPE = 'Accommodation';
    public static final String RETAILER_COMMUNITY_NAME = 'Retailer Community';
    
    public static final String BASIC = 'Basic ';
    public static final String AUTHORIZATION = 'Authorization';
    public static final String CONTENT_TYPE_FOR_PRICE_API = 'Content-Type';
    public static final String ERROR_LOG_TYPE = 'Price API';
    
    public static final Integer BATCH_RMA_RECEIPT_PRICE_CALCULATION_CHUNK_SIZE = 50;
    public static final Set<String> applicableClaimTypes = new Set<String>{'Freight Charge', 'Inspection Charge', 'Labor Charge'};
    public static final Set<String> applicableClaimTypesExceptFreight = new Set<String>{'Inspection Charge', 'Labor Charge'};
    public static final Set<String> applicableWorkOrderCurrencySet = new Set<String>{'AUD', 'NZD', 'CAD'};
    
    public static final Set<String> CASEAUTOCLOSEDISPOSITION_CASE_STATUS = new Set<String>{'Waiting on consumer','Waiting on return'};
    public static final Set<String> CASEAUTOCLOSEDISPOSITION_ORDER_STATUS = new Set<String>{'Open'};
    public static final Set<String> CASEAUTOCLOSEDISPOSITION_WORKORDER_STATUS = new Set<String>{'Completed','Cancelled'};    
    public static final Integer CASEAUTOCLOSEDISPOSITION_DaysForFirstNotification = 15;
    public static final Integer CASEAUTOCLOSEDISPOSITION_DaysForHardClose = 7;
    public static final String CASEAUTOCLOSEDISPOSITION_SoftCloseReason = 'Auto Soft Closed';
    public static final String CASEAUTOCLOSEDISPOSITION_HardClosedReason = 'Auto Hard Closed';
    
    public static final Integer BACKORDERNOTIFICATION_Duration = 15;
    
    
    
}