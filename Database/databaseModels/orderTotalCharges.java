package Model;

public class orderTotalCharges {
private order order_id;
private double food_total_charges;
private double service_total_charges;
public orderTotalCharges(order order_id, double food_total_charges, double service_total_charges) {
	super();
	this.order_id = order_id;
	this.food_total_charges = food_total_charges;
	this.service_total_charges = service_total_charges;
}
public order getOrder_id() {
	return order_id;
}
public void setOrder_id(order order_id) {
	this.order_id = order_id;
}
public double getFood_total_charges() {
	return food_total_charges;
}
public void setFood_total_charges(double food_total_charges) {
	this.food_total_charges = food_total_charges;
}
public double getService_total_charges() {
	return service_total_charges;
}
public void setService_total_charges(double service_total_charges) {
	this.service_total_charges = service_total_charges;
}

}
