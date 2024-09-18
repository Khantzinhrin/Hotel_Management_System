package Model;

public class food {
private int food_id;
private String food_name;
private double food_price;
private String food_category;
private String stock_status;

public food(int food_id, String food_name, double food_price, String food_category , String stock_status) {
	super();
	this.food_id = food_id;
	this.food_name = food_name;
	this.food_price = food_price;
	this.food_category = food_category;
	this.stock_status = stock_status;
}
public int getFood_id() {
	return food_id;
}
public void setFood_id(int food_id) {
	this.food_id = food_id;
}

public String getFood_name() {
	return food_name;
}
public void setFood_name(String food_name) {
	this.food_name = food_name;
}
public double getFood_price() {
	return food_price;
}
public void setFood_price(double food_price) {
	this.food_price = food_price;
}
public String getfood_category() {
	return food_category;
}
public void setfood_category(String food_category) {
	this.food_category = food_category;
}
public String getStock_status() {
	return stock_status;
}
public void setStock_status(String stock_status) {
	this.stock_status = stock_status;
}
@Override
public String toString() {
	return "food [food_id=" + food_id + ", food_name=" + food_name + ", food_price=" + food_price + ", description="
			+ food_category + ", stock_status=" + stock_status + "]";
}



}
