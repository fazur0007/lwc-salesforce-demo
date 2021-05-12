public class ProductRegisterController{

@AuraEnabled
public static List<Product2> getProductSubConfi() { 
   
    String countryCode = 'US';
    String brand = 'Breville'; 
    String language = 'en_US';
    
    String query = 'SELECT Product_Sub_Family__c subCategory ' +
        ' FROM Product2 ' +
        '  WHERE Finished_Good__c = true ' +
        ' AND IsActive = true ' + 
        ' AND Spare_Part__c = false ' + 
        ' AND Exclude_from_Sync__c = false ';
     

    
    List<Product2> subCategoryList = Database.query(query);
     System.Debug('subCategoryList*****'+subCategoryList) ;
     if(subCategoryList == null)
     subCategoryList = [Select Name,Product_Sub_Family__c  from Product2 LIMIT 20];
     
     System.Debug('subCategoryList2*****'+subCategoryList) ;

    return subCategoryList;
}

@AuraEnabled
public static List<Product2> getAllProducts(){
List<Product2> productList = [Select Name,Product_Sub_Family__c ,GlobalLanguageID__c from Product2 LIMIT 20];

return productList;
}

@AuraEnabled
public static List<String> getModels(String productId){

List<String> models = new List<String>();
if(productId == '01t0L00000Ac62oQAB'){
models.add('abc');
models.add('dce');
}
if(productId == '01t0L00000Ac62YQAR'){
models.add('Second1');
models.add('Second2');
}

return models;
}


@AuraEnabled
public static List<ItemWrapper> getOffers(){
String productCodeOrCategoryFilter,productCode;

Set<String> plmStatusNotStartsWith = new Set<String>{'01%', '00%', '99%', '04%'}; 

List<SelectOption> options = new List<SelectOption>();
List<ItemWrapper> productSubCategories = new List<ItemWrapper>();
List<Offer__c> lstOffers =  [select id,MultipleProducts__c from Offer__c where OfferCode__c='AusMothersDay2021' and Active__c=true];

if(lstOffers.size()>0)

{

        for(Offer__c ObjOffer:lstOffers)

        {

                        if(String.IsNotBlank(ObjOffer.MultipleProducts__c))

                        {

                                        String strMulProd = ObjOffer.MultipleProducts__c;

                                        strMulProd = strMulProd.replaceAll(';','\',\'');

                                        strMulProd = strMulProd.removeEnd(',\'').removeStart('\',');

                                        if(String.isNotBlank(productCode))

                                        {

                                                        productCode = productCode + ',' + strMulProd;

                                        }

                                        else

                                        {

                                                        productCode = strMulProd;

                                        }

                                        system.debug('strMulProd:'+strMulProd);           

                        }                             

        }

        system.debug('productCode:'+productCode);

        productCodeOrCategoryFilter =  'AX_Item_Number__c IN('+productCode+')';

}

system.debug('productCodeOrCategoryFilter:'+productCodeOrCategoryFilter);

Map<string,string> result = CommunityUserManagementUtility.GetUserAttributesFromExpId('BrevilleENAU');

string regionCode = Utility.fetchRegionCodeFromEPRegion(result.get('Locale').right(2));

system.debug('regionCode:'+regionCode);

options = Utility.fetchProductSubcategories(regionCode, result.get('Brand'),plmStatusNotStartsWith ,productCodeOrCategoryFilter,result.get('Locale'));
for(SelectOption product:options){
ItemWrapper item = new ItemWrapper();
item.value = product.getValue();
item.label = product.getLabel();
item.disabled = product.getDisabled();
productSubCategories.add(item);
}

return productSubCategories;

}

public class ItemWrapper{
@AuraEnabled
public String value{get; set;}
@AuraEnabled
public String label{get; set;}
@AuraEnabled
public Boolean disabled{get; set;}
}
public class Product {
    
    public String Name;
    public String Description;
    public String ProductId;
}

}