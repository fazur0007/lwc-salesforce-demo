public class JWT {
    
    public String alg {get;set;}
    public String iss {get;set;}
    public String sub {get;set;}
    public String aud {get;set;}
    public String exp {get;set;}
    public String iat {get;set;}
    public Map<String, Object> claims {get;set;}
    public Integer validFor {get;set;}
    public String cert {get;set;}
    public String pkcs8 {get;set;}
    public String privateKey {get;set;}
    private Boolean isTimeStampNeeded { get; set; }
    
    public static final String RS512 = 'RS512';
    public static final String NONE = 'none';

    
    public JWT(String alg) {
        this(alg, false);
    }
    
    public JWT(String alg, Boolean isTimestampNeeded) {
        this.alg = alg;
        this.isTimeStampNeeded = isTimestampNeeded;
        if (this.isTimeStampNeeded) {
            this.validFor = 300;
        }
    }
    
    
    public String issue() {
    
        String jwt = '';
    
        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', this.alg);
        header.writeStringField('typ', 'JWT');
        header.writeEndObject();
        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));
            
        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        if (this.isTimeStampNeeded) {
            Long rightNow = (dateTime.now().getTime()/1000)+1;
            body.writeNumberField('iat', rightNow);
            body.writeNumberField('exp', (rightNow + validFor));
        }
        
        if (claims != null) {
            for (String claim : claims.keySet()) {
                Object val = claims.get(claim);
                if (val instanceOf Integer) {
                    body.writeNumberField(claim, (Integer) val);
                } else if (val instanceOf Long) {
                    body.writeNumberField(claim, (Long) val);
                } else if (val instanceOf Double) {
                    body.writeNumberField(claim, (Double) val);
                }  else if (val instanceOf Decimal) {
                    body.writeNumberField(claim, (Decimal) val);
                } else {
                    body.writeStringField(claim, (String) val);
                }
            }
        }
        writeStringField(body, 'iss', this.iss);
        writeStringField(body, 'sub', this.sub);
        writeStringField(body, 'aud', this.aud);
        
        body.writeEndObject();
        
        jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));
        
        if ( this.alg == RS512 ) {
            Blob privateKey = EncodingUtil.base64Decode(pkcs8);
            Blob signature = Crypto.sign('rsa-sha512', Blob.valueOf(jwt), privateKey);
            jwt += '.' + base64URLencode(signature);  
        } else if ( this.alg == NONE ) {
            jwt += '.';
        }
        return jwt;
    }
    
    private void writeStringField(JSONGenerator body, String key, String value) {
        if (key != null && value != null) {
            body.writeStringField(key, value);
        }
    }
    

    public String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }
}