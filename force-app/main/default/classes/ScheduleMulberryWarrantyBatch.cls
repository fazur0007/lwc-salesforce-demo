global class ScheduleMulberryWarrantyBatch Implements Schedulable{        
    global void execute(SchedulableContext sc)            
    {
        BatchTriggerMulberryWarrantyRegistration objBatch = new BatchTriggerMulberryWarrantyRegistration();
        Database.executeBatch(objBatch, 1);
    }
}