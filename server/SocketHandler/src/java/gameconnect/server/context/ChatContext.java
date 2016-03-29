package gameconnect.server.context;

import gameconnect.server.Client;
import gameconnect.server.ClientGroup;
import gameconnect.server.MessageType;
import gameconnect.server.io.MessageTypes.Message;
import javax.websocket.Session;

/**
 *
 * @author davidboschwitz
 */
public class ChatContext extends Context {

    public ChatContext(ClientGroup group) {
        super(group);

        //no limits on number of group members for this context
    }

    @Override
    public void handleMessage(Message incomingMessage, Session session) {
        switch (incomingMessage.getMessageType()) {
            case MessageType.CHAT_MESSAGE:
                
                break;
        
        }
        switch (1) {
            default:
                for (Client c : group.clients) {
                    try {
                        c.sendText(session.getId() + ": ");
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
        }
    }

    @Override
    public void endContext() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

}
