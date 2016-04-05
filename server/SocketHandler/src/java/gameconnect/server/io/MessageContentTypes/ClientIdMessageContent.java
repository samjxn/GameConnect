package gameconnect.server.io.MessageContentTypes;

/**
 *
 * @author davidboschwitz
 */
public class ClientIdMessageContent extends MessageContent {
    
    public String clientId;
    
    public ClientIdMessageContent(String clientID){
        this.clientId = clientID;
    }
    
}
