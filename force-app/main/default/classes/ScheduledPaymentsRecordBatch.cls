/* 
* ScheduledPaymentsRecordBatch is class which schedule payment record batch

* Version       Author             Date                  Description 
*  1.0        Yogesh Sharma      1/29/2016             Initial Draft
*/
global class ScheduledPaymentsRecordBatch implements Schedulable {

  global void execute(SchedulableContext sc) {
  PaymentsRecordBatch objPaymentsRecordBatch = new PaymentsRecordBatch();
  Id jobid = Database.executebatch(objPaymentsRecordBatch ,2000);
 }

}