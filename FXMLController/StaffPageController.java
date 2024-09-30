package application;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.geometry.HPos;
import javafx.geometry.VPos;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.scene.control.ComboBox;
import javafx.scene.control.DatePicker;
import javafx.scene.control.ScrollPane;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.image.Image;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.GridPane;
import javafx.scene.text.Text;
import javafx.stage.Stage;

public class StaffPageController{

	@FXML
	private Button All;
	@FXML
	private DatePicker ArrivalDate;
	@FXML
	private AnchorPane BookingInputUI;

	@FXML
	private TextField BookingSearch;

	@FXML
	private Button Bookingbtn;

	@FXML
	private Button Cancelbtn;

	@FXML
	private DatePicker CheckInDate;

	@FXML
	private DatePicker CheckOutDate;

	@FXML
	private Text CkinDate;

	@FXML
	private Text CkoutDate;

	@FXML
	private Button Decreasebtn;

	@FXML
	private TextField Deposit;

	@FXML
	private TextField Email;

	@FXML
	private Text EmailText;

	@FXML
	private TextField FirstName;

	@FXML
	private Text Floor;

	@FXML
	private Button Floor1;

	@FXML
	private Button Floor2;

	@FXML
	private Button Floor3;

	@FXML
	private Button Floor4;

	@FXML
	private ScrollPane FloorScene;

	@FXML
	private Button Increasebtn;

	@FXML
	private AnchorPane InputUI;

	@FXML
	private TextField LastName;

	@FXML
	private Button LogOutbtn;

	@FXML
	private Text Name;

	@FXML
	private TextField NrcOrId;

	@FXML
	private DatePicker OrderDate;
	@FXML
	private TextField OrderFirstName;

	@FXML
	private TextField OrderLastName;

	@FXML
	private TextField OrderPhoneNumber;

	@FXML
	private AnchorPane OrderUI;

	@FXML
	private Button Orderbtn;

	@FXML
	private Text PhoneNo;

	@FXML
	private AnchorPane RoomBody;

	@FXML
	private AnchorPane RoomDetails;

	@FXML
	private AnchorPane RoomDetailsUI;

	@FXML
	private Button Roombtn;

	@FXML
	private TextField SearchBar;

	@FXML
	private Button Servicebtn;

	@FXML
	private AnchorPane ServicesUI;

	@FXML
	private AnchorPane SettingUI;

	@FXML
	private Button Settingbtn;

	@FXML
	private AnchorPane ShowDetails;

	@FXML
	private Button Submitbtn;

	@FXML
	private TextField TakenRooms;

	@FXML
	private CheckBox doubleRoomCheckBox;

	@FXML
	private TextField phoneNumber;

	@FXML
	private Text price;

	@FXML
	private Text roomID;

	@FXML
	private ComboBox<String> roomOptions;

	@FXML
	private Text roomType;

	@FXML
	private CheckBox singleRoomCheckBox;

	@FXML
	private AnchorPane StatusUI;

	@FXML
	private Text StaffName;

	@FXML
	private TableView<BookingDetails> OrderDetailsTable;
	@FXML
	private TableColumn<BookingDetails, String> firstNameColumn;
	@FXML
	private TableColumn<BookingDetails, String> lastNameColumn;
	@FXML
	private TableColumn<BookingDetails, String> phoneColumn;
	@FXML
	private TableColumn<BookingDetails, LocalDate> bookingDateColumn;
	@FXML
	private TableColumn<BookingDetails, LocalDate> arrivalDateColumn;
	@FXML
	private TableColumn<BookingDetails, String> roomTypeColumn;
	@FXML
	private TableColumn<BookingDetails, String> depositColumn;
	@FXML
	private TableColumn<BookingDetails, String> takenRoomColumn;
	@FXML
	private TableColumn<BookingDetails, String> orderID;


	private ObservableList<BookingDetails> bookingDetailsList = FXCollections.observableArrayList();

	private String userId;

	private static final String JDBC_URL = "jdbc:mysql://localhost:3306/hotel_management_system";
	private static final String DB_USER = "root";
	private static final String DB_PASSWORD = "";
	@FXML
	void LogOut(ActionEvent event) throws IOException {
		Parent root = FXMLLoader.load(getClass().getResource("LogIn.fxml"));
		Stage stage = (Stage) ((Node) event.getSource()).getScene().getWindow();
		Scene scene = new Scene(root);
		stage.setScene(scene);
		stage.setTitle("LogIn");
		stage.show();
		Image logo = new Image(getClass().getResourceAsStream("/Icon/logo1.png"));
		stage.getIcons().add(logo);
	}

