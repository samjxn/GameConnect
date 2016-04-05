package gameconnect.server.io.MessageTypes;

import gameconnect.server.SourceType;
import gameconnect.server.io.MessageContentTypes.ClientIdMessageContent;

/**
 *
 * @author davidboschwitz
 */
public class ClientIdMessage extends Message{
    
    ClientIdMessageContent content;

    public ClientIdMessage(String id){
        super(null, SourceType.BACKEND, "set-clientid");
        content = new ClientIdMessageContent(id);
    }
    
    @Override
    public ClientIdMessageContent getContent() {
        return content;
    }
    
}
