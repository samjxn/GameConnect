/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gameconnect.server.io;
import java.io.IOException;

/**
 *
 * @author personal
 */
public interface SendStrategy {
    
    public void sendMessage(String messageJson) throws IOException;
    
}
