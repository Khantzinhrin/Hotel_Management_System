package Model;

public class order_service {
private String order_service_id;
private order order_id;
private room room_no;
private service service_id;
private int service_times;
private double service_total_price;
public order_service(String order_service_id, order order_id, room room_no, service service_id, int service_times,
		double service_total_price) {
	super();
	this.order_service_id = order_service_id;
	this.order_id = order_id;
	this.room_no = room_no;
	this.service_id = service_id;
	this.service_times = service_times;
	this.service_total_price = service_total_price;
}
public String getOrder_service_id() {
	return order_service_id;
}
public void setOrder_service_id(String order_service_id) {
	this.order_service_id = order_service_id;
}
public order getOrder_id() {
	return order_id;
}
public void setOrder_id(order order_id) {
	this.order_id = order_id;
}
public room getRoom_no() {
	return room_no;
}
public void setRoom_no(room room_no) {
	this.room_no = room_no;
}
public service getService_id() {
	return service_id;
}
public void setService_id(service service_id) {
	this.service_id = service_id;
}
public int getService_times() {
	return service_times;
}
public void setService_times(int service_times) {
	this.service_times = service_times;
}
public double getService_total_price() {
	return service_total_price;
}
public void setService_total_price(double service_total_price) {
	this.service_total_price = service_total_price;
}

}
