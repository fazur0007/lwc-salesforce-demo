public class MulberryCancellationRequestClass{

    public String cancelled_date;
    public String order_id;
    public List<Line_items> line_items;
    
    public class Line_items {
        public String product_id;
    }        
}