public class SendInvoiceAsEmail {
 

    private final Order order;

 


    public SendInvoiceAsEmail(ApexPages.StandardController controller){

        order = [SELECT id, AccountId,AX_Order_ID__c,BillToContact.Email,OrderNumber FROM Order WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

    }

 
    
    public Order getOrder() {

                    return order;

                           }
 
 

    public PageReference send() {
        
            try {
       //Define the email 
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        PageReference pdf =  Page.OrderInvoicePage;

        pdf.getParameters().put('id',(String)order.id);

        pdf.setRedirect(true);

       Blob content;
   if (Test.IsRunningTest())
   {
        content=Blob.valueOf('UNIT.TEST');
   }
   else
   {
        content=pdf.getContent();
   }

        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();

        efa.setFileName('Order-'+order.AX_Order_ID__c+'_Invoice.pdf');
        
        efa.setBody(content); 
        
       
    
        email.setTargetObjectId(order.BillToContactId);
        email.setTemplateId('00X29000000QNPi');
        email.setWhatId(order.id);
        email.setToAddresses(new List<String>{'mayuripungi@gmail.com'});
     
        

        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
       
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Your email has been sent.');
        ApexPages.addMessage(msg);
        return null;
              }
                
        catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
                         }
    }

}