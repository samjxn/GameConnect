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
    public boolean handleMessage(Message incomingMessage, String msgText, Session session) {
        boolean rtn = false;
        switch (incomingMessage.getMessageType()) {
            case MessageType.CHAT_MESSAGE:
                //forward message to all.
                group.sendToAll(msgText);
                rtn = true;
                break;
        
        }
        return rtn;
    }
    
    @Override
    public void onClose(Session s){
        
    }

    @Override
    public void endContext() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

}
