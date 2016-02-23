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
public class PairingCodeRequestResponseContent extends MessageContent {
    
    private String pairingCode;
    
    public PairingCodeRequestResponseContent(String pairingCode){
        this.pairingCode = pairingCode;
    }
    
    public String getPairingCode(){
        return this.pairingCode;
    }
}
