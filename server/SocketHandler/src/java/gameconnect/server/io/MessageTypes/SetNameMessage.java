package gameconnect.server.io.MessageTypes;

import gameconnect.server.MessageType;
import gameconnect.server.io.MessageContentTypes.SetNameMessageContent;

/**
 *
 * @author davidboschwitz
 */
public class SetNameMessage extends Message {

    public SetNameMessageContent content;
    
    public SetNameMessage(String groupId, String sourceType, SetNameMessageContent content2) {
        super(groupId, sourceType, MessageType.SET_NAME);
        this.content = content2;
    }
    
    @Override
    public SetNameMessageContent getContent() {
        return content;
    }
    
}
