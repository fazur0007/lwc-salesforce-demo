@isTest

public with sharing class ProductSearchHelperCtrltest {
    
       static testMethod void testProductSearchHelperCtrl(){
         Product2 productRecord = TestDataFactory.createProduct('Product1','BES920XL',true,false,false,15,true, false);
         productRecord.IsActive = true;
         insert productRecord;

         PageReference pageRef = Page.ProductSearchHelper;
	     Test.setCurrentPage(pageRef);
	                
         Test.Starttest();
          
         ProductSearchHelperCtrl productsearchCntrl = new ProductSearchHelperCtrl();
         pageRef.getParameters().put('q', 'Product1');
         productsearchCntrl.searchProduct();
           
         pageRef.getParameters().put('q', 'test');
         productsearchCntrl.searchProduct();
           
         Test.Stoptest();         
    }
}