package gameconnect.server.io.MessageContentTypes;

/**
 *
 * @author davidboschwitz
 */
public class ChatMessageContent extends MessageContent {

    //public String from;
    public String message;

    public ChatMessageContent(String message){
        //this.from = from;
        this.message = message;
    }
    
}
