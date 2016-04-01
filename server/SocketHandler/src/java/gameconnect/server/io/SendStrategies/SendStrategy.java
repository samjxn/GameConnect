package gameconnect.server.io.SendStrategies;

import java.io.IOException;

/**
 *
 * @author personal
 */
public interface SendStrategy {
    
    public void sendMessage(String messageJson) throws IOException;
    
}
