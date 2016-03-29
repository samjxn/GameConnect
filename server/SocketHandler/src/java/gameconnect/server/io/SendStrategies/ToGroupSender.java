package gameconnect.server.io.SendStrategies;

import gameconnect.server.Client;
import java.io.IOException;

/**
 *
 * @author samjackson
 */
public class ToGroupSender implements SendStrategy {
    
    private Client client;
    
    public ToGroupSender(Client c){
        this.client = c;
    }

    @Override
    public void sendMessage(String messageJson) throws IOException {
        this.client.getGroup().sendToAll(messageJson);
    }
}
