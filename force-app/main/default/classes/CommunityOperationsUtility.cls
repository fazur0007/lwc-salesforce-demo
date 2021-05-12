public class CommunityOperationsUtility {
    public static List<Community_Login_Translations__mdt> doGetTranslations(){
        return [select id,DeveloperName,MasterLabel,ENCA__c,FRCA__c,ENUS__c from Community_Login_Translations__mdt];
    }
    public static Map<String,String> getTranlations(String experience){
        experience = String.isNotBlank(experience) ? experience : 'brevilleENUS';
        Map<String,String> mapOfTranslations = new Map<String,String>();
        for(Community_Login_Translations__mdt clt : doGetTranslations()){
            mapOfTranslations.put(clt.DeveloperName, experience.containsIgnoreCase('FRCA') ? clt.FRCA__c : experience.containsIgnoreCase('ENCA') ? clt.ENCA__c : clt.ENUS__c);
        }
    return mapOfTranslations;
    }
}