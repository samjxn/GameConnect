package gameconnect.server.io.MessageTypes;

import gameconnect.server.SourceType;
import gameconnect.server.io.MessageContentTypes.MessageContent;

/**
 *
 * @author David Boschwitz
 * @author Sam Jackson
 */
public abstract class Message {
    
    protected String groupId;
    protected String sourceType;
    protected String messageType;
    //protected MessageContent content;
    
    public Message(String groupId, String sourceType, String messageType) {
        this.groupId = groupId;
        this.sourceType = sourceType;
        this.messageType = messageType;
//        this.content = null;
    }
    
//    /**
//     * Creates a new message
//     * @param groupId 
//     * @param sourceType
//     * @param messageType
//     * @param content 
//     */
//    public Message(String groupId, String sourceType, String messageType, MessageContent content) {
//        this.groupId = groupId;
//        this.sourceType = sourceType;
//        this.messageType = messageType;
//        this.content = content;
//    }

    /**
     * Only for use by gson. Use DefaultMessage instead.
     */
    @Deprecated
    public Message(){
        
    }
       
    public String getGroupId() {
        return this.groupId;
    }
    
    public String getSourceType() {
        return this.sourceType;
    }
    
    public String getMessageType() {
        return this.messageType;
    }
    
    public abstract MessageContent getContent();
}
