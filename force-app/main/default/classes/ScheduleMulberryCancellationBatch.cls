global class ScheduleMulberryCancellationBatch Implements Schedulable{
    global void execute(SchedulableContext sc)            
    {
        BatchTriggerMulberryWarrantyCancellation objBatch = new BatchTriggerMulberryWarrantyCancellation();
        Database.executeBatch(objBatch, 1);
    }
}