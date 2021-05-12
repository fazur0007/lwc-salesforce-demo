public class TroubleshootHelper {
    @Auraenabled
    public static FlowOutput GetFlowName(Id CaseId)
    {
        Case caseObj = [select Product__c,complaint_code__c,Type from case where id=:CaseId];
        FlowOutput ObjOutput = new FlowOutput();    
        ObjOutput.isError = false;
        if(string.isBlank(caseObj.Product__c))
        {
            ObjOutput.isError = true;
            ObjOutput.ErrorMessage = 'Please associate a product to the case';
            return ObjOutput;
        }
        else if(String.isNotBlank(caseObj.Type) && !caseObj.Type.equalsIgnoreCase('Support & Service'))
        {
            system.debug('caseObj.Type:'+caseObj.Type);
            ObjOutput.isError = true;
            ObjOutput.ErrorMessage = 'Troubleshoot flow can only be executed on \'Support & Service\' cases';
            return ObjOutput;
        }
        Id ProductId = caseObj.Product__c;
        string ComplaintCode = caseObj.complaint_code__c;
        List<Product2> productlist = [SELECT Id, Family, Product_Sub_Family__c FROM Product2 where Id = :ProductId];
        string category = productlist[0].Family;
        system.debug('category:'+category);
        //string subCategory = products[0].Product_Sub_Family__c.replace(/'/g, "");
        string subCategory = productlist[0].Product_Sub_Family__c;
        system.debug('subCategory:'+subCategory);
        string query = 'SELECT Flow_Name__c, Product__c, Product_Category__c, Product_Sub_Category__c, Complaint_Code__c from Trouble_Shoot_Flow_Mapping__c where Product__c=\'' + ProductId +'\' ';
        if(string.IsNotBlank(category))
        {
            query = query + ' OR Product_Category__c = \'' + category + '\' ';
        }
        if(string.IsNotBlank(subCategory))
        {
            query = query + ' OR Product_Sub_Category__c= \'' + subCategory + '\'';
        }
        List<Trouble_Shoot_Flow_Mapping__c> troubleShootings = Database.query(query);
        if(troubleShootings.size() > 0)
        {
            string productFlowName = '';
            string productFlowNameWithComplaintCode = '';
            string subCategoryFlowName = '';
            string subCategoryFlowNameWithComplaintCode = '';
            string categoryFlowName = '';
            string categoryFlowNameWithComplaintCode = '';
            for(Trouble_Shoot_Flow_Mapping__c currTBFM:troubleShootings) 
            {
                if(string.isNotBlank(currTBFM.Product__c) && currTBFM.Product__c == productId && (string.isBlank(currTBFM.Complaint_Code__c) || (currTBFM.Complaint_Code__c != null && currTBFM.Complaint_Code__c == '')))
                {
                    productFlowName = currTBFM.Flow_Name__c;
                }
                if(((currTBFM.Product_Sub_Category__c != null && currTBFM.Product_Sub_Category__c != '' && subCategory != null && subCategory != '' && currTBFM.Product_Sub_Category__c.toUpperCase() == subCategory.toUpperCase())|| (currTBFM.Product_Sub_Category__c == subCategory)) && (currTBFM.Complaint_Code__c == null || (currTBFM.Complaint_Code__c != null && currTBFM.Complaint_Code__c == '')) && (currTBFM.Product__c == null || (currTBFM.Product__c != null && currTBFM.Product__c == '')))
                {
                    subCategoryFlowName = currTBFM.Flow_Name__c;
                }
                if(((currTBFM.Product_Category__c != null && currTBFM.Product_Category__c != '' && category != null && category != '' && currTBFM.Product_Category__c.toUpperCase() == category.toUpperCase()) || (currTBFM.Product_Category__c == category)) &&(currTBFM.Complaint_Code__c == null || (currTBFM.Complaint_Code__c != null && currTBFM.Complaint_Code__c == '')) && (currTBFM.Product__c == null || (currTBFM.Product__c != null && currTBFM.Product__c == '')) && (currTBFM.Product_Sub_Category__c == null || (currTBFM.Product_Sub_Category__c != null && currTBFM.Product_Sub_Category__c == '')))
                {
                    categoryFlowName = currTBFM.Flow_Name__c;
                }
                if(ComplaintCode != null && ComplaintCode != '' && currTBFM.Complaint_Code__c != null)
                {
                    if(string.isNotBlank(currTBFM.Product__c) && currTBFM.Product__c == productId && currTBFM.Complaint_Code__c.equalsIgnoreCase(ComplaintCode))
                    {
                        productFlowNameWithComplaintCode = currTBFM.Flow_Name__c;
                    }
                    if(((String.isNotBlank(currTBFM.Product_Sub_Category__c) && String.isNotBlank(subCategory) && currTBFM.Product_Sub_Category__c.equalsIgnoreCase(subCategory.toUpperCase()) )||(currTBFM.Product_Sub_Category__c == subCategory)) && currTBFM.Complaint_Code__c == complaintCode && string.IsBlank(currTBFM.Product__c))
                    {
                        subCategoryFlowNameWithComplaintCode = currTBFM.Flow_Name__c;
                    }
                    if(((currTBFM.Product_Category__c != null && currTBFM.Product_Category__c != '' && category != null && category != '' && currTBFM.Product_Category__c.toUpperCase() == category.toUpperCase()) ||(currTBFM.Product_Category__c == category)) && currTBFM.Complaint_Code__c == complaintCode && string.IsBlank(currTBFM.Product__c) && (currTBFM.Product_Sub_Category__c == null || (currTBFM.Product_Sub_Category__c != null && currTBFM.Product_Sub_Category__c == '')))
                    {
                        categoryFlowNameWithComplaintCode = currTBFM.Flow_Name__c;
                    }
                }
            }
            
            if(string.isNotBlank(productFlowNameWithComplaintCode))
            {
                ObjOutput.Name = productFlowNameWithComplaintCode;                
            }
            else if(string.isNotBlank(subCategoryFlowNameWithComplaintCode))
            {
                ObjOutput.Name = subCategoryFlowNameWithComplaintCode;
            }
            else if(string.isNotBlank(categoryFlowNameWithComplaintCode))
            {
                ObjOutput.Name = categoryFlowNameWithComplaintCode;
            }
            else if(string.isNotBlank(productFlowName))
            {
                ObjOutput.Name = productFlowName;
            }
            else if(string.isNotBlank(subCategoryFlowName))
            {
                ObjOutput.Name = subCategoryFlowName;
            }
            else if(string.isNotBlank(categoryFlowName))
            {
                ObjOutput.Name = categoryFlowName;
            }
            else
            {
                ObjOutput.isError = true;
                ObjOutput.ErrorMessage = 'There is no Troubleshoot Flow associated to this product';
            }
            return ObjOutput;
        }
        ObjOutput.isError = true;
        ObjOutput.ErrorMessage = 'There is no Troubleshoot Flow associated to this product';
        return ObjOutput;
    }
    public class FlowOutput {
        
        @AuraEnabled public Boolean isError { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String ErrorMessage { get; set; }
        
        public FlowOutput(Boolean isError, String name,string ErrorMessage) {
            this.isError = isError;
            this.Name = name;
            this.ErrorMessage = ErrorMessage;
        }
        public FlowOutput() {}
    }
}