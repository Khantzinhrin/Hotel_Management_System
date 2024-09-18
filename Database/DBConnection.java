public class DBConnection {
    public static Connection getConnection() throws SQLException {
        String url = "jdbc:mysql://localhost/";
        String username = "root";
        String password = "";

        return DriverManager.getConnection(url, username, password);
    }
}
