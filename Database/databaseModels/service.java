package Model;

public class service {
private String service_id;
private String service_name;
private double price;
private String description;
public service(String service_id, String service_name, double price, String description) {
	super();
	this.service_id = service_id;
	this.service_name = service_name;
	this.price = price;
	this.description = description;
}
public String getService_id() {
	return service_id;
}
public void setService_id(String service_id) {
	this.service_id = service_id;
}
public String getService_name() {
	return service_name;
}
public void setService_name(String service_name) {
	this.service_name = service_name;
}
public double getPrice() {
	return price;
}
public void setPrice(double price) {
	this.price = price;
}
public String getDescription() {
	return description;
}
public void setDescription(String description) {
	this.description = description;
}

}
