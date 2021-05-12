@isTest(SeeAllData = true)
public class TaxRateTest {
    

 public static id worectypeID = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get(system.Label.Record_Type_Work).getRecordTypeId();
 
    
    public static Account accData(){
        Account objAccount = new Account();
        objAccount.Name = 'Test';
        objAccount.ShippingStreet = 'GEORGIA ST';
        objAccount.ShippingCity = 'VANCOUVER';
        objAccount.ShippingStateCode = 'CA'; 
        objAccount.ShippingCountryCode = 'US';
        objAccount.ShippingPostalCode = '123';
        objAccount.BillingPostalCode = '123';
        insert objAccount;
        return objAccount;
    } 

    public static Tax_Rate__c taxRateData(){
        Tax_Rate__c objTaxRate = new Tax_Rate__c();
        objTaxRate.Name = '123';
        objTaxRate.CurrencyIsoCode = 'USD';
        objTaxRate.GST_Tax_Rate__c = 4.00;
        objTaxRate.Provincial_Tax_Rate__c = 6.00;
        objTaxRate.CitySalesTaxRate__c = 1.00;
        objTaxRate.County_Sales_Tax_Rate__c = 1.00;
        objTaxRate.SpecialSalesTaxRate__c  = 1.00;
        objTaxRate.Combined_Rate__c = 7.00;
        objTaxRate.City_Use_Tax_Rate__c  = 1.00;
        objTaxRate.CitySalesTaxRate__c = 1.00;
        objTaxRate.County_Sales_Tax_Rate__c = 1.00;
        objTaxRate.CountyUseTaxRate__c = 1.00;
        objTaxRate.Provincial_Tax_Rate__c = 1.00;
        objTaxRate.StateUseTaxRate__c = 1.00;
        objTaxRate.SpecialSalesTaxRate__c = 1.00;
        objTaxRate.SpecialUseTaxRate__c = 1.00;
        objTaxRate.CombinedUseTaxRate__c = 1.00;
        insert objTaxRate;
        return objTaxRate;
    }
    
     public static Tax_Rate__c taxRateData1(){
        Tax_Rate__c objTaxRate = new Tax_Rate__c();
        objTaxRate.Name = '123';
        objTaxRate.CurrencyIsoCode = 'USD';
        objTaxRate.GST_Tax_Rate__c = null;
        objTaxRate.Provincial_Tax_Rate__c = null;
        objTaxRate.CitySalesTaxRate__c = null;
        objTaxRate.County_Sales_Tax_Rate__c = null;
        objTaxRate.SpecialSalesTaxRate__c  = null;
        objTaxRate.Combined_Rate__c = null;
        objTaxRate.City_Use_Tax_Rate__c  = null;
        objTaxRate.CitySalesTaxRate__c = null;
        objTaxRate.County_Sales_Tax_Rate__c = null;
        objTaxRate.CountyUseTaxRate__c = null;
        objTaxRate.Provincial_Tax_Rate__c = null;
        objTaxRate.StateUseTaxRate__c = null;
        objTaxRate.SpecialSalesTaxRate__c = null;
        objTaxRate.SpecialUseTaxRate__c = null;
        objTaxRate.CombinedUseTaxRate__c = null;
        insert objTaxRate;
        return objTaxRate;
    }        
     public static Case caseData1(){
        Account objAccount = new Account();
        objAccount.Name = 'Test';
        objAccount.ShippingStreet = 'GEORGIA ST';
        objAccount.ShippingCity = 'VANCOUVER';
        objAccount.ShippingStateCode = 'CA';
        objAccount.ShippingCountryCode = 'US';
        objAccount.ShippingPostalCode = '123';
        insert objAccount;
        Case objCase1 = new Case();
        objCase1.recordTypeId='012E00000005a80';
        objCase1.AccountId = objAccount.Id;
        objCase1.Type = 'Feedback';
        objCase1.CurrencyIsoCode = 'USD';
        objCase1.Origin = 'Email';
        objCase1.Status = 'Open';
        objCase1.CurrencyIsoCode = 'USD';
        objCase1.Complaint_Code__c='Dented';
        objCase1.Sub_Complaint_Code__c='Dented, Back';
        objCase1.Subject = 'Test123';
        return objCase1;
    }
    
    public static WorkOrder workorderData1(){
        Account objAcc = accData();
        Case objCs = caseData1();
        insert objCs;
        WorkOrder objWorkOrder = new WorkOrder();
        objWorkOrder.recordTypeId = worectypeID ;
        objWorkOrder.AccountId = objAcc.Id;
        objWorkOrder.CurrencyIsoCode = 'USD';
        objWorkOrder.Status = 'New';
        objWorkOrder.ServiceCentre__c = objAcc.Id;
        objWorkOrder.Product__c = '01tE0000001U2Pb';//01tE0000001U2f3
        objWorkOrder.CaseId = objCs.id;
        return objWorkOrder;  
    }
    
