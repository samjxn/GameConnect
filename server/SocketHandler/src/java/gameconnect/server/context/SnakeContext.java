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
public class SnakeContext extends Context {

    public SnakeContext(ClientGroup group) {
        super(group);
        group.sendToAll("{ \"sourceType\":\"backend\", \"messageType\": \"game-mode\", \"content\": { \"gameMode\": 3 } }");
        //no limits on number of group members for this context
    }

    @Override
    public boolean handleMessage(Message incomingMessage, String msgText, Session session) {
        boolean rtn = false;
        switch (incomingMessage.getMessageType()) {
            case MessageType.CONTROLLER_SNAPSHOT:
                //just send it off as is
                group.sendToAll(msgText, session);
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
