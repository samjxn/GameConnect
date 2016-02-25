package gameconnect.server;

import javax.websocket.Session;
/**
 *
 * @author davidboschwitz
 * @author Sam Jackson
 */
public class Client {
    
    // TODO:  give client ids
    
    protected Session session;
    protected final ClientType clientType;
    protected ClientGroup clientGrouping;
    
    /**
     * 
     * @param type
     * @param session
     * @param group 
     */
    public Client(ClientType type, Session session, ClientGroup group) {
        this.clientType = type;
        this.session = session;
        this.clientGrouping = group;
    }
    
    public void sendText(String msg) throws java.io.IOException {
        session.getBasicRemote().sendText(msg);
    }
    
    public ClientGroup getGroup() {
        return this.clientGrouping;
    }
    
}
