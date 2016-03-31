package gameconnect.server.io.MessageTypes;

import gameconnect.server.io.MessageContentTypes.MessageContent;

/**
 *
 * @author davidboschwitz
 */
public class DisconnectMessage extends Message {
    
    MessageContent content;
    
    public DisconnectMessage(String groupId, String sourceType, String messageType) {
        super(groupId, sourceType, messageType);
    }

    @Override
    public MessageContent getContent() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }
    
    
    
}
