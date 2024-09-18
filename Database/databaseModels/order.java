package Model;

public class order {
private String order_id;
private booking booking_id;
private String order_description;
private double total_price;
public order(String order_id, booking booking_id, String order_description, double total_price) {
	super();
	this.order_id = order_id;
	this.booking_id = booking_id;
	this.order_description = order_description;
	this.total_price = total_price;
}
public String getOrder_id() {
	return order_id;
}
public void setOrder_id(String order_id) {
	this.order_id = order_id;
}
public booking getBooking_id() {
	return booking_id;
}
public void setBooking_id(booking booking_id) {
	this.booking_id = booking_id;
}
public String getOrder_description() {
	return order_description;
}
public void setOrder_description(String order_description) {
	this.order_description = order_description;
}
public double getTotal_price() {
	return total_price;
}
public void setTotal_price(double total_price) {
	this.total_price = total_price;
}

}
