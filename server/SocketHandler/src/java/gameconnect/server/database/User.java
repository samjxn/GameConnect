package gameconnect.server.database;

/**
 *
 * @author davidboschwitz
 */
public class User {

    /**
     *
     */
    public final long uid;
    
    /**
     *
     */
    protected String name;
    
    /**
     *
     */
    protected String fbid;
    
    protected String fbpic;
    
    protected String role = "user";
    
    /**
     *
     */
    protected String[] uuids;

    /**
     *
     * @param uid
     */
    public User(long uid) {
        this.uid = uid;
    }
    
    public static User createUser(String name, String uuid){
        User u = null;
        long uid = DatabaseSupport.getSingleton().getNewUserUID();
        if(uid <= 0) {
            return null;
        }
        u = new User(uid);
        u.name = name;
        u.uuids = new String[]{uuid};
        DatabaseSupport.getSingleton().updateUser(u);
        return u;
    }
    
    public String getName(){
        return name;
    }
    
    public String[] getUUIDs(){
        return uuids;
    }
    
    public String getFBID(){
        return fbid;
    }
    
    public String getFBPic(){
        return fbpic;
    }
    
    public String getRole(){
        return role;
    }
}
