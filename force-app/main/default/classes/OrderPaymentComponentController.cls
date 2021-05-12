public without sharing class OrderPaymentComponentController{
    
    public Id orderId {get;set;}
    public String strCreditCardType {get;set;}
    public String strCreditCardNumber {get;set;}
    public List<Order> OrderList;
    public DateTime date_time { get; set; } //property that reads the datetime value from component attribute tag
    public String defined_format { get; set;} //property that reads the string value from component attribute tag
    
    public OrderPaymentComponentController() {
      OrderList = new List<Order>();
    }
    
  public void getPaymentRecord() {
    OrderList = [Select Id,
                             Credit_Card_Type__c, Credit_Card_Last_4_Digits__c
                       From Order
                       Where Id =: orderId ];
        
    if(OrderList != NULL && OrderList.size() > 0 ) {
      strCreditCardType = OrderList[0].Credit_Card_Type__c <> NULL ? OrderList[0].Credit_Card_Type__c : '' ;
      strCreditCardNumber = OrderList[0].Credit_Card_Last_4_Digits__c <> NULL ? OrderList[0].Credit_Card_Last_4_Digits__c : '';
    } 
  }  
        
  public String getFormatted() {
        
    User objUser=[Select TimeZoneSidKey from User where id =: USerInfo.getUserId() limit 1];
    if (date_time == null){
      return ''; 
    }else { 
      if (defined_format == null) {
        return date_time.format(); //return the full date/time in user's locale and time zone
      }else{ 
        return date_time.format(defined_format,objUser.TimeZoneSidKey );  //Specify Time zone like IST,CST
      }
    }
        
  }
}