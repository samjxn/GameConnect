package gameconnect.server.io.MessageTypes;

import gameconnect.server.io.MessageContentTypes.MessageContent;

/**
 *
 * @author davidboschwitz
 */
public class DisconnectMessage extends Message {
    
    MessageContent content = null;
    
    public DisconnectMessage(String groupId) {
        super(groupId, "backend", "disconnect");
    }

    @Override
    public MessageContent getContent() {
        return null;
    }
    
    
    
}