	@FXML
	void initialize() { 
		orderID.setCellValueFactory(new PropertyValueFactory<>("orderId"));
		firstNameColumn.setCellValueFactory(new PropertyValueFactory<>("firstName"));
		lastNameColumn.setCellValueFactory(new PropertyValueFactory<>("lastName"));
		phoneColumn.setCellValueFactory(new PropertyValueFactory<>("phone"));
		bookingDateColumn.setCellValueFactory(new PropertyValueFactory<>("bookingDate"));
		arrivalDateColumn.setCellValueFactory(new PropertyValueFactory<>("arrivalDate"));
		roomTypeColumn.setCellValueFactory(new PropertyValueFactory<>("roomType"));
		takenRoomColumn.setCellValueFactory(new PropertyValueFactory<>("takenRoom"));
		depositColumn.setCellValueFactory(new PropertyValueFactory<>("deposit"));
		roomOptions.getItems().addAll("Single", "Double");
		loadBookingDetailsFromDatabase();
		AddingRooms(0, null);
		updateRoomAvailability();
	    setStaffDetails();
	}
	 public void setUserId(String userIdInput) {
	        this.userId = userIdInput;
	        setStaffDetails();
	    }

	    private void setStaffDetails() {
	        String query = "SELECT user_name, role FROM admin_and_staff WHERE user_id = ?";

	        try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
	             PreparedStatement pstmt = conn.prepareStatement(query)) {

	            // Set the user_id parameter in the query
	            pstmt.setString(1, this.userId);

	            // Execute the query
	            try (ResultSet rs = pstmt.executeQuery()) {
	                if (rs.next()) {
	                    String name = rs.getString("user_name");
	                    StaffName.setText(name);
	                if(name==null) {
	                	StaffName.setText("No User Name");
	                }
	                   
	                } else {
	                    StaffName.setText("User not found");
	                   
	                }
	            }
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
	    }
	
	private void loadBookingDetailsFromDatabase() {
		bookingDetailsList.clear();
		String query = "SELECT * FROM orderbookings"; 

		try (Connection conn = DriverManager.getConnection(JDBC_URL,DB_USER,DB_PASSWORD);
				Statement stmt = conn.createStatement();
				ResultSet rs = stmt.executeQuery(query)) {

			while (rs.next()) {
				String orderId = rs.getString("id");
				String firstName = rs.getString("first_name");
				String lastName = rs.getString("last_name");
				String phone = rs.getString("phone_number");
				LocalDate bookingDate = rs.getDate("booking_date").toLocalDate();
				LocalDate arrivalDate = rs.getDate("arrival_date").toLocalDate();
				String roomType = rs.getString("room_type");
				String takenRoom = rs.getString("taken_rooms");
				String deposit = rs.getString("deposit");
				BookingDetails bookingDetail = new BookingDetails(orderId,firstName, lastName, phone, bookingDate, arrivalDate, roomType, takenRoom,deposit );
				bookingDetailsList.add(bookingDetail);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}

		OrderDetailsTable.setItems(bookingDetailsList);
	}

	public void updateRoomAvailability() {
		String updateRoomSQL = "UPDATE rooms r " +
				"JOIN bookings b ON r.room_id = b.room_id " +
				"SET r.status = 0 " +
				"WHERE b.check_out_date <= CURDATE() AND r.status = 1";

		try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
				PreparedStatement pstmt = con.prepareStatement(updateRoomSQL)) {

			int rowsAffected = pstmt.executeUpdate();

			if (rowsAffected > 0) {
				System.out.println("Rooms updated to available status where check-out date has passed.");
			} else {
				System.out.println("No rooms to update.");
			}

		} catch (SQLException e) {
			e.printStackTrace();
			System.out.println("Error updating room availability.");
		}
	}

