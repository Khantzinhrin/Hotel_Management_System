package application;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.scene.image.Image;
import javafx.scene.text.Text;
import javafx.stage.Stage;

public class LogInController {

    @FXML
    private Button LogIn;

    @FXML
    private PasswordField Password;

    @FXML
    private TextField PasswordTextFiled;

    @FXML
    private Button Reset;

    @FXML
    private TextField UserID;

    @FXML
    private CheckBox showPassword;
    
    @FXML
    private Text userError;
    
    @FXML
    private Text passwordError;
    
    private String userIdInput;

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/hotel_management_system";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";

    @FXML
    void LogInAction(ActionEvent event) {
        userIdInput = UserID.getText();
        String passwordInput = Password.isVisible() ? Password.getText() : PasswordTextFiled.getText();
        String sql = "SELECT * FROM admin_and_staff WHERE user_id = ? AND user_password = ?";

        try {
            Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userIdInput);
            pstmt.setString(2, passwordInput); 

            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                String role = rs.getString("role");

                FXMLLoader loader = new FXMLLoader();

                if ("staff".equalsIgnoreCase(role)) {
                    // Load Staff Page and set user ID in StaffPageController
                    loader.setLocation(getClass().getResource("StaffPage.fxml"));
                    Parent staffPage = loader.load();
                    
                    // Pass userId to the StaffPageController
                    StaffPageController staffController = loader.getController();
                    staffController.setUserId(userIdInput);  // Set the userId in StaffPageController

                    Stage stage = (Stage) ((Node) event.getSource()).getScene().getWindow();
                    Scene scene = new Scene(staffPage);
                    stage.setScene(scene);
                    stage.setTitle("Staff Page");
                    stage.show();
                    Image logo = new Image(getClass().getResourceAsStream("/Icon/logo1.png"));
                    stage.getIcons().add(logo);
                } else if ("admin".equalsIgnoreCase(role)) {
                    // Load Admin Page
                    loader.setLocation(getClass().getResource("AdminPage.fxml"));
                    Parent adminPage = loader.load();

                    Stage stage = (Stage) ((Node) event.getSource()).getScene().getWindow();
                    Scene scene = new Scene(adminPage);
                    stage.setScene(scene);
                    stage.setTitle("Admin Page");
                    stage.show();
                    Image logo = new Image(getClass().getResourceAsStream("/Icon/logo1.png"));
                    stage.getIcons().add(logo);
                } else {
                    // Handle any other roles or unexpected values
                    System.out.println("Unexpected role found: " + role);
                }

            } else {
                userError.setVisible(true);
                passwordError.setVisible(true);
            }

            rs.close();
            pstmt.close();
            con.close();
            
        } catch (SQLException | IOException e) {
            e.printStackTrace();
        }
    }

    @FXML
    void ResetAction(ActionEvent event) {
        if (event.getSource() == Reset) {
            Password.setText("");
            UserID.setText("");
            PasswordTextFiled.setText("");
        }
    }

    @FXML
    void ShowPasswordAction(ActionEvent event) {
        if (showPassword.isSelected()) {
            PasswordTextFiled.setText(Password.getText());
            PasswordTextFiled.setVisible(true);
            Password.setVisible(false);
        } else {
            Password.setText(PasswordTextFiled.getText());
            Password.setVisible(true);
            PasswordTextFiled.setVisible(false);
        }
    }
}
