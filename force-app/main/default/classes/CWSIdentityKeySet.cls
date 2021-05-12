public class CWSIdentityKeySet {

    private Enum Usage { SIGNING }
    private static Map<Usage,String> usageToString = new Map<Usage,String>{ Usage.SIGNING => 'sig'};
    private static Map<String,Usage> stringToUsage = new Map<String,Usage>{ 'sig' => Usage.SIGNING };

    private Enum SigningAlgorithm { RS256 }
    private static Map<SigningAlgorithm,String> algoToString = 
        new Map<SigningAlgorithm,String>{ SigningAlgorithm.RS256 => 'RS256'};
    private static Map<String,SigningAlgorithm> stringToAlgo = 
        new Map<String,SigningAlgorithm>{ 'RS256' => SigningAlgorithm.RS256 };
        
    private static Map<SigningAlgorithm,String> algoToKeyType = 
        new Map<SigningAlgorithm,String>{ SigningAlgorithm.RS256 => 'RSA'};

    public List<JWK> keys {get;private set;}

    private static final CWSIdentityKeySet INSTANCE = new CWSIdentityKeySet();
    
    public static CWSIdentityKeySet getInstance() { return INSTANCE; }
    
    private CWSIdentityKeySet() {
         
         List<Identity_Services_Public_Key__mdt> publicKeys = [
            SELECT Kid__c,Usage__c,Algorithm__c,Modulus__c,Exponent__c
            FROM Identity_Services_Public_Key__mdt];
        
        keys = new JWK[publicKeys.size()-1];
        
        for(Identity_Services_Public_Key__mdt publicKey: publicKeys) {
            Usage usage = stringToUsage.get(publicKey.Usage__c);
            SigningAlgorithm algo = stringToAlgo.get(publicKey.Algorithm__c);
            JWK key = new JWK(publicKey.Kid__c,usage,algo,publicKey.Modulus__c,publicKey.Exponent__c);
            keys.add(key);
        }
    }
    
    public class JWK {
        
        
        public JWK(String kid, Usage usage, SigningAlgorithm signingAlgo, String modulus, String exponent) {
            this.kid = kid;
            this.n = modulus;
            this.e = exponent;
            this.use = usageToString.get(usage);
            this.alg = algoToString.get(signingAlgo);
            this.kty = algoToKeyType.get(signingAlgo);
        }
 
        public String n {get; private set;}
        public String e {get; private set;}
        public String alg {get; private set;}
        public String use {get; private set;}
        public String kid {get; private set;}
        public String kty {get; private set;}
    }
}