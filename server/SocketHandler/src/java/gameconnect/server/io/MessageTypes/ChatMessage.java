package gameconnect.server.io.MessageTypes;

/**
 *
 * @author davidboschwitz
 */
public class ChatMessage extends Message {
    
    public ChatMessage(String groupId, String sourceType, String messageType) {
        super(groupId, sourceType, messageType);
    }
    
}
