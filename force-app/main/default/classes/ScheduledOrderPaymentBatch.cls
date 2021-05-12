/* 
* ScheduledOrderPaymentBatch is class which schedule order record batch

* Version       Author             Date                  Description 
*  1.0        Yogesh Sharma      1/13/2016             Initial Draft
*/
global class ScheduledOrderPaymentBatch implements Schedulable {

  global void execute(SchedulableContext sc) {
  OrderPaymentsBatch objOrderPaymentsBatch = new OrderPaymentsBatch ();
  Id jobid = Database.executebatch(objOrderPaymentsBatch ,2000);
 }

}