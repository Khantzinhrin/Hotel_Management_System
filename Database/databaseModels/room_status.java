package Model;

public class room_status {
private String room_status_id;
private String room_status;
public String getRoom_status_id() {
	return room_status_id;
}
public void setRoom_status_id(String room_status_id) {
	this.room_status_id = room_status_id;
}
public String getRoom_status() {
	return room_status;
}
public void setRoom_status(String room_status) {
	this.room_status = room_status;
}
public String toStringForFilter() {
	return "[" + room_status +"]";
}
public room_status(String room_status_id, String room_status) {
	super();
	this.room_status_id = room_status_id;
	this.room_status = room_status;
}
}
