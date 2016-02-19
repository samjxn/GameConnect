package gameconnect.server;

import javax.websocket.Session;
/**
 *
 * @author davidboschwitz
 */
public class Client {
    
    private Session session;
    private final ClientType type;
    
    public Client() {
        type = ClientType.PC;
    }
    
    public void sendText(String msg) throws java.io.IOException {
        session.getBasicRemote().sendText(msg);
    }
    
}
