package gameconnect.server;

import javax.websocket.Session;
/**
 *
 * @author davidboschwitz
 * @author Sam Jackson
 */
public class Client {
    
    // TODO:  give client ids
    private static Integer clientCount = 0;
    protected Session session;
    protected final ClientType clientType;
    protected ClientGroup clientGrouping;
    protected String clientId;
    
    /**
     * 
     * @param type
     * @param session
     * @param group 
     */
    public Client(ClientType type, Session session, ClientGroup group) {
        Client.clientCount++;

        this.clientType = type;
        this.session = session;
        this.clientGrouping = group;
        this.clientId = Client.clientCount.toString();
    }
    
    public void sendText(String msg) throws java.io.IOException {
        session.getBasicRemote().sendText(msg);
    }
    
    public ClientGroup getGroup() {
        return this.clientGrouping;
    }
    
    public String getId() {
        return this.clientId;
    }
    
}
