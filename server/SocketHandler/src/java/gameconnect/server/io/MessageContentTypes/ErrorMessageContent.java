package gameconnect.server.io.MessageContentTypes;

/**
 *
 * @author samjackson
 */
public class ErrorMessageContent extends MessageContent {
    
    private String messageText;
    
    public ErrorMessageContent(String messageText){
        this.messageText = messageText;
    }
    
    public String getMessageText() {
        return this.messageText;
    }
}
