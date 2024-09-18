package Model;

public class booking_charges {
private booking booking_id;
private double total_room_charges;
private double total_order_charges;
private double total_booking_charges;
public booking_charges(booking booking_id, double total_room_charges, double total_order_charges,
		double total_booking_charges) {
	super();
	this.booking_id = booking_id;
	this.total_room_charges = total_room_charges;
	this.total_order_charges = total_order_charges;
	this.total_booking_charges = total_booking_charges;
}
public booking getBooking_id() {
	return booking_id;
}
public void setBooking_id(booking booking_id) {
	this.booking_id = booking_id;
}
public double getTotal_room_charges() {
	return total_room_charges;
}
public void setTotal_room_charges(double total_room_charges) {
	this.total_room_charges = total_room_charges;
}
public double getTotal_order_charges() {
	return total_order_charges;
}
public void setTotal_order_charges(double total_order_charges) {
	this.total_order_charges = total_order_charges;
}
public double getTotal_booking_charges() {
	return total_booking_charges;
}
public void setTotal_booking_charges(double total_booking_charges) {
	this.total_booking_charges = total_booking_charges;
}

}
