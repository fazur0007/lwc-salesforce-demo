public class ErrorFinderController {
    public String failingPageResponse { get; set; }
    
    public void fetchFailingPage() {
       try {
           // Make a call to failing sites page here
           PageReference page = new PageReference('/apex/productregistrationWeb?param=US&language=en_US&brand=Breville');
           string content = page.getContent().toString(); 
           failingPageResponse =content;
       } catch (Exception e) {
           failingPageResponse = e.getTypeName() + ' : ' + e.getMessage() + ':' + e.getstacktracestring();
       }       
    }   
}