/* 
* BrevilleRMAComponentController is class which is called by VF component Named 'BrevilleRMAComponent'.
* Functionality: To get the Case, RMA Products, Account and Contact information to be used in VF template.
* Version       Author             Date                  Description 
*  1.0        Yogesh Sharma      09/09/2016             Initial Draft
*/
public class BrevilleRMAComponentController {

    public string caseId{get;set;}
    public Case objCase{get;set;}
    public list<RMA_Product__c> lstRMAProduct {get;set;}
    //Constrctor
    public BrevilleRMAComponentController () { 
    }
    //get the case and its related RMA Product to display on Visual force template
    public void getinit() {
        if(caseId<> NULL && caseId<> ''){ 
            lstRMAProduct = new list<RMA_Product__c>();
            objCase= new Case();
            objCase= [SELECT CaseNumber,Account.Name, Account.VendAccount__c, Account.Phone,
                             Account.Fax, Account.ShippingStreet, Account.ShippingCity,
                             Account.ShippingState, Account.ShippingPostalCode,
                             Account.ShippingCountry, Contact.Email,
                             Account.BillingStreet, Account.BillingCity,
                             Account.BillingState, Account.BillingPostalCode,
                             Account.BillingCountry,Return_Address__c,
                             RTV__c, Requested_Product_Value__c, RequestedProductValue__c,
                             Return_Product_Required__c, Destroy_in_Field__c,
                             Other_Action__c, Other_Action_Description__c,
                             Return_Location__c,CurrencyIsoCode,
                             Return_Ready_Date__c, Return_Carrier__c,
                             Return_Tracking__c, Consignee_Contact_Name__c,
                             Consignee_Phone__c, Return_Freight_BOL_No__c,
                             Return_Pro_No__c, Freight_Reference__c,
                             Carton_Count__c, Stackable_Freight__c,
                             Pallet_Gaylord_Count__c, Return_Load_Weight__c,
                             Return_Freight_DIMS__c,RMATotalCreditValue__c
                         FROM Case WHERE Id =:caseId];
         lstRMAProduct = [SELECT Quantity__c,
                                 Price__c,Case_Currency__c,
                                 Product__r.Name,
                                 Product__r.Description
                            FROM RMA_Product__c
                           WHERE Case__c =:caseId];
         }// end if
    }// end getinit
}// end class BrevilleRMAComponentController