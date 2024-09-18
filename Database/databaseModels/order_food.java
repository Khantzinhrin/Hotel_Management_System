package Model;

public class order_food {
private String order_food_id;
private order order_id;
private room roomNo;
private food food_id;
private int food_quantity;
private double food_total_price;

public order_food(String order_food_id, order order_id, room roomNo, food food_id, int food_quantity,
		double food_total_price) {
	super();
	this.order_food_id = order_food_id;
	this.order_id = order_id;
	this.roomNo = roomNo;
	this.food_id = food_id;
	this.food_quantity = food_quantity;
	this.food_total_price = food_total_price;
}
public String getOrder_food_id() {
	return order_food_id;
}
public void setOrder_food_id(String order_food_id) {
	this.order_food_id = order_food_id;
}
public order getOrder_id() {
	return order_id;
}
public void setOrder_id(order order_id) {
	this.order_id = order_id;
}
public room getRoomNo() {
	return roomNo;
}
public void setRoomNo(room roomNo) {
	this.roomNo = roomNo;
}
public food getFood_id() {
	return food_id;
}
public void setFood_id(food food_id) {
	this.food_id = food_id;
}
public int getFood_quantity() {
	return food_quantity;
}
public void setFood_quantity(int food_quantity) {
	this.food_quantity = food_quantity;
}
public double getFood_total_price() {
	return food_total_price;
}
public void setFood_total_price(double food_total_price) {
	this.food_total_price = food_total_price;
}

}
