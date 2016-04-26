package gameconnect.server.io.SendStrategies;

import java.io.IOException;
import javax.websocket.Session;

/**
 *
 * @author samjackson
 */
public class ToSessionSender implements SendStrategy {

    private Session session;
    
    public ToSessionSender(Session s){
        this.session = s;
    }
    
    @Override
    public void sendMessage(String messageJson) throws IOException {
        session.getAsyncRemote().sendText(messageJson);
    }
    
}
