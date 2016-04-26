package gameconnect.server.io.MessageTypes;

import gameconnect.server.MessageType;
import gameconnect.server.io.MessageContentTypes.ChatMessageContent;

/**
 *
 * @author davidboschwitz
 */
public class ChatMessage extends Message {
    
    ChatMessageContent content;
    
    public ChatMessage(String groupId, String sourceType, ChatMessageContent content) {
        super(groupId, sourceType, MessageType.CHAT_MESSAGE);
        this.content =  content;
    }

    @Override
    public ChatMessageContent getContent() {
        return content;
    }
    
}
