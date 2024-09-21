package application;


import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

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
    

    
    @FXML
    void LogInAction(ActionEvent event) {
        if (event.getSource() == LogIn) {
            try {
               //DataBase Connection
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/your_database_name", "name", "your_password");

                // Retrieve user input from the text fields
                String user_id = UserID.getText();
                String password = !Password.getText().isEmpty() ? Password.getText() : PasswordTextFiled.getText();

                // Ensure user input is not empty
                if (user_id.isEmpty() || password.isEmpty()) {
                	userError.setVisible(true);
                	passwordError.setVisible(true);
                }

                // Prepare SQL query to prevent SQL injection
                String sql = "SELECT * FROM admin_and_staff WHERE user_id = ? AND user_password = ?";
                PreparedStatement pstmt = con.prepareStatement(sql);
                pstmt.setString(1, user_id);
                pstmt.setString(2, password);

                // Execute query
                ResultSet rs = pstmt.executeQuery();

                // If a matching user is found, log them in
                if (rs.next()) {
                    // Load the StaffPage.fxml and switch scene
                    Parent root = FXMLLoader.load(getClass().getResource("StaffPage.fxml"));
                    Stage stage = (Stage) ((Node) event.getSource()).getScene().getWindow();
                    Scene scene = new Scene(root);
                    stage.setScene(scene);
                    stage.setTitle("Staff Part");
                    stage.show();
                } else {
                	userError.setVisible(true);
                	passwordError.setVisible(true);
                 
                }

                // Close resources
                rs.close();
                pstmt.close();
                con.close();
                
            } catch (Exception e) {
                e.printStackTrace();
                System.out.println("Error: " + e.getMessage());
            }
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
