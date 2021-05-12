public class BrevilleWelcomeCmpController {
    @AuraEnabled
    public static List<CheckBoxDataWrapper> getMandatoryDetails() {
        List<CheckBoxDataWrapper> checkboxDataWrapperList = new List<CheckBoxDataWrapper>(); 
        String label1 = 'YES, I have purchased a participating product/s between Sunday 1st November 2020 and Thursday 31st December 2020';
        String label2 = 'YES, the purchase was made from a participating retailer';
        String label3 = 'YES, I have a receipt to show my purchase. This receipt must show the model number, purchase date and an outstanding balance of $0.00 to be valid';
        CheckBoxDataWrapper checkBox1 = new CheckBoxDataWrapper();
        CheckBoxDataWrapper checkBox2 = new CheckBoxDataWrapper();
        CheckBoxDataWrapper checkBox3 = new CheckBoxDataWrapper();
        checkBox1.label = label1;
        checkBox1.value = label1;
        checkBox2.label = label2;
        checkBox2.value = label2;
        checkBox3.label = label3;
        checkBox3.value = label3;
        checkboxDataWrapperList.add(checkBox1);
        checkboxDataWrapperList.add(checkBox2);
        checkboxDataWrapperList.add(checkBox3);
        return checkboxDataWrapperList;
    }
    public class CheckBoxDataWrapper {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }
}