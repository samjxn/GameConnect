package gameconnect.server.io.MessageTypes;

import gameconnect.server.io.MessageContentTypes.SetContextMessageContent;

/**
 *
 * @author davidboschwitz
 */
public class SetContextMessage extends Message {
    
    SetContextMessageContent content;
    
    public SetContextMessage(String groupId, String sourceType, String messageType, SetContextMessageContent content) {
        super(groupId, sourceType, messageType);
        this.content = content;
    }
    
    @Override
    public SetContextMessageContent getContent(){
        return this.content;
    }
    
}
