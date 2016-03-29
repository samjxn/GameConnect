package gameconnect.server.io.MessageTypes;

/**
 *
 * @author davidboschwitz
 */
public class DisconnectMessage extends Message {
    
    public DisconnectMessage(String groupId, String sourceType, String messageType) {
        super(groupId, sourceType, messageType);
    }
    
}
