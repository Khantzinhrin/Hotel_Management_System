package Model;

public class stock {
private food food_id;
private int current_stock;
public stock(food food_id, int current_stock) {
	super();
	this.food_id = food_id;
	this.current_stock = current_stock;
}
public food getFood_id() {
	return food_id;
}
public void setFood_id(food food_id) {
	this.food_id = food_id;
}
public int getCurrent_stock() {
	return current_stock;
}
public void setCurrent_stock(int current_stock) {
	this.current_stock = current_stock;
}
@Override
public String toString() {
	return "stock [food_id=" + food_id + ", current_stock=" + current_stock + "]";
}

}
