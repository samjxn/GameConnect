package gameconnect.server.database;

import gameconnect.server.ConnectionHandler;
import gameconnect.server.panel.Panel;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author davidboschwitz
 */
public class DatabaseSupport {
    // JDBC driver name and database URL

    /**
     *
     */
    static final String JDBC_DRIVER = "com.mysql.jdbc.Driver";

    /**
     *
     */
    static final String DB_URL = "jdbc:mysql://mysql.cs.iastate.edu";

    // Database credentials
    static final String USER = "dbu309grp16";
    static final String PASS = "4JP4wVWK4vp";

    private static DatabaseSupport singleton = null;
    private boolean closed = false;
    private Connection connection;

    public static DatabaseSupport getSingleton() {
        if (singleton == null || singleton.closed) {
            try {
                Class.forName("com.mysql.jdbc.Driver");
            } catch (ClassNotFoundException cnfe) {
                cnfe.printStackTrace();
            }
            singleton = new DatabaseSupport();
        }
        return singleton;
    }

    private DatabaseSupport() {
        open();
    }

    private void open() {
        try {
            connection = DriverManager.getConnection(DB_URL, USER, PASS);
        } catch (SQLException sqle) {
            sqle.printStackTrace();
            closed = true;
        }
    }

    public void close() throws SQLException {
        closed = true;
        connection.close();
    }

    public ResultSet querySelect(String sql) throws SQLException {
        return connection.createStatement().executeQuery(sql);
    }

    public int queryUpdate(String sql) throws SQLException {
        return connection.createStatement().executeUpdate(sql);
    }

    public Statement getStatement() throws SQLException {
        return connection.createStatement();
    }

    public User getUser(int uid) {
        User u = null;
        try {
            ResultSet rs = querySelect("SELECT * FROM `db309grp16`.`users` WHERE `uid` = " + uid + ";");
            if (rs.next()) {
                u = getUserFromRS(rs);
            }
        } catch (SQLException e) {
            Panel.log(e.getMessage());
            e.printStackTrace();
        }
        return u;
    }

    protected long getNewUserUID() {
        long l = 0L;
        try {
            Statement s = getStatement();
            s.execute("INSERT INTO `db309grp16`.`users` (uid, name, device_uuid, fbid, fbpic) VALUES (NULL, '', '', 0, ''); ");
            ResultSet rs = querySelect("SELECT LAST_INSERT_ID();");
            if (rs.next()) {
                l = rs.getLong(1);
            }
        } catch (SQLException e) {
            Panel.log(e.getMessage());
            e.printStackTrace();
        }
        return l;
    }

    public boolean updateUser(User u) {
        try {
            int i = queryUpdate("UPDATE `db309grp16`.`users` SET `name` = '" + u.name + "', `fbid` = '" + (u.fbid == null ? 0 : u.fbid) + "', `device_uuid` = '" + ConnectionHandler.gsonSingleton().toJson(u.uuids, String[].class) + "' WHERE `users`.`uid` = " + u.uid + ";");
        } catch (SQLException e) {
            Panel.log(e.getMessage());
            e.printStackTrace();
            return false;
        }
        return true;
    }

    public User getByUUID(String uuid) {
        //SELECT * FROM `db309grp16`.`users` WHERE `device_uuid` LIKE '%davidsuuid%'
        User u = null;
        try {
            ResultSet rs = querySelect("SELECT * FROM `db309grp16`.`users` WHERE `device_uuid` LIKE '%\"" + uuid + "\"%'");
            if (rs.next()) {
                u = getUserFromRS(rs);
            }
        } catch (SQLException e) {
            Panel.log(e.getMessage());
            e.printStackTrace();
        }
        return u;
    }

    private User getUserFromRS(ResultSet rs) throws SQLException {
        User u;
        u = new User(rs.getLong("uid"));
        u.name = rs.getString("name");
        u.uuids = ConnectionHandler.gsonSingleton().fromJson(rs.getString("device_uuid"), String[].class);
        u.fbid = rs.getString("fbid");
        u.fbpic = rs.getString("fbpic");
        return u;

    }
    
    public boolean addScore(Score s){
//        INSERT INTO `db309grp16`.`highscores` (`scoreid`, `uid`, `gameid`, `score`) VALUES (NULL, '7', '1', '342');
        try {
            int i = queryUpdate("INSERT INTO `db309grp16`.`highscores` (`scoreid`, `uid`, `gameid`, `score`) VALUES (NULL, '"+s.uid+"', '"+s.gameid+"', '"+s.score+"');");
        } catch (SQLException e) {
            Panel.log(e.getMessage());
            e.printStackTrace();
            return false;
        }
        return true;
    }
}
