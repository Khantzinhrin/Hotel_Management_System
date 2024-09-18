package Model;

import java.time.LocalDateTime;

public class payment {
	
private String payment_id;
private booking booking_id;
private double amount;
private LocalDateTime payment_date;
private String payment_method;

public String getPayment_id() {
	return payment_id;
}
public void setPayment_id(String payment_id) {
	this.payment_id = payment_id;
}
public booking getBooking_id() {
	return booking_id;
}
public void setBooking_id(booking booking_id) {
	this.booking_id = booking_id;
}
public double getAmount() {
	return amount;
}
public void setAmount(double amount) {
	this.amount = amount;
}
public LocalDateTime getPayment_date() {
	return payment_date;
}
public void setPayment_date(LocalDateTime payment_date) {
	this.payment_date = payment_date;
}
public String getPayment_method() {
	return payment_method;
}
public void setPayment_method(String payment_method) {
	this.payment_method = payment_method;
}
public payment(String payment_id, booking booking_id, double amount, LocalDateTime payment_date,
		String payment_method) {
	super();
	this.payment_id = payment_id;
	this.booking_id = booking_id;
	this.amount = amount;
	this.payment_date = payment_date;
	this.payment_method = payment_method;
}
}
