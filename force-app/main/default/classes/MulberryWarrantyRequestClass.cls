public class MulberryWarrantyRequestClass {

	public class Warranty {
		public Integer warranty_duration;
		public String warranty_price;
		public String warranty_id;
		public String warranty_program_id;
	}

	public Integer id;
	public String email;
	public String phone;
	public String cart_token;
	public List<Line_items> line_items;
	public Billing_address billing_address;

	public class Product_meta {
		public String field_name;
		public String field_value;
	}

	public class Line_items {
		public String product_id;
		public String product_price;
		public String product_title;
		public Warranty warranty;
		public List<Product_meta> product_meta;
	}

	public class Billing_address {
		public String first_name;
		public String last_name;
		public String address1;
		public String address2;
		public String phone;
		public String city;
		public String state;
		public String zip;
		public String country;
		public String country_code;
	}
}