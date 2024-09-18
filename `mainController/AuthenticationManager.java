
/*package name may vary*/

import com.password4j.Hash;
import com.password4j.Password;
import com.password4j.ScryptFunction;


public class AuthenticationManager {
  
   private static final ScryptFunction scrypt = ScryptFunction.getInstance(128, 12, 2, 32);

    public static boolean Authenticate(String id, String password) {
        if (/*controller class name. method exists(id)*/) { /*method should return true or false*/
            user userDetails = /*controller classs name.getUserByID(id)*/ 
            if (userDetails != null 
                /*depending on the testing, more conditions might be added or removed*/
                /*as for the method names, please check the Database Model classes*/
                && userDetails.getPrivilege() /*method depends may vary*/ != null
                && userDetails.getPassword() /*method name may vary*/!= null ) {
              
                return Password.check(password, userDetails.getPassword())
                        .addSalt(userDetails.getPrivilege())
                        .with(scrypt);
            }
        }
        return false;
    }

    public static boolean AddNewUser(String id, String password, String privilege){
      
        Hash hash = Password.hash(password).addSalt(privilege).with(scrypt);

        return /*controller class name.controller method (id, hash.getResult(), privilege)*/; 
    }
}
