public class AccountOrderCreateFlowController{
   
   public List<Order> lstOrder { get; set; }
   
   
   private Id AccountId;
 
    
    //Constructor
    public AccountOrderCreateFlowController() {
        
    }

   public pageReference getOrderId(){
       
        PageReference reRedirect;
        lstOrder = new List<Order>();
        AccountId = Apexpages.currentpage().getparameters().get('id');
        
        if (AccountId!= null) {
            lstOrder = [Select id 
                          From Order 
                            where AccountId =: AccountId order by CreatedDate desc limit 1];
            if (!lstOrder.IsEmpty() && lstOrder!= null) {
                reRedirect = new PageReference('/_ui/busop/orderitem/SelectSearch?addTo=' + lstOrder[0].Id);
                reRedirect.setRedirect(false);
            }
        }
        return reRedirect ;
    }
}