package gameconnect.server.io.MessageTypes;

import gameconnect.server.io.MessageContentTypes.GroupingCodeMessageContent;

/**
 *
 * @author Sam Jackson
 */
public class GroupingCodeMessage extends Message {
    
    GroupingCodeMessageContent content;
    
    public GroupingCodeMessage(String groupId, String sourceType, String messageType, GroupingCodeMessageContent content) {
        super(groupId, sourceType, messageType);
        this.content = content;
    }
    
    public GroupingCodeMessageContent getContent(){
        return (GroupingCodeMessageContent) this.content;
    }
    
}
