/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gameconnect.server.io;

import gameconnect.server.Client;
import java.io.IOException;

/**
 *
 * @author personal
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
