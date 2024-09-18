package Model;

public class room {
private String room_no;
private roomType room_type;
private int floor;
private room_status room_status;

public int getFloor() {
	return floor;
}
public void setFloor(int floor) {
	this.floor = floor;
}


public String getRoom_no() {
	return room_no;
}
public void setRoom_no(String room_no) {
	this.room_no = room_no;
}
public roomType getRoom_type() {
	return room_type;
}
public void setRoom_type(roomType room_type) {
	this.room_type = room_type;
}
public room_status getRoom_status() {
	return room_status;
}

public void setRoom_status(room_status room_status) {
	this.room_status = room_status;
}
public String toString() {
	return "room [roomNo=" + room_no + ", roomtype=" + room_type.toStringFOrFilter() +", floor=" + floor+ ", room_status=" + room_status.toStringForFilter()+ "]";
}

public room(String room_no, roomType room_type,int floor, room_status room_status) {
	super();
	this.room_no = room_no;
	this.room_type = room_type;
	this.floor = floor;
	this.room_status = room_status;
}
public room(String room_no) {
	this.room_no = room_no;
}
}