	void AddingRooms(int floorFilter, String searchQuery) {
		RoomBody.getChildren().clear();
		GridPane roomGrid = new GridPane();
		roomGrid.setHgap(25);
		roomGrid.setVgap(20);

		// SQL query to select rooms, optionally joining with bookings for customer name search
		String sql = "SELECT r.room_id, r.room_type, r.floor, r.price, r.status " +
				"FROM rooms r " +
				"LEFT JOIN bookings b ON r.room_id = b.room_id " +
				"WHERE 1=1";

		if (floorFilter != 0) {
			sql += " AND r.floor = ?";
		}

		if (searchQuery != null && !searchQuery.trim().isEmpty()) {
			sql += " AND (b.first_name LIKE ? OR b.last_name LIKE ? OR r.room_id LIKE ?)";
		}

		if (singleRoomCheckBox.isSelected() || doubleRoomCheckBox.isSelected()) {
			sql += " AND r.room_type IN (";
			if (singleRoomCheckBox.isSelected()) {
				sql += "'Single'";
			}
			if (singleRoomCheckBox.isSelected() && doubleRoomCheckBox.isSelected()) {
				sql += ", ";
			}
			if (doubleRoomCheckBox.isSelected()) {
				sql += "'Double'";
			}
			sql += ")";
		}

		try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
				PreparedStatement pstmt = con.prepareStatement(sql)) {

			int paramIndex = 1;
			if (floorFilter != 0) {
				pstmt.setInt(paramIndex++, floorFilter);
			}
			if (searchQuery != null && !searchQuery.trim().isEmpty()) {
				String searchPattern = "%" + searchQuery + "%";
				pstmt.setString(paramIndex++, searchPattern);  // Search by first name
				pstmt.setString(paramIndex++, searchPattern);  // Search by last name
				pstmt.setString(paramIndex++, searchPattern);  // Search by room ID
			}

			try (ResultSet rs = pstmt.executeQuery()) {
				int row = 0;
				int column = 0;
				final int MAX_COLUMNS = 5;

				while (rs.next()) {
					int roomId = rs.getInt("room_id");
					String roomType = rs.getString("room_type");
					int floor = rs.getInt("floor");
					double roomPrice = rs.getDouble("price");
					String status = rs.getString("status");

					Button roomButton = new Button("Room " + roomId);
					roomButton.setPrefSize(100, 50);

					if (status.equals("1")) {
						roomButton.setStyle("-fx-background-color:red; -fx-border-color:red; -fx-background-radius:10; -fx-border-radius:10;");
						roomButton.setOnAction(e -> {
							roomID.setText(String.valueOf(roomId));
							price.setText("$" + roomPrice);
							Floor.setText("Floor " + floor);
							this.roomType.setText(roomType);

							fetchCustomerDetails(roomId);

							RoomDetails.setVisible(true);
							ShowDetails.setVisible(true);
							InputUI.setVisible(false);
						});
					}
					else if(status.equals("booked")) {
						roomButton.setStyle("-fx-background-color:yellow; -fx-border-color:yellow; -fx-background-radius:10; -fx-border-radius:10;");
						roomButton.setOnAction(e -> {
							roomID.setText(String.valueOf(roomId));
							price.setText("$" + roomPrice);
							Floor.setText("Floor " + floor);
							this.roomType.setText(roomType);

							fetchCustomerDetails(roomId);

							RoomDetails.setVisible(false);
							ShowDetails.setVisible(false);
							InputUI.setVisible(true);

						});
					}else{
						roomButton.setStyle("-fx-background-color:forestgreen; -fx-border-color:forestgreen; -fx-background-radius:10; -fx-border-radius:10;");
						roomButton.setOnAction(e -> {
							roomID.setText(String.valueOf(roomId));
							price.setText("$" + roomPrice);
							Floor.setText("Floor " + floor);
							this.roomType.setText(roomType);

							fetchCustomerDetails(roomId);

							RoomDetails.setVisible(false);
							ShowDetails.setVisible(false);
							InputUI.setVisible(true);
						}
								);
					}

					roomGrid.add(roomButton, column, row);
					GridPane.setHalignment(roomButton, HPos.CENTER);
					GridPane.setValignment(roomButton, VPos.CENTER);

					column++;
					if (column == MAX_COLUMNS) {
						column = 0;
						row++;
					}
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.out.println("Error loading rooms from the database.");
		}

		RoomBody.getChildren().add(roomGrid);
		AnchorPane.setTopAnchor(roomGrid, 10.0);
		AnchorPane.setLeftAnchor(roomGrid, 10.0);
		AnchorPane.setRightAnchor(roomGrid, 10.0);
		AnchorPane.setBottomAnchor(roomGrid, 10.0);
	}


	private void fetchCustomerDetails(int roomId) {
		String sql = "SELECT first_name, last_name, phone_number, email, check_in_date, check_out_date " +
				"FROM bookings WHERE room_id = ?";

		try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
				PreparedStatement pstmt = con.prepareStatement(sql)) {

			pstmt.setInt(1, roomId);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					String firstName = rs.getString("first_name");
					String lastName = rs.getString("last_name");
					String phoneNumber = rs.getString("phone_number");
					String email = rs.getString("email");
					LocalDate checkInDate = rs.getDate("check_in_date").toLocalDate();
					LocalDate checkOutDate = rs.getDate("check_out_date").toLocalDate();

					Name.setText(firstName + " " + lastName);
					PhoneNo.setText(phoneNumber);
					EmailText.setText(email);
					CkinDate.setText(checkInDate.toString());
					CkoutDate.setText(checkOutDate.toString());
				} else {
					Name.setText("N/A");
					PhoneNo.setText("N/A");
					EmailText.setText("N/A");
					CkinDate.setText("N/A");
					CkoutDate.setText("N/A");
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
			System.out.println("Error fetching customer details from the database.");
		}
	}

