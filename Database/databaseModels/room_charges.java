package Model;

public class room_charges {
private booking booking_id;
private room room_no;
private roomType room_type_id;
private double room_charges;
public room_charges(booking booking_id, room room_no, roomType room_type_id, double room_charges) {
	super();
	this.booking_id = booking_id;
	this.room_no = room_no;
	this.room_type_id = room_type_id;
	this.room_charges = room_charges;
}
public booking getBooking_id() {
	return booking_id;
}
public void setBooking_id(booking booking_id) {
	this.booking_id = booking_id;
}
public room getRoom_no() {
	return room_no;
}
public void setRoom_no(room room_no) {
	this.room_no = room_no;
}
public roomType getRoom_type_id() {
	return room_type_id;
}
public void setRoom_type_id(roomType room_type_id) {
	this.room_type_id = room_type_id;
}
public double getRoom_charges() {
	return room_charges;
}
public void setRoom_charges(double room_charges) {
	this.room_charges = room_charges;
}

}
