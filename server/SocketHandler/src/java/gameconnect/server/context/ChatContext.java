package gameconnect.server.context;

import gameconnect.server.Client;
import gameconnect.server.ClientGroup;
import gameconnect.server.MessageType;
import gameconnect.server.SourceType;
import gameconnect.server.io.MessageContentTypes.ChatMessageContent;
import gameconnect.server.io.MessageTypes.ChatMessage;
import gameconnect.server.io.MessageTypes.Message;
import javax.websocket.Session;

/**
 *
 * @author davidboschwitz
 */
public class ChatContext extends Context {

    public ChatContext(ClientGroup group) {
        super(group);
        group.sendToAll("{ \"sourceType\":\"backend\", \"messageType\": \"game-mode\", \"content\": { \"gameMode\": 6 } }");

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
    public void onClose(Client c) {
        group.sendToAll(new ChatMessage(group.getGroupID(), SourceType.BACKEND, new ChatMessageContent(c.getName()+" has left the chat.")), ChatMessage.class);
        group.softDisconnect(c);
    }

    @Override
    public void endContext() {
        group.context = null;
        //do nothing for now
    }
    
    @Override
    public int getScoreContextID(){
        return 0;
    }

}
