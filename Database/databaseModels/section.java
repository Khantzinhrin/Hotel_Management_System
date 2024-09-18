package Model;

public class section {
private booking booking_id;
private room room_no;
private roomType room_type;
private int day_section;
private int night_section;
private int hour_section;
private double room_charges;

public section(booking booking_id, room room_no, roomType room_type, int day_section, int night_section,
		int hour_section, double room_charges) {
	super();
	this.booking_id = booking_id;
	this.room_no = room_no;
	this.room_type = room_type;
	this.day_section = day_section;
	this.night_section = night_section;
	this.hour_section = hour_section;
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
public roomType getRoom_type() {
	return room_type;
}
public void setRoom_type(roomType room_type) {
	this.room_type = room_type;
}
public int getDay_section() {
	return day_section;
}
public void setDay_section(int day_section) {
	this.day_section = day_section;
}
public int getNight_section() {
	return night_section;
}
public void setNight_section(int night_section) {
	this.night_section = night_section;
}
public int getHour_section() {
	return hour_section;
}
public void setHour_section(int hour_section) {
	this.hour_section = hour_section;
}
public double getRoom_charges() {
	return room_charges;
}
public void setRoom_charges(double room_charges) {
	this.room_charges = room_charges;
}

}
