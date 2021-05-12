/**
 * This class is a driver class on the cases trigger. This class will populate
 * the cost of the items on the case as well as create the order block if any of
 * the items have been changed.
 *
 * @author james@highondemand.com
 * @version 1.0
 * @since February 4, 2013
 */
public class ModifiedOrderBlock {
/*
    private Map<Id, Product2> prodMap;
    private Set<Id> pids;

 
    /**
     * This method updates the order block by first blanking the field and then
     * overwriting by calling the create1stitem or craeateLineItem methods. Because
     * the first line item is different it has its own method. The values are
     * put into a string list so the createLineItem function will work for
     * the remaining line items.
     */
/*    public void updateOrderBlock(Case[] cases){
    	pids = new Set<Id>();
    	Boolean addCase = false;
        for(Case c : cases){
        	pids.add(c.Item_1__c);
            pids.add(c.Item_2__c);
            pids.add(c.Item_3__c);
            pids.add(c.Item_4__c);
            pids.add(c.Item_5__c);
         
        }
        pids.remove(null);
        
        for(Case c :cases){
            c.Order_Block__c = '';
            if(c.Item_1__c != null){
                String[] values = new String[0];
                values.add(getprodMap().get(c.Item_1__c).Description);
                values.add(getProdMap().get(c.Item_1__c).Name);
                values.add(String.valueOf(c.Item_1_Qty__c));
                values.add(String.valueOf(c.Item_1_Cost__c));
                values.add(c.CurrencyIsoCode);
                c.Order_Block__c += create1stItem(values);
            }
            if(c.Item_2__c != null){
                String[] values = new String[0];
                values.add(getprodMap().get(c.Item_2__c).Description);
                values.add(getProdMap().get(c.Item_2__c).Name);
                values.add(String.valueOf(c.Item_2_Qty__c));
                values.add(String.valueOf(c.Item_2_Cost__c));
                values.add(c.CurrencyIsoCode);
                c.Order_Block__c += createLineItem(values);
            }
            if(c.Item_3__c != null){
                String[] values = new String[0];
                values.add(getprodMap().get(c.Item_3__c).Description);
                values.add(getProdMap().get(c.Item_3__c).Name);
                values.add(String.valueOf(c.Item_3_Qty__c));
                values.add(String.valueOf(c.Item_3_Cost__c));
                values.add(c.CurrencyIsoCode);
                c.Order_Block__c += createLineItem(values);
            }
            if(c.Item_4__c != null){
                String[] values = new String[0];
                values.add(getprodMap().get(c.Item_4__c).Description);
                values.add(getProdMap().get(c.Item_4__c).Name);
                values.add(String.valueOf(c.Item_4_Qty__c));
                values.add(String.valueOf(c.Item_4_Cost__c));
                values.add(c.CurrencyIsoCode);
                c.Order_Block__c += createLineItem(values);
            }
            if(c.Item_5__c != null){
                String[] values = new String[0];
                values.add(getprodMap().get(c.Item_5__c).Description);
                values.add(getProdMap().get(c.Item_5__c).Name);
                values.add(String.valueOf(c.Item_5_Qty__c));
                values.add(String.valueOf(c.Item_5_Cost__c));
                values.add(c.CurrencyIsoCode);
                c.Order_Block__c += createLineItem(values);
            }
        }
    }

    private Integer safeInt(String val) {
        return (val == null || val == '' ? 0 : Integer.valueOf(val));
    }

    private Decimal safeDecimal(String val) {
        return (val == null || val == '' ? 0 : Decimal.valueOf(val));
    }


    /**
     * Hard coded text to display data in the order_block field on the case.
     * This method works for all but the first line.
     */
 /*   private String createLineItem(String[] values){
        String block = '==================================================';
        block += '\n';
        block += '\nDescription  = '+values[0];
        block += '\n'+values[1];
        block += '\nQuantity     = ' + safeInt(values[2]);
        block += '\nUnit Price   = '+values[4]+' ' + safeDecimal(values[3]).setScale(2);
        block += '\nSale Price   = '+values[4]+' ' + safeDecimal(values[3]).setScale(2);
        block += '\nUnit Total   = '+values[4]+' ' + safeDecimal(values[2]) * safeDecimal(values[3]).setScale(2);
        block += '\n \n';
        return block;
    }

    /**
     * This method creates the first line for the order block field.
     */
 /*   private String create1stItem(String[] values){
        String block = 'Order Product Detail';
        block += '\n==================================================';
        block += '\nDescription  = '+values[0];
        block += '\n'+values[1];
        block += '\nQuantity     = ' + safeInt(values[2]);
        block += '\nUnit Price   = '+values[4]+' ' + safeDecimal(values[3]).setScale(2);
        block += '\nSale Price   = '+values[4]+' ' + safeDecimal(values[3]).setScale(2);
        block += '\nUnit Total   = '+values[4]+' ' + safeDecimal(values[2]) * safeDecimal(values[3]).setScale(2);
        block += '\n \n';
        return block;
    }

 
    /**
     * This method returns the Map of ids to products.
     */
  /*  private Map<Id, Product2> getProdMap(){
        if(prodMap == null){
            prodMap = new Map<Id, Product2>(queryForProducts(pids));
        }
        return prodMap;
    }

    /**
     * Queries for the product data necessary to populate the cost field and teh
     * Order_Block field.
     */
  /*  private Product2[] queryForProducts(Set<Id> pids){
        return [SELECT Id, MAP__c, Description, Name
                FROM Product2
                WHERE Id IN :pids];
    }

    @isTest(SeeAllData=true)
        static void testAll()
        {
        	RecordType objRecordType = [select id from RecordType where isActive=:true AND DeveloperName =: 'New_Case' AND sobjectType =: 'Case'];
			system.debug('******objRecordType: '+objRecordType);
			
			Product2 objProduct2 = new Product2();
			objProduct2.Name = 'Test Product';
			//objProduct2.SKU__c = 'test sku';
			objProduct2.CurrencyIsoCode = 'CAD';
			objProduct2.Country_Code__C = 'CAN';
			//objProduct2.Breville_US_Product__c = true;
			objProduct2.Spare_Part__c = false;
			insert objProduct2;
			
			
			Account objAccount = new Account();
			objAccount.Name ='Test Account';
			insert objAccount;
			
			Case objCase =  new case();
			objCase.AccountId = objAccount.Id;
			objCase.Product__c = objProduct2.id;
			objCase.Status = 'Open';
			objCase.Origin = 'Email';
			objCase.Type = 'Feedback';
			objCase.Complaint_Code__c = 'Dented';
			objCase.CurrencyIsoCode = 'CAD';
			objCase.Sub_Complaint_Code__c = 'ERROR 1';
			objCase.Subject = 'Test Subject';
			insert objCase; 
		
        TestObjects to = new TestObjects();
        Account acct = to.getAccount(true);
       // Product2 prod = to.getProduct(true);
        
        
        /*Case c = to.getCase2(acct.Id, objProduct2.id, false);
        objCase.CurrencyIsoCode = 'CAD';
        c.Item_1__c = objProduct2.id;
        c.Item_1_Qty__c = 1;
        c.Item_2__c = objProduct2.id;
        c.Item_2_Qty__c =2;
        c.Item_3__c = objProduct2.id;
        c.Item_3_Qty__c = 3;
        c.Item_4__c = objProduct2.id;
        c.Item_4_Qty__c = 4;
        c.Item_5__c = objProduct2.id;
        c.Item_5_Qty__c = 5;
        insert c;
       */
          
  /*        Case[] cases = new Case[0];
          cases.add(objCase);          
         ModifiedOrderBlock mob = new ModifiedOrderBlock();
         mob.updateOrderBlock(cases);
         
          

    }
*/

}