      public static WorkOrder workorderData2(){
        Account objAcc = accData();
        Case objCs = caseData1();
        insert objCs;
        WorkOrder objWorkOrder = new WorkOrder();
        objWorkOrder.recordTypeId = worectypeID ;
        objWorkOrder.AccountId = objAcc.Id;
        objWorkOrder.CurrencyIsoCode = 'USD';
        objWorkOrder.Status = 'New';
        objWorkOrder.ServiceCentre__c = objAcc.Id;
        objWorkOrder.Product__c = '01tE0000001U2Pb';//01tE0000001U2f3
        objWorkOrder.CaseId = objCs.id;
        return objWorkOrder;  
    }
    
    
  public static Order orderData1(){
        Account objAcc = accData();
        Order objOrder1 = new Order();
        objOrder1.AccountId = objAcc.Id;
        //objOrder1.recordTypeId = rectypeID;
        objOrder1.Type = 'Sale';
        objOrder1.Status = 'Open';
        objOrder1.eComm__c = false;
        objOrder1.ShippingCity = 'VANCOUVER';
        objOrder1.ShippingCountryCode = 'US';
        objOrder1.ShippingStateCode = 'CA';
        objOrder1.ShippingStreet = 'GEORGIA ST';
        objOrder1.ShippingPostalCode = '123';
        objOrder1.EffectiveDate = system.today();
        objOrder1.CurrencyIsoCode = 'USD';
        return objOrder1;
    }
    public static Order orderData2(){
        Account objAcc = accData();
        Order objOrder1 = new Order();
        objOrder1.AccountId = objAcc.Id;
        //objOrder1.recordTypeId = rectypeID;
        objOrder1.Type = 'Sale';
        objOrder1.Status = 'Open';
        objOrder1.eComm__c = false;
        objOrder1.ShippingCity = 'VANCOUVER';
        objOrder1.ShippingCountryCode = 'US';
        objOrder1.ShippingStateCode = 'CA';
        objOrder1.ShippingStreet = 'GEORGIA ST';
        objOrder1.ShippingPostalCode = '123';
        objOrder1.EffectiveDate = system.today();
        objOrder1.CurrencyIsoCode = 'USD';
        return objOrder1;
    }

    static testMethod void Ordertest() {
        test.startTest();
        taxRateData();
        Order objOrder1 = orderData1();
        Taxrate tr = new Taxrate();
        system.debug(objOrder1);
        tr.filterOrders(objOrder1);
        insert objOrder1;
        taxRateData1();
        Order objOrder2 = orderData2();
        Taxrate tr1 = new Taxrate();
        system.debug(objOrder2);
        tr1.filterOrders(objOrder2);
        insert objOrder2;
        
        objOrder2.Tax_Exempt_Order__c = true;
        upsert objOrder2;
        tr1.filterOrders(objOrder2);
        
        objOrder2.CurrencyIsoCode = 'NZD';
        upsert objOrder2;
        //tr1.filterOrders(objOrder2);
      
        
        Tax_Rate__c tax = TaxRateUtility.findAppropriateTaxRateRecord('NZD', objOrder2,  accData());
        
        test.stopTest();
	}
    
	static testMethod void WorkOrdertest() {    
        test.startTest();
         Case objCs1 = caseData1();
        insert objCs1;
        taxRateData();
        WorkOrder objWorkOrder = workorderData1();
        objWorkOrder.ServiceCentre__c = accData().Id;
        insert objWorkOrder; 
         WorkOrder wo= [select id,AccountId,CurrencyIsoCode,ServiceCentre__c,ServiceCentre__r.ShippingPostalCode from WorkOrder where id= : objWorkOrder.id];
        Taxrate tr2 = new Taxrate();
        tr2.filterWorkOrders(objWorkOrder, accData()); 
        Case objCs2 = caseData1();
        insert objCs2;
        taxRateData1();
        WorkOrder objWorkOrder1 = workorderData1();
        objWorkOrder1.ServiceCentre__c = accData().Id;
        insert objWorkOrder1;
        WorkOrder wo1= [select id,AccountId,CurrencyIsoCode,ServiceCentre__c,ServiceCentre__r.ShippingPostalCode from WorkOrder where id= : objWorkOrder1.id];
        Taxrate tr3 = new Taxrate();
        tr3.filterWorkOrders(objWorkOrder1, accData());
        objWorkOrder1.ExemptTaxDueToStateCode__c = true;
        update objWorkOrder1;
        tr3.filterWorkOrders(objWorkOrder1, accData());
        tr3.filterWorkOrders(objWorkOrder1, accData());
        tr3.filterWorkOrders(objWorkOrder1, accData());
        test.stopTest();
	}
}