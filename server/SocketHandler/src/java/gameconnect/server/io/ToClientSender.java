/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gameconnect.server.io;

import gameconnect.server.Client;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.websocket.Session;

/**
 *
 * @author personal
 */
public class ToClientSender implements SendStrategy {
    
    private Client client;
    
    /**
     * Creates a message sender that sends a message to the provided session
     * @param s the session to send to
     */
    public ToClientSender(Client c){
        this.client = c;
    }

    @Override
    public void sendMessage(String messageJson) throws IOException {
        this.client.sendText(messageJson);
    }
    
    
}
