package Model;

public class roomType {
private String room_type;

private String description;


public roomType(String room_type, String description) {
	super();
	this.room_type = room_type;
	
	this.description = description;
	
	
}

public String getRoom_type() {
	return room_type;
}

public void setRoom_type(String room_type) {
	this.room_type = room_type;
}
public String getDescription() {
	return description;
}
public void setDescription(String description) {
	this.description = description;
}
public String toStringFOrFilter() {
	return "[" + room_type +  " + description= " + description+"]";
}

public roomType(String room_type) {
	this.room_type=room_type;
}


}
