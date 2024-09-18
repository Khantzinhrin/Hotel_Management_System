package Model;

public class charges_for_food {
private booking booking_id;
private double Allfood_total_charges;
public booking getBooking_id() {
	return booking_id;
}
public void setBooking_id(booking booking_id) {
	this.booking_id = booking_id;
}
public double getAllfood_total_charges() {
	return Allfood_total_charges;
}
public void setAllfood_total_charges(double allfood_total_charges) {
	Allfood_total_charges = allfood_total_charges;
}
public charges_for_food(booking booking_id, double allfood_total_charges) {
	super();
	this.booking_id = booking_id;
	Allfood_total_charges = allfood_total_charges;
}
}
