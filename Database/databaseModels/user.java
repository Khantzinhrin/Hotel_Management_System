package Model;

public class user {
private String user_id;
private String password;
private String privilage;

public String getUser_id() {
	return user_id;
}
public void setUser_id(String user_id) {
	this.user_id = user_id;
}
public String getprivilage() {
	return privilage;
}
public void setPrivilage(String privilage) {
	this.privilage = privilage;
}
public String getPassword() {
	return password;
}
public void setPassword(String password) {
	this.password = password;
}
public user(String user_id , String password, String privilage) {
	super();
	this.user_id = user_id;

	this.password = password;
	this.privilage = privilage;
}

}
