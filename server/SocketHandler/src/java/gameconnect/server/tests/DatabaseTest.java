package gameconnect.server.tests;

import gameconnect.server.database.User;

/**
 *
 * @author davidboschwitz
 */
public class DatabaseTest {
    public static void main(String... argu){
        User u;
        u = User.createUser("David Boschwitz", "davidsuuid");
        System.out.println(u.uid);
        System.out.println(u.getName());
    }
    
    
}
