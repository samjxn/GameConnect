/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gameconnect.server.io;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.io.IOException;

/**
 *
 * @author personal
 */
public class OutgoingMessage extends Message {
 
    private SendStrategy sendStrategy;
    private static Gson gson = null;
    
    public OutgoingMessage(String groupId, String sourceType, String messageType, MessageContent content, SendStrategy sender) {
        super(groupId, sourceType, messageType, content);
        
        if (OutgoingMessage.gson == null){
            this.gson = new GsonBuilder().create();
        }
        
        this.sendStrategy = sender;
    }
        
    public SendStrategy getSendStrategy() {
        return this.sendStrategy;
    }
    
    public void send() throws IOException {
        this.sendStrategy.sendMessage(gson.toJson(this, Message.class));
    }
}
