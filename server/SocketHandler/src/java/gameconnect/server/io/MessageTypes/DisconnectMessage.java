package gameconnect.server.io.MessageTypes;

import gameconnect.server.MessageType;
import gameconnect.server.SourceType;
import gameconnect.server.io.MessageContentTypes.MessageContent;

/**
 *
 * @author davidboschwitz
 */
public class DisconnectMessage extends Message {
    
    MessageContent content = null;
    
    public DisconnectMessage(String groupId) {
        super(groupId, SourceType.BACKEND, MessageType.DISCONNECT);
    }

    @Override
    public MessageContent getContent() {
        return null;
    }
    
    
    
}