	@FXML
	void FloorAction(ActionEvent event) {
		Button source = (Button) event.getSource();
		int floor = 0;
		switch (source.getText()) {
		case "Floor 1":
			floor = 1;
			break;
		case "Floor 2":
			floor = 2;
			break;
		case "Floor 3":
			floor = 3;
			break;
		case "Floor 4":
			floor = 4;
			break;
		case "All":
			floor = 0;
			break;
		}

		String searchQuery = SearchBar.getText().trim();
		AddingRooms(floor, searchQuery.isEmpty() ? null : searchQuery);
	}
	@FXML
	void change_name_pass_Action(ActionEvent event) {

	}


	@FXML
	void SearchAction(ActionEvent event) {
		String searchQuery = SearchBar.getText().trim();
		AddingRooms(0, searchQuery.isEmpty() ? null : searchQuery);
	}
	@FXML
	void SubmitAction(ActionEvent event) {
		String nrcOrId = NrcOrId.getText();
		String firstName = FirstName.getText();
		String lastName = LastName.getText();
		String phone = phoneNumber.getText();
		String email = Email.getText();
		LocalDate checkIn = CheckInDate.getValue();
		LocalDate checkOut = CheckOutDate.getValue();
		String roomId = roomID.getText();

		if (nrcOrId.isEmpty() || firstName.isEmpty() || lastName.isEmpty() || phone.isEmpty() || checkIn == null || checkOut == null || roomId.isEmpty()) {
			System.out.println("Please fill in all required fields.");
			return;
		}

		String insertBookingSQL = "INSERT INTO bookings (customer_nrc_or_id, first_name, last_name, phone_number, email, check_in_date, check_out_date, room_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
		String updateRoomSQL = "UPDATE rooms SET status = 1 WHERE room_id = ?";

		try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
				PreparedStatement pstmt1 = con.prepareStatement(insertBookingSQL);
				PreparedStatement pstmt2 = con.prepareStatement(updateRoomSQL)) {

			pstmt1.setString(1, nrcOrId);
			pstmt1.setString(2, firstName);
			pstmt1.setString(3, lastName);
			pstmt1.setString(4, phone);
			pstmt1.setString(5, email);
			pstmt1.setDate(6, java.sql.Date.valueOf(checkIn));
			pstmt1.setDate(7, java.sql.Date.valueOf(checkOut));
			pstmt1.setString(8, roomId);

			int rowsAffected1 = pstmt1.executeUpdate();
			pstmt2.setInt(1, Integer.parseInt(roomId));
			int rowsAffected2 = pstmt2.executeUpdate();

			if (rowsAffected1 > 0 && rowsAffected2 > 0) {
				System.out.println("Booking successful and room marked as booked!");
				AddingRooms(0, null);
				InputUI.setVisible(false);
				RoomDetails.setVisible(true);
				ShowDetails.setVisible(true);

				NrcOrId.setText(""); 
				FirstName.setText(""); 
				LastName.setText("");
				phoneNumber.setText("");
				Email.setText("");
				CheckInDate.setValue(null);
				CheckOutDate.setValue(null);
			} else {
				System.out.println("Booking failed, please try again.");
			}

		} catch (SQLException e) {
			e.printStackTrace();
			System.out.println("Error while booking the room.");
		}
	}
	@FXML
	void BookingAction(ActionEvent event) {
		String firstName = OrderFirstName.getText();
		String lastName = OrderLastName.getText();
		String phone = OrderPhoneNumber.getText();
		LocalDate bookingDate = OrderDate.getValue();
		LocalDate arrivalDate = ArrivalDate.getValue();
		String roomType = roomOptions.getValue();
		String deposit = Deposit.getText();
		String numberoftakenRooms = TakenRooms.getText(); // Number of rooms taken by the customer

		// Check if mandatory fields are filled
		if (firstName.isEmpty() || lastName.isEmpty() || phone.isEmpty() || roomType == null || roomType.isEmpty() || numberoftakenRooms.isEmpty()) {
			System.out.println("Please fill in all required fields, including taken rooms.");
			return;
		}

		String insertBookingSQL = "INSERT INTO orderBookings (first_name, last_name, phone_number, booking_date, arrival_date, room_type, deposit, taken_rooms) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
		String updateRoomSQL = "UPDATE rooms SET status = 'booked' WHERE room_id =? AND status = 0 "; 

		try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
				PreparedStatement pstmt1 = con.prepareStatement(insertBookingSQL);
				PreparedStatement pstmt2 = con.prepareStatement(updateRoomSQL)) {

			pstmt1.setString(1, firstName);
			pstmt1.setString(2, lastName);
			pstmt1.setString(3, phone);
			pstmt1.setDate(4, java.sql.Date.valueOf(bookingDate));
			pstmt1.setDate(5, java.sql.Date.valueOf(arrivalDate));
			pstmt1.setString(6, roomType);
			pstmt1.setString(7, deposit);
			pstmt1.setString(8, numberoftakenRooms);

			int rowsAffected1 = pstmt1.executeUpdate();
			pstmt2.setInt(1, Integer.parseInt(numberoftakenRooms));
			int rowsAffected2 = pstmt2.executeUpdate();

			// Check if both operations were successful
			if (rowsAffected1 > 0 && rowsAffected2 > 0) {
				System.out.println("Booking successful!");
				loadBookingDetailsFromDatabase();
				clearInputFields();
			} else {
				System.out.println("Booking failed, please try again.");
			}

		} catch (SQLException e) {
			e.printStackTrace();
			System.out.println("Error while booking the room: " + e.getMessage());
		} catch (NumberFormatException e) {
			System.out.println("Invalid number of rooms entered. Please enter a valid number.");
		}
	}

	// Clear the input fields after booking
	private void clearInputFields() {
		OrderFirstName.clear();
		OrderLastName.clear();
		OrderPhoneNumber.clear();
		OrderDate.setValue(null);
		ArrivalDate.setValue(null);
		roomOptions.setValue("SelectRoomType");
		Deposit.clear();
		TakenRooms.clear();
	}


	@FXML
	void ShowOrderTableAction(ActionEvent event) {
		OrderDetailsTable.setVisible(true);
		BookingInputUI.setVisible(false);
		StatusUI.setVisible(false);
	}
	@FXML
	void CancleShowOrderTableAction(ActionEvent event) {
		OrderDetailsTable.setVisible(false);
		BookingInputUI.setVisible(true);
		StatusUI.setVisible(true);
	}



	@FXML
	void BookingShow(ActionEvent event) {
		OrderUI.setVisible(true);
		RoomDetailsUI.setVisible(false);
		ServicesUI.setVisible(false);
		SettingUI.setVisible(false);
	}

	@FXML
	void RoomDetailShow(ActionEvent event) {
		OrderUI.setVisible(false);
		RoomDetailsUI.setVisible(true);
		ServicesUI.setVisible(false);
		SettingUI.setVisible(false);
	}

	@FXML
	void ServicesShow(ActionEvent event) {
		OrderUI.setVisible(false);
		RoomDetailsUI.setVisible(false);
		ServicesUI.setVisible(true);
		SettingUI.setVisible(false);
	}

	@FXML
	void SettingShow(ActionEvent event) {
		OrderUI.setVisible(false);
		RoomDetailsUI.setVisible(false);
		ServicesUI.setVisible(false);
		SettingUI.setVisible(true);
	}

	@FXML
	void CancelAction(ActionEvent event) {
		RoomDetails.setVisible(true);
		ShowDetails.setVisible(true);
		InputUI.setVisible(false);
	}

}
