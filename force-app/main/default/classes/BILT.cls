public with sharing class BILT {
    
    public class ProductRegistrationResponse {
        public List<Data> data    { get; set; }
        public Context    context { get; set; }
    }
    
    public class Context {
        public Boolean withSubsidiaries { get; set; }
        public Long    endTimestamp     { get; set; }
        public Long    startTimestamp   { get; set; }
    }
    
    public class Data {
        public String             modelNumber      { get; set; }
        public String             productName      { get; set; }
        public String             manufacturerName { get; set; }
        public List<Registration> registrations    { get; set; }
    }
    
    public class Registration {
        public Datetime             registered              { get; set; }
        public Attribute            attributes              { get; set; }
        public UnClassifiedAttibute notClassifiedAttributes { get; set; }
        public Datetime             purchaseDate            { get; set; }
    }
    
    public class UnClassifiedAttibute {
        public String APP_COUNTRY { get; set; }
        public String COUNTRY     { get; set; }
        public String STATE       { get; set; }
        public String serialNum   { get; set; }
    }
    
    public class Attribute {
        public UserInfo    user_info    { get; set; }
        public ProductInfo product_info { get; set; }
    }
    
    public class UserInfo {
        public String lastName               { get; set; }
        public String email                  { get; set; }
        public String firstName              { get; set; }
        public String ADDRESS_LINE1          { get; set; }
        public String ADDRESS_LINE2          { get; set; }
        public String COUNTRY                { get; set; }
        public String CITY                   { get; set; }
        public String ZIP_CODE               { get; set; }
        public String PHONE                  { get; set; }
        public String OPT_IN_MARKETINGEMAILS { get; set; }
        public String STATE                  { get; set; }
        public String confimrEmail           { get; set; }
    }
    
    public class ProductInfo {
        public String MODEL_NUMBER    { get; set; }
        public String serialNum       { get; set; }
        public String DATE_CODE       { get; set; }
        public String placeOfPurchase { get; set; }
    }
    
    public class ProductIntegrationResponse {
        public List<Product> available { get; set; }
    }
    
    public class Country {
        public String code { get; set; }
        public String name { get; set; }
    }
    
    public class Brand {
        public String name { get; set; }
        public String id   { get; set; }
    }
    
    public class Product {
        public String        id         { get; set; }
        public String        name       { get; set; }
        public List<String>  model      { get; set; }
        public List<String>  languages  { get; set; }
        public List<Country> countries  { get; set; }
        public List<String>  skuNumbers { get; set; }
        public Brand         brand      { get; set; }
    }
}