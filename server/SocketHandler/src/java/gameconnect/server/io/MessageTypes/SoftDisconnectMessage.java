package gameconnect.server.io.MessageTypes;

import gameconnect.server.MessageType;
import gameconnect.server.SourceType;
import gameconnect.server.io.MessageContentTypes.MessageContent;

/**
 *
 * @author davidboschwitz
 */
public class SoftDisconnectMessage extends Message{
    
    SoftDisconnectMessageContent content = new SoftDisconnectMessageContent();
    
    public SoftDisconnectMessage(String clientId, String groupId) {
        super(groupId, SourceType.BACKEND, MessageType.SOFT_DISCONNECT);
        content.clientId = clientId;
    }
    
    public class SoftDisconnectMessageContent extends MessageContent {
        public String clientId;
    }

    @Override
    public SoftDisconnectMessageContent getContent() {
        return content;
    }
}
