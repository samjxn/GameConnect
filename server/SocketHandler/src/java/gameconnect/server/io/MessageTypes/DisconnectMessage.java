/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gameconnect.server.io.MessageTypes;

/**
 *
 * @author davidboschwitz
 */
public class DisconnectMessage extends Message {
    
    public DisconnectMessage(String groupId, String sourceType, String messageType) {
        super(groupId, sourceType, messageType);
    }
    
}
