/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gameconnect.server.io;

/**
 *
 * @author personal
 */
public class ErrorMessageContent extends MessageContent {
    
    private String messageText;
    
    public ErrorMessageContent(String messageText){
        this.messageText = messageText;
    }
    
    public String getMessageText() {
        return this.messageText;
    }
}
