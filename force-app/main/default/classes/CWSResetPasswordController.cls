public without sharing class CWSResetPasswordController {


    public Boolean resetComplete{get;set;}
    public Boolean showError{get;set;}
    public String newPassword{get;set;}
    public String verifyNewPassword{get;set;}
    public STring errorMessage{get;set;}
     String token{get;set;}
     String experienceId{get;set;}

    public CWSResetPasswordController() {
        resetComplete = false;
        showERror=false;
        this.token = ApexPages.currentPage().getParameters().get('token');
        this.experienceId = ApexPages.currentPage().getParameters().get('experience_id');
        if (String.isBlank(this.token)){
            showError = true;
            errorMessage = 'Something went wrong.  You are unable to set your password at this time.';
        }

    }

    public PageReference resetPassword(){

        if(newPassword == verifyNewPassword){
            try{
                System.debug('The token is: ' + this.token);
            CWSIdentityRequest.PasswordResetCompletionRequest req = new 
                CWSIdentityRequest.PasswordResetCompletionRequest(this.token,newPassword);
            
            CWSIdentitySErvice.getInstance().completePasswordReset(req);
            resetComplete = true;
            showERror=false;
            }
            catch(CWSIdentityPasswordPolicyException ppe){

                resetComplete = false;
                showError = true;
                System.debug('MESSAGE: '+ppe.getMessage());
                if( ppe.getMessage().contains('INVALID_NEW_PASSWORD:')){
                    errorMessage = ppe.getMessage().substringAfter('INVALID_NEW_PASSWORD:');
                }
                else if(ppe.getMessage().containsIgnoreCase('invalid repeated password') ){
                    errorMessage = 'please try a different password. You cannot use a password you have used previously.';
                }
                else{
                    errorMessage=ppe.getMessage();
                }
            }
          
            catch(Exception e){
                resetComplete=false;
                showError=true;
                errorMessage = 'oops. something went wrong.';
                System.debug('ERROR MESSAGE:' + e.getMessage());
             
            }
        }
        else{
            showError=true;
            errorMessage ='Please make sure your passwords are the same.';
        }
      
        ApexPages.currentPage().getParameters().put('token',this.token);
        ApexPages.currentPage().getParameters().put('experience_id',this.experienceId);
        return null;
    }
}