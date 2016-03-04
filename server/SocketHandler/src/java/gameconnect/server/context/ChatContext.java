package gameconnect.server.context;

import gameconnect.server.ClientGroup;
import javax.websocket.Session;

/**
 *
 * @author davidboschwitz
 */
public class ChatContext extends Context {

    public ChatContext(ClientGroup group) {
        super(group);
    }

    @Override
    public void handleMessage(String messageJson, Session session) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public void endContext() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }
    
}
