/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gameconnect.server.io.SendStrategies;

import java.io.IOException;
import javax.websocket.Session;

/**
 *
 * @author personal
 */
public class ToSessionSender implements SendStrategy {

    private Session session;
    
    public ToSessionSender(Session s){
        this.session = s;
    }
    
    @Override
    public void sendMessage(String messageJson) throws IOException {
        session.getBasicRemote().sendText(messageJson);
    }
    
}
