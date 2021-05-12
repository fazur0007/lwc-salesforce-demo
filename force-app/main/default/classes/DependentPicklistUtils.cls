public class DependentPicklistUtils {
 
    public class PickListInfo{
        public String validFor;
    }
    
    public static Map<string,string> getStateCodesForCountry(string objectName,string controllingField,string dependentField,string countryCode)
    {
        //String objectName, controllingField, dependentField;
        //objectName='Account';
        //controllingField = 'ShippingCountryCode';
        //dependentField = 'ShippingStateCode';
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
		//string countryCode = 'AU';
     	Map<string,string> mapStates = new Map<String,String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
     
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
     
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
     
        for(Schema.PicklistEntry currControllingValue : controllingValues){ 
            if(currControllingValue.getValue() == countryCode)
            	controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }
        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            
            String jsonString = JSON.serialize(currDependentValue);
         
            PickListInfo info = (PickListInfo) JSON.deserialize(jsonString, PickListInfo.class);
         
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
         
            Integer baseCount = 0;
         
            for(Integer curr : hexString.getChars()){
                Integer val = 0;
             
                if(curr >= 65){
                    val = curr - 65 + 10;
                }
                else{
                    val = curr - 48;
                }
             	
                    
                if((val & 8) == 8){
                    if(controllingValues[baseCount + 0].getValue() == countryCode)
                        mapStates.put(currDependentValue.getValue(),currDependentValue.getLabel());
                    //controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4){
                    if(controllingValues[baseCount + 1].getValue() == countryCode)
                        mapStates.put(currDependentValue.getValue(),currDependentValue.getLabel());
                    //controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                 
                }
                if((val & 2) == 2){
                    if(controllingValues[baseCount + 2].getValue() == countryCode)
                        mapStates.put(currDependentValue.getValue(),currDependentValue.getLabel());
                    //controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                 
                }
                if((val & 1) == 1){
                    if(controllingValues[baseCount + 3].getValue() == countryCode)
                        mapStates.put(currDependentValue.getValue(),currDependentValue.getLabel());
                    //controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                 
                }
             
                baseCount += 4;
            }         
        }

        system.debug('controllingInfo:'+controllingInfo);
        system.debug('mapStates:'+mapStates);
        return mapStates;
    }
 
    public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField){
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
     
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
     
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
     
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
     
        for(Schema.PicklistEntry currControllingValue : controllingValues){
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }
     
        for(Schema.PicklistEntry currDependentValue : dependentValues){
            String jsonString = JSON.serialize(currDependentValue);
         
            PickListInfo info = (PickListInfo) JSON.deserialize(jsonString, PickListInfo.class);
         
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
         
            Integer baseCount = 0;
         
            for(Integer curr : hexString.getChars()){
                Integer val = 0;
             
                if(curr >= 65){
                    val = curr - 65 + 10;
                }
                else{
                    val = curr - 48;
                }
             
                if((val & 8) == 8){
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4){
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                 
                }
                if((val & 2) == 2){
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                 
                }
                if((val & 1) == 1){
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                 
                }
             
                baseCount += 4;
            }         
        }
        return controllingInfo;
    }
}