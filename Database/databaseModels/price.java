package Model;

public class price {
private String price_id;
private roomType room_type;
private double price_per_day;
private double price_per_night;
private double price_per_hour;
public price(String price_id, roomType room_type, double price_per_day, double price_per_night, double price_per_hour) {
	super();
	this.price_id = price_id;
	this.room_type = room_type;
	this.price_per_day = price_per_day;
	this.price_per_night = price_per_night;
	this.price_per_hour = price_per_hour;
}
public String getPrice_id() {
	return price_id;
}
public void setPrice_id(String price_id) {
	this.price_id = price_id;
}
public roomType getRoom_type() {
	return room_type;
}
public void setRoom_type(roomType room_type) {
	this.room_type = room_type;
}
public double getPrice_per_day() {
	return price_per_day;
}
public void setPrice_per_day(double price_per_day) {
	this.price_per_day = price_per_day;
}
public double getPrice_per_night() {
	return price_per_night;
}
public void setPrice_per_night(double price_per_night) {
	this.price_per_night = price_per_night;
}
public double getPrice_per_hour() {
	return price_per_hour;
}
public void setPrice_per_hour(double price_per_hour) {
	this.price_per_hour = price_per_hour;
}

}
