package gameconnect.server.io.MessageTypes;

import gameconnect.server.io.MessageContentTypes.MessageContent;
import gameconnect.server.io.SendStrategies.SendStrategy;
import com.google.gson.Gson;
import java.io.IOException;

/**
 *
 * @author personal
 */
public class OutgoingMessage extends Message {
 
    private MessageContent content;
    
    public OutgoingMessage(String groupId, String sourceType, String messageType, MessageContent content) {
        super(groupId, sourceType, messageType, content);
        this.content = content;
        
    }
    
    public void send(Gson gson, SendStrategy sendStrategy) throws IOException {
        String json = gson.toJson(this, OutgoingMessage.class);        
        sendStrategy.sendMessage(json);
    }
}
